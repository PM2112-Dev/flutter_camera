import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CheckAuthStatusUseCase {
  final AuthRepository _authRepository;

  CheckAuthStatusUseCase(this._authRepository);

  Future<Either<Failure, bool>> call() async {
    return await _authRepository.isLoggedIn();
  }
}
