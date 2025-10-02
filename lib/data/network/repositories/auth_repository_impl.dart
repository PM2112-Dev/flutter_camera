import 'package:dartz/dartz.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/local/preference/selected_cameras_preference.dart';
import 'package:flutter_camera/data/local/preference/pin_camera_preference.dart';
import 'package:flutter_camera/data/network/api/auth_api_service.dart';
import 'package:flutter_camera/data/network/model/auth_tokens_model.dart';
import 'package:flutter_camera/data/network/model/login_response.dart';
import 'package:flutter_camera/data/network/model/user_response.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/auth_tokens.dart';
import 'package:flutter_camera/domain/model/login_request.dart';
import 'package:flutter_camera/domain/model/refresh_token_request.dart';
import 'package:flutter_camera/domain/model/user.dart';
import 'package:flutter_camera/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final AuthLocalPreference _localPreference;
  final SelectedCamerasPreference _selectedCamerasPreference;
  final PinCameraPreference _pinCameraPreference;

  AuthRepositoryImpl(
    this._apiService,
    this._localPreference,
    this._selectedCamerasPreference,
    this._pinCameraPreference,
  );

  @override
  Future<Either<Failure, AuthTokens>> login(LoginRequest request) async {
    try {
      final response = await _apiService.login(
        username: request.username,
        password: request.password,
      );

      if (response.isSuccess && response.data != null) {
        // Convert LoginResponse to AuthTokens
        final authTokens = response.data!.toAuthTokens();
        return Right(authTokens.toEntity());
      } else {
        return Left(ServerFailure(message: response.message ?? 'Login failed'));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final response = await _apiService.logout();

      if (response.isSuccess) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: response.message ?? 'Logout failed'));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _apiService.refreshToken(
        accessToken: request.accessToken,
        refreshToken: request.refreshToken,
      );

      if (response.isSuccess && response.data != null) {
        return Right(response.data!.toEntity());
      } else {
        return Left(ServerFailure(message: response.message ?? 'Token refresh failed'));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      // Get stored tokens first
      final tokens = _localPreference.getTokens();
      final accessToken = tokens?.accessToken;

      print(
        'Getting profile with accessToken: ${accessToken?.isNotEmpty == true ? '${accessToken!.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...' : 'null or empty'}',
      );

      final response = await _apiService.getProfile(accessToken: accessToken);

      if (response.isSuccess && response.data != null) {
        return Right(response.data!.toEntity());
      } else {
        return Left(ServerFailure(message: response.message ?? 'Failed to get profile'));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTokens(AuthTokens tokens) async {
    try {
      print(
        'Saving tokens: ${tokens.accessToken.substring(0, tokens.accessToken.length > 20 ? 20 : tokens.accessToken.length)}...',
      );
      await _localPreference.saveTokens(AuthTokensModelExtension.fromEntity(tokens));
      print('Tokens saved successfully');
      return const Right(null);
    } catch (e) {
      print('Failed to save tokens: $e');
      return Left(CacheFailure('Failed to save tokens: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthTokens?>> getStoredTokens() async {
    try {
      final tokens = _localPreference.getTokens();
      print(
        'Retrieved tokens: ${tokens?.accessToken != null ? '${tokens!.accessToken.substring(0, tokens.accessToken.length > 20 ? 20 : tokens.accessToken.length)}...' : 'null'}',
      );
      return Right(tokens?.toEntity());
    } catch (e) {
      print('Failed to get stored tokens: $e');
      return Left(CacheFailure('Failed to get stored tokens: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearTokens() async {
    try {
      print('🧹 Clearing all user data on logout...');

      // Clear authentication tokens
      await _localPreference.clearTokens();
      print('✅ Cleared auth tokens');

      // Clear selected cameras
      await _selectedCamerasPreference.clearSelectedCameras();
      print('✅ Cleared selected cameras');

      // Clear pinned cameras
      await _pinCameraPreference.clearAllPinnedCameras();
      print('✅ Cleared pinned cameras');

      return const Right(null);
    } catch (e) {
      print('❌ Failed to clear data: $e');
      return Left(CacheFailure('Failed to clear tokens: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      return Right(_localPreference.isLoggedIn());
    } catch (e) {
      return Left(CacheFailure('Failed to check login status: $e'));
    }
  }
}
