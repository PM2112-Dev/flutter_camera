import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/area_devices.dart';
import 'package:flutter_camera/domain/repositories/area_devices_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAreaDevicesUseCase {
  final AreaDevicesRepository repository;

  GetAreaDevicesUseCase(this.repository);

  Future<Either<Failure, AreaDevicesResponse>> call(int areaId) {
    return repository.getMachinesAndResultByArea(areaId);
  }
}
