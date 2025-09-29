import 'package:dio/dio.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/model/api_response.dart';
import 'package:flutter_camera/domain/model/camera_control_request.dart';
import 'package:flutter_camera/domain/model/camera_control_response.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';

@injectable
class CameraControlApiService {
  final Dio dio;
  final AuthLocalPreference authLocalPreference;

  CameraControlApiService(this.dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  /// Send camera control command to API
  ///
  /// POST /api/Cameras/control
  /// Body: { "cameraId": 2, "speed": 3, "command": 6 }
  Future<ApiResponse<CameraControlResponse>> controlCamera({
    required CameraControlRequest request,
  }) async {
    try {
      print('API Service: Sending request to $_baseUrl/api/Cameras/control');
      print('API Service: Request body: ${request.toJson()}');

      // Get access token from local storage
      final tokens = authLocalPreference.getTokens();
      final accessToken = tokens?.accessToken ?? '';

      print('API Service: Access token available: ${accessToken.isNotEmpty}');

      final headers = <String, String>{
        'Content-Type': 'application/json-patch+json',
        'Accept': '*/*',
      };
      if (accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      final response = await dio.post(
        '$_baseUrl/api/Cameras/control',
        data: request.toJson(),
        options: Options(headers: headers),
      );

      print('API Service: Response status: ${response.statusCode}');
      print('API Service: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final controlResponse = CameraControlResponse.fromJson(response.data);

        return ApiResponse<CameraControlResponse>(
          isSuccess: controlResponse.isSuccess,
          code: controlResponse.code,
          message: controlResponse.message ?? 'Camera control executed successfully',
          data: controlResponse,
        );
      } else {
        return ApiResponse<CameraControlResponse>(
          isSuccess: false,
          code: response.statusCode.toString(),
          message: 'Failed to control camera. Status: ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      print('API Service: DioException occurred: ${e.message}');
      print('API Service: Error type: ${e.type}');
      print('API Service: Response: ${e.response?.data}');
      print('API Service: Status code: ${e.response?.statusCode}');

      String errorMessage = 'Camera control failed';

      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            errorMessage = 'Invalid camera control request';
            break;
          case 401:
            errorMessage = 'Unauthorized access to camera control';
            break;
          case 403:
            errorMessage = 'Camera control access forbidden';
            break;
          case 404:
            errorMessage = 'Camera not found';
            break;
          case 500:
            errorMessage = 'Camera control server error';
            break;
          default:
            errorMessage = 'Camera control failed: ${e.response!.statusMessage}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Camera control connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Camera control response timeout';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Camera control network error';
      }
      return ApiResponse<CameraControlResponse>(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? 'ERROR',
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      return ApiResponse<CameraControlResponse>(
        isSuccess: false,
        code: 'UNKNOWN',
        message: 'Unexpected camera control error: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Helper method for PTZ commands
  Future<ApiResponse<CameraControlResponse>> sendPTZCommand({
    required int cameraId,
    required int command,
    required int speed,
  }) async {
    final request = CameraControlRequest(cameraId: cameraId, speed: speed, command: command);

    return controlCamera(request: request);
  }

  /// Helper method to stop PTZ movement
  Future<ApiResponse<CameraControlResponse>> stopPTZ({required int cameraId}) async {
    final request = CameraControlRequest(
      cameraId: cameraId,
      speed: 0,
      command: 0, // Stop command
    );

    return controlCamera(request: request);
  }
}
