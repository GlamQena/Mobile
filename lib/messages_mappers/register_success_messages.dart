import 'package:easy_localization/easy_localization.dart';

class RegisterSuccessMessages{
  static String _mapToLocalizedKey(String serverMessage){
    if (serverMessage.contains('Verification link sent to your email')) {
      return 'register_success_verification';
    }
    if (serverMessage.contains('Account created successfully! Guest cart merged')) {
      return 'register_success_cart_merged';
    }
    if (serverMessage.contains('Account created successfully')) {
      return 'register_success_default';
    }
    // Default fallback
    return 'register_success_default';
  }

  static String getLocalizedSuccess(String serverMessage){
    final key = _mapToLocalizedKey(serverMessage);
    final translated = key.tr();
    return translated == key ? serverMessage : translated;
  }
}