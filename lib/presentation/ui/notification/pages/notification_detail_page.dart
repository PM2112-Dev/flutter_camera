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

  const NotificationDetailPage({
    super.key,
    required this.notificationId,
    required this.dataTime,
  });

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
            return AppWidgets.buildLoadingIndicator(
              message: 'Loading detail...',
            );
          }
          final prefs = snapshot.data!;
          final authLocalPreference = AuthLocalPreference(prefs);
          final apiService = getIt<NotificationApiService>();
          final repository = NotificationsRepositoryImpl(apiService);
          final useCase = GetNotificationDetailUseCase(repository);

          return BlocProvider(
            create: (context) =>
                NotificationDetailBloc(
                  getNotificationDetailUseCase: useCase,
                  authLocalPreference: authLocalPreference,
                )..add(
                  FetchNotificationDetail(
                    id: notificationId,
                    dataTime: dataTime,
                  ),
                ),
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
          return AppWidgets.buildLoadingIndicator(
            message: 'Loading notification detail...',
          );
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
                  _buildImageSection(detail),
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

  Widget _buildHeaderCard(NotificationDetailData detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: const Icon(
                  Icons.thermostat,
                  color: AppColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cảnh báo nhiệt độ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.warningEventName ?? 'Temperature Alert',
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Text(
              'ID: ${detail.id ?? 'N/A'}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(NotificationDetailData detail) {
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppBorderRadius.large),
              bottomRight: Radius.circular(AppBorderRadius.large),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                detail.imagePath!,
                fit: BoxFit.cover,
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
                        Icon(
                          Icons.image_not_supported,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Không thể tải hình ảnh',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
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
              Icon(
                Icons.info_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
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
            'Trạng thái',
            detail.statusObject?.name ?? 'Chưa xác định',
            icon: Icons.info,
            valueColor: _getStatusColor(detail.statusObject?.name),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            'Mức độ',
            'Cao',
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
            _buildDetailRow(
              'Máy móc',
              detail.machineName!,
              icon: Icons.precision_manufacturing,
            ),
          if (detail.machineComponentName != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              'Thành phần',
              detail.machineComponentName!,
              icon: Icons.settings,
            ),
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
          if (detail.componentValue != null)
            _buildDetailRow(
              'Nhiệt độ hiện tại',
              '${detail.componentValue!.toStringAsFixed(1)}°C',
              icon: Icons.thermostat,
              valueColor: AppColors.warning,
            ),
          if (detail.compareValue != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              'Nhiệt độ so sánh',
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
              valueColor: detail.deltaValue! > 10
                  ? AppColors.error
                  : AppColors.textPrimary,
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
            _buildDetailRow(
              'Thời gian dữ liệu',
              detail.dataTime!,
              icon: Icons.access_time,
            ),
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

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
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
