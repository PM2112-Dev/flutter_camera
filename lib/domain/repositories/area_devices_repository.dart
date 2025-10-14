import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/area_devices.dart';

abstract class AreaDevicesRepository {
  Future<Either<Failure, AreaDevicesResponse>> getMachinesAndResultByArea(int areaId);
}
