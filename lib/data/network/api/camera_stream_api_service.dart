import 'package:dio/dio.dart';
import 'package:flutter_camera/data/network/model/camera_stream_response.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';

@injectable
class CameraStreamApiService {
  final Dio dio;
  final AuthLocalPreference authLocalPreference;

  CameraStreamApiService(this.dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  String? get _accessToken => authLocalPreference.getTokens()?.accessToken;

  Map<String, String> _getHeaders() {
    final headers = <String, String>{'Accept': '*/*', 'Content-Type': 'application/json'};

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  Future<CameraStreamResponse> getCameraStream({required int cameraId}) async {
    try {
      print('CameraStreamApiService: Getting stream for camera ID: $cameraId');
      print('CameraStreamApiService: Base URL: $_baseUrl');
      print('CameraStreamApiService: Full URL: $_baseUrl/api/Cameras/stream/$cameraId');
      print('CameraStreamApiService: Headers: ${_getHeaders()}');

      final response = await dio.get(
        '$_baseUrl/api/Cameras/stream/$cameraId',
        options: Options(
          headers: _getHeaders(),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('CameraStreamApiService: Response status: ${response.statusCode}');
      print('CameraStreamApiService: Response data: ${response.data}');

      return CameraStreamResponse(
        isSuccess: response.data['isSuccess'] ?? false,
        code: response.data['code'] ?? response.statusCode.toString(),
        name: response.data['name'],
        message: response.data['message'],
        data: response.data['data'],
      );
    } on DioException catch (e) {
      print('CameraStreamApiService: DioException: ${e.message}');
      print('CameraStreamApiService: Response status: ${e.response?.statusCode}');
      print('CameraStreamApiService: Response data: ${e.response?.data}');

      return CameraStreamResponse(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? '500',
        message: e.message ?? 'Failed to get camera stream',
      );
    } catch (e) {
      print('CameraStreamApiService: Unexpected error: $e');
      return CameraStreamResponse(isSuccess: false, code: '500', message: 'Unexpected error: $e');
    }
  }
}
