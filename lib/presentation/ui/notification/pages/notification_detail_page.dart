import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_detail_bloc.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/notification_api_service.dart';
import 'package:flutter_camera/data/network/repositories/notification_repository_impl.dart';
import 'package:flutter_camera/domain/usecase/notification/get_notification_detail_use_case.dart';
import 'package:flutter_camera/data/network/model/notification_detail_response.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationDetailPage extends StatelessWidget {
  final String notificationId;
  final String dataTime;

  const NotificationDetailPage({super.key, required this.notificationId, required this.dataTime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết cảnh báo nhiệt độ',
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return AppWidgets.buildLoadingIndicator(message: 'Loading detail...');
          }
          final prefs = snapshot.data!;
          final authLocalPreference = AuthLocalPreference(prefs);
          final apiService = getIt<NotificationApiService>();
          final repository = NotificationsRepositoryImpl(apiService);
          final useCase = GetNotificationDetailUseCase(repository);

          return BlocProvider(
            create: (context) => NotificationDetailBloc(
              getNotificationDetailUseCase: useCase,
              authLocalPreference: authLocalPreference,
            )..add(FetchNotificationDetail(id: notificationId, dataTime: dataTime)),
            child: const NotificationDetailView(),
          );
        },
      ),
    );
  }
}

class NotificationDetailView extends StatelessWidget {
  const NotificationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationDetailBloc, NotificationDetailState>(
      builder: (context, state) {
        if (state is NotificationDetailLoading) {
          return AppWidgets.buildLoadingIndicator(message: 'Loading notification detail...');
        } else if (state is NotificationDetailError) {
          return AppWidgets.buildEmptyState(
            icon: Icons.error_outline,
            title: 'Error loading detail',
            subtitle: state.message,
            action: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          );
        } else if (state is NotificationDetailLoaded) {
          final detail = state.detail;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                // _buildHeaderCard(detail),
                // const SizedBox(height: AppSpacing.md),

                // Image Section
                if (detail.imagePath != null) ...[
                  _buildImageSection(context, detail),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Details Section
                _buildDetailsSection(detail),
                const SizedBox(height: AppSpacing.md),

                // Location Section
                if (detail.areaName != null || detail.machineName != null) ...[
                  _buildLocationSection(detail),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Temperature Section
                _buildTemperatureSection(detail),
                const SizedBox(height: AppSpacing.md),

                // Time Section
                _buildTimeSection(detail),
              ],
            ),
          );
        }

        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildImageSection(BuildContext context, NotificationDetailData detail) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.image, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Hình ảnh nhiệt',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageViewer(
                    imageUrl: detail.imagePath!,
                    title: detail.warningEventName ?? 'Hình ảnh nhiệt',
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppBorderRadius.large),
                bottomRight: Radius.circular(AppBorderRadius.large),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Image.network(
                      detail.imagePath!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.error.withOpacity(0.1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: AppColors.error, size: 48),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Không thể tải hình ảnh',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vui lòng kiểm tra kết nối mạng',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Overlay hint
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.zoom_in, size: 16, color: Colors.white.withOpacity(0.9)),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Nhấn để xem toàn màn hình',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(NotificationDetailData detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Thông tin chi tiết',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            'Loại cảnh báo',
            detail.warningEventName ?? 'Không xác định',
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            'Kiểu cảnh báo',
            detail.compareTypeObject?.name ?? 'Không xác định',
            icon: Icons.compare_arrows,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            'Trạng thái',
            detail.statusObject?.name ?? 'Chưa xác định',
            icon: Icons.info,
            valueColor: _getStatusColor(detail.statusObject?.name),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            'Đánh giá',
            detail.compareResultObject?.name ?? 'Không xác định',
            icon: Icons.priority_high,
            valueColor: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(NotificationDetailData detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Vị trí',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (detail.areaName != null)
            _buildDetailRow('Khu vực', detail.areaName!, icon: Icons.place),
          if (detail.areaName != null && detail.machineName != null)
            const SizedBox(height: AppSpacing.sm),
          if (detail.machineName != null)
            _buildDetailRow('Thiết bị', detail.machineName!, icon: Icons.precision_manufacturing),
          if (detail.machineComponentName != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow('Bộ phận', detail.machineComponentName!, icon: Icons.settings),
          ],
          if (detail.monitorPointCode != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow('Điểm nhiệt', detail.monitorPointCode!, icon: Icons.thermostat),
          ],
        ],
      ),
    );
  }

  Widget _buildTemperatureSection(NotificationDetailData detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Dữ liệu nhiệt độ',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // if (detail.compareMinTemperature != null) ...[
          //   _buildDetailRow(
          //     'Đối tượng so sánh',
          //     '${detail.compareComponent}',
          //     icon: Icons.precision_manufacturing,
          //   ),
          // ],
          // const SizedBox(height: AppSpacing.sm),
          if (detail.componentValue != null)
            _buildDetailRow(
              'Nhiệt độ hiện tại - ${detail.monitorPointCode}',
              '${detail.componentValue!.toStringAsFixed(1)}°C',
              icon: Icons.thermostat,
              valueColor: AppColors.warning,
            ),
          if (detail.compareValue != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              'Nhiệt độ so sánh - ${detail.compareMonitorPoint}',
              '${detail.compareValue!.toStringAsFixed(1)}°C',
              icon: Icons.compare,
            ),
          ],
          if (detail.deltaValue != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              'Chênh lệch',
              '${detail.deltaValue!.toStringAsFixed(1)}°C',
              icon: Icons.trending_up,
              valueColor: detail.deltaValue! > 10 ? AppColors.error : AppColors.textPrimary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSection(NotificationDetailData detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Thời gian',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            'Thời gian phát hiện',
            detail.formattedDate ?? 'Không xác định',
            icon: Icons.schedule,
          ),
          if (detail.dataTime != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow('Thời gian dữ liệu', detail.dataTime!, icon: Icons.access_time),
          ],
          if (detail.resolveTime != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              'Thời gian xử lý',
              detail.resolveTime!,
              icon: Icons.check_circle,
              valueColor: AppColors.success,
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              'Thời gian xử lý',
              'Chưa xử lý',
              icon: Icons.pending,
              valueColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'chưa xử lý':
        return AppColors.warning;
      case 'critical':
      case 'error':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}

// Full Screen Image Viewer with Zoom
class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String title;

  const FullScreenImageViewer({super.key, required this.imageUrl, required this.title});

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      // Reset zoom
      _transformationController.value = Matrix4.identity();
    } else {
      // Zoom in to 3x at tap position
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fit_screen, color: Colors.white),
            onPressed: () {
              setState(() {
                _transformationController.value = Matrix4.identity();
              });
            },
            tooltip: 'Reset zoom',
          ),
        ],
      ),
      body: GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.1,
          maxScale: 50.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Center(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Đang tải hình ảnh...',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, color: Colors.white54, size: 64),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Không thể tải hình ảnh',
                        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
          top: AppSpacing.sm,
        ),
        child: Text(
          'Pinch để zoom (tối đa 50x) • Double tap để zoom 3x',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
