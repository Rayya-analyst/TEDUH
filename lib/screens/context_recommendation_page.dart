import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/context_recommendation.dart';
import '../services/voice_service.dart';
import '../state/app_settings.dart';
import '../widgets/context_card.dart';
import '../widgets/teduh_common.dart';

class ContextRecommendationPage extends StatefulWidget {
  const ContextRecommendationPage({super.key});

  @override
  State<ContextRecommendationPage> createState() =>
      _ContextRecommendationPageState();
}

class _ContextRecommendationPageState extends State<ContextRecommendationPage> {
  final SectionKeys _sk = SectionKeys(8);

  List<CoachStep> get _tour => [
        CoachStep(
          target: _sk.keys[0],
          title: 'Kondisi yang dianalisis',
          body: 'Data udara yang dipakai: lokasi, ISPU, PM2.5, sumber, dan waktu pembaruan.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _sk.keys[1],
          title: 'Pilih aktivitasmu',
          body: 'Ganti aktivitas dan saran langsung menyesuaikan. Aktifkan saklar bila kamu sensitif terhadap polusi.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _sk.keys[3],
          title: 'Alasan rekomendasi',
          body: 'Penjelasan mengapa saran ini diberikan. Aktifkan Bahasa Sederhana bila istilahnya terlalu teknis.',
          scrollAlignment: 0.2,
        ),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      VoiceService.instance.autoReadIfEnabled(_current().spoken(
          simple: AppSettings.instance.effectiveSimpleLanguage));
    });
  }

  @override
  void dispose() {
    VoiceService.instance.stopSpeaking();
    super.dispose();
  }

  ContextRecommendation _current() => ContextRecommender.build(
        air: AppSettings.instance.snapshot,
        activity: ActivityChoice.current,
        sensitive: ActivityChoice.sensitive,
      );

  Widget _card(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: TC.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );

  Widget _title(String t, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: TC.greenDeep),
            const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  t,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: TC.dark,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(k,
                  style: GoogleFonts.poppins(fontSize: 11, color: TC.hint)),
            ),
            Expanded(
              child: Text(v,
                  style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: TC.dark)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return VoiceScope(
      screen: 'context_rec',
      tour: _tour,
      guide: PageGuide(
        content: () => 'Ini halaman rekomendasi aktivitas. ${VoiceService.instance.recommendationSummary()} Kamu bisa mengganti aktivitas, mengaktifkan saklar sensitif polusi, atau mengetuk Dengarkan untuk mendengar penjelasan lengkap. Ucapkan kembali untuk ke halaman sebelumnya.',
      ),
      child: TeduhPage(
      title: 'Rekomendasi Aktivitas',
      builder: (context, anim) {
        return ListenableBuilder(
          listenable: Listenable.merge(
              [AppSettings.instance, VoiceService.instance]),
          builder: (context, _) {
            final air = AppSettings.instance.snapshot;
            final simple = AppSettings.instance.effectiveSimpleLanguage;
            final rec = _current();
            final st = RiskStyle.of(rec.level);
            final now = DateTime.now();

            _sk.reset();
            Widget r(double b, double e, Widget c) =>
                Reveal(animation: anim, begin: b, end: e, child: _sk.wrap(c));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                r(0.0, 0.4, _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title('Kondisi udara yang dianalisis', Icons.air_rounded),
                    _row('Lokasi', air.location),
                    _row('Status', '${air.status} · ISPU ${air.ispu}'),
                    _row('PM2.5', air.pm25),
                    _row('Waktu', 'Saat ini (${ContextRecommender.timeOfDay(now)})'),
                    _row('Sumber', air.sourceName),
                    _row('Diperbarui', air.updatedAt),
                  ],
                ))),
                const SizedBox(height: 14),
                r(0.1, 0.5, _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title('Aktivitas yang dipilih', Icons.directions_run_rounded),
                    ActivityPicker(onChanged: () => setState(() {})),
                  ],
                ))),
                const SizedBox(height: 14),
                r(0.2, 0.6, Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: st.bg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: st.fg.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(st.icon, color: st.fg, size: 22),
                          const SizedBox(width: 8),
                          Text(rec.levelLabel,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: st.fg)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        simple ? rec.headlineSimple : rec.headline,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: TC.dark,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 14),
                r(0.3, 0.7, _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title('Mengapa rekomendasi ini diberikan?',
                        Icons.help_outline_rounded),
                    Text(
                      simple ? rec.reasonSimple : rec.reason,
                      style: GoogleFonts.poppins(
                          fontSize: 12, height: 1.6, color: TC.dark),
                    ),
                  ],
                ))),
                const SizedBox(height: 14),
                r(0.4, 0.8, _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title('Apa yang perlu dilakukan?', Icons.checklist_rounded),
                    for (int i = 0; i < rec.steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: TC.iconBox,
                                shape: BoxShape.circle,
                              ),
                              child: Text('${i + 1}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: TC.greenDeep)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(rec.steps[i],
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, height: 1.5, color: TC.dark)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ))),
                const SizedBox(height: 14),
                r(0.5, 0.9, _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title('Alternatif aktivitas', Icons.swap_horiz_rounded),
                    for (final a in rec.alternatives)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right_rounded,
                                size: 20, color: TC.greenDeep),
                            Expanded(
                              child: Text(a,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, height: 1.5, color: TC.dark)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ))),
                const SizedBox(height: 16),
                const NoteRow(
                  icon: Icons.info_outline_rounded,
                  text: 'Data simulasi. Bukan pengganti saran tenaga medis.',
                ),
              ],
            );
          },
        );
      },
    ));
  }
}
