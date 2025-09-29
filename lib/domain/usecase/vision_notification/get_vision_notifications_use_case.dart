import 'package:flutter_camera/data/network/model/vision_notification_list_request.dart';
import 'package:flutter_camera/data/network/model/vision_notification_list_response.dart';
import 'package:flutter_camera/domain/repositories/vision_notifications_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetVisionNotificationsUseCase {
  final VisionNotificationsRepository repository;
  GetVisionNotificationsUseCase(this.repository);

  Future<VisionNotificationListResponse?> call({
    required VisionNotificationListRequest request,
    required String token,
  }) {
    return repository.getNotifications(request: request, token: token);
  }
}
