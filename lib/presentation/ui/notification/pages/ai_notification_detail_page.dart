import 'package:flutter/material.dart';
import 'package:flutter_camera/data/network/model/vision_notification_list_response.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';

class AINotificationDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const AINotificationDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiết cảnh báo AI',
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            // _buildHeaderCard(),
            // const SizedBox(height: AppSpacing.md),

            // Image Section
            if (notification.imagePath != null) ...[
              _buildImageSection(context),
              const SizedBox(height: AppSpacing.md),
            ],

            // Details Section
            _buildDetailsSection(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
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
                  'Hình ảnh phát hiện',
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
                    imageUrl: notification.imagePath!,
                    title: notification.warningEventName ?? 'Hình ảnh phát hiện',
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
                      notification.imagePath!,
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

  Widget _buildDetailsSection() {
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
              const SizedBox(width: AppSpacing.md),
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
            notification.warningEventName ?? 'Không xác định',
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (notification.areaName != null)
            _buildDetailRow('Khu vực', notification.areaName!, icon: Icons.place),
          const SizedBox(height: AppSpacing.sm),
          // if (notification.areaName != null && notification.cameraName != null)
          //   const SizedBox(height: AppSpacing.sm),
          if (notification.cameraName != null)
            _buildDetailRow('Camera', notification.cameraName!, icon: Icons.videocam),
          // const SizedBox(height: AppSpacing.sm),
          if (notification.dateData != null && notification.timeData != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow('Ngày', notification.dateData!, icon: Icons.calendar_today),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow('Giờ', notification.timeData!, icon: Icons.watch_later),
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
