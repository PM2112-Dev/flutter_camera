import 'package:dio/dio.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/model/api_response.dart';
import 'package:flutter_camera/data/network/model/area_tree_model.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';

@injectable
class AreaApiService {
  final Dio _dio;
  final AuthLocalPreference authLocalPreference;

  AreaApiService(this._dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  Future<ApiResponse<List<AreaTreeWithCamerasModel>>> getAreaAllTree({String? accessToken}) async {
    try {
      final headers = <String, String>{'Accept': '*/*'};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      final response = await _dio.get(
        '$_baseUrl/api/Areas/allTree?cameras=true',
        options: Options(headers: headers, validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        try {
          final apiResponse = ApiResponse<List<AreaTreeWithCamerasModel>>.fromJson(response.data, (
            json,
          ) {
            try {
              if (json is List) {
                return json.map((e) {
                  try {
                    return AreaTreeWithCamerasModel.fromJson(e as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parsing single area tree: $e');
                    print('Problematic item: $e');
                    rethrow;
                  }
                }).toList();
              } else {
                throw Exception('Expected List but got ${json.runtimeType}');
              }
            } catch (e) {
              print('Error parsing area trees list: $e');
              rethrow;
            }
          });
          return apiResponse;
        } catch (e, stackTrace) {
          print('Error creating ApiResponse: $e');
          print('Stack trace: $stackTrace');
          return ApiResponse<List<AreaTreeWithCamerasModel>>(
            isSuccess: false,
            code: '500',
            name: null,
            message: 'Data parsing error: $e',
            data: [],
          );
        }
      } else {
        return ApiResponse<List<AreaTreeWithCamerasModel>>(
          isSuccess: false,
          code: response.statusCode.toString(),
          name: null,
          message: 'Failed to get area tree: ${response.statusMessage}',
          data: [],
        );
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('DioException response: ${e.response?.data}');
      return ApiResponse<List<AreaTreeWithCamerasModel>>(
        isSuccess: false,
        code: e.response?.statusCode?.toString() ?? '500',
        name: null,
        message: 'Network error: ${e.message}',
        data: [],
      );
    } catch (e, stackTrace) {
      print('Unexpected exception: $e');
      print('Stack trace: $stackTrace');
      return ApiResponse<List<AreaTreeWithCamerasModel>>(
        isSuccess: false,
        code: '500',
        name: null,
        message: 'Unexpected error: $e',
        data: [],
      );
    }
  }
}
