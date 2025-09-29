import 'package:flutter_camera/data/network/model/notification_list_request.dart';
import 'package:flutter_camera/data/network/model/notification_list_response.dart';
import 'package:flutter_camera/data/network/model/notification_detail_response.dart';

abstract class NotificationsRepository {
  Future<NotificationListResponse?> getNotifications({
    required NotificationListRequest request,
    required String token,
  });

  Future<NotificationDetailResponse?> getNotificationDetail({
    required String id,
    required String dataTime,
    required String token,
  });
}
