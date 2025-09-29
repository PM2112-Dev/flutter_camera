import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/auth_tokens.dart';
import 'package:flutter_camera/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetStoredTokensUseCase {
  final AuthRepository _authRepository;

  GetStoredTokensUseCase(this._authRepository);

  Future<Either<Failure, AuthTokens?>> call() async {
    return await _authRepository.getStoredTokens();
  }
}
