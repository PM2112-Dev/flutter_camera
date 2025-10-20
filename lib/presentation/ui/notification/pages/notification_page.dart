import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/data/network/model/vision_notification_list_request.dart';
import 'package:flutter_camera/data/network/model/vision_notification_list_response.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/presentation/ui/notification/pages/notification_list_page.dart';
import 'package:flutter_camera/presentation/ui/notification/pages/ai_notification_detail_page.dart';
import 'package:flutter_camera/presentation/ui/notification/models/notification_filter.dart';
import '../bloc/notification_bloc.dart';

class NotificationPage extends StatefulWidget {
  final NotificationFilter filter;

  const NotificationPage({super.key, required this.filter});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _applyAIFilter(List<dynamic> notifications) {
    var filtered = notifications;

    // Filter by time range (using alertTime for AI notifications)
    if (widget.filter.startDate != null && widget.filter.endDate != null) {
      filtered = filtered.where((item) {
        if (item is! NotificationItem || item.alertTime == null) return false;
        try {
          final itemDate = DateTime.parse(item.alertTime!);
          return itemDate.isAfter(widget.filter.startDate!.subtract(const Duration(days: 1))) &&
              itemDate.isBefore(widget.filter.endDate!.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Filter by areaName (exact match - AI notifications only have areaName, no compareTypeObject or statusObject)
    if (widget.filter.areaName != null && widget.filter.areaName!.isNotEmpty) {
      filtered = filtered.where((item) {
        if (item is! NotificationItem) return false;
        return item.areaName == widget.filter.areaName;
      }).toList();
    }

    // Note: AI notifications don't have compareTypeObject or statusObject,
    // so we only filter by time and area

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom Tab Bar
          // Container(
          //   margin: const EdgeInsets.all(AppSpacing.md),
          //   decoration: BoxDecoration(
          //     color: AppColors.surface,
          //     borderRadius: BorderRadius.circular(AppBorderRadius.large),
          //     boxShadow: AppShadows.cardShadow,
          //     border: Border.all(color: AppColors.border, width: 0.5),
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: GestureDetector(
          //           onTap: () => _tabController.animateTo(0),
          //           child: AnimatedBuilder(
          //             animation: _tabController,
          //             builder: (context, child) {
          //               final isSelected = _tabController.index == 0;
          //               return Container(
          //                 padding: const EdgeInsets.symmetric(
          //                   vertical: AppSpacing.md,
          //                   horizontal: AppSpacing.sm,
          //                 ),
          //                 decoration: BoxDecoration(
          //                   color: isSelected
          //                       ? AppColors.warning
          //                       : Colors.transparent,
          //                   borderRadius: BorderRadius.circular(
          //                     AppBorderRadius.large,
          //                   ),
          //                   boxShadow: isSelected
          //                       ? [
          //                           BoxShadow(
          //                             color: AppColors.warning.withOpacity(0.3),
          //                             blurRadius: 8,
          //                             offset: const Offset(0, 2),
          //                           ),
          //                         ]
          //                       : null,
          //                 ),
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     // Container(
          //                     //   padding: const EdgeInsets.all(6),
          //                     //   decoration: BoxDecoration(
          //                     //     color: isSelected
          //                     //         ? AppColors.textOnPrimary.withOpacity(0.2)
          //                     //         : AppColors.warning.withOpacity(0.1),
          //                     //     borderRadius: BorderRadius.circular(6),
          //                     //   ),
          //                     //   child: Icon(
          //                     //     Icons.thermostat,
          //                     //     size: 18,
          //                     //     color: isSelected
          //                     //         ? AppColors.textOnPrimary
          //                     //         : AppColors.warning,
          //                     //   ),
          //                     // ),
          //                     const SizedBox(width: AppSpacing.sm),
          //                     Flexible(
          //                       child: Text(
          //                         'Nhiệt độ',
          //                         style: AppTextStyles.bodyMedium.copyWith(
          //                           fontWeight: FontWeight.w600,
          //                           color: isSelected
          //                               ? AppColors.textOnPrimary
          //                               : AppColors.textPrimary,
          //                         ),
          //                         overflow: TextOverflow.ellipsis,
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               );
          //             },
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 2),
          //       Expanded(
          //         child: GestureDetector(
          //           onTap: () => _tabController.animateTo(1),
          //           child: AnimatedBuilder(
          //             animation: _tabController,
          //             builder: (context, child) {
          //               final isSelected = _tabController.index == 1;
          //               return Container(
          //                 padding: const EdgeInsets.symmetric(
          //                   vertical: AppSpacing.md,
          //                   horizontal: AppSpacing.sm,
          //                 ),
          //                 decoration: BoxDecoration(
          //                   color: isSelected
          //                       ? AppColors.info
          //                       : Colors.transparent,
          //                   borderRadius: BorderRadius.circular(
          //                     AppBorderRadius.large,
          //                   ),
          //                   boxShadow: isSelected
          //                       ? [
          //                           BoxShadow(
          //                             color: AppColors.info.withOpacity(0.3),
          //                             blurRadius: 8,
          //                             offset: const Offset(0, 2),
          //                           ),
          //                         ]
          //                       : null,
          //                 ),
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     Container(
          //                       padding: const EdgeInsets.all(6),
          //                       decoration: BoxDecoration(
          //                         color: isSelected
          //                             ? AppColors.textOnPrimary.withOpacity(0.2)
          //                             : AppColors.info.withOpacity(0.1),
          //                         borderRadius: BorderRadius.circular(6),
          //                       ),
          //                       child: Icon(
          //                         Icons.smart_toy,
          //                         size: 18,
          //                         color: isSelected
          //                             ? AppColors.textOnPrimary
          //                             : AppColors.info,
          //                       ),
          //                     ),
          //                     const SizedBox(width: AppSpacing.sm),
          //                     Flexible(
          //                       child: Text(
          //                         'Cảnh báo AI',
          //                         style: AppTextStyles.bodyMedium.copyWith(
          //                           fontWeight: FontWeight.w600,
          //                           color: isSelected
          //                               ? AppColors.textOnPrimary
          //                               : AppColors.textPrimary,
          //                         ),
          //                         overflow: TextOverflow.ellipsis,
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               );
          //             },
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Cảnh báo nhiệt độ
                NotificationListPage(filter: widget.filter),
                // Tab 2: Cảnh báo AI
                _buildAIWarningTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIWarningTab() {
    return BlocProvider(
      create: (context) {
        // Lấy token từ local storage
        final authPreference = getIt<AuthLocalPreference>();
        final tokens = authPreference.getTokens();
        final accessToken = tokens?.accessToken ?? '';

        return getIt<NotificationBloc>()..add(
          NotificationFetchEvent(
            VisionNotificationListRequest(
              page: 1,
              pageSize: 10,
              fromTime: DateTime.now()
                  .subtract(const Duration(days: 7))
                  .toIso8601String()
                  .replaceAll('T', ' ')
                  .substring(0, 19),
            ),
            accessToken,
          ),
        );
      },
      child: Container(
        color: AppColors.background,
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return AppWidgets.buildLoadingIndicator(message: 'Loading AI warnings...');
            } else if (state is NotificationLoaded) {
              final allNotifications = state.items;
              final filteredNotifications = _applyAIFilter(allNotifications);

              if (filteredNotifications.isEmpty) {
                return AppWidgets.buildEmptyState(
                  icon: Icons.smart_toy_outlined,
                  title: allNotifications.isEmpty ? 'No AI warnings' : 'No matching notifications',
                  subtitle: allNotifications.isEmpty
                      ? 'There are no AI detection warnings at this time'
                      : 'Try adjusting your filter criteria',
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  final authPreference = getIt<AuthLocalPreference>();
                  final tokens = authPreference.getTokens();
                  final accessToken = tokens?.accessToken ?? '';

                  context.read<NotificationBloc>().add(
                    NotificationFetchEvent(
                      VisionNotificationListRequest(
                        page: 1,
                        pageSize: 10,
                        fromTime: DateTime.now()
                            .subtract(const Duration(days: 7))
                            .toIso8601String()
                            .replaceAll('T', ' ')
                            .substring(0, 19),
                      ),
                      accessToken,
                    ),
                  );
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filteredNotifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = filteredNotifications[index] as NotificationItem;
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                        boxShadow: AppShadows.cardShadow,
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AINotificationDetailPage(notification: item),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  // Image or Icon
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                      border: Border.all(color: AppColors.border, width: 0.5),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                      child: item.imagePath != null && item.imagePath!.isNotEmpty
                                          ? Image.network(
                                              item.imagePath!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: AppColors.error.withOpacity(0.1),
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: AppColors.error,
                                                  size: 24,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: AppColors.info.withOpacity(0.1),
                                              child: const Icon(
                                                Icons.smart_toy,
                                                size: 28,
                                                color: AppColors.info,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.warningEventName ?? 'AI Detection Alert',
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        if (item.areaName != null)
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
                                                  item.areaName!,
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
                                              item.formattedDate ?? '',
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
                                  // Arrow
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.xs),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                    ),
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is NotificationError) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(Icons.wifi_off_outlined, size: 40, color: AppColors.error),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Lỗi kết nối AI',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Không thể tải dữ liệu cảnh báo AI. Vui lòng kiểm tra:\n• Kết nối internet\n• Tình trạng máy chủ AI\n• Quyền truy cập API',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                        border: Border.all(color: AppColors.error.withOpacity(0.2)),
                      ),
                      child: Text(
                        'Chi tiết lỗi: ${state.message}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Retry loading
                            final authPreference = getIt<AuthLocalPreference>();
                            final tokens = authPreference.getTokens();
                            final accessToken = tokens?.accessToken ?? '';

                            context.read<NotificationBloc>().add(
                              NotificationFetchEvent(
                                VisionNotificationListRequest(
                                  page: 1,
                                  pageSize: 10,
                                  fromTime: DateTime.now()
                                      .subtract(const Duration(days: 7))
                                      .toIso8601String()
                                      .replaceAll('T', ' ')
                                      .substring(0, 19),
                                ),
                                accessToken,
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Show detailed error info
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Thông tin chi tiết'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'API Endpoint:',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${getIt<AuthLocalPreference>().getFullBaseUrl().isNotEmpty ? getIt<AuthLocalPreference>().getFullBaseUrl() : 'http://thermal.infosysvietnam.com.vn:10253'}/api/VisionNotifications/list',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontFamily: 'monospace',
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Lỗi:',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        state.message,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontFamily: 'monospace',
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Đóng'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Chi tiết'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
