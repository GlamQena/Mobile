import './user.dart';
import './user.dart';

class RegisterRequestBody {
  // Required fields
  final String username;
  final String email;
  final String password;

  // Optional fields with defaults (nulls)
  final String role;
  final String? phoneNumber;
  final String? birthdate;
  final String? gender;
  final Address? address;

  RegisterRequestBody({
    required this.username,
    required this.email,
    required this.password,
    this.role = 'client',
    this.phoneNumber,
    this.birthdate,
    this.gender,
    this.address,
  });

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'username': username,
      'email': email,
      'password': password,
      "confirmPassword": password,
      if (phoneNumber != null && phoneNumber!.isNotEmpty) 'phoneNumber': phoneNumber,
      if (birthdate != null && birthdate!.isNotEmpty) 'birthdate': birthdate,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (address != null) 'address': address!.toJson(),
    };
  }

  // Named constructor for creating from form data
  factory RegisterRequestBody.fromForm({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    String? birthdate,
    String? gender,
    String? city,
    String? district,
    String? street,
    String role = 'client',
  }) {
    Address? address;
    if (city != null && city.isNotEmpty ||
        district != null && district.isNotEmpty ||
        street != null && street.isNotEmpty) {
      address = Address(
        city: city?.trim().isEmpty == true ? null : city?.trim(),
        district: district?.trim().isEmpty == true ? null : district?.trim(),
        street: street?.trim().isEmpty == true ? null : street?.trim(),
      );
    }

    return RegisterRequestBody(
      username: username.trim(),
      email: email.trim(),
      password: password,
      role: role,
      phoneNumber: phoneNumber?.trim().isEmpty == true ? null : phoneNumber?.trim(),
      birthdate: birthdate?.trim().isEmpty == true ? null : birthdate?.trim(),
      gender: gender?.trim().isEmpty == true ? null : gender?.trim(),
      address: address,
    );
  }
}

class RegisterResponse{
  final String message;
  final User user;
  final String accessToken;
  final String refreshToken;
  final bool? cartMerged;

  RegisterResponse({required this.message, required this.user, required this.accessToken, required this.refreshToken, this.cartMerged});

  factory  RegisterResponse.fromJson(Map<String, dynamic> response){
    return RegisterResponse(message: response["message"], user: response["User"], accessToken: response["accessToken"], refreshToken: response["refreshToken"], cartMerged: response["cartMerged"]);
  }
}