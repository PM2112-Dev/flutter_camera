import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/model/notification_detail_response.dart';
import 'package:flutter_camera/domain/usecase/notification/get_notification_detail_use_case.dart';
import 'package:injectable/injectable.dart';

part 'notification_detail_event.dart';
part 'notification_detail_state.dart';

@injectable
class NotificationDetailBloc
    extends Bloc<NotificationDetailEvent, NotificationDetailState> {
  final GetNotificationDetailUseCase getNotificationDetailUseCase;
  final AuthLocalPreference authLocalPreference;

  NotificationDetailBloc({
    required this.getNotificationDetailUseCase,
    required this.authLocalPreference,
  }) : super(NotificationDetailInitial()) {
    on<FetchNotificationDetail>(_onFetchNotificationDetail);
  }

  Future<void> _onFetchNotificationDetail(
    FetchNotificationDetail event,
    Emitter<NotificationDetailState> emit,
  ) async {
    emit(NotificationDetailLoading());
    try {
      final tokens = authLocalPreference.getTokens();
      if (tokens == null) {
        emit(NotificationDetailError(message: 'No token available'));
        return;
      }

      final response = await getNotificationDetailUseCase(
        id: event.id,
        dataTime: event.dataTime,
        token: tokens.accessToken,
      );

      if (response?.isSuccess == true && response?.data != null) {
        emit(NotificationDetailLoaded(detail: response!.data!));
      } else {
        emit(
          NotificationDetailError(
            message: response?.message ?? 'Failed to fetch notification detail',
          ),
        );
      }
    } catch (e) {
      emit(NotificationDetailError(message: e.toString()));
    }
  }
}
