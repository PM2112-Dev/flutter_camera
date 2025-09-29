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
      return ApiResponse<LoginResponse>(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? '500',
        message: e.message ?? 'Login failed',
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
      final response = await dio.post(
        '$_baseUrl/api/Auth/logout',
        options: Options(headers: {'Accept': '*/*'}),
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
}
