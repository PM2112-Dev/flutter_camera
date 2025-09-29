import 'package:flutter_camera/data/network/model/auth_tokens_model.dart';
import 'package:flutter_camera/data/network/model/user_response.dart';

class LoginResponse {
  final UserResponse user;
  final String token;
  final String refreshToken;
  final String refreshTokenExpiryTime;

  const LoginResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
    required this.refreshTokenExpiryTime,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiryTime: json['refreshTokenExpiryTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'refreshToken': refreshToken,
      'refreshTokenExpiryTime': refreshTokenExpiryTime,
    };
  }
}

extension LoginResponseExtension on LoginResponse {
  AuthTokensModel toAuthTokens() {
    return AuthTokensModel(
      accessToken: token,
      refreshToken: refreshToken,
      tokenType: 'Bearer',
      expiresIn: 0, // We'll calculate this from refreshTokenExpiryTime if needed
    );
  }
}
