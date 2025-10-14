import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/real_time_thermal_api_service.dart';
import 'package:flutter_camera/domain/model/real_time_thermal_data.dart';
import 'package:flutter_camera/domain/repositories/real_time_thermal_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RealTimeThermalRepository)
class RealTimeThermalRepositoryImpl implements RealTimeThermalRepository {
  final RealTimeThermalApiService _apiService;
  final AuthLocalPreference _authLocalPreference;

  RealTimeThermalRepositoryImpl(this._apiService, this._authLocalPreference);

  @override
  Future<RealTimeThermalDataResponse?> getRealTimeThermalData({
    required int machineId,
    required int id,
    required String deviceType,
  }) async {
    try {
      final token = _authLocalPreference.getTokens()?.accessToken;
      final response = await _apiService.getRealTimeThermalData(
        machineId: machineId,
        id: id,
        deviceType: deviceType,
        accessToken: token,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!.toEntity();
      }
      return null;
    } catch (e) {
      print('Error in getRealTimeThermalData: $e');
      return null;
    }
  }
}
