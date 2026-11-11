import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';
import 'activity_recommendation_page.dart';

class _Range {
  final String label;
  final List<double> values;
  final List<String> xLabels;
  final String nowLabel;
  const _Range(this.label, this.values, this.xLabels, this.nowLabel);
}

const List<_Range> _ranges = [
  _Range(
    '6 jam',
    [285, 300, 342, 330, 395, 440, 428, 470, 520, 505, 580, 640, 615, 700, 760,
      735, 800, 850, 883.2],
    ['08.30', '10.30', '12.30', '14.30'],
    '14.30 WIB · saat ini',
  ),
  _Range(
    '12 jam',
    [255, 270, 300, 290, 340, 380, 360, 420, 470, 455, 520, 580, 560, 640, 720,
      690, 770, 830, 883.2],
    ['02.30', '06.30', '10.30', '14.30'],
    '14.30 WIB · saat ini',
  ),
  _Range(
    '24 jam',
    [270, 260, 300, 340, 310, 380, 350, 300, 280, 330, 420, 480, 460, 540, 620,
      600, 700, 760, 883.2],
    ['14.30', '20.30', '02.30', '08.30', '14.30'],
    '14.30 WIB · saat ini',
  ),
  _Range(
    '7 hari',
    [270, 300, 280, 340, 420, 380, 450, 520, 500, 590, 560, 650, 720, 690, 780,
      760, 830, 860, 883.2],
    ['01 Nov', '03 Nov', '05 Nov', '07 Nov'],
    '07 Nov · saat ini',
  ),
];

class AiAnalysisPage extends StatefulWidget {
  const AiAnalysisPage({super.key});

  @override
  State<AiAnalysisPage> createState() => _AiAnalysisPageState();
}

class _AiAnalysisPageState extends State<AiAnalysisPage>
    with TickerProviderStateMixin {
  late final AnimationController _anim; 
  late final AnimationController _chart; 
  late final Animation<double> _tip;
  int _range = 0;

  static const _bg = Color(0xFFF4F6F2);
  static const _danger = Color(0xFFB3261E);
  static const _dangerDeep = Color(0xFF8E1B1B);
  static const _dangerTint = Color(0xFFFDECE8);
  static const _pill = Color(0xFF1F6B4F);
  static const _tealCard = Color(0xFF1B7A5F);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AnimationBehavior.preserve,
    )..forward();

    _chart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      animationBehavior: AnimationBehavior.preserve,
    );
    _tip = CurvedAnimation(
      parent: _chart,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted) _chart.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _chart.dispose();
    super.dispose();
  }

  void _pickRange(int i) {
    if (i == _range) return;
    setState(() => _range = i);
    _chart.forward(from: 0);
  }

  Widget _r(double b, double e, Widget child) =>
      Reveal(animation: _anim, begin: b, end: e, child: child);

  List<CoachStep> get _tour => const [
        CoachStep(title: 'Analisis AI', body: 'Penjelasan mendalam tentang kondisi dan tren kualitas udara di wilayahmu.'),
        CoachStep(title: 'Angka dan grafik', body: 'Lihat status udara, ISPU, kepadatan asap, dan grafik PM2.5. Data masih simulasi.'),
        CoachStep(title: 'Interpretasi TEDUH AI', body: 'Bagian ini menafsirkan data: pola asap, kemungkinan penyebab, dan apa artinya bagi kesehatanmu.'),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'analysis',
        tour: _tour,
        guide: PageGuide(content: () => 'Ini halaman Analisis AI. Berisi status udara di lokasimu, ISPU, kepadatan asap, grafik PM2.5, dan interpretasi TEDUH AI tentang pola asap. Data masih simulasi. Ucapkan kembali untuk ke halaman sebelumnya.'),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    final sections = <Widget>[
      _simulationLabel(),
      _headlineBlock(),
      _ispuBox(),
      _chartCard(),
      _interpretationCard(),
      _riskTitle(),
      _riskCard(),
      _todoTitle(),
      _todoCard(context),
      _sourceCard(),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Reveal(
              animation: _anim,
              begin: 0.0,
              end: 0.35,
              child: _header(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < sections.length; i++) ...[
                      _r(_begin(i), _begin(i) + 0.4, sections[i]),
                      SizedBox(height: _gapAfter(i)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _begin(int i) {
    final b = 0.08 + i * 0.07;
    return b > 0.6 ? 0.6 : b;
  }

  double _gapAfter(int i) {
    switch (i) {
      case 0:
        return 14;
      case 5:
        return 12;
      case 7:
        return 10;
      case 9:
        return 0;
      default:
        return 16;
    }
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: Color(0xFFCFE8D2))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: TC.dark,
            iconSize: 26,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analisis AI',
                  style: GoogleFonts.poppins(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: TC.dark,
                  ),
                ),
                Text(
                  'Telemetri & interpretasi asap',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
                ),
              ],
            ),
          ),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => showSoon(context, 'Menu'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: TC.border),
              ),
              child: const Icon(Icons.more_horiz_rounded,
                  size: 22, color: TC.dark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _simulationLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: TC.hint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Data simulasi · 07 Nov 2026 · 14.30 WIB',
            style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
          ),
        ],
      ),
    );
  }

  Widget _headlineBlock() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'JEKAN RAYA · PM2.5',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: TC.greenDeep,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _dangerDeep,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      'BERBAHAYA',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '883.2',
            style: GoogleFonts.poppins(
              fontSize: 76,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: _dangerDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'µg/m³',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: _danger,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Partikel kecil. ',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    color: TC.dark,
                  ),
                ),
                TextSpan(
                  text: 'Risiko besar.',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    color: TC.green,
                  ),
                ),
              ],
            ),
            style: GoogleFonts.poppins(
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Asap sangat pekat. Partikel halus dapat masuk jauh ke '
            'paru-paru. Semua warga perlu mengurangi paparan.',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.6,
              color: TC.hint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ispuBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _dangerTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9908A)),
      ),
      child: Row(
        children: [
          Text(
            '462',
            style: GoogleFonts.poppins(
              fontSize: 38,
              height: 1.1,
              fontWeight: FontWeight.w400,
              color: _danger,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ISPU · Berbahaya',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _dangerDeep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Indeks terpisah dari konsentrasi PM2.5. Tidak dihitung '
                  'sebagai konversi di sini.',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    height: 1.45,
                    color: _danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard() {
    final data = _ranges[_range];

    return _Card(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kepadatan asap',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TC.dark,
                      ),
                    ),
                    Text(
                      'Jejak konsentrasi partikel halus',
                      style:
                          GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bar_chart_rounded,
                  size: 24, color: TC.greenDeep),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                for (int i = 0; i < _ranges.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _pickRange(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i == _range ? _pill : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          _ranges[i].label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: i == _range
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: i == _range ? Colors.white : TC.hint,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'PM2.5 (µg/m³) · Data simulasi',
            style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
          ),
          const SizedBox(height: 4),

          SizedBox(
            height: 240,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LineChartPainter(
                      values: data.values,
                      xLabels: data.xLabels,
                      progress: _chart,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 24,
                  child: FadeTransition(
                    opacity: _tip,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA83A3A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.nowLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          Text(
                            '883.2 µg/m³',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: _danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Partikel halus · tren ilustratif meningkat',
                style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _interpretationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _tealCard,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  size: 18, color: Color(0xFFBDE8A0)),
              const SizedBox(width: 8),
              Text(
                'Interpretasi TEDUH AI',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFBDE8A0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pola konsisten dengan asap Karhutla.',
            style: GoogleFonts.poppins(
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Lonjakan partikel dan tren yang bertahan tinggi mengindikasikan '
            'paparan asap kebakaran hutan dan lahan. Ini interpretasi '
            'ilustratif, bukan konfirmasi titik api atau prediksi '
            'penyebaran.',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Analisis otomatis · perlu pemeriksaan sumber resmi',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RISIKO PAPARAN · SANGAT TINGGI',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: _dangerDeep,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bukan hanya kelompok rentan.',
            style: GoogleFonts.poppins(
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: TC.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Warga Jekan Raya dapat mengalami iritasi mata, batuk, dan '
            'sesak. Paparan dapat memperburuk penyakit paru atau jantung.',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.6,
              color: TC.hint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskCard() {
    return _Card(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.groups_outlined,
            iconBg: _dangerTint,
            iconColor: _danger,
            title: 'Risiko untuk seluruh warga',
            body: 'Batasi keluar rumah. Anak, lansia, ibu hamil, dan '
                'penderita penyakit kronis perlu perlindungan lebih ketat.',
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.monitor_heart_outlined,
            iconBg: _dangerTint,
            iconColor: _danger,
            title: 'Kenali tanda kegawatan',
            body: 'Sesak berat, nyeri dada, atau penurunan kesadaran '
                'memerlukan pertolongan medis segera.',
          ),
        ],
      ),
    );
  }

  Widget _todoTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        'Yang perlu dilakukan',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: TC.dark,
        ),
      ),
    );
  }

  Widget _todoCard(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.home_outlined,
            iconBg: TC.iconBox,
            iconColor: TC.green,
            title: '01 · Buat ruang udara bersih',
            body: 'Tutup jendela dan pintu. Gunakan penyaring HEPA; hindari '
                'sumber asap di dalam rumah.',
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            iconBg: TC.iconBox,
            iconColor: TC.green,
            title: '02 · Bila keluar tidak terhindarkan',
            body: 'Pakai N95 rapat. Persingkat durasi di luar dan hindari '
                'aktivitas berat.',
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.location_on_outlined,
            iconBg: TC.iconBox,
            iconColor: TC.green,
            title: '03 · Cari tempat lebih aman',
            body: 'Jika asap menembus rumah, pertimbangkan pindah ke ruang '
                'berfilter. Ikuti arahan evakuasi resmi.',
          ),
          const SizedBox(height: 14),
          Material(
            color: const Color(0xFFE8F1EA),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => openActivityRecommendation(
                context,
                ispu: kSimulatedIspu,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lihat panduan TEDUH',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: TC.greenDeep,
                        ),
                      ),
                    ),
                    const Icon(Icons.north_east_rounded,
                        size: 18, color: TC.greenDeep),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sourceCard() {
    Widget item(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: TC.dark,
              ),
            ),
          ],
        ),
      );
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage_outlined,
                  size: 22, color: TC.greenDeep),
              const SizedBox(width: 10),
              Text(
                'Sumber & validasi data',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TC.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          item('Sumber yang direncanakan', 'BMKG'),
          item('Waktu sampel ilustratif', '07 Nov 2026 · 14.30 WIB'),
          item('Lokasi pelaporan', 'Jekan Raya, Palangka Raya'),
          const Divider(height: 1, thickness: 1, color: TC.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 18, color: _danger),
              const SizedBox(width: 8),
              Text(
                'Simulasi · belum terverifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Belum terhubung ke umpan langsung BMKG. Nilai, grafik, dan '
            'waktu adalah konten desain, bukan data observasi terverifikasi.',
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              height: 1.55,
              color: TC.hint,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> xLabels;
  final Animation<double> progress;

  static const double _minV = 250;
  static const double _maxV = 1000;
  static const Color _line = Color(0xFFB23A3A);

  _LineChartPainter({
    required this.values,
    required this.xLabels,
    required this.progress,
  }) : super(repaint: progress);

  TextPainter _tp(String text) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.poppins(fontSize: 9, color: TC.hint),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void paint(Canvas canvas, Size size) {
    const left = 46.0;
    const right = 12.0;
    const top = 38.0;
    const bottom = 28.0;
    final chart = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);

    double yOf(double v) =>
        chart.bottom - (v - _minV) / (_maxV - _minV) * chart.height;

    final grid = Paint()
      ..color = const Color(0xFFE9EEEA)
      ..strokeWidth = 1;
    const ticks = [1000.0, 750.0, 500.0, 250.0];
    for (final v in ticks) {
      final y = yOf(v);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      final tp = _tp(v == 1000 ? '1.000' : v.toInt().toString());
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final n = xLabels.length;
    for (int i = 0; i < n; i++) {
      final x = chart.left + chart.width * (n == 1 ? 0 : i / (n - 1));
      final tp = _tp(xLabels[i]);
      double dx = x - tp.width / 2;
      if (dx < 0) dx = 0;
      if (dx + tp.width > size.width) dx = size.width - tp.width;
      tp.paint(canvas, Offset(dx, chart.bottom + 9));
    }

    if (values.length < 2) return;

    final pts = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(
          chart.left + chart.width * i / (values.length - 1),
          yOf(values[i]),
        ),
    ];

    final p = Curves.easeOutCubic.transform(progress.value);
    final revealX = chart.left + chart.width * p;

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    final fillPath = Path.from(linePath)
      ..lineTo(pts.last.dx, chart.bottom)
      ..lineTo(pts.first.dx, chart.bottom)
      ..close();

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, revealX, size.height));
    canvas.drawPath(
      fillPath,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _line.withValues(alpha: 0.22),
            _line.withValues(alpha: 0.0),
          ],
        ).createShader(chart),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = _line,
    );
    canvas.restore();

    double op = (p - 0.9) / 0.1;
    if (op < 0) op = 0;
    if (op > 1) op = 1;
    if (op > 0) {
      final last = pts.last;
      canvas.drawLine(
        last,
        Offset(last.dx, chart.bottom),
        Paint()
          ..strokeWidth = 1.2
          ..color = const Color(0xFF3A2A2A).withValues(alpha: op),
      );
      canvas.drawCircle(
        last,
        8,
        Paint()..color = _line.withValues(alpha: 0.25 * op),
      );
      canvas.drawCircle(
        last,
        4.5,
        Paint()..color = _line.withValues(alpha: op),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.values != values || old.xLabels != xLabels;
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
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
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, thickness: 1, color: TC.divider),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;

  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: TC.dark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  height: 1.55,
                  color: TC.hint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
