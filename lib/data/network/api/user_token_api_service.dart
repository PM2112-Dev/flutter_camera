import 'package:dio/dio.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';

@injectable
class UserTokenApiService {
  final Dio _dio;
  final AuthLocalPreference authLocalPreference;

  UserTokenApiService(this._dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  Future<bool> postUserToken({
    required String userId,
    required String deviceType,
    required String token,
    required List<String> areaIds,
    required bool isAdmin,
    required String authToken,
  }) async {
    try {
      print('🚀 UserToken API: Posting token to server...');
      print('👤 User ID: $userId');
      print('📱 Device Type: $deviceType');
      print('🔑 FCM Token: ${token.isNotEmpty ? "Present (${token.length} chars)" : "Missing"}');
      print('📍 Area IDs: $areaIds');
      print('👑 Is Admin: $isAdmin');

      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };
      final response = await _dio.post(
        '$_baseUrl/api/Users/userToken',
        data: {
          'userId': userId,
          'deviceType': deviceType,
          'token': token,
          'areaIds': areaIds,
          'isAdmin': true,
        },
        options: Options(headers: headers),
      );

      print('✅ UserToken API: Response received');
      print('📊 Status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ UserToken API Error: $e');
      if (e is DioException) {
        print('🌐 Dio Error Details:');
        print('   - Type: ${e.type}');
        print('   - Message: ${e.message}');
        print('   - Response: ${e.response?.data}');
        print('   - Status Code: ${e.response?.statusCode}');
      }
      return false;
    }
  }

  // DELETE API không tồn tại trên server
  // Server sẽ tự động clean up tokens không còn hoạt động
  // Giữ lại function này để tương lai nếu server implement API

  // Future<bool> deleteUserToken({required String token, required String authToken}) async {
  //   try {
  //     print('🗑️ UserToken API: Deleting token from server...');
  //     print('🔑 FCM Token: ${token.isNotEmpty ? "Present (${token.length} chars)" : "Missing"}');
  //
  //     final headers = <String, String>{
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $authToken',
  //     };
  //     final response = await _dio.delete(
  //       '$_baseUrl/api/Users/userToken',
  //       data: {'token': token},
  //       options: Options(headers: headers),
  //     );
  //
  //     print('✅ UserToken API: Delete response received');
  //     print('📊 Status: ${response.statusCode}');
  //
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     print('❌ UserToken API Delete Error: $e');
  //     if (e is DioException) {
  //       print('🌐 Dio Error Details:');
  //       print('   - Type: ${e.type}');
  //       print('   - Message: ${e.message}');
  //       print('   - Response: ${e.response?.data}');
  //       print('   - Status Code: ${e.response?.statusCode}');
  //     }
  //     return false;
  //   }
  // }
}
