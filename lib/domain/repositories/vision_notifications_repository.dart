import 'package:flutter_camera/data/network/model/vision_notification_list_request.dart';
import 'package:flutter_camera/data/network/model/vision_notification_list_response.dart';

abstract class VisionNotificationsRepository {
  Future<VisionNotificationListResponse?> getNotifications({
    required VisionNotificationListRequest request,
    required String token,
  });
}