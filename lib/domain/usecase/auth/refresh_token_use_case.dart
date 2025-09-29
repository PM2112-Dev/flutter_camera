import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/auth_tokens.dart';
import 'package:flutter_camera/domain/model/refresh_token_request.dart';
import 'package:flutter_camera/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  Future<Either<Failure, AuthTokens>> call(RefreshTokenRequest request) async {
    // Validation
    if (request.accessToken.isEmpty) {
      return const Left(ValidationFailure('Access token cannot be empty'));
    }
    if (request.refreshToken.isEmpty) {
      return const Left(ValidationFailure('Refresh token cannot be empty'));
    }

    // Call repository
    final result = await _repository.refreshToken(request);
    
    // Save new tokens if refresh successful
    return result.fold(
      (failure) => Left(failure),
      (tokens) async {
        final saveResult = await _repository.saveTokens(tokens);
        return saveResult.fold(
          (failure) => Left(failure),
          (_) => Right(tokens),
        );
      },
    );
  }
}
