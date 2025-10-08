import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/model/notification_list_request.dart';
import 'package:flutter_camera/data/network/model/notification_list_response.dart';
import 'package:flutter_camera/domain/usecase/notification/get_notifications_use_case.dart';
import 'package:injectable/injectable.dart';

part 'notification_list_event.dart';
part 'notification_list_state.dart';

@injectable
class NotificationListBloc
    extends Bloc<NotificationListEvent, NotificationListState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final AuthLocalPreference authLocalPreference;

  NotificationListBloc({
    required this.getNotificationsUseCase,
    required this.authLocalPreference,
  }) : super(NotificationListInitial()) {
    on<FetchNotificationList>(_onFetchNotificationList);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
  }

  Future<void> _onFetchNotificationList(
    FetchNotificationList event,
    Emitter<NotificationListState> emit,
  ) async {
    emit(NotificationListLoading());
    try {
      final tokens = authLocalPreference.getTokens();
      if (tokens == null) {
        emit(NotificationListError(message: 'No token available'));
        return;
      }

      final request = NotificationListRequest(page: 1, pageSize: 100);

      final response = await getNotificationsUseCase(
        request: request,
        token: tokens.accessToken,
      );

      if (response?.isSuccess == true && response?.data != null) {
        final notifications = response!.data!.items ?? [];
        final totalCount = response.data!.totalRow ?? 0;
        final totalPages = response.data!.totalPages ?? 0;

        emit(
          NotificationListLoaded(
            notifications: notifications,
            totalCount: totalCount,
            currentPage: 1,
            totalPages: totalPages,
            hasMoreData: totalPages > 1,
          ),
        );
      } else {
        emit(
          NotificationListError(
            message: response?.message ?? 'Failed to fetch notifications',
          ),
        );
      }
    } catch (e) {
      emit(NotificationListError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationListLoaded || !currentState.hasMoreData) {
      return;
    }

    try {
      final tokens = authLocalPreference.getTokens();
      if (tokens == null) {
        return;
      }

      final nextPage = currentState.currentPage + 1;
      final request = NotificationListRequest(page: nextPage, pageSize: 20);

      final response = await getNotificationsUseCase(
        request: request,
        token: tokens.accessToken,
      );

      if (response?.isSuccess == true && response?.data != null) {
        final newNotifications = response!.data!.items ?? [];
        final totalPages = response.data!.totalPages ?? 0;

        emit(
          NotificationListLoaded(
            notifications: [...currentState.notifications, ...newNotifications],
            totalCount: currentState.totalCount,
            currentPage: nextPage,
            totalPages: totalPages,
            hasMoreData: nextPage < totalPages,
          ),
        );
      }
    } catch (e) {
      // Don't emit error for pagination failure, just keep current state
    }
  }
}
