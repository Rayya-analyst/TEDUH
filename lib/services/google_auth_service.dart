import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_profile_service.dart';

class GoogleAuthResult {
  final bool success;
  final User? user;
  final String? message;
  final bool isCancelled;

  const GoogleAuthResult({
    required this.success,
    this.user,
    this.message,
    this.isCancelled = false,
  });
}

class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<GoogleAuthResult> signInWithGoogle(BuildContext context) async {
    try {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const GoogleAuthResult(
          success: false,
          isCancelled: true,
          message: 'Login Google dibatalkan.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        await UserProfileService.instance.syncGoogleUser(user);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', true);
        await prefs.setString('login_provider', 'google');
        if (user.email != null) {
          await prefs.setString('saved_email', user.email!);
        }

        return GoogleAuthResult(
          success: true,
          user: user,
          message: 'Berhasil masuk sebagai ${user.displayName ?? user.email}.',
        );
      }

      return const GoogleAuthResult(
        success: false,
        message: 'Gagal mendapatkan data pengguna Google.',
      );
    } on PlatformException catch (e) {
      debugPrint('[GoogleAuthService] PlatformException: ${e.code} - ${e.message}');
      
      if (e.message?.contains('10') == true || e.code.contains('10')) {
        return const GoogleAuthResult(
          success: false,
          message: 'SHA-1 aplikasi belum terdaftar di Firebase Console. Gunakan email/password atau daftarkan SHA-1: A9:44:31:2D:8E:52:18:D7:94:19:F1:F0:FB:A9:59:F6:D9:97:B1:75',
        );
      }
      return GoogleAuthResult(
        success: false,
        message: 'Kendala layanan Google: ${e.message ?? e.code}',
      );
    } catch (e) {
      debugPrint('[GoogleAuthService] Unexpected error: $e');
      return GoogleAuthResult(
        success: false,
        message: 'Gagal masuk dengan Google: $e',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}

