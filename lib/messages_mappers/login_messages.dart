import 'package:easy_localization/easy_localization.dart';

class LoginMessages {
  static String _mapToLocalizedKey(String serverMessage) {
    // ============ SUCCESS MESSAGES ============
    if (serverMessage.contains(
        'Login successful. Guest cart merged with your account.')) {
      return 'login_success_with_cart';
    }
    if (serverMessage.contains('Login successful')) {
      return 'login_success';
    }

    // ============ VALIDATION: usernameOrEmail ============
    if (serverMessage.contains('usernameOrEmail is required')) {
      return 'login_error_username_or_email_required';
    }

    // Nested email errors (prefixed with "email error:")
    if (serverMessage.contains('email error:')) {
      if (serverMessage.contains('email is required')) {
        return 'login_error_email_required';
      }
      if(serverMessage.contains('at most')){
        return 'login_error_email_max_length';
      }
      if (serverMessage.contains('invalid email')) {
        return 'login_error_email_invalid';
      }
      return 'login_error_email_invalid';
    }

    // Nested username errors (prefixed with "username error:")
    if (serverMessage.contains('username error:')) {
      if (serverMessage.contains('username is required')) {
        return 'login_error_username_required';
      }
      if (serverMessage.contains('at least')) {
        return 'login_error_username_too_short';
      }
      if (serverMessage.contains('at most')) {
        return 'login_error_username_too_long';
      }
      if (serverMessage.contains('alphanumeric') ||
          serverMessage.contains('letters and numbers')) {
        return 'login_error_username_invalid_chars';
      }
      return 'login_error_username_invalid';
    }

    // ============ VALIDATION: password ============
    if (serverMessage.contains('password is required')) {
      return 'login_error_password_required';
    }
    if (serverMessage.contains('password must be at least 8 characters')) {
      return 'login_error_password_too_short';
    }
    if (serverMessage.contains('password must be at most 64 characters')) {
      return 'login_error_password_too_long';
    }
    if (serverMessage.contains('password must contain at least one uppercase character')) {
      return 'login_error_password_no_uppercase';
    }
    if (serverMessage.contains('password must contain at least one lowercase character')) {
      return 'login_error_password_no_lowercase';
    }
    if (serverMessage.contains('password must contain at least one digit')) {
      return 'login_error_password_no_digit';
    }

    // ============ AUTH ERRORS ============
    if (serverMessage.contains('Invalid email or username')) {
      return 'login_error_invalid_identifier';
    }
    if (serverMessage.contains('Invalid password')) {
      return 'login_error_invalid_password';
    }
    if (serverMessage.contains('Account is deactivated')) {
      return 'login_error_account_deactivated';
    }

    // ============ SERVER ERROR ============
    if (serverMessage.contains('Internal server error') ||
        serverMessage.contains('internal server error')) {
      return 'login_error_server';
    }

    // ============ DEFAULT FALLBACK ============
    return 'login_error_default';
  }

  static String getLocalizedMessage(String serverMessage) {
    final String key = _mapToLocalizedKey(serverMessage);
    final translated = key.tr(); //easyLocalization be default when the key not mapped to a message in the loaded en.json or ar.json it return the key itself as a fallback
    // Fallback to raw server message if no translation matched
    return translated == key ? serverMessage : translated;
  }
}