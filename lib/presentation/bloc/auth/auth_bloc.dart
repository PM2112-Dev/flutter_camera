import 'package:bloc/bloc.dart';
import 'package:flutter_camera/domain/model/login_request.dart';
import 'package:flutter_camera/domain/usecase/auth/get_profile_use_case.dart';
import 'package:flutter_camera/domain/usecase/auth/get_stored_tokens_usecase.dart';
import 'package:flutter_camera/domain/usecase/auth/login_use_case.dart';
import 'package:flutter_camera/domain/usecase/auth/logout_use_case.dart';
import 'package:flutter_camera/data/services/firebase_messaging_service.dart';
import 'package:injectable/injectable.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final GetStoredTokensUseCase _getStoredTokensUseCase;
  final FirebaseMessagingService _firebaseMessagingService;

  AuthBloc(
    this._loginUseCase,
    this._logoutUseCase,
    this._getProfileUseCase,
    this._getStoredTokensUseCase,
    this._firebaseMessagingService,
  ) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ProfileRequested>(_onProfileRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      print('🔐 Attempting login with username: ${event.username}');
      final result = await _loginUseCase(
        LoginRequest(username: event.username, password: event.password),
      );

      result.fold(
        (failure) {
          print('❌ Login failed: ${failure.toString()}');
          print('❌ Failure type: ${failure.runtimeType}');
          emit(AuthError(message: failure.toString()));
        },
        (tokens) {
          print('✅ Login successful, tokens saved automatically');
          // After login success (tokens already saved), get user profile
          add(const ProfileRequested());
        },
      );
    } catch (e) {
      print('❌ Login exception: $e');
      emit(AuthError(message: 'Login failed: $e'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      // LogoutUseCase will handle clearing tokens and API call
      final result = await _logoutUseCase();

      result.fold(
        (failure) {
          print('Logout failed: ${failure.toString()}');
          emit(AuthError(message: failure.toString()));
        },
        (_) {
          print('Logout successful');
          // Unregister FCM token when logging out
          _firebaseMessagingService.unregisterToken();
          emit(const AuthUnauthenticated());
        },
      );
    } catch (e) {
      print('Logout exception: $e');
      emit(AuthError(message: 'Logout failed: $e'));
    }
  }

  Future<void> _onProfileRequested(ProfileRequested event, Emitter<AuthState> emit) async {
    try {
      print('Getting profile...');
      final result = await _getProfileUseCase();

      result.fold(
        (failure) {
          print('Profile failed: ${failure.toString()}');
          emit(AuthError(message: failure.toString()));
        },
        (user) {
          print('Profile successful: ${user.username}');
          // Register FCM token for the authenticated user
          _firebaseMessagingService.registerTokenForNewUser(user);
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e) {
      print('Profile exception: $e');
      emit(AuthError(message: 'Profile failed: $e'));
    }
  }

  Future<void> _onAuthStatusChecked(AuthStatusChecked event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      print('🔍 Checking auth status...');

      // Check if user has stored tokens using UseCase
      final tokensResult = await _getStoredTokensUseCase();

      tokensResult.fold(
        (failure) {
          print('❌ No stored tokens: ${failure.toString()}');
          print('🧹 Firebase: Clearing current user');
          // Clear FCM user info when no stored tokens
          _firebaseMessagingService.clearCurrentUser();
          emit(const AuthUnauthenticated());
        },
        (tokens) {
          if (tokens != null && tokens.accessToken.isNotEmpty) {
            print('✅ Found stored tokens, getting profile...');
            // User has tokens, get profile to verify
            add(const ProfileRequested());
          } else {
            print('❌ No valid tokens found');
            print('🧹 Firebase: Clearing current user');
            // Clear FCM user info when no valid tokens
            _firebaseMessagingService.clearCurrentUser();
            emit(const AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      print('Auth status check exception: $e');
      // Clear FCM user info on exception
      _firebaseMessagingService.clearCurrentUser();
      emit(const AuthUnauthenticated());
    }
  }
}
