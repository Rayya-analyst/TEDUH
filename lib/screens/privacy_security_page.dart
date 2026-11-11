import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';
import '../services/account_actions.dart';
import '../state/app_settings.dart';
import 'account_security_page.dart';
import 'change_password_page.dart';
import 'data_profile_page.dart';
import 'location_permission_dialog.dart';
import 'privacy_policy_page.dart';

class _Item {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Item(this.icon, this.title, this.subtitle);
}

const List<_Item> _items = [
  _Item(Icons.person_outline_rounded, 'Data Pribadi',
      'Kelola informasi tentang dirimu'),
  _Item(Icons.key_outlined, 'Ubah Kata Sandi', 'Perbarui kata sandi akun'),
  _Item(Icons.verified_user_outlined, 'Keamanan Akun',
      'Lindungi akses ke akunmu'),
  _Item(Icons.location_on_outlined, 'Izin Lokasi',
      'Atur akses lokasi untuk data udara'),
  _Item(Icons.description_outlined, 'Kebijakan Privasi',
      'Pelajari cara kami menjaga data'),
  _Item(Icons.delete_outline_rounded, 'Hapus Akun',
      'Hapus akun dan data secara permanen'),
];

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  void _onTap(BuildContext context, _Item item) {
    switch (item.title) {
      case 'Data Pribadi':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DataProfilePage()),
        );
        break;
      case 'Ubah Kata Sandi':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
        );
        break;
      case 'Keamanan Akun':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AccountSecurityPage()),
        );
        break;
      case 'Izin Lokasi':
        _askLocation(context);
        break;
      case 'Kebijakan Privasi':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
        );
        break;
      case 'Hapus Akun':
        _confirmDelete(context);
        break;
      default:
        showSoon(context, item.title);
    }
  }

  Future<void> _askLocation(BuildContext context) async {
    final c = await showLocationPermissionDialog(context);
    if (c == null || !context.mounted) return;
    AppSettings.instance
        .update(() => AppSettings.instance.locationChoice = c.name);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Izin lokasi diperbarui.')),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus akun?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TC.dark,
          ),
        ),
        content: Text(
          'Akun dan seluruh datamu akan dihapus secara permanen dan tidak '
          'dapat dikembalikan.',
          style: GoogleFonts.poppins(fontSize: 12, height: 1.5, color: TC.hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: TC.dark,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              deleteAccountFlow(context);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD64545),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final SectionKeys _sk = SectionKeys(4);

  List<CoachStep> get _tour => [
        CoachStep(
          target: _sk.keys[0],
          title: 'Privasi dan keamanan',
          body: 'Kelola data dan keamanan akunmu di satu tempat.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _sk.keys[1],
          title: 'Data dan perlindungan',
          body: 'Buka Data Pribadi, Ubah Kata Sandi, Keamanan Akun, Izin Lokasi, dan Kebijakan Privasi. Hapus Akun menghapus akun dan datamu secara permanen.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _sk.keys[3],
          title: 'Datamu dalam kendalimu',
          body: 'Kamu bisa mengubah izin dan menghapus data kapan saja.',
          scrollAlignment: 0.5,
        ),
      ];

  @override
  Widget build(BuildContext context) =>
      VoiceScope(
        screen: 'privacy',
        tour: _tour,
        guide: PageGuide(
          content: () => 'Ini halaman Privasi dan Keamanan. Berisi Data Pribadi, Ubah Kata Sandi, Keamanan Akun, Izin Lokasi, Kebijakan Privasi, dan Hapus Akun yang menghapus akun dan datamu secara permanen. Kamu bisa mengubah izin dan menghapus data kapan saja. Ucapkan kembali untuk ke halaman sebelumnya.',
        ),
        child: _page(context),
      );

  Widget _page(BuildContext context) {
    return TeduhPage(
      title: 'Privasi dan Keamanan',
      builder: (context, anim) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            key: _sk.keys[0],
animation: anim,
            begin: 0.1,
            end: 0.55,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [TC.heroTop, TC.heroBottom],
                ),
              ),
              child: Column(
                children: [
                  LaurelHero(
                    iconWidth: 58,
                    iconHeight: 68,
                    icon: CustomPaint(painter: _ShieldLockPainter()),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rasa aman, di setiap langkah',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TC.greenDeep,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kelola data dan keamanan akunmu. Privasi kamu adalah '
                    'prioritas TEDUH.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      height: 1.5,
                      color: const Color(0xFF55705F),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          Reveal(
            key: _sk.keys[1],
animation: anim,
            begin: 0.3,
            end: 0.7,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Data dan perlindungan',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: TC.dark,
                    ),
                  ),
                ),
                Text(
                  'Akun pribadi',
                  style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Reveal(
            key: _sk.keys[2],
animation: anim,
            begin: 0.4,
            end: 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TC.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    for (int i = 0; i < _items.length; i++) ...[
                      _SettingRow(
                        item: _items[i],
                        onTap: () => _onTap(context, _items[i]),
                      ),
                      if (i != _items.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          indent: 66,
                          endIndent: 16,
                          color: TC.divider,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 34),

          Reveal(
            key: _sk.keys[3],
animation: anim,
            begin: 0.7,
            end: 1.0,
            child: const NoteRow(
              icon: Icons.check_circle_outline_rounded,
              text: 'Datamu tetap dalam kendalimu.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final _Item item;
  final VoidCallback onTap;

  const _SettingRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: TC.green.withValues(alpha: 0.06),
      highlightColor: TC.green.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 11, 14, 11),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: TC.iconBox,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(item.icon, size: 19, color: TC.green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: TC.dark,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 22, color: TC.greenDeep),
          ],
        ),
      ),
    );
  }

}

class _ShieldLockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Path shield(double inset) {
      final l = w * inset;
      final r = w * (1 - inset);
      final t = h * inset * 0.7;
      final b = h * (1 - inset * 0.7);
      final mid = w * 0.5;
      return Path()
        ..moveTo(mid, t)
        ..quadraticBezierTo(w * 0.72, h * 0.13 + t, r, h * 0.13 + t)
        ..lineTo(r, h * 0.52)
        ..quadraticBezierTo(r, h * 0.84, mid, b)
        ..quadraticBezierTo(l, h * 0.84, l, h * 0.52)
        ..lineTo(l, h * 0.13 + t)
        ..quadraticBezierTo(w * 0.28, h * 0.13 + t, mid, t)
        ..close();
    }

    canvas.drawPath(
      shield(0),
      Paint()
        ..isAntiAlias = true
        ..color = const Color(0xFF1F6B4F),
    );
    canvas.drawPath(
      shield(0.09),
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF5BA585).withValues(alpha: 0.8),
    );

    final lockColor = const Color(0xFFC3DCC8);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.56),
        width: w * 0.44,
        height: h * 0.30,
      ),
      Radius.circular(w * 0.06),
    );
    canvas.drawPath(
      Path()
        ..addArc(
          Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.40),
            width: w * 0.28,
            height: h * 0.26,
          ),
          3.1416,
          3.1416,
        ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07
        ..strokeCap = StrokeCap.round
        ..color = lockColor,
    );
    canvas.drawRRect(body, Paint()..color = lockColor);

    final dark = Paint()..color = const Color(0xFF1F6B4F);
    canvas.drawCircle(Offset(w * 0.5, h * 0.54), w * 0.045, dark);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.61),
          width: w * 0.04,
          height: h * 0.08,
        ),
        Radius.circular(w * 0.02),
      ),
      dark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
