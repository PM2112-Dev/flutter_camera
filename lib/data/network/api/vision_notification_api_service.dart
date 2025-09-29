import 'package:dio/dio.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';
import '../model/vision_notification_list_request.dart';
import '../model/vision_notification_list_response.dart';

@injectable
class VisionNotificationApiService {
  final Dio _dio;
  final AuthLocalPreference authLocalPreference;

  VisionNotificationApiService(this._dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  Future<VisionNotificationListResponse?> getVisionNotifications({
    required VisionNotificationListRequest request,
    required String token,
  }) async {
    try {
      print('🚀 Vision API: Making request to vision notifications...');
      print('🔑 Token: ${token.isNotEmpty ? "Present (${token.length} chars)" : "Missing"}');
      print('📝 Request params: ${request.toQueryParameters()}');

      final headers = <String, String>{'Accept': '*/*', 'Authorization': 'Bearer $token'};
      final response = await _dio.get(
        '$_baseUrl/api/VisionNotifications/list',
        queryParameters: request.toQueryParameters(),
        options: Options(headers: headers),
      );

      print('✅ Vision API: Response received');
      print('📊 Status: ${response.statusCode}');

      // Safe logging để tránh lỗi substring
      try {
        final dataString = response.data?.toString() ?? 'null';
        if (dataString.length <= 200) {
          print('📋 Data: $dataString');
        } else {
          print('📋 Data (first 200 chars): ${dataString.substring(0, 200)}...');
        }
        print('📏 Total data length: ${dataString.length} characters');
      } catch (logError) {
        print('📋 Data: [Error displaying data - $logError]');
      }

      if (response.data == null) {
        print('⚠️ Vision API: Response data is null');
        return null;
      }
      return VisionNotificationListResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Vision API Error: $e');
      print('🔍 Error type: ${e.runtimeType}');
      if (e is DioException) {
        print('🌐 Dio Error Details:');
        print('   - Type: ${e.type}');
        print('   - Message: ${e.message}');
        print('   - Response: ${e.response?.data}');
        print('   - Status Code: ${e.response?.statusCode}');
      }

      // Throw lại error để bloc có thể handle
      rethrow;
    }
  }
}
