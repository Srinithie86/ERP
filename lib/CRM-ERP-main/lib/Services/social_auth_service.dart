import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

class SocialAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (error) {
      if (kDebugMode) {
        print('Google Sign-In Error: $error');
      }
      return null;
    }
  }

  Future<User?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // Required for Android implementation
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId:
              'com.erpsmart.crm.service', // TODO: REPLACE with your Service ID from Apple Developer Console
          redirectUri: Uri.parse(
            'https://your-project-id.firebaseapp.com/__/auth/handler', // TODO: REPLACE with your Firebase Auth Handler URL
          ),
        ),
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (error) {
      if (kDebugMode) {
        print('Apple Sign-In Error: $error');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
