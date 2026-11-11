import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';

enum _Risk { tinggi, sedang, rendah }

extension _RiskX on _Risk {
  String get label => switch (this) {
        _Risk.tinggi => 'Risiko tinggi',
        _Risk.sedang => 'Risiko sedang',
        _Risk.rendah => 'Risiko rendah',
      };

  Color get tagColor => switch (this) {
        _Risk.tinggi => const Color(0xFFB5731A),
        _Risk.sedang => const Color(0xFFA47A10),
        _Risk.rendah => const Color(0xFF1F7A4F),
      };

  Color get boxColor => switch (this) {
        _Risk.tinggi => const Color(0xFFFDEBD2),
        _Risk.sedang => const Color(0xFFFFF3CF),
        _Risk.rendah => const Color(0xFFE3F1E6),
      };

  Color get iconColor => switch (this) {
        _Risk.tinggi => const Color(0xFFE8873A),
        _Risk.sedang => const Color(0xFFD9A21B),
        _Risk.rendah => const Color(0xFF3F8F6C),
      };

  IconData get icon => switch (this) {
        _Risk.tinggi => Icons.warning_amber_rounded,
        _Risk.sedang => Icons.info_outline_rounded,
        _Risk.rendah => Icons.lightbulb_outline_rounded,
      };
}

class _Rec {
  final int bucket;
  final String meta;
  final _Risk risk;
  final String title;
  final String body;
  const _Rec(this.bucket, this.meta, this.risk, this.title, this.body);
}

const List<_Rec> _all = [
  _Rec(0, 'Hari ini, 08.00 WIB', _Risk.tinggi, 'Pemberitahuan Peringatan Masker N95',
      'Kualitas udara menurun. Gunakan masker N95 saat keluar rumah.'),
  _Rec(0, 'Hari ini, 07.30 WIB', _Risk.tinggi, 'Rekomendasi Batasi Aktivitas Luar',
      'Tunda olahraga di luar. Pilih gerak ringan di dalam ruangan.'),
  _Rec(1, 'Kemarin, 16.00 WIB', _Risk.rendah, 'Saatnya Jeda dan Hidrasi',
      'Cukupi air minum dan luangkan 5 menit untuk bernapas tenang.'),
  _Rec(1, '2 hari lalu, 06.30 WIB', _Risk.rendah, 'Udara Segar untuk Pagi Anda',
      'Udara lebih bersih pagi ini. Nikmati jalan santai selama 15 menit.'),
  _Rec(2, '5 hari lalu, 07.15 WIB', _Risk.sedang, 'Cek Udara Sebelum Berolahraga',
      'Indeks udara sedang. Pilih olahraga ringan dan hindari jalan raya.'),
  _Rec(3, '28 Okt, 08.00 WIB', _Risk.tinggi, 'Peringatan Kabut Asap Pekat',
      'Jarak pandang menurun. Tetap di dalam ruangan dan tutup ventilasi.'),
];


class RecommendationHistoryPage extends StatefulWidget {
  const RecommendationHistoryPage({super.key});

  @override
  State<RecommendationHistoryPage> createState() =>
      _RecommendationHistoryPageState();
}

class _RecommendationHistoryPageState extends State<RecommendationHistoryPage> {
  static const _tabs = ['Semua', 'Minggu Ini', 'Bulan Ini'];
  static const _maxBucket = [3, 1, 2];
  static const _rangeLabel = ['Semua', 'Minggu ini', 'Bulan ini'];

  int _tab = 1; 

  List<CoachStep> get _tour => const [
        CoachStep(title: 'Riwayat Rekomendasi', body: 'Semua saran yang pernah diberikan TEDUH kepadamu, diurutkan dari yang terbaru.'),
        CoachStep(title: 'Tingkat risiko', body: 'Tiap kartu diberi label risiko tinggi, sedang, atau rendah, lengkap dengan waktunya.'),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'rec_history',
        tour: _tour,
        guide: PageGuide(content: () => 'Ini halaman Riwayat Rekomendasi. Berisi saran-saran terdahulu seperti memakai masker N95, membatasi aktivitas luar, jeda dan hidrasi, serta cek udara sebelum berolahraga, masing-masing dengan label risiko dan waktunya. Ucapkan kembali untuk ke halaman sebelumnya.'),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    final visible = _all.where((r) => r.bucket <= _maxBucket[_tab]).toList();
    final today = visible.where((r) => r.bucket == 0).toList();
    final before = visible.where((r) => r.bucket > 0).toList();

    return TeduhPage(
      title: 'Riwayat Rekomendasi',
      titleWeight: FontWeight.w500,
      background: const Color(0xFFF6F8F4),
      leafColor: const Color(0xFFDDEADA),
      builder: (context, anim) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            animation: anim,
            begin: 0.1,
            end: 0.5,
            child: _Segmented(
              tabs: _tabs,
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),

          const SizedBox(height: 20),

          Reveal(
            animation: anim,
            begin: 0.3,
            end: 0.9,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              child: Column(
                key: ValueKey(_tab),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (today.isNotEmpty) ...[
                    _SectionTitle(left: 'Hari ini', right: 'Minggu, 1 Nov'),
                    const SizedBox(height: 10),
                    for (final r in today) ...[
                      _RecCard(rec: r),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 6),
                  ],
                  if (before.isNotEmpty) ...[
                    _SectionTitle(
                        left: 'Sebelumnya', right: _rangeLabel[_tab]),
                    const SizedBox(height: 10),
                    for (final r in before) ...[
                      _RecCard(rec: r),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Reveal(
            animation: anim,
            begin: 0.7,
            end: 1.0,
            child: const NoteRow(
              icon: Icons.eco_outlined,
              text: 'Disesuaikan dengan kondisi udara di sekitar Anda',
            ),
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  const _Segmented({
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEADC),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment(-1.0 + index * 1.0, 0),
            child: FractionallySizedBox(
              widthFactor: 1 / tabs.length,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: TC.greenDeep,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: TC.greenDeep.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (int i = 0; i < tabs.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight:
                              i == index ? FontWeight.w600 : FontWeight.w500,
                          color: i == index
                              ? Colors.white
                              : const Color(0xFF4E7A67),
                        ),
                        child: Text(tabs[i]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String left;
  final String right;

  const _SectionTitle({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: TC.greenDeep,
            ),
          ),
        ),
        Text(
          right,
          style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
        ),
      ],
    );
  }
}

class _RecCard extends StatelessWidget {
  final _Rec rec;
  const _RecCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAF0EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rec.risk.boxColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(rec.risk.icon, size: 19, color: rec.risk.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rec.meta,
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          color: TC.hint,
                        ),
                      ),
                    ),
                    Text(
                      rec.risk.label,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: rec.risk.tagColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  rec.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: TC.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rec.body,
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
    );
  }
}
