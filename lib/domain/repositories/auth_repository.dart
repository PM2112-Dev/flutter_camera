import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/auth_tokens.dart';
import 'package:flutter_camera/domain/model/login_request.dart';
import 'package:flutter_camera/domain/model/refresh_token_request.dart';
import 'package:flutter_camera/domain/model/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthTokens>> login(LoginRequest request);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthTokens>> refreshToken(RefreshTokenRequest request);
  Future<Either<Failure, User>> getProfile();
  
  // Local storage methods
  Future<Either<Failure, void>> saveTokens(AuthTokens tokens);
  Future<Either<Failure, AuthTokens?>> getStoredTokens();
  Future<Either<Failure, void>> clearTokens();
  Future<Either<Failure, bool>> isLoggedIn();
}