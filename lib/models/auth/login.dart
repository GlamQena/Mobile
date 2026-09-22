import "package:flutter/material.dart";
import '../entities/user.dart';

class LoginRequestBody {
  final String usernameOrEmail;
  final String password;
  final bool rememberMe;
  final String? sessionId;

  LoginRequestBody({
    required this.usernameOrEmail,
    required this.password,
    this.rememberMe = false,
    this.sessionId
  });

  Map<String, dynamic> toJson() => {
    "usernameOrEmail": usernameOrEmail.trim(),
    "password": password,
    "rememberMe": rememberMe,
    "session_id": sessionId,
  };
}

//for success=true
class LoginResponse {
  final String message;
  final User? user;
  final String accessToken;
  final String refreshToken;
  final int accessTokenExp;
  final int refreshTokenExp;
  final bool cartMerged;

  LoginResponse({
    required this.message,
    this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExp,
    required this.refreshTokenExp,
    required this.cartMerged,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> response) {
    debugPrint('=== PARSING LOGIN RESPONSE ===');
    debugPrint('Full response: $response');

    return LoginResponse(
      message: response['message'] ?? 'Login successful',
      user: User.fromJson(response['user'] as Map<String, dynamic>),
      accessToken: response['accessToken'],
      refreshToken: response['refreshToken'],
      accessTokenExp: response['accessTokenExp'] ?? 900,
      refreshTokenExp: response['refreshTokenExp'] ?? 63072000,
      cartMerged: response['cart_merged'],
    );
  }
}