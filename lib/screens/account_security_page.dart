import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_settings.dart';
import '../widgets/teduh_common.dart';
import 'change_password_page.dart';
import 'location_permission_dialog.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  bool _sending = false;

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt',
    'Nov', 'Des',
  ];

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.day} ${_bulan[l.month - 1]} ${l.year}, ${two(l.hour)}.${two(l.minute)}';
  }

  String _locLabel(String c) {
    switch (c) {
      case 'onlyThisTime':
        return 'Hanya kali ini';
      case 'deny':
        return 'Tidak diizinkan';
      default:
        return 'Saat aplikasi digunakan';
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _verify(User user) async {
    setState(() => _sending = true);
    try {
      await user.sendEmailVerification();
      _snack('Email verifikasi dikirim ke ${user.email}.');
    } on FirebaseAuthException catch (e) {
      _snack(e.code == 'too-many-requests'
          ? 'Terlalu banyak permintaan. Coba lagi nanti.'
          : 'Gagal mengirim email (${e.code}).');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _reload(User user) async {
    await user.reload();
    if (mounted) setState(() {});
  }

  Future<void> _location() async {
    final c = await showLocationPermissionDialog(context);
    if (c == null || !mounted) return;
    AppSettings.instance.update(() => AppSettings.instance.locationChoice = c.name);
    setState(() {});
  }

  Widget _card(List<Widget> children) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TC.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: children),
      );

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 2),
        child: Semantics(
          header: true,
          child: Text(t,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w700, color: TC.dark)),
        ),
      );

  Widget _info(String k, String v, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k,
                      style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint)),
                  const SizedBox(height: 2),
                  Text(v,
                      style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: TC.dark)),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      );

  Widget _nav(IconData icon, String title, String sub, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: TC.iconBox,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: TC.greenDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: TC.dark)),
                    Text(sub,
                        style: GoogleFonts.poppins(fontSize: 10, color: TC.hint)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: TC.hint),
            ],
          ),
        ),
      );

  Widget _div() => const Divider(
      height: 1, thickness: 1, indent: 16, endIndent: 16, color: TC.divider);

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'security',
        tour: const [
          CoachStep(title: 'Status akunmu', body: 'Di sini terlihat email yang kamu pakai dan apakah email sudah terverifikasi. Bila belum, ketuk Kirim email verifikasi, lalu Saya sudah verifikasi setelah membuka email.'),
          CoachStep(title: 'Riwayat masuk', body: 'Metode masuk, kapan terakhir kamu masuk, dan kapan akun dibuat. Periksa bila ada waktu yang tidak kamu kenali.'),
          CoachStep(title: 'Perlindungan', body: 'Ubah kata sandi untuk memperbarui kata sandi akun. Izin lokasi membuka pilihan izin lokasi TEDUH, yaitu saat aplikasi digunakan, hanya kali ini, atau tidak diizinkan.'),
          CoachStep(title: 'Tips menjaga akun', body: 'Gunakan kata sandi unik, jangan bagikan kepada siapa pun, verifikasi email, dan keluar dari akun bila memakai perangkat bersama.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Keamanan Akun. Berisi status akun dan verifikasi email, riwayat masuk, perlindungan yaitu Ubah kata sandi dan Izin lokasi, serta tips menjaga akun. Katakan buka privasi untuk kembali ke Privasi dan Keamanan.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final verified = user?.emailVerified ?? false;
    final meta = user?.metadata;

    return TeduhPage(
      title: 'Keamanan Akun',
      builder: (context, anim) {
        Widget r(double b, double e, Widget c) =>
            Reveal(animation: anim, begin: b, end: e, child: c);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            r(0.0, 0.5, _title('Status akun')),
            r(0.05, 0.6, _card([
              _info('Email', user?.email ?? '-'),
              _div(),
              _info(
                'Verifikasi email',
                verified ? 'Terverifikasi' : 'Belum terverifikasi',
                trailing: Icon(
                  verified
                      ? Icons.verified_rounded
                      : Icons.error_outline_rounded,
                  color: verified ? TC.greenDeep : const Color(0xFFB3261E),
                ),
              ),
              if (!verified && user != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _sending ? null : () => _verify(user),
                        child: Text(_sending ? 'Mengirim...' : 'Kirim email verifikasi'),
                      ),
                      TextButton(
                        onPressed: () => _reload(user),
                        child: const Text('Saya sudah verifikasi'),
                      ),
                    ],
                  ),
                ),
              ],
              _div(),
              _info('Metode masuk', 'Email dan kata sandi'),
              _div(),
              _info('Terakhir masuk', _fmt(meta?.lastSignInTime)),
              _div(),
              _info('Akun dibuat', _fmt(meta?.creationTime)),
            ])),
            const SizedBox(height: 18),
            r(0.2, 0.7, _title('Perlindungan')),
            r(0.25, 0.8, _card([
              _nav(Icons.key_outlined, 'Ubah kata sandi',
                  'Perbarui kata sandi akunmu', () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const ChangePasswordPage()));
              }),
              _div(),
              _nav(Icons.location_on_outlined, 'Izin lokasi',
                  _locLabel(AppSettings.instance.locationChoice), _location),
            ])),
            const SizedBox(height: 18),
            r(0.4, 0.9, _title('Tips menjaga akun')),
            r(0.45, 1.0, _card([
              for (final tip in const [
                'Gunakan kata sandi unik, minimal 8 karakter, dengan huruf dan angka.',
                'Jangan membagikan kata sandi atau kode kepada siapa pun.',
                'Verifikasi emailmu agar akun mudah dipulihkan.',
                'Keluar dari akun bila memakai perangkat bersama.',
              ])
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 18, color: TC.greenDeep),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(tip,
                            style: GoogleFonts.poppins(
                                fontSize: 11.5, height: 1.5, color: TC.dark)),
                      ),
                    ],
                  ),
                ),
            ])),
          ],
        );
      },
    );
  }
}
