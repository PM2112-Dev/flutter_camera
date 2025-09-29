import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/area_tree.dart';
import 'package:flutter_camera/domain/repositories/area_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAllTreeUseCase {
  final AreaRepository repository;

  GetAllTreeUseCase(this.repository);

  Future<Either<Failure, List<AreaTreeWithCameras>>> call() {
    return repository.getAreaAllTree();
  }
}