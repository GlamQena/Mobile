import './api_client.dart';
import './secure_storage.dart';
import '../models/register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService{
  final apiClient = ApiClient();

  Future<String> register(Map<String, dynamic> data) async{
    try{
      Map<String, dynamic> response = await apiClient.publicPost("auth", "register", data);
      RegisterResponse modeledResponse = RegisterResponse.fromJson(response);

      SecureStorageService storageService = SecureStorageService();
      storageService.saveTokens(
        accessToken: modeledResponse.accessToken,
        refreshToken: modeledResponse.refreshToken,
        accessTokenExpirySeconds: 900,
        refreshTokenExpirySeconds: 604800,
        userId: modeledResponse.user.id,
      );

      FlutterSecureStorage secureStorage = FlutterSecureStorage();
      if((await secureStorage.read(key: "session_id") != null) && modeledResponse.cartMerged == true){
        await secureStorage.delete(key: "session_id");
      }

      return apiClient.extractResponseMessage(modeledResponse.toString());
    }catch(ex){
      rethrow;
    }
  }
}