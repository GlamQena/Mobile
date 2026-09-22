import 'package:flutter/foundation.dart';

class AuthState {
  AuthState._();

  static final ValueNotifier<bool> isLoggedIn =
      ValueNotifier<bool>(false);

  /// Convenience setters so callers don't touch `.value` directly.
  static void setLoggedIn() => isLoggedIn.value = true;
  static void setLoggedOut() => isLoggedIn.value = false;
}