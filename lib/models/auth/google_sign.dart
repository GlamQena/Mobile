import "package:flutter/material.dart";
import '../entities/user.dart';

class GoogleSignRequestBody {
  final String idToken;
  final String? sessionId;

  GoogleSignRequestBody({
    required this.idToken,
    this.sessionId
  });

  Map<String, String?> toJson() => {
    "idToken": idToken,
    "session_id": sessionId,
  };
}

class GoogleSignResponse {
  final String message;
  final User? user;
  final String accessToken;
  final String refreshToken;
  final int accessTokenExp;
  final int refreshTokenExp;
  final bool cartMerged;

  GoogleSignResponse({
    required this.message,
    this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExp,
    required this.refreshTokenExp,
    required this.cartMerged,
  });

  factory GoogleSignResponse.fromJson(Map<String, dynamic> response) {
    debugPrint('=== PARSING GOOGLE SIGN RESPONSE ===');
    debugPrint('Full response: $response');

    return GoogleSignResponse(
      message: response['message'] ?? 'google signing successful',
      user: User.fromJson(response['user'] as Map<String, dynamic>),
      accessToken: response['accessToken'],
      refreshToken: response['refreshToken'],
      accessTokenExp: response['accessTokenExp'] ?? 900,
      refreshTokenExp: response['refreshTokenExp'] ?? 63072000,
      cartMerged: response['cart_merged'],
    );
  }
}