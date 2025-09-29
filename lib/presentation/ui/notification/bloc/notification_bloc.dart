import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_camera/data/network/model/vision_notification_list_request.dart';
import 'package:flutter_camera/domain/usecase/vision_notification/get_vision_notifications_use_case.dart';
import 'package:injectable/injectable.dart';

part 'notification_event.dart';
part 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetVisionNotificationsUseCase getNotificationsUseCase;

  NotificationBloc({required this.getNotificationsUseCase})
    : super(NotificationInitial()) {
    on<NotificationFetchEvent>(_onFetch);
  }

  Future<void> _onFetch(
    NotificationFetchEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final response = await getNotificationsUseCase(
        request: event.request,
        token: event.token,
      );
      if (response?.data?.items != null && response!.data!.items!.isNotEmpty) {
        emit(NotificationLoaded(response.data!.items!));
      } else {
        emit(NotificationEmpty());
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
