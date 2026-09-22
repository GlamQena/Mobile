import 'package:easy_localization/easy_localization.dart';

class VerifyEmailMessages {
  static String _mapToLocalizedKey(String serverMessage) {
    // ============ SUCCESS MESSAGES ============
    if (serverMessage.contains('email verification link sent successfully')) {
      return 'verify_email_resend_success';
    }
    if (serverMessage.contains('Email verified successfully')) {
      return 'verify_email_success_title';
    }

    // ============ ERROR MESSAGES ============
    if (serverMessage.contains('email is required')) {
      return 'register_error_email_required';
    }
    if (serverMessage.contains('user not found') ||
        serverMessage.contains('User not found')) {
      return 'verify_email_resend_user_not_found'; //for both verifyEmail and resend
    }
    if (serverMessage.contains('Email already verified')) {
      return 'verify_email_already_verified';
    }
    if (serverMessage.contains('Invalid or expired token')) {
      return 'verify_email_expired_title';
    }
    if (serverMessage.contains('Token does not match email')) {
      return 'verify_email_invalid_title';
    }
    if (serverMessage.contains('error occurred while sending verification link')) {
      return 'verify_email_resend_error';
    }
    if (serverMessage.contains('Internal server error') ||
        serverMessage.contains('internal server error')) {
      return 'verify_email_resend_server_error';
    }

    // ============ DEFAULT FALLBACK ============
    return 'verify_email_error_default';
  }

  static String getLocalizedKey(String serverMessage) {
    return _mapToLocalizedKey(serverMessage);
  }

  static String getLocalizedMessage(String serverMessage) {
    final String key = _mapToLocalizedKey(serverMessage);
    final translated = key.tr();
    return translated == key ? serverMessage : translated;
  }

  static bool isAlreadyVerified(String serverMessage) {
    return serverMessage.contains('Email already verified');
  }

  static bool isExpired(String serverMessage) {
    return serverMessage.contains('expired') ||
      serverMessage.contains('Invalid or expired token');
  }

  static bool isInvalid(String serverMessage) {
    return serverMessage.contains('invalid') ||
      serverMessage.contains('Token does not match email') ||
      serverMessage.contains('email is required') ||
      serverMessage.contains('user not found') ||
      serverMessage.contains('User not found');
  }
}