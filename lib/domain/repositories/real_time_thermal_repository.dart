import 'package:flutter_camera/domain/model/real_time_thermal_data.dart';

abstract class RealTimeThermalRepository {
  Future<RealTimeThermalDataResponse?> getRealTimeThermalData({
    required int machineId,
    required int id,
    required String deviceType,
  });
}
