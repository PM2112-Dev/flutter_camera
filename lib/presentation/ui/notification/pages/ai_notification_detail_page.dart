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
              _buildImageSection(),
              const SizedBox(height: AppSpacing.md),
            ],

            // Details Section
            _buildDetailsSection(),
            const SizedBox(height: AppSpacing.md),

            // Location Section
            if (notification.areaName != null ||
                notification.cameraName != null) ...[
              _buildLocationSection(),
              const SizedBox(height: AppSpacing.md),
            ],

            // Time Section
            _buildTimeSection(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.1),
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
                  color: AppColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: AppColors.info,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cảnh báo AI',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.warningEventName ?? 'AI Detection Alert',
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
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Text(
              'ID: ${notification.id ?? 'N/A'}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.info,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppBorderRadius.large),
              bottomRight: Radius.circular(AppBorderRadius.large),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                notification.imagePath!,
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
            notification.warningEventName ?? 'Không xác định',
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            'Trạng thái',
            'Đã phát hiện',
            icon: Icons.check_circle,
            valueColor: AppColors.success,
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

  Widget _buildLocationSection() {
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
          if (notification.areaName != null)
            _buildDetailRow(
              'Khu vực',
              notification.areaName!,
              icon: Icons.place,
            ),
          if (notification.areaName != null && notification.cameraName != null)
            const SizedBox(height: AppSpacing.sm),
          if (notification.cameraName != null)
            _buildDetailRow(
              'Camera',
              notification.cameraName!,
              icon: Icons.videocam,
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
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
            notification.formattedDate ?? 'Không xác định',
            icon: Icons.schedule,
          ),
          if (notification.alertTime != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              'Thời gian cảnh báo',
              notification.alertTime!,
              icon: Icons.notifications_active,
            ),
          ],
          if (notification.dateData != null &&
              notification.timeData != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              'Ngày dữ liệu',
              notification.dateData!,
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              'Giờ dữ liệu',
              notification.timeData!,
              icon: Icons.watch_later,
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
}
