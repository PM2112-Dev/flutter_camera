import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    // Call logout API FIRST (while we still have tokens)
    final logoutResult = await _repository.logout();

    // Clear local tokens AFTER API call
    // (regardless of API result - even if API fails, we still want to clear local tokens)
    final clearResult = await _repository.clearTokens();

    // If logout API failed, return that error
    if (logoutResult.isLeft()) {
      return logoutResult;
    }

    // If clear failed, return that error
    if (clearResult.isLeft()) {
      return clearResult;
    }

    return const Right(null);
  }
}
