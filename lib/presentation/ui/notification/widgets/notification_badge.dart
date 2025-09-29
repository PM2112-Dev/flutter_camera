import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_count_bloc.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/presentation/routes/app_routes.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCountBloc, NotificationCountState>(
      builder: (context, state) {
        int count = 0;
        if (state is NotificationCountLoaded) {
          count = state.totalCount;
        }

        return Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: AppColors.textOnPrimary,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notificationList);
                },
              ),
              if (count > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.small,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
