import 'package:dio/dio.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/model/api_response.dart';
import 'package:flutter_camera/data/network/model/area_map_model.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';

@injectable
class AreaMapApiService {
  final Dio _dio;
  final AuthLocalPreference authLocalPreference;

  AreaMapApiService(this._dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  Future<ApiResponse<AreaMapResponseModel>> getMachinesAndResultByArea({
    String? accessToken,
  }) async {
    try {
      final headers = <String, String>{'Accept': '*/*'};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await _dio.get(
        '$_baseUrl/api/ThermalDatas/machinesAndResultByArea',
        options: Options(headers: headers, validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        try {
          final apiResponse = ApiResponse<AreaMapResponseModel>.fromJson(response.data, (json) {
            try {
              return AreaMapResponseModel.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing area map response: $e');
              rethrow;
            }
          });
          return apiResponse;
        } catch (e, stackTrace) {
          print('Error creating ApiResponse: $e');
          print('Stack trace: $stackTrace');
          return ApiResponse<AreaMapResponseModel>(
            isSuccess: false,
            code: '500',
            name: null,
            message: 'Data parsing error: $e',
            data: AreaMapResponseModel(machines: [], areas: []),
          );
        }
      } else {
        return ApiResponse<AreaMapResponseModel>(
          isSuccess: false,
          code: response.statusCode.toString(),
          name: null,
          message: 'Failed to get area map data: ${response.statusMessage}',
          data: AreaMapResponseModel(machines: [], areas: []),
        );
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('DioException response: ${e.response?.data}');
      return ApiResponse<AreaMapResponseModel>(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? '500',
        name: null,
        message: 'Network error: ${e.message}',
        data: AreaMapResponseModel(machines: [], areas: []),
      );
    } catch (e, stackTrace) {
      print('Unexpected exception: $e');
      print('Stack trace: $stackTrace');
      return ApiResponse<AreaMapResponseModel>(
        isSuccess: false,
        code: '500',
        name: null,
        message: 'Unexpected error: $e',
        data: AreaMapResponseModel(machines: [], areas: []),
      );
    }
  }
}
