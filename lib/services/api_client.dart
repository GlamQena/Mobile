import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/auth/tokens.dart';
import 'auth/secure_storage.dart';

class ApiClient {
  final String baseUrl = AppConfig.apiUrl;
  http.Client httpClient = http.Client();
  final SecureStorageService _storage = SecureStorageService();

  // ============ PUBLIC METHODS ============
  Future<Map<String, dynamic>> publicPost({
    required String route,
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, String>? queryParams
  }) async {
    String queryString = queryParams != null
        ? queryParams.entries.map((entry) => "${entry.key}=${entry.value}").toList().join("&")
        : "";
    final response = await httpClient.post(
      Uri.parse("$baseUrl$route$endpoint${queryString.isNotEmpty ? '?$queryString' : ''}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> publicGet(
      String route,
      String endpoint, {
        Map<String, String?>? queryParams,
      }) async {
    String queryString = queryParams != null
        ? queryParams.entries.map((entry) => "${entry.key}=${entry.value}").toList().join("&")
        : "";
    final response = await httpClient.get(
      Uri.parse("$baseUrl$route$endpoint${queryString.isNotEmpty ? '?$queryString' : ''}"),
      headers: {"Content-Type": "application/json"},
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> publicPut({
    required String route,
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, String>? queryParams,
  }) async {
    String queryString = queryParams != null
        ? queryParams.entries.map((entry) => "${entry.key}=${entry.value}").toList().join("&")
        : "";
    final response = await httpClient.put(
      Uri.parse("$baseUrl$route$endpoint${queryString.isNotEmpty ? '?$queryString' : ''}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> publicDelete(
      String route,
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    String queryString = queryParams != null
        ? queryParams.entries.map((entry) => "${entry.key}=${entry.value}").toList().join("&")
        : "";
    final response = await httpClient.delete(
      Uri.parse("$baseUrl$route$endpoint${queryString.isNotEmpty ? '?$queryString' : ''}"),
      headers: {"Content-Type": "application/json"},
    );
    return _parseResponse(response);
  }


  // ============ PRIVATE METHODS (With Token) ============
  Future<Map<String, dynamic>> privatePost({
    required String route,
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, String>? queryParams,
  }) async {
    final tokenInfo = await _getValidToken();
    if (tokenInfo == null) {
      throw Exception('Session expired. Please login again.');
    }
    return await _makeAuthenticatedRequest(
      method: 'POST',
      route: route,
      endpoint: endpoint,
      data: data,
      token: tokenInfo.accessToken,
      queryParams: queryParams,
    );
  }

  Future<Map<String, dynamic>> privateGet(
      String route,
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    final tokenInfo = await _getValidToken();
    if (tokenInfo == null) {
      throw Exception('Session expired. Please login again.');
    }
    return await _makeAuthenticatedRequest(
      method: 'GET',
      route: route,
      endpoint: endpoint,
      token: tokenInfo.accessToken,
      queryParams: queryParams,
    );
  }

  Future<Map<String, dynamic>> privatePut({
    required String route,
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, String>? queryParams,
  }) async {
    final tokenInfo = await _getValidToken();
    if (tokenInfo == null) {
      throw Exception('Session expired. Please login again.');
    }
    return await _makeAuthenticatedRequest(
      method: 'PUT',
      route: route,
      endpoint: endpoint,
      data: data,
      token: tokenInfo.accessToken,
      queryParams: queryParams,
    );
  }

  Future<Map<String, dynamic>> privateDelete(
      String route,
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    final tokenInfo = await _getValidToken();
    if (tokenInfo == null) {
      throw Exception('Session expired. Please login again.');
    }
    return await _makeAuthenticatedRequest(
      method: 'DELETE',
      route: route,
      endpoint: endpoint,
      token: tokenInfo.accessToken,
      queryParams: queryParams,
    );
  }


  // ============ HELPER METHODS ============
  Future<TokenInfo?> _getValidToken() async {
    final tokenInfo = await _storage.getTokenInfo();

    if (tokenInfo == null) {
      return null;
    }

    // Check if access token needs refresh
    if (tokenInfo.needsRefresh) {
      final newTokenInfo = await refreshToken(tokenInfo.refreshToken!);
      if (newTokenInfo == null) {
        return null;
      }
      return newTokenInfo;
    }

    return tokenInfo;
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
          accessTokenExpirySeconds: data['expires_in'] ?? 900,
          refreshTokenExpirySeconds: 604800,
        );
        return await _storage.getTokenInfo();
      } else if (response.statusCode == 401) {
        await _storage.clearTokens();
        throw Exception('Session expired. Please login again.');
      }
      return null;
    } catch (e) {
      await _storage.clearTokens();
      throw Exception('Session expired. Please login again.');
    }
  }

  // Generic authenticated request (handles all HTTP methods)
  Future<Map<String, dynamic>> _makeAuthenticatedRequest({
    required String method,
    required String route,
    required String endpoint,
    String? token,
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
  }) async {
    String queryString = queryParams != null
        ? queryParams.entries.map((entry) => "${entry.key}=${entry.value}").toList().join("&")
        : "";

    final url = Uri.parse("$baseUrl$route$endpoint${queryString.isNotEmpty ? '?$queryString' : ''}");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await httpClient.get(url, headers: headers);
        break;
      case 'POST':
        response = await httpClient.post(
          url,
          headers: headers,
          body: jsonEncode(data),
        );
        break;
      case 'PUT':
        response = await httpClient.put(
          url,
          headers: headers,
          body: jsonEncode(data),
        );
        break;
      case 'DELETE':
        response = await httpClient.delete(url, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

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

  //extract exception messages from stringified json response and raw String exception
  String extractResponseMessage(String res) {
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
    } catch (e) {
      // Not JSON, continue
    }

    return res
        .replaceAll('Exception: ', '')
        .replaceAll('API Error: ', '')
        .replaceAll('Unauthorized: ', '')
        .replaceAll(RegExp(r'\d{3} - '), '');
  }
}