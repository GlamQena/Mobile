import "package:flutter/material.dart";
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile_app/models/auth/verify_email.dart';
import 'package:mobile_app/services/auth/auth_state.dart';

import '../../models/auth/google_sign.dart';
import '../../models/auth/login.dart';
import '../api_client.dart';
import 'secure_storage.dart';
import '../../models/auth/register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService{
  final apiClient = ApiClient();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  SecureStorageService storageService = SecureStorageService();

  Future<String> register(Map<String, dynamic> data) async {
    try {
      debugPrint('=== AUTH SERVICE REGISTER ===');
      debugPrint('Request data: $data');

      Map<String, dynamic> response = await apiClient.publicPost(
          route: "/auth",
          endpoint: "/register",
          data: {...data},
          queryParams: {"platform": "mobile"}
      );
      debugPrint('Response: $response');

      RegisterResponse modeledResponse = RegisterResponse.fromJson(response);
      String? userId;
      if(modeledResponse.user != null){
        userId = modeledResponse.user!.id;
      }
      await storageService.saveTokens(
        accessToken: modeledResponse.accessToken,
        refreshToken: modeledResponse.refreshToken,
        accessTokenExpirySeconds: modeledResponse.accessTokenExp,
        refreshTokenExpirySeconds: modeledResponse.refreshTokenExp,
        userId: userId,
      );

      if ((await secureStorage.read(key: "sessionId") != null) &&
          modeledResponse.cartMerged == true) {
        await secureStorage.delete(key: "sessionId");
      }

      return modeledResponse.message;
    } catch (ex) {
      debugPrint('AuthService.register error: $ex');
      rethrow;
    }
  }

  Future<String> login (Map<String, dynamic> data) async{
    try{
      Map<String, dynamic> response = await apiClient.publicPost(route: "/auth", endpoint: "/login", data: data);
      debugPrint("ℹ️ LOGIN RESPONSE: $response");

      LoginResponse modeledResponse = LoginResponse.fromJson(response);
      String? userId;
      if(modeledResponse.user != null){
        userId = modeledResponse.user!.id;
      }

      await storageService.saveTokens(
        accessToken: modeledResponse.accessToken,
        refreshToken: modeledResponse.refreshToken,
        accessTokenExpirySeconds: modeledResponse.accessTokenExp,
        refreshTokenExpirySeconds: modeledResponse.refreshTokenExp,
        userId: userId,
      );

      return modeledResponse.message;
    }catch(ex){
      rethrow;
    }
  }

  Future<String> googleSign(Map<String, String?> data) async{
    try{
      Map<String, dynamic> response = await apiClient.publicPost(route: "/auth", endpoint: "/google-sign", data: data);
      debugPrint("google sign response: $response");

      GoogleSignResponse modeledResponse = GoogleSignResponse.fromJson(response);
      String? userId;
      if(modeledResponse.user != null){
        userId = modeledResponse.user!.id;
      }

      await storageService.saveTokens(
        accessToken: modeledResponse.accessToken,
        refreshToken: modeledResponse.refreshToken,
        accessTokenExpirySeconds: modeledResponse.accessTokenExp,
        refreshTokenExpirySeconds: modeledResponse.refreshTokenExp,
        userId: userId,
      );

      return modeledResponse.message;
    }catch(ex){
      rethrow;
    }
  }

  Future<String> emailVerificationRequest (String? email) async{
    try{
      Map<String, dynamic> response = await apiClient.publicPost(route: "/auth", endpoint: "/email/send-token", data: {"email": email}, queryParams: {"platform": "mobile"});
      return response['message'] ?? 'verify_email_resend_success'.tr();
    }catch(ex){
      rethrow;
    }
  }

  Future<String> verifyEmailLink ({required String? email, required String? token}) async{
    try{
      Map<String, dynamic> response = await apiClient.publicGet("/auth", "/verify/$email/$token", queryParams: {"platform": "mobile"});
      debugPrint("VERIFY EMAIL RESPONSE: $response");

      VerifyEmailResponse modeledResponse = VerifyEmailResponse.fromJson(response);
      String? userId;
      if(modeledResponse.user != null){
        userId = modeledResponse.user!.id;
      }
      await storageService.saveTokens(
        accessToken: modeledResponse.accessToken,
        refreshToken: modeledResponse.refreshToken,
        accessTokenExpirySeconds: modeledResponse.accessTokenExp,
        refreshTokenExpirySeconds: modeledResponse.refreshTokenExp,
        userId: userId,
      );

      return modeledResponse.message;
    }catch(ex){
      rethrow;
    }
  }

  Future<String> logout () async{
    try{
      String? sessionId = await secureStorage.read(key: "sessionId");
      final Map<String, String>? queryParams =
      (sessionId != null && sessionId.isNotEmpty)
          ? {'session_id': sessionId}
          : null;
      Map<String, dynamic> response = await apiClient.publicDelete("/auth", "/logout", queryParams: queryParams);
      storageService.clearTokens();
      AuthState.setLoggedOut();
      await secureStorage.delete(key: "sessionId");
      return response['message'] ?? 'logout_success'.tr();

    }catch(ex){
      // Even if API fails, clear local data to avoid inconsistent state
      try {
        await storageService.clearTokens();
        await secureStorage.delete(key: "sessionId");
      } catch (_) {
        // Ignore clearing errors
      }
      rethrow;
    }
  }
}