import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart' show LoginScreen;
import '../services/voice_service.dart';
import '../state/app_settings.dart';

const Color _kGreen = Color(0xFF176D59);
const Color _kInk = Color(0xFF1F3D34);
const Color _kMuted = Color(0xFF7C8D85);
const Color _kBg = Color(0xFFF7FBF8);
const Color _kLine = Color(0xFFE1EAE4);

class _AuthIllustration extends StatelessWidget {
  final IconData icon;
  final double iconAngle;
  final IconData badge;
  const _AuthIllustration({
    required this.icon,
    this.iconAngle = 0,
    this.badge = Icons.shield_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kLine),
              color: const Color(0xFFEFF6F1),
            ),
          ),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                angle: iconAngle,
                child: Icon(icon, size: 70, color: _kGreen),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 28,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _kGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _kGreen.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(badge, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco_rounded, color: _kGreen, size: 32),
              const SizedBox(width: 8),
              Text('TEDUH',
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: _kGreen)),
            ],
          ),
          Text('Hidup Sehat, Udara Sehat',
              style: GoogleFonts.poppins(fontSize: 12, color: _kGreen)),
        ],
      );
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  int get _strength {
    final p = _new.text;
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(p) && RegExp(r'\d').hasMatch(p)) score++;
    if (p.length >= 10 || RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
    return score.clamp(1, 3).toInt();
  }

  String get _strengthLabel {
    switch (_strength) {
      case 0:
        return 'Minimal 8 karakter';
      case 1:
        return 'Lemah · minimal 8 karakter';
      case 2:
        return 'Sedang · tambah angka atau simbol';
      default:
        return 'Kuat · minimal 8 karakter';
    }
  }

  bool get _match => _confirm.text.isNotEmpty && _confirm.text == _new.text;
  bool get _valid => _new.text.length >= 8 && _match;

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    if (AppSettings.instance.effectiveAutoRead) {
      VoiceService.instance.speak(m);
    }
  }

  Future<String?> _askCurrentPassword() {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Verifikasi dulu',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700, color: _kInk)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Demi keamanan, masukkan kata sandi kamu saat ini.',
              style: GoogleFonts.poppins(fontSize: 12, color: _kMuted),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: c,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Kata sandi saat ini'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.poppins(color: _kMuted))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: Text('Lanjut',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, color: _kGreen))),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('Sesi berakhir. Silakan masuk lagi.');
      return;
    }
    if (!_valid) {
      _snack(_new.text.length < 8
          ? 'Kata sandi minimal 8 karakter.'
          : 'Konfirmasi kata sandi belum sama.');
      return;
    }
    setState(() => _saving = true);
    try {
      try {
        await user.updatePassword(_new.text);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'requires-recent-login') rethrow;
        final current = await _askCurrentPassword();
        if (current == null || current.isEmpty) {
          if (mounted) setState(() => _saving = false);
          return;
        }
        final email = user.email;
        if (email == null) rethrow;
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: current),
        );
        await user.updatePassword(_new.text);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const PasswordUpdatedPage()),
      );
    } on FirebaseAuthException catch (e) {
      _snack(switch (e.code) {
        'wrong-password' || 'invalid-credential' => 'Kata sandi saat ini salah.',
        'weak-password' => 'Kata sandi terlalu lemah.',
        'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
        'network-request-failed' => 'Koneksi internet bermasalah.',
        _ => e.message ?? 'Gagal memperbarui kata sandi (${e.code}).',
      });
    } catch (e) {
      _snack('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String label, TextEditingController c, bool hidden,
      VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600, color: _kInk)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kLine),
          ),
          child: TextField(
            controller: c,
            obscureText: hidden,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.poppins(fontSize: 14, color: _kInk),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  size: 20, color: _kMuted),
              suffixIcon: IconButton(
                tooltip: hidden ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
                onPressed: toggle,
                icon: Icon(
                    hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: _kMuted),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'changepass',
        tour: const [
          CoachStep(title: 'Kata Sandi Baru', body: 'Ketik kata sandi baru minimal 8 karakter. Ketuk ikon mata untuk melihat atau menyembunyikan huruf. Garis kekuatan menunjukkan lemah, sedang, atau kuat.'),
          CoachStep(title: 'Konfirmasi Kata Sandi', body: 'Ketik ulang kata sandi yang sama. Tulisan di bawahnya menunjukkan apakah kedua kata sandi sudah cocok.'),
          CoachStep(title: 'Simpan Kata Sandi Baru', body: 'Ketuk tombol ini setelah kata sandi kuat dan cocok. Bila diminta, masukkan kata sandi lamamu demi keamanan.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Ubah Kata Sandi. Ada kolom Kata Sandi Baru dengan indikator kekuatan, kolom Konfirmasi Kata Sandi Baru, dan tombol Simpan Kata Sandi Baru. Gunakan kata sandi minimal delapan karakter.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final st = _strength;
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.maybePop(context),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.arrow_back_rounded, color: _kInk),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Kata Sandi Baru',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _kInk)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                        child: _AuthIllustration(
                            icon: Icons.vpn_key_outlined, iconAngle: -0.6)),
                    Semantics(
                      header: true,
                      child: Text('Kata sandi, rasa aman.',
                          style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: _kInk)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Buat kata sandi baru yang kuat untuk melindungi akun Anda.',
                      style: GoogleFonts.poppins(
                          fontSize: 13.5, height: 1.5, color: _kMuted),
                    ),
                    const SizedBox(height: 22),
                    _field('Kata Sandi Baru', _new, _hideNew,
                        () => setState(() => _hideNew = !_hideNew)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (int i = 1; i <= 3; i++) ...[
                          Container(
                            width: 28,
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= st ? _kGreen : _kLine,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(_strengthLabel,
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: _kGreen)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _field('Konfirmasi Kata Sandi Baru', _confirm, _hideConfirm,
                        () => setState(() => _hideConfirm = !_hideConfirm)),
                    const SizedBox(height: 10),
                    if (_confirm.text.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                              _match
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.error_outline_rounded,
                              size: 18,
                              color: _match
                                  ? _kGreen
                                  : const Color(0xFFB3261E)),
                          const SizedBox(width: 6),
                          Text(
                              _match
                                  ? 'Kata sandi sudah cocok'
                                  : 'Kata sandi belum cocok',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _match
                                      ? _kGreen
                                      : const Color(0xFFB3261E))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        disabledBackgroundColor: _kGreen.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: Colors.white))
                          : Text('Simpan Kata Sandi Baru',
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: _kMuted),
                      const SizedBox(width: 6),
                      Text('Privasi Anda, prioritas kami.',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: _kMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordUpdatedPage extends StatefulWidget {
  const PasswordUpdatedPage({super.key});

  @override
  State<PasswordUpdatedPage> createState() => _PasswordUpdatedPageState();
}

class _PasswordUpdatedPageState extends State<PasswordUpdatedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoiceService.instance.autoReadIfEnabled(
          'Kata sandi berhasil diperbarui. Kamu bisa masuk dengan kata sandi baru.');
    });
  }

  Future<void> _goLogin() async {
    await VoiceService.instance.cancelAll();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  children: [
                    const _Logo(),
                    const SizedBox(height: 24),
                    const _AuthIllustration(
                        icon: Icons.check_rounded,
                        badge: Icons.auto_awesome_outlined),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F0E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 14, color: _kGreen),
                          const SizedBox(width: 6),
                          Text('AKUN KEMBALI AMAN',
                              style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: _kGreen)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text('Kata sandi berhasil\ndiperbarui.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 28,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: _kInk)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kini Anda bisa masuk dengan kata sandi baru. Mari kembali '
                      'merawat diri dan bumi bersama TEDUH.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 13.5, height: 1.55, color: _kMuted),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6F1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_outlined,
                              color: _kGreen),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Langkah kecil, rasa aman lebih besar.',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: _kInk)),
                                Text(
                                    'Kata sandi baru Anda tersimpan dengan aman.',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11, color: _kMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text('Masuk ke Akun',
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Ruang tenangmu menanti.',
                      style: GoogleFonts.poppins(fontSize: 11, color: _kMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
