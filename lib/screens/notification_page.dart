import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';

class _Pref {
  final String title;
  final String subtitle;
  bool on;
  _Pref(this.title, this.subtitle, this.on);
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  final List<_Pref> _prefs = [
    _Pref('Peringatan Kualitas Udara', 'Peringatan saat udara mulai tidak sehat.',
        true),
    _Pref('Informasi Kabut Asap', 'Kabar kabut asap di sekitar lokasimu.', true),
    _Pref('Rekomendasi Kesehatan', 'Saran sehat sesuai kondisi udara.', true),
    _Pref('Pengingat Perlengkapan', 'Ingatkan masker sebelum beraktivitas.',
        true),
    _Pref('Pengingat Harian', 'Ringkasan udara setiap pukul 07.00.', true),
  ];

  int get _active => _prefs.where((p) => p.on).length;

  final List<GlobalKey> _k = List<GlobalKey>.generate(4, (_) => GlobalKey());

  List<CoachStep> get _tour => [
        CoachStep(
          target: _k[0],
          title: 'Pilih kabar yang kamu mau',
          body: 'Di halaman ini kamu menentukan kabar udara apa saja yang ingin diterima supaya napas tetap nyaman.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _k[1],
          title: 'Jumlah notifikasi aktif',
          body: 'Menunjukkan berapa jenis notifikasi yang sedang menyala dari total lima jenis.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _k[2],
          title: 'Lima jenis notifikasi',
          body: 'Peringatan Kualitas Udara, Informasi Kabut Asap, Rekomendasi Kesehatan, Pengingat Perlengkapan, dan Pengingat Harian. Setiap baris punya saklar untuk menyalakan atau mematikannya.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _k[3],
          title: 'Tersimpan otomatis',
          body: 'Preferensimu tersimpan otomatis begitu saklar diubah, tidak perlu menekan tombol simpan.',
          scrollAlignment: 0.5,
        ),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'notif_pref',
        tour: _tour,
        guide: PageGuide(content: () => 'Ini halaman Notifikasi. Ada lima pilihan: Peringatan Kualitas Udara, Informasi Kabut Asap, Rekomendasi Kesehatan, Pengingat Perlengkapan, dan Pengingat Harian berupa ringkasan udara setiap pukul tujuh pagi. Preferensi tersimpan otomatis. Ucapkan kembali untuk ke halaman sebelumnya.'),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    return TeduhPage(
      title: 'Notifikasi',
      builder: (context, anim) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Reveal(
            key: _k[0],
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
                    swing: true,
                    iconWidth: 56,
                    iconHeight: 64,
                    icon: CustomPaint(painter: _BellPainter()),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tetap siaga, tetap tenang',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TC.greenDeep,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih kabar yang ingin kamu terima untuk menjaga '
                    'napas tetap nyaman.',
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
            key: _k[1],
            animation: anim,
            begin: 0.3,
            end: 0.7,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Preferensi notifikasi',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: TC.dark,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    '$_active notifikasi aktif',
                    key: ValueKey(_active),
                    style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Reveal(
            key: _k[2],
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
              child: Column(
                children: [
                  for (int i = 0; i < _prefs.length; i++) ...[
                    _PrefRow(
                      pref: _prefs[i],
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _prefs[i].on = v);
                      },
                    ),
                    if (i != _prefs.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                        color: TC.divider,
                      ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          Reveal(
            key: _k[3],
            animation: anim,
            begin: 0.7,
            end: 1.0,
            child: const NoteRow(
              icon: Icons.check_circle_outline_rounded,
              text: 'Preferensi notifikasi tersimpan otomatis.',
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  final _Pref pref;
  final ValueChanged<bool> onChanged;

  const _PrefRow({required this.pref, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!pref.on),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pref.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: TC.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pref.subtitle,
                    style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                  ),
                ],
              ),
            ),
            Switch(
              value: pref.on,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              thumbColor: WidgetStateProperty.all(Colors.white),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? TC.greenDeep
                    : const Color(0xFFCBD5CE),
              ),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}

class _BellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final body = Path()
      ..moveTo(w * 0.16, h * 0.76)
      ..cubicTo(w * 0.17, h * 0.36, w * 0.30, h * 0.16, w * 0.50, h * 0.16)
      ..cubicTo(w * 0.70, h * 0.16, w * 0.83, h * 0.36, w * 0.84, h * 0.76)
      ..lineTo(w * 0.94, h * 0.84)
      ..lineTo(w * 0.06, h * 0.84)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..isAntiAlias = true
        ..color = const Color(0xFF1F6B4F),
    );

    final shine = Path()
      ..moveTo(w * 0.28, h * 0.70)
      ..cubicTo(w * 0.28, h * 0.42, w * 0.36, h * 0.28, w * 0.46, h * 0.24)
      ..cubicTo(w * 0.38, h * 0.36, w * 0.36, h * 0.52, w * 0.37, h * 0.70)
      ..close();
    canvas.drawPath(
      shine,
      Paint()
        ..isAntiAlias = true
        ..color = const Color(0xFF3E8F6C).withValues(alpha: 0.7),
    );

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.11),
      w * 0.06,
      Paint()..color = const Color(0xFF1F6B4F),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.92),
        width: w * 0.24,
        height: h * 0.13,
      ),
      Paint()..color = const Color(0xFF174F3B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
