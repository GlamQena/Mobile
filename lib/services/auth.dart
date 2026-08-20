import 'package:easy_localization/easy_localization.dart';

import './api_client.dart';
import './secure_storage.dart';
import '../models/register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService{
  final apiClient = ApiClient();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  SecureStorageService storageService = SecureStorageService();

  Future<String> register(Map<String, dynamic> data) async{
    try{
      Map<String, dynamic> response = await apiClient.publicPost(route: "/auth", endpoint: "/register", data: data);
      RegisterResponse modeledResponse = RegisterResponse.fromJson(response);

      storageService.saveTokens(
        accessToken: modeledResponse.accessToken,
        refreshToken: modeledResponse.refreshToken,
        accessTokenExpirySeconds: 900,
        refreshTokenExpirySeconds: 604800,
        userId: modeledResponse.user.id,
      );

      if((await secureStorage.read(key: "session_id") != null) && modeledResponse.cartMerged == true){
        await secureStorage.delete(key: "session_id");
      }

      return response['message'] ?? 'register_success_default'.tr();
    }catch(ex){
      rethrow;
    }
  }

  Future<String> emailVerificationRequest (String email) async{
    try{
      Map<String, dynamic> response = await apiClient.publicPost(route: "/auth", endpoint: "/email/send-token", data: {"email": email}, queryParams: {"platform": "mobile"});
      return response['message'] ?? 'verify_email_resend_success'.tr();
    }catch(ex){
      rethrow;
    }
  }

  Future<String> verifyEmailLink ({required String email, required String token}) async{
    try{
      Map<String, dynamic> response = await apiClient.publicGet("/auth", "/verify/$email/$token");
      return response['message'] ?? 'verify_email_success_title'.tr();
    }catch(ex){
      rethrow;
    }
  }

  Future<String> logout () async{
    try{
      String? sessionId = await secureStorage.read(key: "session_id");
      final Map<String, String>? queryParams =
      (sessionId != null && sessionId.isNotEmpty)
          ? {'session_id': sessionId}
          : null;
      Map<String, dynamic> response = await apiClient.publicGet("/auth", "/logout", queryParams: queryParams);
      storageService.clearTokens();
      await secureStorage.delete(key: "session_id");
      return response['message'] ?? 'logout_success'.tr();

    }catch(ex){
      // Even if API fails, clear local data to avoid inconsistent state
      try {
        await storageService.clearTokens();
        await secureStorage.delete(key: "session_id");
      } catch (_) {
        // Ignore clearing errors
      }
      rethrow;
    }
  }
}