part of 'notification_detail_bloc.dart';

abstract class NotificationDetailEvent extends Equatable {
  const NotificationDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchNotificationDetail extends NotificationDetailEvent {
  final String id;
  final String dataTime;

  const FetchNotificationDetail({required this.id, required this.dataTime});

  @override
  List<Object> get props => [id, dataTime];
}
