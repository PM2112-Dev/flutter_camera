import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/area_map.dart';
import 'package:flutter_camera/domain/repositories/area_map_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAreaMapUseCase {
  final AreaMapRepository repository;

  GetAreaMapUseCase(this.repository);

  Future<Either<Failure, AreaMapResponse>> call() {
    return repository.getMachinesAndResultByArea();
  }
}
