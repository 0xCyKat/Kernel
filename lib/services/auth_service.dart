import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  AuthService() {
    _initGoogleSignIn();
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  Future<void> _initGoogleSignIn() async {
    await _googleSignIn.initialize(
      serverClientId:
          '273351594464-kj13nm7nrqfdo27bhhj0p5jku4h6lbdk.apps.googleusercontent.com',
    );
    _initialized = true;
  }

  bool get isLoggedIn => _auth.currentUser != null;

  Future<void> signInWithGoogle() async {
    try {
      if (!_initialized) {
        await _initGoogleSignIn();
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
