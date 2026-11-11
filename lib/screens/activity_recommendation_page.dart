import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';
import 'indoor_activity_pages.dart';
import 'outdoor_activity_pages.dart';

const int kSimulatedIspu = 462;

const int kOutdoorMaxIspu = 100;

String ispuCategory(int v) {
  if (v <= 50) return 'Baik';
  if (v <= 100) return 'Sedang';
  if (v <= 200) return 'Tidak sehat';
  if (v <= 300) return 'Sangat tidak sehat';
  return 'Berbahaya';
}

void openActivityRecommendation(BuildContext context, {required int ispu}) {
  final Widget page = ispu <= kOutdoorMaxIspu
      ? OutdoorRecommendationPage(ispu: ispu)
      : IndoorRecommendationPage(ispu: ispu);
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

class OutdoorRecommendationPage extends StatelessWidget {
  final int ispu;
  const OutdoorRecommendationPage({super.key, this.ispu = 42});

  @override
  Widget build(BuildContext context) =>
      _RecommendationView(indoor: false, ispu: ispu);
}

class IndoorRecommendationPage extends StatelessWidget {
  final int ispu;
  const IndoorRecommendationPage({super.key, this.ispu = kSimulatedIspu});

  @override
  Widget build(BuildContext context) =>
      _RecommendationView(indoor: true, ispu: ispu);
}

class _Activity {
  final String title;
  final String duration;
  final String level;
  final String desc;
  final IconData icon;
  final String asset;
  const _Activity(
      this.title, this.duration, this.level, this.desc, this.icon, this.asset);
}

const List<_Activity> _outdoorItems = [
  _Activity(
    'Jalan Santai',
    '15 menit',
    'Ringan',
    'Mulai hari dengan langkah santai untuk meningkatkan sirkulasi darah '
        'dan membangkitkan energi tubuh.',
    Icons.directions_walk_rounded,
    'assets/images/activities/jalan_santai.jpg',
  ),
  _Activity(
    'Jogging',
    '20 menit',
    'Sedang',
    'Tingkatkan denyut jantung dan kekuatan kaki dengan intensitas yang '
        'terukur untuk kesehatan jantung.',
    Icons.directions_run_rounded,
    'assets/images/activities/jogging.jpg',
  ),
  _Activity(
    'Bersepeda',
    '25 menit',
    'Sedang',
    'Aktivitas kardio yang menyenangkan untuk menguatkan kaki dan menikmati '
        'udara pagi dengan lebih santai.',
    Icons.directions_bike_rounded,
    'assets/images/activities/bersepeda.jpg',
  ),
  _Activity(
    'Bermain di Taman',
    '30 menit',
    'Ringan',
    'Aktivitas santai di luar ruangan yang membantu meningkatkan mood dan '
        'kualitas tidur dengan gerakan alami.',
    Icons.park_rounded,
    'assets/images/activities/taman.jpg',
  ),
];

const List<_Activity> _indoorItems = [
  _Activity(
    'Yoga Ringan',
    '20 menit',
    'Ringan',
    'Gerakan lembut untuk meningkatkan fleksibilitas, mengurangi stres, dan '
        'memulihkan tubuh setelah aktivitas.',
    Icons.self_improvement_rounded,
    'assets/images/activities/yoga.jpg',
  ),
  _Activity(
    'Peregangan',
    '10 menit',
    'Ringan',
    'Melepaskan ketegangan otot dan meningkatkan kelenturan tubuh sebelum '
        'atau setelah aktivitas utama.',
    Icons.accessibility_new_rounded,
    'assets/images/activities/peregangan.jpg',
  ),
  _Activity(
    'Latihan Pernapasan',
    '10 menit',
    'Ringan',
    'Latihan napas yang membantu menenangkan pikiran, mengurangi stres, dan '
        'meningkatkan kualitas istirahat.',
    Icons.spa_rounded,
    'assets/images/activities/pernapasan.jpg',
  ),
  _Activity(
    'Aktivitas Indoor',
    '15 menit',
    'Ringan',
    'Pilihan aman untuk hari berkualitas udara tidak sehat, tetap menjaga '
        'tubuh aktif tanpa paparan polusi luar.',
    Icons.fitness_center_rounded,
    'assets/images/activities/indoor.jpg',
  ),
];

class _Palette {
  final Color leaf;
  final Color regionColor;
  final Color iconCircle;
  final Color iconColor;
  final Color infoBorder;
  final Color infoBg;
  final Color labelColor;
  final FontWeight labelWeight;
  final bool upperLabels;
  final Color valueColor;
  final Color infoDesc;
  final Color cardBorder;
  final List<Color> cardBg;
  final Color photoRing;
  final Color title;
  final Color chipBg;
  final Color chipText;
  final Color levelText;
  final Color descText;
  final List<Color> button;

  const _Palette({
    required this.leaf,
    required this.regionColor,
    required this.iconCircle,
    required this.iconColor,
    required this.infoBorder,
    required this.infoBg,
    required this.labelColor,
    required this.labelWeight,
    required this.upperLabels,
    required this.valueColor,
    required this.infoDesc,
    required this.cardBorder,
    required this.cardBg,
    required this.photoRing,
    required this.title,
    required this.chipBg,
    required this.chipText,
    required this.levelText,
    required this.descText,
    required this.button,
  });
}

const _Palette _outdoorPalette = _Palette(
  leaf: Color(0xFFDCEADA),
  regionColor: Color(0xFF0B5D43),
  iconCircle: Color(0xFFE3F6EA),
  iconColor: Color(0xFF0B5D43),
  infoBorder: Color(0xFF22A877),
  infoBg: Color(0xFFF1FBF5),
  labelColor: Color(0xFF7C9084),
  labelWeight: FontWeight.w400,
  upperLabels: false,
  valueColor: Color(0xFF0B5D43),
  infoDesc: Color(0xFF7C9084),
  cardBorder: Color(0xFF1FA971),
  cardBg: [Colors.white, Color(0xFFF1FBF5)],
  photoRing: Color(0xFFE3F6EA),
  title: Color(0xFF0B5D43),
  chipBg: Color(0xFFE3F6EA),
  chipText: Color(0xFF0B5D43),
  levelText: Color(0xFF7C9084),
  descText: Color(0xFF7C9084),
  button: [Color(0xFF14B885), Color(0xFF0F766E)],
);

const _Palette _indoorPalette = _Palette(
  leaf: Color(0xFFE4EFE3),
  regionColor: Color(0xFF8E1B1B),
  iconCircle: Color(0xFFFBC8C8),
  iconColor: Color(0xFF8E1B1B),
  infoBorder: Color(0xFFE05A5A),
  infoBg: Color(0xFFFFECEC),
  labelColor: Color(0xFF8E1B1B),
  labelWeight: FontWeight.w700,
  upperLabels: true,
  valueColor: Color(0xFF8E1B1B),
  infoDesc: Color(0xFFE04848),
  cardBorder: Color(0xFFD6A53F),
  cardBg: [Color(0xFFFFFBF6), Color(0xFFFFEFE2)],
  photoRing: Color(0xFFFFF3E8),
  title: Color(0xFF1F3D2F),
  chipBg: Color(0xFFFDE8D8),
  chipText: Color(0xFF7A2E0E),
  levelText: Color(0xFFC2610C),
  descText: Color(0xFF5B6B60),
  button: [Color(0xFFFB7A1E), Color(0xFFEA580C)],
);

class _RecommendationView extends StatefulWidget {
  final bool indoor;
  final int ispu;
  const _RecommendationView({required this.indoor, required this.ispu});

  @override
  State<_RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends State<_RecommendationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AnimationBehavior.preserve,
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  final GlobalKey _kInfo = GlobalKey();
  final GlobalKey _kHead = GlobalKey();
  final GlobalKey _kCard = GlobalKey();
  final GlobalKey _kNote = GlobalKey();

  Widget _r(double b, double e, Widget child) =>
      Reveal(animation: _anim, begin: b, end: e, child: child);

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'activities',
        tour: [
          CoachStep(
            target: _kInfo,
            title: 'Kondisi udara saat ini',
            body: 'Kartu ini menjelaskan kondisi kualitas udara terkini. Rekomendasi aktivitas dipilih otomatis mengikuti kondisi ini: bila udara baik kamu mendapat aktivitas luar ruangan, bila udara buruk kamu mendapat aktivitas dalam ruangan.',
            scrollAlignment: 0.1,
          ),
          CoachStep(
            target: _kHead,
            title: widget.indoor ? 'Aktivitas Indoor' : 'Aktivitas Outdoor',
            body: 'Jumlah aktivitas yang aman untukmu saat ini ditampilkan di sini, tanpa perlu memilih sendiri.',
            scrollAlignment: 0.1,
          ),
          CoachStep(
            target: _kCard,
            title: 'Kartu aktivitas',
            body: 'Setiap kartu memuat nama aktivitas, durasi, tingkat intensitas, dan manfaat singkat. Ketuk salah satu untuk melihat detail dan memulainya.',
            scrollAlignment: 0.15,
          ),
          if (widget.indoor)
            CoachStep(
              target: _kNote,
              title: 'Catatan keselamatan',
              body: 'Pengingat agar tetap aman saat beraktivitas di dalam ruangan ketika udara luar kurang baik.',
              scrollAlignment: 0.5,
            ),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman rekomendasi aktivitas. Aktivitas dipilih otomatis sesuai kualitas udara: outdoor bila udara baik, indoor bila udara buruk. Ada daftar aktivitas dengan durasi dan intensitasnya. Katakan buka beserta nama aktivitas untuk melihat detailnya.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final p = widget.indoor ? _indoorPalette : _outdoorPalette;
    final items = widget.indoor ? _indoorItems : _outdoorItems;
    final kind = widget.indoor ? 'Indoor' : 'Outdoor';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6F1),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: SoftLeavesPainter(_anim, p.leaf)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Reveal(
                    animation: _anim,
                    begin: 0.0,
                    end: 0.35,
                    child: _header(kind),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _r(0.08, 0.5, KeyedSubtree(key: _kInfo, child: _infoCard(p))),
                        const SizedBox(height: 22),
                        _r(
                          0.2,
                          0.6,
                          KeyedSubtree(
                            key: _kHead,
                            child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Aktivitas $kind',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: TC.dark,
                                  ),
                                ),
                              ),
                              Text(
                                '${items.length} aktivitas',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: TC.hint),
                              ),
                            ],
                          ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (int i = 0; i < items.length; i++) ...[
                          _r(
                            0.28 + i * 0.1,
                            0.68 + i * 0.1,
                            i == 0
                                ? KeyedSubtree(
                                    key: _kCard,
                                    child: _activityCard(items[i], p))
                                : _activityCard(items[i], p),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (widget.indoor) ...[
                          const SizedBox(height: 6),
                          _r(0.6, 1.0, KeyedSubtree(key: _kNote, child: _warningNote())),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: TC.dark),
        ),
      ),
    );
  }

  Widget _header(String kind) {
    return Row(
      children: [
        _circleButton(Icons.arrow_back_rounded, () => Navigator.maybePop(context)),
        Expanded(
          child: Center(
            child: Text(
              'Rekomendasi $kind',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TC.dark,
              ),
            ),
          ),
        ),
        _circleButton(
          Icons.home_outlined,
          () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ],
    );
  }

  Widget _metric(_Palette p, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: p.iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.upperLabels ? label.toUpperCase() : label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  letterSpacing: p.upperLabels ? 0.8 : 0,
                  fontWeight: p.labelWeight,
                  color: p.labelColor,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: p.valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoCard(_Palette p) {
    final desc = widget.indoor
        ? 'Tetap aktif di dalam ruangan dengan udara bersih. Pilih latihan '
            'yang nyaman dan sesuaikan dengan kemampuan tubuhmu.'
        : (widget.ispu <= 50
            ? 'Cocok untuk aktivitas ringan di luar ruangan. Pilih '
                'rekomendasi yang sesuai dengan energi dan tujuan '
                'kebugaranmu hari ini.'
            : 'Masih aman untuk aktivitas ringan di luar ruangan. Kelompok '
                'sensitif sebaiknya lebih berhati-hati dan tidak terlalu '
                'lama di luar.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: p.iconCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.home_outlined, size: 23, color: p.iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KALIMANTAN TENGAH',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: p.regionColor,
                      ),
                    ),
                    Text(
                      'Jekan Raya, Palangka Raya',
                      style: GoogleFonts.poppins(fontSize: 11.5, color: TC.dark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.infoBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.infoBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _metric(p, Icons.air_rounded, 'Kualitas udara',
                    ispuCategory(widget.ispu)),
                const SizedBox(height: 12),
                _metric(p, Icons.cloud_outlined, 'ISPU', '${widget.ispu}'),
                const SizedBox(height: 12),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    height: 1.6,
                    color: p.infoDesc,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photo(_Activity a, _Palette p) {
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: p.photoRing,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),

        child: Image.asset(
          a.asset,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: p.iconCircle,
            alignment: Alignment.center,
            child: Icon(a.icon, size: 32, color: p.iconColor),
          ),
        ),
      ),
    );
  }

  Widget _activityCard(_Activity a, _Palette p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.cardBorder, width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: p.cardBg,
        ),
        boxShadow: [
          BoxShadow(
            color: p.cardBorder.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _photo(a, p),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: p.title,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: p.chipBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            a.duration,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: p.chipText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          a.level,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: p.levelText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            a.desc,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.6,
              color: p.descText,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: p.button),
              boxShadow: [
                BoxShadow(
                  color: p.button.last.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),

                onTap: () => widget.indoor
                    ? openIndoorActivityDetail(context, a.title)
                    : openOutdoorActivityDetail(context, a.title),
                child: Center(
                  child: Text(
                    'Lihat Detail',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _warningNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE05A5A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline_rounded,
                size: 18, color: Color(0xFFD64545)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ruang masih berasap? Tunda peregangan dan yoga. Cari udara '
              'bersih; berhenti jika bergejala.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.5,
                color: const Color(0xFFD64545),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
