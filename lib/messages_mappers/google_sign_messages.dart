import 'package:easy_localization/easy_localization.dart';

class GoogleSignMessages {
  static String _mapToLocalizedKey(String serverMessage) {
    // ============ SUCCESS MESSAGES ============
    if (serverMessage.contains(
        'user account created successfully. Guest cart merged with your account.')) {
      return 'google_sign_success_created_with_cart';
    }
    if (serverMessage.contains(
        'user loggedIn successfully. Guest cart merged with your account.')) {
      return 'google_sign_success_login_with_cart';
    }
    if (serverMessage.contains('user account created successfully')) {
      return 'google_sign_success_created';
    }
    if (serverMessage.contains('user loggedIn successfully')) {
      return 'google_sign_success_login';
    }

    // ============ VALIDATION ERRORS ============
    if (serverMessage.contains('idToken is required')) {
      return 'google_sign_error_id_token_required';
    }

    // ============ AUTH ERRORS ============
    if (serverMessage.contains('Invalid or expired Google token')) {
      return 'google_sign_error_invalid_token';
    }
    if (serverMessage.contains('Account conflict')) {
      return 'google_sign_error_account_conflict';
    }

    // ============ SERVER ERROR ============
    if (serverMessage.contains('Internal server error') ||
        serverMessage.contains('internal server error')) {
      return 'google_sign_error_server';
    }

    // ============ DEFAULT FALLBACK ============
    return 'google_sign_error_default';
  }

  static String getLocalizedMessage(String serverMessage) {
    final String key = _mapToLocalizedKey(serverMessage);
    final translated = key.tr();
    return translated == key ? serverMessage : translated;
  }
}