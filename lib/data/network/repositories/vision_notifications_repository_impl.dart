import 'package:flutter_camera/data/network/api/vision_notification_api_service.dart';
import 'package:flutter_camera/data/network/model/vision_notification_list_request.dart';
import 'package:flutter_camera/data/network/model/vision_notification_list_response.dart';
import 'package:flutter_camera/domain/repositories/vision_notifications_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: VisionNotificationsRepository)
class VisionNotificationsRepositoryImpl
    implements VisionNotificationsRepository {
  final VisionNotificationApiService _apiService;

  VisionNotificationsRepositoryImpl(this._apiService);

  @override
  Future<VisionNotificationListResponse?> getNotifications({
    required VisionNotificationListRequest request,
    required String token,
  }) {
    return _apiService.getVisionNotifications(request: request, token: token);
  }
}
