import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';

class _Step {
  final IconData icon;
  final String title;
  final String subtitle;
  final String guide;
  bool done;

  _Step(this.icon, this.title, this.subtitle, this.guide, this.done);
}

class PreparednessPage extends StatefulWidget {
  const PreparednessPage({super.key});

  @override
  State<PreparednessPage> createState() => _PreparednessPageState();
}

class _PreparednessPageState extends State<PreparednessPage>
    with SingleTickerProviderStateMixin {
  final List<_Step> _steps = [
    _Step(
      Icons.masks_outlined,
      'Gunakan Masker',
      'Masker bersih siap dibawa',
      'Simpan 2–3 masker bersih (N95 saat kabut asap) di tas atau dekat pintu.',
      true,
    ),
    _Step(
      Icons.home_outlined,
      'Menyiapkan Air Minum',
      'Jaga udara di rumah tetap bersih',
      'Siapkan air minum cukup untuk seharian dan jaga ruangan tetap bersih '
          'dari debu.',
      true,
    ),
    _Step(
      Icons.health_and_safety_outlined,
      'Siapkan Kebutuhan Kesehatan',
      'Obat pribadi & air minum tersedia',
      'Pastikan obat pribadi, inhaler (bila perlu), dan air minum mudah '
          'dijangkau.',
      true,
    ),
    _Step(
      Icons.air_rounded,
      'Cek Udara Sebelum Keluar',
      'Lihat kondisi sebelum beraktivitas',
      'Buka TEDUH sebelum keluar. Jika ISPU di atas 100, kurangi aktivitas di '
          'luar ruangan.',
      false,
    ),
  ];

  late final AnimationController _ring;

  int get _done => _steps.where((s) => s.done).length;
  double get _target => _done / _steps.length;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      animationBehavior: AnimationBehavior.preserve,
    );
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        _ring.animateTo(_target, curve: Curves.easeOutCubic);
      }
    });
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  void _toggle(int i) {
    HapticFeedback.selectionClick();
    setState(() => _steps[i].done = !_steps[i].done);
    _ring.animateTo(
      _target,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  (String, String) get _message {
    final d = _done;
    final n = _steps.length;
    if (d == n) {
      return ('Kamu siap,\ntetap waspada.', '$d dari $n langkah selesai.\nHebat, pertahankan ya.');
    }
    if (d >= 2) {
      final left = n - d;
      return (
        'Sedikit lagi,\nlebih siap.',
        '$d dari $n langkah selesai.\n'
            '${left == 1 ? 'Satu langkah' : '$left langkah'} untuk dirimu.'
      );
    }
    return ('Ayo mulai,\nlangkah kecil.', '$d dari $n langkah selesai.\nMulai dari yang termudah.');
  }

  void _showGuide() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E2DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                'Panduan Detail',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TC.greenDeep,
                ),
              ),
              const SizedBox(height: 12),
              for (final s in _steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: TC.iconBox,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(s.icon, size: 18, color: TC.greenDeep),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: TC.dark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.guide,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                height: 1.45,
                                color: TC.hint,
                              ),
                            ),
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
    );
  }

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'prepare',
        tour: const [
          CoachStep(title: 'Status kesiapsiagaan', body: 'Bagian atas menunjukkan seberapa siap kamu hari ini, dari ayo mulai sampai kamu siap.'),
          CoachStep(title: 'Langkah hari ini', body: 'Daftar langkah kecil: gunakan masker, siapkan air minum, siapkan kebutuhan kesehatan, dan cek udara sebelum keluar. Ketuk untuk menandai selesai.'),
          CoachStep(title: 'Panduan Detail', body: 'Ketuk Lihat Panduan Detail untuk penjelasan lebih lengkap tiap langkah kesiapsiagaan.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Rekomendasi dan Kesiapsiagaan. Ada status kesiapsiagaan, empat langkah hari ini: gunakan masker, siapkan air minum, siapkan kebutuhan kesehatan, dan cek udara sebelum keluar, serta tombol Lihat Panduan Detail.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    return TeduhPage(
      title: 'Kesiapsiagaan',
      centerTitle: true,
      background: const Color(0xFFF2F7F2),
      leafColor: const Color(0xFFD6E7D4),
      trailing: IconButton(
        onPressed: () => showSoon(context, 'Menu'),
        icon: const Icon(Icons.more_horiz_rounded),
        color: TC.dark,
        iconSize: 24,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      builder: (context, anim) {
        final msg = _message;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Reveal(
              animation: anim,
              begin: 0.1,
              end: 0.55,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEADC),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 104,
                      height: 104,
                      child: AnimatedBuilder(
                        animation: _ring,
                        builder: (context, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(104, 104),
                                painter: _RingPainter(_ring.value),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(_ring.value * 100).round()}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: TC.greenDeep,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'Siap',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: TC.greenDeep,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  size: 13, color: TC.greenDeep),
                              const SizedBox(width: 5),
                              Text(
                                'LANGKAH HARI INI',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                  color: TC.greenDeep,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey(msg.$1),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.$1,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    color: TC.greenDeep,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  msg.$2,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    height: 1.5,
                                    color: const Color(0xFF3F7A55),
                                  ),
                                ),
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

            const SizedBox(height: 20),

            Reveal(
              animation: anim,
              begin: 0.3,
              end: 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi & Kesiapsiagaan',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TC.greenDeep,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kebiasaan kecil, perlindungan setiap hari.',
                    style: GoogleFonts.poppins(fontSize: 11, color: TC.hint),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            for (int i = 0; i < _steps.length; i++) ...[
              Reveal(
                animation: anim,
                begin: 0.4 + i * 0.1,
                end: 0.8 + i * 0.07,
                child: _StepCard(
                  step: _steps[i],
                  onTap: () => _toggle(i),
                ),
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 4),

            Reveal(
              animation: anim,
              begin: 0.7,
              end: 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    const Icon(Icons.spa_outlined, size: 16, color: TC.hint),
                    const SizedBox(width: 10),
                    Text(
                      'Kamu selangkah lebih peduli hari ini.',
                      style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Reveal(
              animation: anim,
              begin: 0.75,
              end: 1.0,
              child: _GuideButton(onTap: _showGuide),
            ),
          ],
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  final _Step step;
  final VoidCallback onTap;

  const _StepCard({required this.step, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6EEE8)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: TC.iconBox,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(step.icon, size: 22, color: const Color(0xFF4E7A67)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: TC.dark,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      step.subtitle,
                      style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: step.done ? TC.greenDeep : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: step.done ? TC.greenDeep : const Color(0xFFC9D3CC),
                    width: 1.4,
                  ),
                ),
                child: AnimatedScale(
                  scale: step.done ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GuideButton({required this.onTap});

  @override
  State<_GuideButton> createState() => _GuideButtonState();
}

class _GuideButtonState extends State<_GuideButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: TC.greenDeep,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: TC.greenDeep.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Lihat Panduan Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  size: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);

    canvas.drawArc(
      arc,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xFFC8DDCA),
    );
    canvas.drawArc(
      arc,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = TC.greenDeep,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
