import 'package:dio/dio.dart';
import 'package:flutter_camera/data/network/model/api_response.dart';
import 'package:flutter_camera/data/network/model/auth_tokens_model.dart';
import 'package:flutter_camera/data/network/model/login_response.dart';
import 'package:flutter_camera/data/network/model/user_response.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthApiService {
  final Dio dio;
  final AuthLocalPreference authLocalPreference;

  AuthApiService(this.dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  Future<ApiResponse<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('AuthApiService: Login URL: $_baseUrl/api/Auth/login');
      print('AuthApiService: Username: $username');

      final response = await dio.post(
        '$_baseUrl/api/Auth/login',
        data: {'username': username, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json-patch+json', 'Accept': '*/*'}),
      );

      print('AuthApiService: Response status: ${response.statusCode}');
      print('AuthApiService: Response data: ${response.data}');

      return ApiResponse<LoginResponse>(
        isSuccess: response.data['isSuccess'] ?? false,
        code: response.data['code'] ?? '',
        name: response.data['name'],
        message: response.data['message'],
        data: response.data['data'] != null ? LoginResponse.fromJson(response.data['data']) : null,
      );
    } on DioException catch (e) {
      print('AuthApiService: DioException: ${e.message}');
      print('AuthApiService: Response status: ${e.response?.statusCode}');
      print('AuthApiService: Response data: ${e.response?.data}');

      // Extract error message from response data if available
      String errorMessage = 'Login failed';
      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] as String?;
          if (message != null && message.isNotEmpty) {
            errorMessage = _decodeHtmlEntities(message);
          }
        }
      }

      // Fallback to DioException message if no response message
      if (errorMessage == 'Login failed' && e.message != null) {
        errorMessage = e.message!;
      }

      return ApiResponse<LoginResponse>(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? '500',
        message: errorMessage,
      );
    } catch (e) {
      print('AuthApiService: Unexpected error: $e');
      return ApiResponse<LoginResponse>(
        isSuccess: false,
        code: '500',
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      // Get current tokens to include in logout request
      final tokens = authLocalPreference.getTokens();
      final headers = <String, String>{'Accept': '*/*'};

      if (tokens?.accessToken != null && tokens!.accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        print(
          'AuthApiService: Logout with token: ${tokens.accessToken.substring(0, tokens.accessToken.length > 20 ? 20 : tokens.accessToken.length)}...',
        );
      } else {
        print('AuthApiService: Logout without token (no stored tokens)');
      }

      final response = await dio.post(
        '$_baseUrl/api/Auth/logout',
        options: Options(headers: headers),
      );

      return ApiResponse<void>(
        isSuccess: response.data['isSuccess'] ?? true,
        code: response.data['code'] ?? '200',
        message: response.data['message'] ?? 'Logout successful',
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? '500',
        message: e.message ?? 'Logout failed',
      );
    } catch (e) {
      return ApiResponse<void>(isSuccess: false, code: '500', message: 'Unexpected error: $e');
    }
  }

  Future<ApiResponse<AuthTokensModel>> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/api/Auth/refresh',
        data: {'accessToken': accessToken, 'refreshToken': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json-patch+json', 'Accept': '*/*'}),
      );

      return ApiResponse<AuthTokensModel>(
        isSuccess: response.data['isSuccess'] ?? false,
        code: response.data['code'] ?? '',
        message: response.data['message'],
        data: response.data['data'] != null
            ? AuthTokensModel.fromJson(response.data['data'])
            : null,
      );
    } on DioException catch (e) {
      return ApiResponse<AuthTokensModel>(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? '500',
        message: e.message ?? 'Token refresh failed',
      );
    } catch (e) {
      return ApiResponse<AuthTokensModel>(
        isSuccess: false,
        code: '500',
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<ApiResponse<UserResponse>> getProfile({String? accessToken}) async {
    try {
      final headers = <String, String>{'Accept': '*/*'};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      final response = await dio.get(
        '$_baseUrl/api/Auth/myProfile',
        options: Options(headers: headers),
      );

      return ApiResponse<UserResponse>(
        isSuccess: response.data['isSuccess'] ?? false,
        code: response.data['code'] ?? '',
        message: response.data['message'],
        data: response.data['data'] != null ? UserResponse.fromJson(response.data['data']) : null,
      );
    } on DioException catch (e) {
      return ApiResponse<UserResponse>(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? '500',
        message: e.message ?? 'Failed to get profile',
      );
    } catch (e) {
      return ApiResponse<UserResponse>(
        isSuccess: false,
        code: '500',
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Decode HTML entities in error messages
  /// Example: "M\u1EADt kh\u1EA9u kh\u00F4ng \u0111\u00FAng" -> "Mật khẩu không đúng"
  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('\\u1EAD', 'ậ') // ậ
        .replaceAll('\\u1EA9', 'ẩ') // ẩ
        .replaceAll('\\u00F4', 'ô') // ô
        .replaceAll('\\u0111', 'đ') // đ
        .replaceAll('\\u00FA', 'ú') // ú
        .replaceAll('\\u0103', 'ă') // ă
        .replaceAll('\\u1EA7', 'ầ') // ầ
        .replaceAll('\\u1EA5', 'ấ') // ấ
        .replaceAll('\\u1EB9', 'ẹ') // ẹ
        .replaceAll('\\u1EC3', 'ể') // ể
        .replaceAll('\\u1EC1', 'ế') // ế
        .replaceAll('\\u1EC9', 'ệ') // ệ
        .replaceAll('\\u1EC5', 'ễ') // ễ
        .replaceAll('\\u00E2', 'â') // â
        .replaceAll('\\u1EA1', 'ạ') // ạ
        .replaceAll('\\u1EB3', 'ẳ') // ẳ
        .replaceAll('\\u1EB1', 'ẳ') // ẳ
        .replaceAll('\\u1EBB', 'ỳ') // ỳ
        .replaceAll('\\u1EBD', 'ỵ') // ỵ
        .replaceAll('\\u1EB5', 'ỵ') // ỵ
        .replaceAll('\\u1EB7', 'ỷ') // ỷ
        .replaceAll('\\u1EAF', 'ặ') // ặ
        .replaceAll('\\u1EAB', 'ặ') // ặ
        .replaceAll('\\u1EA3', 'ả') // ả
        .replaceAll('\\u00E0', 'à') // à
        .replaceAll('\\u00E1', 'á') // á
        .replaceAll('\\u00E3', 'ã') // ã
        .replaceAll('\\u00E8', 'è') // è
        .replaceAll('\\u00E9', 'é') // é
        .replaceAll('\\u00EC', 'ì') // ì
        .replaceAll('\\u00ED', 'í') // í
        .replaceAll('\\u00F2', 'ò') // ò
        .replaceAll('\\u00F3', 'ó') // ó
        .replaceAll('\\u00F5', 'õ') // õ
        .replaceAll('\\u00F9', 'ù') // ù
        .replaceAll('\\u0169', 'ũ') // ũ
        .replaceAll('\\u1EF1', 'ự') // ự
        .replaceAll('\\u1EF3', 'ỳ') // ỳ
        .replaceAll('\\u1EF5', 'ỵ') // ỵ
        .replaceAll('\\u1EF7', 'ỷ') // ỷ
        .replaceAll('\\u1EF9', 'ỹ') // ỹ
        .replaceAll('\\u1EDB', 'ụ') // ụ
        .replaceAll('\\u1EDD', 'ụ') // ụ
        .replaceAll('\\u1EDF', 'ủ') // ủ
        .replaceAll('\\u1EE1', 'ũ') // ũ
        .replaceAll('\\u1EE3', 'ụ') // ụ
        .replaceAll('\\u1EE5', 'ụ') // ụ
        .replaceAll('\\u1EE7', 'ụ') // ụ
        .replaceAll('\\u1EE9', 'ụ') // ụ
        .replaceAll('\\u1EEB', 'ụ') // ụ
        .replaceAll('\\u1EED', 'ụ') // ụ
        .replaceAll('\\u1EEF', 'ụ') // ụ
        .replaceAll('\\u1EF1', 'ụ') // ụ
        .replaceAll('\\u1EF3', 'ụ') // ụ
        .replaceAll('\\u1EF5', 'ụ') // ụ
        .replaceAll('\\u1EF7', 'ụ') // ụ
        .replaceAll('\\u1EF9', 'ụ'); // ụ
  }
}
