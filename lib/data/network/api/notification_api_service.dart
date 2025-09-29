import 'package:dio/dio.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';
import '../model/notification_list_request.dart';
import '../model/notification_list_response.dart';
import '../model/notification_detail_response.dart';

@injectable
class NotificationApiService {
  final Dio _dio;
  final AuthLocalPreference authLocalPreference;

  NotificationApiService(this._dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  Future<NotificationListResponse?> getNotifications({
    required NotificationListRequest request,
    required String token,
  }) async {
    try {
      final headers = <String, String>{'Accept': '*/*', 'Authorization': 'Bearer $token'};
      final response = await _dio.get(
        '$_baseUrl/api/Notifications/list',
        queryParameters: request.toQueryParameters(),
        options: Options(headers: headers),
      );
      if (response.data == null) return null;
      return NotificationListResponse.fromJson(response.data);
    } catch (e) {
      // Có thể log lỗi ở đây nếu cần
      return null;
    }
  }

  Future<NotificationDetailResponse?> getNotificationDetail({
    required String id,
    required String dataTime,
    required String token,
  }) async {
    try {
      final headers = <String, String>{'Accept': '*/*', 'Authorization': 'Bearer $token'};
      final response = await _dio.get(
        '$_baseUrl/api/Notifications',
        queryParameters: {'id': id, 'dataTime': dataTime},
        options: Options(headers: headers),
      );
      if (response.data == null) return null;
      return NotificationDetailResponse.fromJson(response.data);
    } catch (e) {
      // Có thể log lỗi ở đây nếu cần
      return null;
    }
  }
}
