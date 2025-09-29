import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/auth_tokens.dart';
import 'package:flutter_camera/domain/model/login_request.dart';
import 'package:flutter_camera/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, AuthTokens>> call(LoginRequest request) async {
    // Validation
    if (request.username.isEmpty) {
      return const Left(ValidationFailure('Username cannot be empty'));
    }
    if (request.password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }

    // Call repository
    final result = await _repository.login(request);
    
    // Save tokens if login successful
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