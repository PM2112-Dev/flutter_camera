import 'package:dio/dio.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/model/api_response.dart';
import 'package:flutter_camera/data/network/model/common_enums_model.dart';
import 'package:flutter_camera/shared/constants/url_constants.dart';
import 'package:injectable/injectable.dart';

@injectable
class CommonEnumsApiService {
  final Dio _dio;
  final AuthLocalPreference authLocalPreference;

  CommonEnumsApiService(this._dio, this.authLocalPreference);

  String get _baseUrl {
    final dynamicUrl = authLocalPreference.getFullBaseUrl();
    return dynamicUrl.isNotEmpty ? dynamicUrl : '${UrlConstants.baseUrl}:10253';
  }

  Future<ApiResponse<CommonEnumsResponse>> getAllEnums({String? accessToken}) async {
    try {
      final headers = <String, String>{'Accept': '*/*'};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await _dio.get(
        '$_baseUrl/api/CommonLists/allEnums',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CommonEnumsResponse>.fromJson(
          response.data,
          (json) => CommonEnumsResponse.fromJson(json as Map<String, dynamic>),
        );
        return apiResponse;
      }

      return ApiResponse<CommonEnumsResponse>(
        isSuccess: false,
        code: response.statusCode.toString(),
        message: 'Failed to fetch enums',
      );
    } catch (e) {
      return ApiResponse<CommonEnumsResponse>(isSuccess: false, code: '500', message: e.toString());
    }
  }
}
