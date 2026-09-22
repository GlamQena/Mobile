import "package:flutter/material.dart";

class User {
  final String id;
  final String role;
  final String username;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phoneNumber;
  final String? avatar;
  final String? gender;
  final Address? address;
  final DateTime? birthdate;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isActive;
  final List<String> notifications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.role = 'client',
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatar,
    this.gender,
    this.address,
    this.birthdate,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isActive = true,
    this.notifications = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'],
      gender: json['gender'],
      address: json['address'] != null
          ? Address.fromMap(json['address'])
          : null,
      birthdate: json['birthdate'] != null
          ? _parseDateTime(json['birthdate'])
          : null,
      role: json['role'] ?? 'client',
      isEmailVerified: json['isEmailVerified'] ?? json['isVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      notifications: json['notifications'] != null
          ? List<String>.from(json['notifications'])
          : [],
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'gender': gender,
      if (address != null) 'address': address!.toMap(),
      'birthdate': birthdate?.toIso8601String(),
      'role': role,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isActive': isActive,
      'notifications': notifications,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to parse dates safely
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) return value;
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('Failed to parse date: $value, error: $e');
        return null;
      }
    }
    
    return null;
  }

  User copyWith({
    String? id,
    String? role,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? avatar,
    String? gender,
    Address? address,
    DateTime? birthdate,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isActive,
    List<String>? notifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      birthdate: birthdate ?? this.birthdate,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isActive: isActive ?? this.isActive,
      notifications: notifications ?? this.notifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  } //the copyWith method (standarad name) used to update some properties values of a pre-created object while preserving the previously set values
}

class Address {
  final String city;
  final String district;
  final String street;

  const Address({
    this.city = "",
    this.district = "",
    this.street = "",
  });

  /// Always emits exactly the three keys the server expects.
  Map<String, String> toMap() => {
    "city": city,
    "district": district,
    "street": street,
  };

  factory Address.fromMap(Map<String, dynamic>? map) => Address(
    city:    (map?["city"]     as String?) ?? "",
    district:(map?["district"] as String?) ?? "",
    street:  (map?["street"]   as String?) ?? "",
  );

  @override
  String toString() =>
      'Address(city: $city, district: $district, street: $street)';
}

//dart doesn't support fuction overloading, constructor overloading or even the operator overloading, but apply the polymorphism concept with only the overriding