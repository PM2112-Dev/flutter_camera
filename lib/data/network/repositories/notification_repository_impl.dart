import 'package:flutter_camera/data/network/api/notification_api_service.dart';
import 'package:flutter_camera/data/network/model/notification_list_request.dart';
import 'package:flutter_camera/data/network/model/notification_list_response.dart';
import 'package:flutter_camera/data/network/model/notification_detail_response.dart';
import 'package:flutter_camera/domain/repositories/notifications_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationApiService _apiService;

  NotificationsRepositoryImpl(this._apiService);

  @override
  Future<NotificationListResponse?> getNotifications({
    required NotificationListRequest request,
    required String token,
  }) {
    return _apiService.getNotifications(request: request, token: token);
  }

  @override
  Future<NotificationDetailResponse?> getNotificationDetail({
    required String id,
    required String dataTime,
    required String token,
  }) {
    return _apiService.getNotificationDetail(
      id: id,
      dataTime: dataTime,
      token: token,
    );
  }
}
