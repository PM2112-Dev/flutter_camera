import 'package:dartz/dartz.dart';
import '.././model/area_tree.dart';
import '../failures/failures.dart';

abstract class AreaRepository {
  Future<Either<Failure, List<AreaTreeWithCameras>>> getAreaAllTree();
}
