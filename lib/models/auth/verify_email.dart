import "package:flutter/material.dart";
import '../entities/user.dart';

class VerifyEmailResponse {
  final String message;
  final User? user;
  final String accessToken;
  final String refreshToken;
  final int accessTokenExp;
  final int refreshTokenExp;

  VerifyEmailResponse({
    required this.message,
    this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExp,
    required this.refreshTokenExp
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> response) {
    debugPrint('=== PARSING VERIFY EMAIL RESPONSE ===');
    debugPrint('Full response: $response');

    User? user;
    String? accessToken;
    String? refreshToken;
    int? accessTokenExp;
    int? refreshTokenExp;

    if (response.containsKey('authData') && response['authData'] != null) {
      final authData = response['authData'] as Map<String, dynamic>;

      if (authData.containsKey('user') && authData['user'] != null) {
        user = User.fromJson(authData['user'] as Map<String, dynamic>);
      }

      if (authData.containsKey('accessToken')) {
        accessToken = authData['accessToken'];
      }

      if (authData.containsKey('refreshToken')) {
        refreshToken = authData['refreshToken'];
      }

      if (authData.containsKey('refreshTokenExp')) {
        refreshTokenExp = authData['refreshTokenExp'];
      }

      if (authData.containsKey('accessTokenExp')) {
        accessTokenExp = authData['accessTokenExp'];
      }
    }

    // Fallback: try to get user directly (for backward compatibility)
    if (user == null && response.containsKey('user')) {
      user = User.fromJson(response['user'] as Map<String, dynamic>);
    }

    // Fallback: try to get tokens directly
    if (accessToken == null && response.containsKey('accessToken')) {
      accessToken = response['accessToken'];
    }

    if (refreshToken == null && response.containsKey('refreshToken')) {
      refreshToken = response['refreshToken'];
    }

    if (refreshTokenExp == null && response.containsKey('refreshTokenExp')) {
      refreshTokenExp = response['refreshTokenExp'];
    }

    if (accessTokenExp == null && response.containsKey('accessTokenExp')) {
      accessTokenExp = response['accessTokenExp'];
    }

    return VerifyEmailResponse(
      message: response['message'] ?? 'Verification successful',
      user: user,
      accessToken: accessToken!,
      refreshToken: refreshToken!,
      accessTokenExp: accessTokenExp ?? 900,
      refreshTokenExp: refreshTokenExp ?? 63072000
    );
  }
}