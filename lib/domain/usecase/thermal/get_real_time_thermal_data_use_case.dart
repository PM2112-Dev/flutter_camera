import 'package:flutter_camera/domain/model/real_time_thermal_data.dart';
import 'package:flutter_camera/domain/repositories/real_time_thermal_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetRealTimeThermalDataUseCase {
  final RealTimeThermalRepository _repository;

  GetRealTimeThermalDataUseCase(this._repository);

  Future<RealTimeThermalDataResponse?> execute({
    required int machineId,
    required int id,
    required String deviceType,
  }) async {
    return await _repository.getRealTimeThermalData(
      machineId: machineId,
      id: id,
      deviceType: deviceType,
    );
  }
}
