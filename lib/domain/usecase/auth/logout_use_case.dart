import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    // Clear local tokens first
    final clearResult = await _repository.clearTokens();
    if (clearResult.isLeft()) {
      return clearResult;
    }

    // Call logout API
    return await _repository.logout();
  }
}