import 'package:flutter_camera/data/network/model/notification_list_request.dart';
import 'package:flutter_camera/data/network/model/notification_list_response.dart';
import 'package:flutter_camera/domain/repositories/notifications_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetNotificationsUseCase {
  final NotificationsRepository repository;
  GetNotificationsUseCase(this.repository);

  Future<NotificationListResponse?> call({
    required NotificationListRequest request,
    required String token,
  }) {
    return repository.getNotifications(request: request, token: token);
  }
}
