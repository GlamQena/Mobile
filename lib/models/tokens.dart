import 'package:flutter/material.dart';

class TokenInfo{
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiry;
  final DateTime refreshTokenExpiry;

  TokenInfo({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry
  });

  bool get isAccessTokenValid => DateTime.now().isBefore(accessTokenExpiry);
  bool get isRefreshTokenValid => DateTime.now().isBefore(refreshTokenExpiry);
  bool get needsRefresh => !isAccessTokenValid && isRefreshTokenValid;
}

