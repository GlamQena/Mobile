// services/api_client.dart
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../models/tokens.dart';
import './secure_storage.dart';

class ApiClient {
  final String baseUrl = "http://127.0.0.1:8080";
  http.Client httpClient = http.Client();
  final SecureStorageService _storage = SecureStorageService();

  // Public request (no token needed)
  Future<Map<String, dynamic>> publicPost(String route, String endpoint, Map<String, dynamic> data) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl$route$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return _parseResponse(response);
  }

  // Private request with token (auto-refresh if needed)
  Future<Map<String, dynamic>> privatePost(String route, String endpoint, Map<String, dynamic> data) async {
    final tokenInfo = await _storage.getTokenInfo();

    if (tokenInfo == null) {
      throw Exception('No tokens found. Please login.');
    }

    // Check if access token needs refresh
    if (tokenInfo.needsRefresh) {
      final newTokenInfo = await refreshToken(tokenInfo.refreshToken);
      if (newTokenInfo == null) {
        throw Exception('Session expired. Please login again.');
      }

      return await _makeAuthenticatedRequest(
        route,
        endpoint,
        data,
        newTokenInfo.accessToken,
      );
    }

    // Use existing valid token
    return await _makeAuthenticatedRequest(
      route,
      endpoint,
      data,
      tokenInfo.accessToken,
    );
  }

  Future<Map<String, dynamic>> privateGet(String route, String endpoint) async {
    final tokenInfo = await _storage.getTokenInfo();

    if (tokenInfo == null) {
      throw Exception('No tokens found. Please login.');
    }

    if (tokenInfo.needsRefresh) {
      final newTokenInfo = await refreshToken(tokenInfo.refreshToken);
      if (newTokenInfo == null) {
        throw Exception('Session expired. Please login again.');
      }
      return await _makeAuthenticatedGetRequest(route, endpoint, newTokenInfo.accessToken);
    }

    return await _makeAuthenticatedGetRequest(route, endpoint, tokenInfo.accessToken);
  }

  Future<TokenInfo?> refreshToken(String refreshToken) async {
    try {
      final response = await httpClient.get(
        Uri.parse("$baseUrl/auth/refresh-token"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $refreshToken",
        }
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'] ?? refreshToken,
          accessTokenExpirySeconds: data['expires_in'] ?? 900, //default 15 minutes
          refreshTokenExpirySeconds: 604800, // 7 days
        );
        return await _storage.getTokenInfo();
      } else if (response.statusCode == 401) {
        // Refresh token expired
        await _storage.clearTokens();
        throw Exception('Session expired. Please login again.');
      }
      return null;
    } catch (e) {
      await _storage.clearTokens();
      throw Exception('Session expired. Please login again.');
    }
  }

  // Authenticated POST request
  Future<Map<String, dynamic>> _makeAuthenticatedRequest(
      String route,
      String endpoint,
      Map<String, dynamic> data,
      String token,
      ) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl$route$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> _makeAuthenticatedGetRequest(
      String route,
      String endpoint,
      String token,
      ) async {
    final response = await httpClient.get(
      Uri.parse("$baseUrl$route$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token expired or invalid');
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }


  // consider the String parameter to include the Exception String thrown from the manual try-catch block
  String extractResponseMessage(String res) {
    // Try to extract JSON res message
    try {
      final start = res.indexOf('{');
      final end = res.lastIndexOf('}');
      if (start != -1 && end != -1) {
        final jsonStr = res.substring(start, end + 1);
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        if (json.containsKey('message')) {
          return json['message'];
        }
        if (json.containsKey('error')) {
          return json['error'];
        }
      }
    } catch (e) { //catch exception while trying to decode the jsonStr
      // Not JSON, continue
    }

    // If no JSON found, clean the error res raw string
    return res
        .replaceAll('Exception: ', '')
        .replaceAll('API Error: ', '')
        .replaceAll('Unauthorized: ', '')
        .replaceAll(RegExp(r'\d{3} - '), ''); //remove the status code from the "API Error" exception
  }
}

class ApiResult{
  final bool isSuccess;
  final String message;
  final String localizedKey;

  ApiResult({required this.isSuccess, required this.message, required this.localizedKey});

  factory ApiResult.success({required String message, required String localizedKey}){
    return ApiResult(isSuccess: true, message: message, localizedKey: localizedKey);
  }

  factory ApiResult.error({required String message, required String localizedKey}){
    return ApiResult(isSuccess: false, message: message, localizedKey: localizedKey);
  }

  String get getLocalizedMessage => localizedKey.tr() ?? message;
}