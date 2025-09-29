import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_list_bloc.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/notification_api_service.dart';
import 'package:flutter_camera/data/network/repositories/notification_repository_impl.dart';
import 'package:flutter_camera/domain/usecase/notification/get_notifications_use_case.dart';
import 'package:flutter_camera/presentation/ui/notification/pages/notification_detail_page.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Màu sắc notification theo trạng thái
class NotificationColors {
  // ĐÃ XỬ LÝ - Màu success (xanh lá cây)
  static const Color processedSuccess = Color(0xFF10B981); // Success green - Đã xử lý
  static const Color processedBg = Color(0xFFF0FDF4); // Very light green background

  // CHƯA XỬ LÝ - Màu warning (vàng cam)
  static const Color pendingWarning = Color(0xFFF59E0B); // Warning amber - Chưa xử lý
  static const Color pendingBg = Color(0xFFFEFBF2); // Very light amber background

  // Màu sắc phụ trợ
  static const Color arrowBg = Color(0xFFF8FAFC); // Light gray
  static const Color arrowBorder = Color(0xFFE2E8F0); // Gray border
  static const Color arrowIcon = Color(0xFF64748B); // Gray icon
}

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return AppWidgets.buildLoadingIndicator(message: 'Loading temperature warnings...');
        }

        final prefs = snapshot.data!;
        final authLocalPreference = AuthLocalPreference(prefs);
        final apiService = getIt<NotificationApiService>();
        final repository = NotificationsRepositoryImpl(apiService);
        final useCase = GetNotificationsUseCase(repository);

        return BlocProvider(
          create: (context) => NotificationListBloc(
            getNotificationsUseCase: useCase,
            authLocalPreference: authLocalPreference,
          )..add(FetchNotificationList()),
          child: const NotificationListView(),
        );
      },
    );
  }
}

class NotificationListView extends StatelessWidget {
  const NotificationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocBuilder<NotificationListBloc, NotificationListState>(
        builder: (context, state) {
          if (state is NotificationListLoading) {
            return AppWidgets.buildLoadingIndicator(message: 'Loading temperature warnings...');
          } else if (state is NotificationListError) {
            return AppWidgets.buildEmptyState(
              icon: Icons.error_outline,
              title: 'Error loading temperature warnings',
              subtitle: state.message,
              action: ElevatedButton(
                onPressed: () {
                  context.read<NotificationListBloc>().add(FetchNotificationList());
                },
                child: const Text('Retry'),
              ),
            );
          } else if (state is NotificationListLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return AppWidgets.buildEmptyState(
                icon: Icons.thermostat_outlined,
                title: 'No temperature warnings',
                subtitle: 'There are no temperature threshold warnings at this time',
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<NotificationListBloc>().add(FetchNotificationList());
              },
              child: CustomScrollView(
                slivers: [
                  // Header with total count
                  // SliverToBoxAdapter(
                  //   child: Container(
                  //     margin: const EdgeInsets.all(AppSpacing.md),
                  //     padding: const EdgeInsets.all(AppSpacing.md),
                  //     decoration: BoxDecoration(
                  //       color: AppColors.surface,
                  //       borderRadius: BorderRadius.circular(
                  //         AppBorderRadius.large,
                  //       ),
                  //       boxShadow: AppShadows.cardShadow,
                  //       border: Border.all(color: AppColors.border, width: 0.5),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.all(12),
                  //           decoration: BoxDecoration(
                  //             color: AppColors.warning.withOpacity(0.2),
                  //             borderRadius: BorderRadius.circular(
                  //               AppBorderRadius.medium,
                  //             ),
                  //           ),
                  //           child: const Icon(
                  //             Icons.thermostat,
                  //             color: AppColors.warning,
                  //             size: 28,
                  //           ),
                  //         ),
                  //         // const SizedBox(width: AppSpacing.md),
                  //         // Expanded(
                  //         //   child: Column(
                  //         //     crossAxisAlignment: CrossAxisAlignment.start,
                  //         //     children: [
                  //         //       Text(
                  //         //         'Cảnh báo nhiệt độ',
                  //         //         style: AppTextStyles.bodyMedium.copyWith(
                  //         //           color: AppColors.warning,
                  //         //           fontWeight: FontWeight.w600,
                  //         //         ),
                  //         //       ),
                  //         //       const SizedBox(height: 4),
                  //         //       Text(
                  //         //         '$totalCount cảnh báo đang hoạt động',
                  //         //         style: AppTextStyles.headline3.copyWith(
                  //         //           color: AppColors.textPrimary,
                  //         //           fontWeight: FontWeight.bold,
                  //         //         ),
                  //         //       ),
                  //         //     ],
                  //         //   ),
                  //         // ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Notifications list
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final notification = notifications[index];
                        final isProcessed = notification.statusObject?.name == "Đã xử lý";

                        // Phân loại màu sắc theo trạng thái:
                        // - "Đã xử lý": Success green (xanh lá cây)
                        // - "Chưa xử lý": Warning amber (vàng cam cảnh báo)
                        final statusColor = isProcessed
                            ? NotificationColors
                                  .processedSuccess // Đã xử lý - success
                            : NotificationColors.pendingWarning; // Chưa xử lý - warning
                        final backgroundColor = isProcessed
                            ? NotificationColors
                                  .processedBg // Nền xanh nhẹ
                            : NotificationColors.pendingBg; // Nền warning nhẹ

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm, top: 16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                            boxShadow: AppShadows.cardShadow,
                            border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (notification.id != null && notification.dataTime != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NotificationDetailPage(
                                          notificationId: notification.id!,
                                          dataTime: notification.dataTime!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      // Temperature Icon with status
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            AppBorderRadius.small,
                                          ),
                                          border: Border.all(
                                            color: statusColor.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            AppBorderRadius.small,
                                          ),
                                          child: Stack(
                                            children: [
                                              Container(
                                                color: statusColor.withOpacity(0.08),
                                                child:
                                                    notification.imagePath != null &&
                                                        notification.imagePath!.isNotEmpty
                                                    ? Image.network(
                                                        notification.imagePath!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Container(
                                                          color: Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.image_not_supported,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons.image_not_supported,
                                                        ),
                                                      ),
                                              ),
                                              // Status indicator
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: statusColor,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  notification.warningEventName ??
                                                      'Temperature Alert',
                                                  style: AppTextStyles.bodyLarge.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(width: AppSpacing.xs),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: statusColor.withOpacity(0.25),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isProcessed
                                                            ? Icons.check_circle
                                                            : Icons.warning,
                                                        size: 14,
                                                        color: statusColor,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        notification.statusObject?.name ?? '',
                                                        style: AppTextStyles.bodySmall.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                          color: statusColor,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                Text(
                                                  notification.compareTypeObject?.name.toString() ?? '',
                                                  style: AppTextStyles.bodyMedium.copyWith(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.precision_manufacturing,
                                                      size: 14,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      notification.machineComponentName ?? '',
                                                      style: AppTextStyles.bodyMedium.copyWith(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.thermostat,
                                                      size: 14,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${notification.componentValue!.toStringAsFixed(1)}°C',
                                                      style: AppTextStyles.bodyMedium.copyWith(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.trending_up,
                                                      size: 14,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${notification.deltaValue!.toStringAsFixed(1)}°C',
                                                      style: AppTextStyles.bodyMedium.copyWith(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (notification.areaName != null)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 14,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      notification.areaName!,
                                                      style: AppTextStyles.bodyMedium.copyWith(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            const SizedBox(height: AppSpacing.xs),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: AppColors.textHint,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  notification.formattedDate ?? '',
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    color: AppColors.textHint,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: notifications.length),
                    ),
                  ),
                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
