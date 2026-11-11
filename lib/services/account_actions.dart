import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart' show LoginScreen;
import '../services/voice_service.dart';
import '../state/app_settings.dart';

void _say(BuildContext context, String m) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  if (AppSettings.instance.effectiveAutoRead) VoiceService.instance.speak(m);
}

Future<String?> _askPassword(BuildContext context, String info) {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Konfirmasi kata sandi',
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F3D34))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(info,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF7C8D85))),
          const SizedBox(height: 10),
          TextField(
            controller: c,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Kata sandi'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal')),
        TextButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: const Text('Lanjut')),
      ],
    ),
  );
}

Future<void> deleteAccountFlow(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    _say(context, 'Sesi berakhir. Silakan masuk lagi.');
    return;
  }
  final navigator = Navigator.of(context);
  final password = await _askPassword(
    context,
    'Untuk menghapus akun secara permanen, masukkan kata sandi kamu.',
  );
  if (password == null || password.isEmpty || !context.mounted) return;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final email = user.email;
    if (email == null) throw FirebaseAuthException(code: 'no-email');
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    await user.delete();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
    if (navigator.mounted) {
      _say(navigator.context, 'Akun dan datamu sudah dihapus.');
    }
  } on FirebaseAuthException catch (e) {
    if (navigator.mounted) navigator.pop();
    if (navigator.mounted) {
      _say(
        navigator.context,
        e.code == 'wrong-password' || e.code == 'invalid-credential'
            ? 'Kata sandi salah.'
            : 'Gagal menghapus akun (${e.code}).',
      );
    }
  } catch (e) {
    if (navigator.mounted) navigator.pop();
    if (navigator.mounted) {
      _say(navigator.context, 'Gagal menghapus data: $e');
    }
  }
}
