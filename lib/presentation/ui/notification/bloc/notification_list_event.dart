part of 'notification_list_bloc.dart';

abstract class NotificationListEvent extends Equatable {
  const NotificationListEvent();

  @override
  List<Object> get props => [];
}

class FetchNotificationList extends NotificationListEvent {}

class LoadMoreNotifications extends NotificationListEvent {}
