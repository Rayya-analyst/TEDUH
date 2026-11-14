import 'dart:math' as math;
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';
import 'readiness_state.dart';
import 'rencana_darurat_page.dart';

class ProgresKesiapsiagaanPage extends StatelessWidget {
  const ProgresKesiapsiagaanPage({super.key});

  static final SectionKeys _sk = SectionKeys(6);

  List<CoachStep> get _tour => [
        CoachStep(
          target: _sk.keys[0],
          title: 'Progres harianmu',
          body: 'Lingkaran ini menunjukkan persentase checklist harian yang sudah kamu selesaikan.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _sk.keys[1],
          title: 'Checklist kebiasaan',
          body: 'Centang langkah harian yang sudah dilakukan. Menu titik tiga di pojok atas mengatur ulang checklist.',
          scrollAlignment: 0.25,
        ),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'progres',
        tour: _tour,
        guide: PageGuide(
          content: () {
            final r = ReadinessState.instance;
            return 'Ini halaman Progres Kesiapsiagaan. Lingkaran di atas menunjukkan checklist harian yang selesai, sekarang ${r.stepsPercent} persen. Di bawahnya ada checklist kebiasaan harian, ${r.stepsDone} dari ${r.stepsTotal} langkah sudah selesai. Menu titik tiga mengatur ulang checklist. Ucapkan kembali untuk ke halaman sebelumnya.';
          },
        ),
        child: _scaffold(context),
      );

  Widget _scaffold(BuildContext context) {
    final s = ReadinessState.instance;
    return ReadyScaffold(
      title: 'Progres Kesiapsiagaan',
      centerTitle: true,
      leaves: false,
      background: const Color(0xFFF4F8F4),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz_rounded, color: RC.dark),
        padding: EdgeInsets.zero,
        onSelected: (v) {
          if (v == 'reset') s.resetSteps();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'reset',
            child: Text('Atur ulang checklist',
                style: GoogleFonts.poppins(fontSize: 13)),
          ),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_outlined, size: 17, color: RC.grey),
              const SizedBox(width: 10),
              Text(
                'Kamu selangkah lebih peduli hari ini.',
                style: GoogleFonts.poppins(fontSize: 11.5, color: RC.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ReadyButton(
            label: 'Simpan Progress',
            icon: Icons.arrow_forward_rounded,
            color: const Color(0xFF225943),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RencanaDaruratPage()),
            ),
          ),
        ],
      ),
      builder: (context, anim) {
        Widget r(double b, double e, Widget c) =>
            Reveal(animation: anim, begin: b, end: e, child: _sk.wrap(c));

        return ListenableBuilder(
          listenable: s,
          builder: (context, _) {
            _sk.reset();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                r(0.05, 0.5, _hero(s)),
                const SizedBox(height: 22),
                r(
                  0.15,
                  0.55,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi & Kesiapsiagaan',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: RC.dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kebiasaan kecil, perlindungan setiap hari.',
                        style:
                            GoogleFonts.poppins(fontSize: 12, color: RC.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < s.steps.length; i++)
                  r(0.22 + i * 0.08, 0.62 + i * 0.08, _stepTile(s, s.steps[i])),
              ],
            );
          },
        );
      },
    );
  }

  Widget _hero(ReadinessState s) {
    final n = s.stepsDone;
    final total = s.stepsTotal;
    final left = total - n;
    final String title;
    final String sub;
    if (left == 0) {
      title = 'Kamu sudah\nsiap!';
      sub = 'Semua langkah selesai. Pertahankan kebiasaanmu.';
    } else if (n == 0) {
      title = 'Mulai dari\nlangkah kecil.';
      sub = '$n dari $total langkah selesai. Pilih satu untuk dirimu.';
    } else {
      title = 'Sedikit lagi,\nlebih siap.';
      sub = '$n dari $total langkah selesai. '
          '${numberWord(left)} langkah untuk dirimu.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEEE2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 148,
            height: 148,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: s.stepsFraction),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => CustomPaint(
                painter: _RingPainter(v),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${s.stepsPercent}%',
                        style: GoogleFonts.poppins(
                          fontSize: 34,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF225943),
                        ),
                      ),
                      Text('Siap',
                          style: GoogleFonts.poppins(
                              fontSize: 12.5, color: const Color(0xFF225943))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_outlined,
                        size: 14, color: Color(0xFF225943)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'LANGKAH HARI INI',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: const Color(0xFF225943),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF225943),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sub,
                  style: GoogleFonts.poppins(
                      fontSize: 11.5, height: 1.5, color: RC.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepTile(ReadinessState s, ReadyStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => s.toggleStep(step),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RC.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2EA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(step.icon, size: 24, color: const Color(0xFF3E6B55)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: RC.dark,
                        ),
                      ),
                      Text(
                        step.subtitle,
                        style:
                            GoogleFonts.poppins(fontSize: 10.5, color: RC.grey),
                      ),
                    ],
                  ),
                ),
                ReadyCheck(
                    checked: step.done, fill: const Color(0xFF2C5F4A)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  _RingPainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xFFC9E0D0),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF225943),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.fraction != fraction;
}
