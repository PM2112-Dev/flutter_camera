part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationFetchEvent extends NotificationEvent {
  final VisionNotificationListRequest request;
  final String token;
  const NotificationFetchEvent(this.request, this.token);

  @override
  List<Object?> get props => [request, token];
}
