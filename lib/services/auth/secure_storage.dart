import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:flutter/material.dart";
import '../../models/auth/tokens.dart';

class SecureStorageService{
  static const String _accessTokenKey = "access_token";
  static const String _refreshTokenKey = "refresh_token";
  static const String _accessTokenExpiryKey = "access_token_expiry";
  static const String _refreshTokenExpiryKey = "refresh_token_expiry";
  static const String _userIdKey = "user_id";

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpirySeconds,
    required int refreshTokenExpirySeconds,
    String? userId
  }) async{
    final now = DateTime.now();

    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _accessTokenExpiryKey, value: now.add(Duration(seconds: accessTokenExpirySeconds)).toIso8601String());
    await _storage.write(key: _refreshTokenExpiryKey, value: now.add(Duration(seconds: refreshTokenExpirySeconds)).toIso8601String());

    if(userId != null){
      await _storage.write(key: _userIdKey, value: userId);
    }
    debugPrint("ℹ️ auth tokens stored successfully in the secure storage");
  }

  Future<TokenInfo?> getTokenInfo() async{
    try{
      final String? accessToken = await _storage.read(key: _accessTokenKey);
      final String? refreshToken = await _storage.read(key: _refreshTokenKey);
      final String? accessTokenExpiryStr = await _storage.read(key: _accessTokenExpiryKey);
      final String? refreshTokenExpiryStr = await _storage.read(key: _refreshTokenExpiryKey);

      TokenInfo tokenInfo = TokenInfo(
          accessToken: accessToken,
          refreshToken: refreshToken,
          accessTokenExpiry: DateTime.parse(accessTokenExpiryStr!),
          refreshTokenExpiry: DateTime.parse(refreshTokenExpiryStr!)
      );

      if(tokenInfo.needsLogin){
        return null;
      }

      return tokenInfo;
    }catch(ex){ //exception in parsing the expiry dates or creating the tokenInfo object
      return null;
    }
  }

  Future<String?> getAccessToken() async{
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async{
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getUserId () async{
    return await _storage.read(key: _userIdKey);
  }

  Future<bool> isLoggedIn() async{
    final tokens = await getTokenInfo();
    if(tokens == null){
      return false;
    }
    return tokens.isRefreshTokenValid;
  }

  Future<void> clearTokens() async{
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessTokenExpiryKey);
    await _storage.delete(key: _refreshTokenExpiryKey);
    await _storage.delete(key: _userIdKey);
  }
}
