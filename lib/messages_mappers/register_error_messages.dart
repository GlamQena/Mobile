import 'package:easy_localization/easy_localization.dart';

class RegisterErrorMessages {

  static String _mapToLocalizedKey(String serverError){
    // Username errors
    if (serverError.contains('username is required')) {
      return 'register_error_username_required';
    }
    if (serverError.contains('username must be at least 3 characters')) {
      return 'register_error_username_min';
    }
    if (serverError.contains('username must be at most 64')) {
      return 'register_error_username_max';
    }
    if (serverError.contains('username must have lowercase letters, numbers and underscores')) {
      return 'register_error_username_format';
    }
    if (serverError.contains('username or email already exists')) {
      return 'register_error_username_email_exists';
    }

    // Email errors
    if (serverError.contains('email is required')) {
      return 'register_error_email_required';
    }
    if (serverError.contains('invalid email format')) {
      return 'register_error_email_format';
    }
    if (serverError.contains('email must be at most 254 characters')) {
      return 'register_error_email_max';
    }

    // Password errors
    if (serverError.contains('password is required')) {
      return 'register_error_password_required';
    }
    if (serverError.contains('password must be at least 8 characters')) {
      return 'register_error_password_min';
    }
    if (serverError.contains('password must be at most 64 characters')) {
      return 'register_error_password_max';
    }
    if (serverError.contains('password must contain at least one uppercase character')) {
      return 'register_error_password_uppercase';
    }
    if (serverError.contains('password must contain at least one lowercase character')) {
      return 'register_error_password_lowercase';
    }
    if (serverError.contains('password must contain at least one digit')) {
      return 'register_error_password_digit';
    }
    if (serverError.contains('passwords must match')) {
      return 'register_error_password_match';
    }

    // Phone errors
    if (serverError.contains('invalid egyptian phone')) {
      return 'register_error_phone_format';
    }

    // Role errors
    if (serverError.contains('role is required')) {
      return 'register_error_role_required';
    }
    if (serverError.contains('role must be either client or store_owner')) {
      return 'register_error_role_invalid';
    }

    // Gender errors
    if (serverError.contains('must be one of: male, female')) {
      return 'register_error_gender_invalid';
    }

    // Address errors
    if (serverError.contains('city must be at most 50 characters')) {
      return 'register_error_city_max';
    }
    if (serverError.contains('district must be at most 50 characters')) {
      return 'register_error_district_max';
    }
    if (serverError.contains('street must be at most 100 characters')) {
      return 'register_error_street_max';
    }

    // General errors
    if (serverError.contains('user account not created')) {
      return 'register_error_account_not_created';
    }
    if (serverError.contains('internal server error')) {
      return 'register_error_server';
    }

    // Default fallback
    return 'register_error_default';
  }

  static String getLocalizedError(String serverError){
    final key = _mapToLocalizedKey(serverError);
    final translated = key.tr();
    return translated == key ? serverError : translated;
  }
}