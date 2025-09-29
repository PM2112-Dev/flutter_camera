import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/user.dart';
import 'package:flutter_camera/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetProfileUseCase {
  final AuthRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, User>> call() async {
    return await _repository.getProfile();
  }
}