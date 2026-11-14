import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/context_recommendation_page.dart';
import '../services/context_recommendation.dart';
import '../state/app_settings.dart';
import 'teduh_common.dart';

class RiskStyle {
  final Color fg;
  final Color bg;
  final IconData icon;
  const RiskStyle(this.fg, this.bg, this.icon);

  static RiskStyle of(RiskLevel l) {
    switch (l) {
      case RiskLevel.aman:
        return const RiskStyle(
            Color(0xFF1B6F57), Color(0xFFE6F2EA), Icons.check_circle_outline_rounded);
      case RiskLevel.waspada:
        return const RiskStyle(
            Color(0xFF9A6200), Color(0xFFFDF3DF), Icons.info_outline_rounded);
      case RiskLevel.tinggi:
        return const RiskStyle(
            Color(0xFFB3261E), Color(0xFFFDECE8), Icons.error_outline_rounded);
      case RiskLevel.sangatTinggi:
        return const RiskStyle(
            Color(0xFF8E1B1B), Color(0xFFFBDADA), Icons.warning_amber_rounded);
    }
  }
}

class ActivityPicker extends StatelessWidget {
  final VoidCallback onChanged;
  const ActivityPicker({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in TeduhActivity.values)
              ChoiceChip(
                label: Text(
                  a.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: ActivityChoice.current == a
                        ? Colors.white
                        : TC.greenDeep,
                  ),
                ),
                selected: ActivityChoice.current == a,
                showCheckmark: false,
                selectedColor: TC.greenDeep,
                backgroundColor: TC.iconBox,
                side: BorderSide(
                  color: ActivityChoice.current == a
                      ? TC.greenDeep
                      : TC.border,
                ),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                onSelected: (_) {
                  ActivityChoice.current = a;
                  onChanged();
                },
              ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            ActivityChoice.sensitive = !ActivityChoice.sensitive;
            onChanged();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Saya sensitif terhadap polusi (asma, anak, lansia)',
                    style: GoogleFonts.poppins(fontSize: 11, color: TC.dark),
                  ),
                ),
                Switch(
                  value: ActivityChoice.sensitive,
                  activeThumbColor: TC.greenDeep,
                  onChanged: (v) {
                    ActivityChoice.sensitive = v;
                    onChanged();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ContextRecommendationCard extends StatefulWidget {
  const ContextRecommendationCard({super.key});

  @override
  State<ContextRecommendationCard> createState() =>
      _ContextRecommendationCardState();
}

class _ContextRecommendationCardState extends State<ContextRecommendationCard> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final air = AppSettings.instance.snapshot;
        final simple = AppSettings.instance.effectiveSimpleLanguage;
        final rec = ContextRecommender.build(
          air: air,
          activity: ActivityChoice.current,
          sensitive: ActivityChoice.sensitive,
        );
        final st = RiskStyle.of(rec.level);
        final headline = simple ? rec.headlineSimple : rec.headline;

        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 18, color: TC.greenDeep),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rekomendasi untuk aktivitasmu',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: TC.dark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih kegiatanmu, TEDUH menyesuaikan saran dengan kondisi '
                'udara saat ini.',
                style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
              ),
              const SizedBox(height: 12),
              ActivityPicker(onChanged: () => setState(() {})),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: st.bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(st.icon, size: 18, color: st.fg),
                        const SizedBox(width: 6),
                        Text(
                          rec.levelLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: st.fg,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      headline,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: TC.dark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ISPU ${air.ispu} · PM2.5 ${air.pm25} · ${air.sourceName}',
                      style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                    ),
                    Text(
                      'Diperbarui ${air.updatedAt}',
                      style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: TC.greenDeep,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ContextRecommendationPage(),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Lihat alasan',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Icon(Icons.north_east_rounded,
                              size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
