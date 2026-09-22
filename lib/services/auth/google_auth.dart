import "package:flutter/material.dart";
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    debugPrint('Initializing GoogleSignIn with serverClientId: ...');

    await _googleSignIn.initialize(
      // clientId is inferred from native config (Info.plist[for ios] / google-services.json[for android])
      serverClientId: '526568342272-d3a3k4i7josdkd360drqead1vn3g0t0a.apps.googleusercontent.com',
    );
    _initialized = true;
  }

  Future<GoogleSignInAccount?> signIn() async {
    await init();
    try {
      // This opens the Google account picker
      GoogleSignInAccount account = await _googleSignIn.authenticate();
       debugPrint('Authenticate returned: ${account.email}');
       return account;    
    } on GoogleSignInException catch (e) {
      debugPrint('Google Sign-In failed: ${e.code.name} – ${e.description}');
      return null;
    }
  }
}