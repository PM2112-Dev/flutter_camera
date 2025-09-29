part of 'notification_list_bloc.dart';

abstract class NotificationListState extends Equatable {
  const NotificationListState();

  @override
  List<Object> get props => [];
}

class NotificationListInitial extends NotificationListState {}

class NotificationListLoading extends NotificationListState {}

class NotificationListLoaded extends NotificationListState {
  final List<NotificationItem> notifications;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMoreData;

  const NotificationListLoaded({
    required this.notifications,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMoreData,
  });

  @override
  List<Object> get props => [
    notifications,
    totalCount,
    currentPage,
    totalPages,
    hasMoreData,
  ];
}

class NotificationListError extends NotificationListState {
  final String message;

  const NotificationListError({required this.message});

  @override
  List<Object> get props => [message];
}
