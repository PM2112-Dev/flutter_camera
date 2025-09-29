part of 'notification_detail_bloc.dart';

abstract class NotificationDetailState extends Equatable {
  const NotificationDetailState();

  @override
  List<Object> get props => [];
}

class NotificationDetailInitial extends NotificationDetailState {}

class NotificationDetailLoading extends NotificationDetailState {}

class NotificationDetailLoaded extends NotificationDetailState {
  final NotificationDetailData detail;

  const NotificationDetailLoaded({required this.detail});

  @override
  List<Object> get props => [detail];
}

class NotificationDetailError extends NotificationDetailState {
  final String message;

  const NotificationDetailError({required this.message});

  @override
  List<Object> get props => [message];
}
