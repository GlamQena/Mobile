class User{
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
}

class Address{
  String? city;
  String? district;
  String? street;

  Address({this.city, this.street, this.district});

  Map<String, String> toJson(){
    return{
      if(city != null && city!.isNotEmpty) "city": city!,
      if(district != null && district!.isNotEmpty) "district": district!,
      if(street != null && street!.isNotEmpty) "street": street!,
    };
  }
}