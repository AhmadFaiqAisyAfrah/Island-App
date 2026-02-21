import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance, GoogleSignIn());
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthService(this._auth, this._googleSignIn);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Pure Google Sign-In. Returns User on success, null on cancel/error.
  /// NO cloud sync — drawer handles that via dialogs.
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('[AuthService] ▶ signInWithGoogle() STARTED');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('[AuthService] ✖ User cancelled sign-in');
        return null;
      }

      debugPrint('[AuthService] ✔ Google account: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      debugPrint('[AuthService] ✔ Firebase sign-in complete — uid: ${user?.uid}');

      // NO auto-sync here. Drawer orchestrates via dialogs.
      return user;
    } catch (e) {
      debugPrint('[AuthService] ❌ signInWithGoogle error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    debugPrint('[AuthService] ✔ Signed out');
  }
}
