import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/model/notification_list_request.dart';
import 'package:flutter_camera/domain/usecase/notification/get_notifications_use_case.dart';
import 'package:injectable/injectable.dart';

// Events
abstract class NotificationCountEvent {}

class FetchNotificationCount extends NotificationCountEvent {}

// States
abstract class NotificationCountState {}

class NotificationCountInitial extends NotificationCountState {}

class NotificationCountLoading extends NotificationCountState {}

class NotificationCountLoaded extends NotificationCountState {
  final int totalCount;

  NotificationCountLoaded({required this.totalCount});
}

class NotificationCountError extends NotificationCountState {
  final String message;

  NotificationCountError({required this.message});
}

@injectable
class NotificationCountBloc
    extends Bloc<NotificationCountEvent, NotificationCountState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final AuthLocalPreference authLocalPreference;

  NotificationCountBloc({
    required this.getNotificationsUseCase,
    required this.authLocalPreference,
  }) : super(NotificationCountInitial()) {
    on<FetchNotificationCount>(_onFetchNotificationCount);
  }

  Future<void> _onFetchNotificationCount(
    FetchNotificationCount event,
    Emitter<NotificationCountState> emit,
  ) async {
    emit(NotificationCountLoading());
    try {
      final tokens = authLocalPreference.getTokens();
      if (tokens == null) {
        emit(NotificationCountError(message: 'No token available'));
        return;
      }

      final request = NotificationListRequest(
        page: 1,
        pageSize: 1, // We only need the total count, not the actual data
      );

      final response = await getNotificationsUseCase(
        request: request,
        token: tokens.accessToken,
      );

      if (response?.isSuccess == true && response?.data != null) {
        final totalCount = response!.data!.totalRow ?? 0;
        emit(NotificationCountLoaded(totalCount: totalCount));
      } else {
        emit(
          NotificationCountError(
            message: response?.message ?? 'Failed to fetch notifications',
          ),
        );
      }
    } catch (e) {
      emit(NotificationCountError(message: e.toString()));
    }
  }
}
