import "package:flutter/material.dart";
import '../entities/user.dart';

class RegisterRequestBody {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final String birthdate; // "YYYY-MM-DD" or ""
  final String gender;
  final String role;
  final Map<String, String> address;
  final String? sessionId;

  RegisterRequestBody({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
    required this.birthdate,
    required this.gender,
    required this.role,
    required this.address,
    this.sessionId
  });

  Map<String, dynamic> toJson() => {
    "username": username,
    "email": email,
    "password": password,
    "confirmPassword": confirmPassword,
    "phoneNumber": phoneNumber,
    "birthdate": birthdate,
    "gender": gender,
    "role": role,
    "address": address,
    "session_id": sessionId
  };

  // Named constructor for creating from form data
   factory RegisterRequestBody.fromForm({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String phoneNumber = "",
    String birthdate = "",
    String gender = "female",
    String city = "",
    String district = "",
    String street = "",
    String role = "client",
    String? sessionId
  }) {

    final address = Address(
      city: city.trim(),
      district: district.trim(),
      street: street.trim(),
    );
    
    return RegisterRequestBody(
      username: username.trim(),
      email: email.trim(),
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber.trim(),
      birthdate: birthdate.trim(),
      gender: gender,
      role: role,
      address: address.toMap(),
      sessionId: sessionId
    );
  }
}

class RegisterResponse {
  final String message;
  final User? user;
  final String accessToken;
  final String refreshToken;
  final int accessTokenExp;
  final int refreshTokenExp;
  final bool? cartMerged;

  RegisterResponse({
    required this.message,
    this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExp,
    required this.refreshTokenExp,
    this.cartMerged
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> response) {
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

    return RegisterResponse(
      message: response['message'] ?? 'Registration successful',
      user: user,
      accessToken: accessToken!,
      refreshToken: refreshToken!,
      accessTokenExp: accessTokenExp ?? 900,
      refreshTokenExp: refreshTokenExp ?? 63072000,
      cartMerged: response["cart_merged"]
    );
  }
}