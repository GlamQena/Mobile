import 'package:easy_localization/easy_localization.dart';

class LogoutMessages {
  static String _mapToLocalizedKey(String serverMessage) {
    // ============ SUCCESS MESSAGES ============
    if (serverMessage.contains(
        'user logout and his tokens removed successfully')) {
      return 'logout_success';
    }
    if (serverMessage.contains(
        'user logout and his tokens and session cart removed successfully')) {
      return 'logout_success_with_cart';
    }

    // ============ ERROR MESSAGES ============
    if (serverMessage.contains('internal server error') ||
        serverMessage.contains('Internal server error')) {
      return 'logout_error_server';
    }

    // ============ DEFAULT FALLBACK ============
    return 'logout_error_default';
  }

  static String getLocalizedMessage(String serverMessage) {
    final String key = _mapToLocalizedKey(serverMessage);
    return key.tr();
  }
}