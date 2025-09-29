import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class ProfileRequested extends AuthEvent {
  const ProfileRequested();
}

class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

class RefreshTokenRequested extends AuthEvent {
  const RefreshTokenRequested();
}
