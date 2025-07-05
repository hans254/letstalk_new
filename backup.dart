import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get the current signed-in user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Sign in with Google
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger Google sign-in flow
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // User canceled the sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in canceled')),
        );
        return null;
      }

      // Obtain Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // Correct getter for google_sign_in 7.1.0
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Sign-in successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as ${user.displayName}')),
        );
        return user;
      } else {
        // Unexpected case where user is null
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in failed: No user returned')),
        );
        return null;
      }
    } catch (e) {
      // Handle specific FirebaseAuth exceptions
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage = 'Account exists with a different sign-in method';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid Google credentials';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Google sign-in is not enabled in Firebase';
            break;
          default:
            errorMessage = 'Google sign-in failed: ${e.message}';
        }
      } else {
        errorMessage = 'An error occurred: $e';
      }

      // Show error to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      print('Google sign-in error: $e');
      return null;
    }
  }

}
