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

    // Priority: Local token clearing is more important than server logout
    // If token clearing succeeds, consider logout successful even if API failed
    if (clearResult.isRight()) {
      // Local tokens cleared successfully
      if (logoutResult.isLeft()) {
        print('⚠️ Logout API failed but local tokens cleared successfully');
      }
      return const Right(null);
    }

    // If token clearing failed, return that error (this is critical)
    if (clearResult.isLeft()) {
      return clearResult;
    }

    // If both succeeded, return success
    return const Right(null);
  }
}
