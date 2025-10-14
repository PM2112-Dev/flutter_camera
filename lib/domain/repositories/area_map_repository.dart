import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/area_map.dart';

abstract class AreaMapRepository {
  Future<Either<Failure, AreaMapResponse>> getMachinesAndResultByArea();
}
