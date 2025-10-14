import 'package:dio/dio.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/model/api_response.dart';
import 'package:flutter_camera/data/network/model/real_time_thermal_data_model.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';

@injectable
class RealTimeThermalApiService {
  final Dio _dio;
  final AuthLocalPreference authLocalPreference;

  RealTimeThermalApiService(this._dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  Future<ApiResponse<RealTimeThermalDataResponseModel>> getRealTimeThermalData({
    required int machineId,
    required int id,
    required String deviceType,
    String? accessToken,
  }) async {
    try {
      print('🌡️  API Request: machineId=$machineId, id=$id, deviceType=$deviceType');
      final headers = <String, String>{'Accept': '*/*'};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await _dio.get(
        '$_baseUrl/api/ThermalDatas/thermalByComponent',
        queryParameters: {'machineId': machineId, 'id': id, 'deviceType': deviceType},
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      print('📡 API Response: status=${response.statusCode}, hasData=${response.data != null}');

      if (response.statusCode == 200) {
        try {
          final apiResponse = ApiResponse<RealTimeThermalDataResponseModel>.fromJson(response.data, (
            json,
          ) {
            try {
              final model = RealTimeThermalDataResponseModel.fromJson(json as Map<String, dynamic>);
              print(
                '✅ Parsed successfully: ${model.data.keys.length} components - ${model.data.keys.join(", ")}',
              );
              return model;
            } catch (e) {
              print('❌ Error parsing real-time thermal data response: $e');
              print('   JSON data: $json');
              rethrow;
            }
          });
          print(
            '📊 API Success: isSuccess=${apiResponse.isSuccess}, hasData=${apiResponse.data != null}',
          );
          return apiResponse;
        } catch (e, stackTrace) {
          print('Error creating ApiResponse: $e');
          print('Stack trace: $stackTrace');
          return ApiResponse<RealTimeThermalDataResponseModel>(
            isSuccess: false,
            code: '500',
            name: null,
            message: 'Data parsing error: $e',
            data: RealTimeThermalDataResponseModel(data: {}),
          );
        }
      } else {
        return ApiResponse<RealTimeThermalDataResponseModel>(
          isSuccess: false,
          code: response.statusCode.toString(),
          name: null,
          message: 'Failed to get real-time thermal data: ${response.statusMessage}',
          data: RealTimeThermalDataResponseModel(data: {}),
        );
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('DioException response: ${e.response?.data}');
      return ApiResponse<RealTimeThermalDataResponseModel>(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? '500',
        name: null,
        message: 'Network error: ${e.message}',
        data: RealTimeThermalDataResponseModel(data: {}),
      );
    } catch (e, stackTrace) {
      print('Unexpected exception: $e');
      print('Stack trace: $stackTrace');
      return ApiResponse<RealTimeThermalDataResponseModel>(
        isSuccess: false,
        code: '500',
        name: null,
        message: 'Unexpected error: $e',
        data: RealTimeThermalDataResponseModel(data: {}),
      );
    }
  }
}
