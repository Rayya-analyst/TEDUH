import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/air_quality_models.dart';
import '../services/air_quality_repository.dart';
import '../services/nasa_firms_provider.dart';
import '../state/app_settings.dart';
import '../state/monitoring_state.dart';
import '../widgets/coach_marks.dart';
import '../widgets/teduh_common.dart';
import '../widgets/voice_scope.dart';
import 'activity_recommendation_page.dart';

class _RangeOption {
  final String label;
  final Duration duration;
  const _RangeOption(this.label, this.duration);
}

const List<_RangeOption> _rangeOptions = [
  _RangeOption('6 jam', Duration(hours: 6)),
  _RangeOption('12 jam', Duration(hours: 12)),
  _RangeOption('24 jam', Duration(hours: 24)),
  _RangeOption('7 hari', Duration(days: 7)),
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
  bool _loadingChart = false;
  List<double> _chartValues = [];
  List<String> _chartXLabels = [];
  String _nowLabel = '';
  String _nowValStr = '--';
  bool _hasHistoryData = false;
  int? _hotspotCount;
  String _nasaKey = '';

  static const _bg = Color(0xFFF4F6F2);
  static const _pill = Color(0xFF1F6B4F);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistoryData();
      _loadNasaHotspots();
    });
  }

  Future<void> _loadNasaHotspots() async {
    final key = await NasaFirmsHotspotProvider.getEffectiveMapKey();
    if (!mounted) return;
    setState(() => _nasaKey = key);
    if (key.isNotEmpty) {
      try {
        final spots =
            await NasaFirmsHotspotProvider().fetchHotspotsForIndonesia(mapKey: key);
        if (!mounted) return;
        setState(() => _hotspotCount = spots.length);
      } catch (_) {}
    } else {
      if (mounted) {
        setState(() => _hotspotCount = null);
      }
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _chart.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    if (!mounted) return;
    setState(() => _loadingChart = true);
    final mon = MonitoringState.instance;
    final opt = _rangeOptions[_range];
    try {
      final readings = await AirQualityRepository.instance.getHistoricalReadings(
        site: mon.selectedSite,
        sourceId: mon.selectedSource.sourceId,
        duration: opt.duration,
      );
      if (!mounted) return;
      final valid = readings
          .where((r) => r.pm25 != null || r.officialIspu != null)
          .toList()
        ..sort((a, b) => a.observedAt.compareTo(b.observedAt));

      if (valid.length >= 2) {
        final vals = valid.map((r) => r.pm25 ?? r.officialIspu!.toDouble()).toList();
        final List<String> labels = [];
        final step = (valid.length / 4).ceil().clamp(1, valid.length);
        for (int i = 0; i < valid.length; i += step) {
          final dt = valid[i].observedAt.toLocal();
          labels.add(opt.duration.inHours <= 24
              ? '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}'
              : '${dt.day}/${dt.month}');
        }
        final lastDt = valid.last.observedAt.toLocal();
        final lastLabel = opt.duration.inHours <= 24
            ? '${lastDt.hour.toString().padLeft(2, '0')}.${lastDt.minute.toString().padLeft(2, '0')} WIB · saat ini'
            : '${lastDt.day}/${lastDt.month} · saat ini';
        final valStr = valid.last.pm25 != null
            ? '${valid.last.pm25!.toStringAsFixed(1).replaceAll('.', ',')} µg/m³'
            : '${valid.last.officialIspu} ISPU';
        if (!mounted) return;
        setState(() {
          _loadingChart = false;
          _hasHistoryData = true;
          _chartValues = vals;
          _chartXLabels = labels;
          _nowLabel = lastLabel;
          _nowValStr = valStr;
        });
        _chart.forward(from: 0);
      } else {
        if (!mounted) return;
        setState(() {
          _loadingChart = false;
          _hasHistoryData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingChart = false;
          _hasHistoryData = false;
        });
      }
    }
  }

  void _pickRange(int i) {
    if (i == _range) return;
    setState(() => _range = i);
    _loadHistoryData();
  }

  Widget _r(double b, double e, Widget child) =>
      Reveal(animation: _anim, begin: b, end: e, child: child);

  List<CoachStep> get _tour => const [
        CoachStep(
            title: 'Analisis AI',
            body: 'Penjelasan mendalam tentang kondisi dan tren kualitas udara di wilayahmu.'),
        CoachStep(
            title: 'Angka dan grafik',
            body: 'Lihat status udara, ISPU, kepadatan asap, dan grafik PM2.5 aktual dari stasiun KLHK.'),
        CoachStep(
            title: 'Interpretasi TEDUH AI',
            body: 'Bagian ini menafsirkan data: pola asap, kemungkinan penyebab, dan apa artinya bagi kesehatanmu.'),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'analysis',
        tour: _tour,
        guide: PageGuide(
          content: () {
            final a = AppSettings.instance.snapshot;
            return 'Ini halaman Analisis AI. Berisi status udara di ${a.location}, '
                'ISPU ${a.ispu} (${a.status}), grafik tren PM2.5, dan interpretasi '
                'TEDUH AI. Ucapkan kembali untuk ke halaman sebelumnya.';
          },
        ),
        child: AnimatedBuilder(
          animation: MonitoringState.instance,
          builder: (ctx, child) => _buildBody(ctx),
        ),
      );

  Widget _buildBody(BuildContext context) {
    final a = AppSettings.instance.snapshot;
    final mon = MonitoringState.instance;
    final cat = mon.currentReading?.category ?? IspuCategory.fromIspu(a.ispu);

    final dangerColor = _categoryColor(cat);
    final dangerDeep = _categoryDeepColor(cat);
    final dangerTint = _categoryTint(cat);
    final tealCard = _categoryCardBg(cat);

    final sections = <Widget>[
      _dataLabel(a, mon),
      _headlineBlock(a, cat, dangerDeep),
      _ispuBox(a, cat, dangerTint, dangerDeep, dangerColor),
      _chartCard(dangerColor),
      _buildMultiSourceComparisonCard(a, mon),
      _interpretationCard(a, cat, tealCard),
      _riskTitle(a, cat, dangerDeep),
      _riskCard(dangerTint, dangerColor),
      _todoTitle(),
      _todoCard(context, a),
      _sourceCard(a, mon),
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
      case 6:
        return 12;
      case 8:
        return 10;
      case 10:
        return 0;
      default:
        return 16;
    }
  }

  Color _categoryColor(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return const Color(0xFF2E7D32);
      case IspuCategory.sedang:
        return const Color(0xFFF9A825);
      case IspuCategory.tidakSehat:
        return const Color(0xFFE65100);
      case IspuCategory.sangatTidakSehat:
        return const Color(0xFF880E4F);
      case IspuCategory.berbahaya:
        return const Color(0xFFB3261E);
      case IspuCategory.tidakTersedia:
        return const Color(0xFF6B7773);
    }
  }

  Color _categoryDeepColor(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return const Color(0xFF1B5E20);
      case IspuCategory.sedang:
        return const Color(0xFFE65100);
      case IspuCategory.tidakSehat:
        return const Color(0xFFBF360C);
      case IspuCategory.sangatTidakSehat:
        return const Color(0xFF6A0036);
      case IspuCategory.berbahaya:
        return const Color(0xFF8E1B1B);
      case IspuCategory.tidakTersedia:
        return const Color(0xFF455A64);
    }
  }

  Color _categoryTint(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return const Color(0xFFE8F5E9);
      case IspuCategory.sedang:
        return const Color(0xFFFFF8E1);
      case IspuCategory.tidakSehat:
        return const Color(0xFFFBE9E7);
      case IspuCategory.sangatTidakSehat:
        return const Color(0xFFFCE4EC);
      case IspuCategory.berbahaya:
        return const Color(0xFFFDECE8);
      case IspuCategory.tidakTersedia:
        return const Color(0xFFECEFF1);
    }
  }

  Color _categoryCardBg(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return const Color(0xFF2E7D32);
      case IspuCategory.sedang:
        return const Color(0xFFE65100);
      case IspuCategory.tidakSehat:
        return const Color(0xFF8D3B1B);
      case IspuCategory.sangatTidakSehat:
        return const Color(0xFF6A1B4D);
      case IspuCategory.berbahaya:
        return const Color(0xFF1B7A5F);
      case IspuCategory.tidakTersedia:
        return const Color(0xFF37474F);
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
                  'Telemetri & interpretasi kondisi udara',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataLabel(AirSnapshot a, MonitoringState mon) {
    final ts = mon.currentReading?.observedAt;
    String timeStr;
    if (ts != null) {
      final local = ts.toLocal();
      timeStr =
          '${local.day.toString().padLeft(2, '0')} ${_monthName(local.month)} ${local.year} · '
          '${local.hour.toString().padLeft(2, '0')}.${local.minute.toString().padLeft(2, '0')} WIB';
    } else {
      timeStr = a.updatedAt;
    }
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
          Expanded(
            child: Text(
              'Stasiun KLHK · $timeStr',
              style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headlineBlock(AirSnapshot a, IspuCategory cat, Color deepColor) {
    final location = (AppSettings.instance.locationName.isNotEmpty
            ? AppSettings.instance.locationName
            : MonitoringState.instance.selectedRegion.regency)
        .toUpperCase();
    final pm25Str = a.pm25.replaceAll(' µg/m³', '');
    final parsed = double.tryParse(pm25Str.replaceAll(',', '.'));
    final double pm25Val = (parsed != null && parsed > 0)
        ? parsed
        : (a.pm25Value > 0
            ? a.pm25Value
            : (a.ispu > 0
                ? (a.ispu <= 50
                    ? a.ispu * 0.31
                    : (a.ispu <= 100
                        ? 15.5 + (a.ispu - 50) * 0.4
                        : 35.5 + (a.ispu - 100) * 0.55))
                : 22.5));
    final pm25Display = pm25Val.toStringAsFixed(1).replaceAll('.', ',');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$location · PM2.5',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: TC.greenDeep,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: deepColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      cat.label.toUpperCase(),
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
            pm25Display,
            style: GoogleFonts.poppins(
              fontSize: 76,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: deepColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'µg/m³',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: _categoryColor(cat),
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Partikel kecil. ',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: TC.dark),
                ),
                TextSpan(
                  text: _riskTagline(cat),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: TC.green),
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
            _riskDesc(cat),
            style: GoogleFonts.poppins(fontSize: 12.5, height: 1.6, color: TC.hint),
          ),
        ],
      ),
    );
  }

  Widget _ispuBox(AirSnapshot a, IspuCategory cat, Color tint, Color deep, Color col) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: col.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            a.ispu > 0 ? '${a.ispu}' : '--',
            style: GoogleFonts.poppins(
              fontSize: 38,
              height: 1.1,
              fontWeight: FontWeight.w400,
              color: col,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ISPU · ${cat.label}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: deep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Indeks Standar Pencemar Udara dari stasiun resmi KLHK.',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    height: 1.45,
                    color: col,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(Color lineColor) {
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
                      style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bar_chart_rounded, size: 24, color: TC.greenDeep),
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
                for (int i = 0; i < _rangeOptions.length; i++)
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
                          _rangeOptions[i].label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight:
                                i == _range ? FontWeight.w600 : FontWeight.w400,
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
            'PM2.5 (µg/m³) · ${MonitoringState.instance.currentReading?.provenanceText ?? "Satelit CAMS / Stasiun Resmi"}',
            style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
          ),
          const SizedBox(height: 4),
          if (_loadingChart)
            const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (!_hasHistoryData)
            SizedBox(
              height: 240,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 36, color: TC.hint.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'Data historis belum tersedia\nuntuk rentang waktu ini.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 11, color: TC.hint),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 240,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LineChartPainter(
                        values: _chartValues,
                        xLabels: _chartXLabels,
                        progress: _chart,
                        lineColor: lineColor,
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
                          color: lineColor.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nowLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            Text(
                              _nowValStr,
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
                decoration: BoxDecoration(
                  color: lineColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Partikel halus · tren PM2.5 aktual',
                style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _interpretationCard(AirSnapshot a, IspuCategory cat, Color cardBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
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
            _interpretationTitle(cat),
            style: GoogleFonts.poppins(
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _interpretationBody(a, cat),
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'TEDUH AI menganalisis data PM2.5 dari Open-Meteo CAMS & Firestore secara otomatis, lalu merekomendasikan keputusan aktivitas. Ini keluaran mesin — bukan konfirmasi resmi. Verifikasi melalui KLHK bila diperlukan.',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskTitle(AirSnapshot a, IspuCategory cat, Color deepColor) {
    final location = MonitoringState.instance.selectedRegion.regency;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RISIKO PAPARAN · ${_riskLevel(cat).toUpperCase()}',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: deepColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _riskTitle2(cat),
            style: GoogleFonts.poppins(
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: TC.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Warga $location ${_riskImpact(cat)}',
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

  Widget _riskCard(Color tint, Color col) {
    return _Card(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.groups_outlined,
            iconBg: tint,
            iconColor: col,
            title: 'Risiko untuk seluruh warga',
            body: 'Batasi keluar rumah. Anak, lansia, ibu hamil, dan '
                'penderita penyakit kronis perlu perlindungan lebih ketat.',
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.monitor_heart_outlined,
            iconBg: tint,
            iconColor: col,
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

  Widget _todoCard(BuildContext context, AirSnapshot a) {
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
                ispu: a.ispu,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Widget _sourceCard(AirSnapshot a, MonitoringState mon) {
    Widget item(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint)),
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

    final ts = mon.currentReading?.observedAt;
    final timeStr = ts != null
        ? () {
            final l = ts.toLocal();
            return '${l.day.toString().padLeft(2, '0')} ${_monthName(l.month)} ${l.year} · '
                '${l.hour.toString().padLeft(2, '0')}.${l.minute.toString().padLeft(2, '0')} WIB';
          }()
        : a.updatedAt;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage_outlined, size: 22, color: TC.greenDeep),
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
          item('Sumber', a.sourceName),
          item('Waktu pengukuran', timeStr),
          item('Lokasi stasiun', a.location),
          const Divider(height: 1, thickness: 1, color: TC.divider),
          const SizedBox(height: 12),
          Text(
            'Validasi Multi-Sumber TEDUH:',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: TC.dark),
          ),
          const SizedBox(height: 6),
          Text(
            '• Stasiun Fisik KLHK: Pengukuran konsentrasi polutan langsung di permukaan tanah.\n'
            '• Satelit Copernicus CAMS: Model asimilasi atmosfer vertikal untuk proyeksi tren.\n'
            '• NASA FIRMS: Deteksi radiasi termal titik api (hotspot), bukan angka PM2.5.\n'
            'Seluruh data ISPU resmi pada aplikasi selalu bersumber dari stasiun pemantau KLHK.',
            style: GoogleFonts.poppins(fontSize: 10, height: 1.55, color: TC.hint),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSourceComparisonCard(AirSnapshot a, MonitoringState mon) {
    final reading = mon.currentReading;

    if (reading == null) {
      return _Card(
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 14),
            Text(
              'Memuat data analisis...',
              style: GoogleFonts.poppins(fontSize: 12, color: TC.hint),
            ),
          ],
        ),
      );
    }

    final effectiveNasaKey = _nasaKey.isNotEmpty
        ? _nasaKey
        : const String.fromEnvironment('NASA_FIRMS_MAP_KEY', defaultValue: '');

    final pm25Str = reading.pm25 != null
        ? reading.pm25!.toStringAsFixed(1)
        : (a.pm25.replaceAll(' µg/m³', '').replaceAll(',', '.'));
    final ispuStr = reading.officialIspu != null ? '${reading.officialIspu}' : '${a.ispu}';

    final camsNilai = (reading.sourceId == 'cams_openmeteo' && reading.pm25 != null)
        ? reading.pm25!.toStringAsFixed(1)
        : '—';

    final rows = <_ComparisonRow>[
      _ComparisonRow(
        provider: 'KLHK / Firestore',
        parameter: 'PM2.5 & ISPU',
        nilai: '$pm25Str / $ispuStr',
        unit: 'µg/m³ / ISPU',
        status: 'Aktif',
        statusColor: const Color(0xFF176D59),
      ),
      _ComparisonRow(
        provider: 'Open-Meteo CAMS',
        parameter: 'PM2.5, PM10, O₃',
        nilai: camsNilai,
        unit: 'µg/m³',
        status: 'Aktif',
        statusColor: const Color(0xFF176D59),
      ),
      _ComparisonRow(
        provider: 'NASA FIRMS',
        parameter: 'Hotspot / Titik Api',
        nilai: effectiveNasaKey.isNotEmpty
            ? (_hotspotCount != null ? '$_hotspotCount' : '...')
            : '—',
        unit: 'titik',
        status: effectiveNasaKey.isNotEmpty ? 'Aktif' : 'Opsional · Belum Aktif',
        statusColor: effectiveNasaKey.isNotEmpty
            ? const Color(0xFF176D59)
            : const Color(0xFF64748B),
        onTap: () => _showNasaConfigDialog(context),
      ),
    ];

    return _Card(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded,
                  size: 22, color: TC.greenDeep),
              const SizedBox(width: 10),
              Text(
                'Perbandingan Multi-Sumber',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TC.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sumber data aktif yang digunakan TEDUH untuk lokasi ini',
            style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
          ),
          const SizedBox(height: 14),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.2),
              1: FlexColumnWidth(1.8),
              2: FlexColumnWidth(1.4),
              3: FlexColumnWidth(1.0),
              4: FlexColumnWidth(1.8),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFE8F0EA), width: 1)),
                ),
                children: [
                  for (final h in [
                    'Provider',
                    'Parameter',
                    'Nilai',
                    'Unit',
                    'Status'
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        h,
                        style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: TC.hint),
                      ),
                    ),
                ],
              ),
              for (final row in rows)
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Color(0xFFF0F4F0), width: 0.8)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        row.provider,
                        style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: TC.dark),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        row.parameter,
                        style: GoogleFonts.poppins(
                            fontSize: 9.5, color: TC.hint),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        row.nilai,
                        style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: TC.dark),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        row.unit,
                        style: GoogleFonts.poppins(
                            fontSize: 9, color: TC.hint),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: row.onTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: row.statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: row.statusColor.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  row.status,
                                  style: GoogleFonts.poppins(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: row.statusColor,
                                  ),
                                ),
                              ),
                              if (row.onTap != null) ...[
                                const SizedBox(width: 3),
                                Icon(Icons.edit_outlined,
                                    size: 9.5, color: row.statusColor),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Open-Meteo CAMS & Firestore: data ditampilkan langsung. NASA FIRMS memerlukan MAP_KEY gratis (opsional · ketuk badge untuk mengatur atau daftar di firms.modaps.eosdis.nasa.gov). Nilai "—" = data tidak tersedia saat ini.',
            style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
          ),
        ],
      ),
    );
  }

  void _showNasaConfigDialog(BuildContext context) {
    final controller = TextEditingController(text: _nasaKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.satellite_alt_rounded,
                color: Color(0xFF176D59), size: 22),
            const SizedBox(width: 8),
            Text(
              'NASA FIRMS MAP_KEY',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kunci API gratis untuk deteksi titik panas satelit (VIIRS/MODIS). Dapatkan di firms.modaps.eosdis.nasa.gov/api/map_key/',
              style: GoogleFonts.poppins(fontSize: 11, color: TC.hint),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Masukkan 32 digit MAP_KEY...',
                hintStyle: GoogleFonts.poppins(fontSize: 11, color: TC.hint),
                filled: true,
                fillColor: const Color(0xFFF4F6F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2EBE5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2EBE5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF176D59), width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (_nasaKey.isNotEmpty)
            TextButton(
              onPressed: () async {
                await NasaFirmsHotspotProvider.saveMapKey('');
                if (ctx.mounted) Navigator.pop(ctx);
                _loadNasaHotspots();
              },
              child: Text('Hapus Kunci',
                  style: GoogleFonts.poppins(
                      color: Colors.red, fontSize: 12)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: TC.hint, fontSize: 12)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF176D59),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final newKey = controller.text.trim();
              await NasaFirmsHotspotProvider.saveMapKey(newKey);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadNasaHotspots();
            },
            child: Text('Simpan',
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _riskTagline(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return 'Kondisi aman.';
      case IspuCategory.sedang:
        return 'Waspadai kelompok sensitif.';
      case IspuCategory.tidakSehat:
        return 'Batasi aktivitas luar.';
      case IspuCategory.sangatTidakSehat:
        return 'Risiko serius.';
      case IspuCategory.berbahaya:
        return 'Risiko besar.';
      case IspuCategory.tidakTersedia:
        return 'Data sedang dimuat.';
    }
  }

  String _riskDesc(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return 'Kualitas udara baik. Aktivitas luar ruangan tetap aman untuk semua kalangan.';
      case IspuCategory.sedang:
        return 'Kualitas udara sedang. Kelompok sensitif seperti penderita asma perlu berhati-hati.';
      case IspuCategory.tidakSehat:
        return 'Udara tidak sehat. Kurangi aktivitas luar ruangan, terutama untuk anak dan lansia.';
      case IspuCategory.sangatTidakSehat:
        return 'Udara sangat tidak sehat. Semua warga disarankan menghindari aktivitas di luar.';
      case IspuCategory.berbahaya:
        return 'Asap sangat pekat. Partikel halus dapat masuk jauh ke paru-paru. Semua warga perlu mengurangi paparan.';
      case IspuCategory.tidakTersedia:
        return 'Data kualitas udara sedang dimuat dari stasiun KLHK.';
    }
  }

  String _interpretationTitle(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return 'Udara bersih, aktivitas aman.';
      case IspuCategory.sedang:
        return 'Kualitas udara moderat.';
      case IspuCategory.tidakSehat:
        return 'Potensi peningkatan asap.';
      case IspuCategory.sangatTidakSehat:
        return 'Asap terdeteksi signifikan.';
      case IspuCategory.berbahaya:
        return 'Pola konsisten dengan asap Karhutla.';
      case IspuCategory.tidakTersedia:
        return 'Memuat data analisis...';
    }
  }

  String _interpretationBody(AirSnapshot a, IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return 'Konsentrasi partikel PM2.5 berada pada level aman. '
            'Tidak terdeteksi indikasi asap kebakaran lahan di wilayah ini.';
      case IspuCategory.sedang:
        return 'Terdapat peningkatan konsentrasi partikel moderat. '
            'Pantau perkembangan dan siapkan masker jika diperlukan.';
      case IspuCategory.tidakSehat:
        return 'Konsentrasi PM2.5 menunjukkan polutan udara yang tidak sehat. '
            'Disarankan mengurangi paparan dan memantau informasi resmi KLHK.';
      case IspuCategory.sangatTidakSehat:
        return 'Tingkat PM2.5 yang sangat tinggi mengindikasikan kemungkinan '
            'asap kebakaran lahan. Ini interpretasi otomatis, bukan konfirmasi resmi.';
      case IspuCategory.berbahaya:
        return 'Lonjakan partikel dan tren yang bertahan tinggi mengindikasikan '
            'paparan asap kebakaran hutan dan lahan. Ini interpretasi '
            'otomatis, bukan konfirmasi titik api atau prediksi penyebaran.';
      case IspuCategory.tidakTersedia:
        return 'Data dari stasiun KLHK sedang dimuat. '
            'Interpretasi akan tersedia setelah data terbaru diterima.';
    }
  }

  String _riskLevel(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return 'Sangat Rendah';
      case IspuCategory.sedang:
        return 'Rendah';
      case IspuCategory.tidakSehat:
        return 'Sedang';
      case IspuCategory.sangatTidakSehat:
        return 'Tinggi';
      case IspuCategory.berbahaya:
        return 'Sangat Tinggi';
      case IspuCategory.tidakTersedia:
        return 'Belum Diketahui';
    }
  }

  String _riskTitle2(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return 'Kondisi aman untuk semua.';
      case IspuCategory.sedang:
        return 'Kelompok sensitif perlu waspada.';
      case IspuCategory.tidakSehat:
        return 'Batasi paparan di luar.';
      case IspuCategory.sangatTidakSehat:
        return 'Semua warga harus waspada.';
      case IspuCategory.berbahaya:
        return 'Bukan hanya kelompok rentan.';
      case IspuCategory.tidakTersedia:
        return 'Memuat data risiko...';
    }
  }

  String _riskImpact(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return 'dapat beraktivitas normal di luar ruangan.';
      case IspuCategory.sedang:
        return 'terutama yang sensitif, perlu memantau kondisi udara.';
      case IspuCategory.tidakSehat:
        return 'dapat mengalami iritasi dan gejala ringan jika terpapar lama.';
      case IspuCategory.sangatTidakSehat:
        return 'berisiko mengalami gangguan pernapasan jika berada di luar.';
      case IspuCategory.berbahaya:
        return 'dapat mengalami iritasi mata, batuk, dan sesak. Paparan dapat memperburuk penyakit paru atau jantung.';
      case IspuCategory.tidakTersedia:
        return 'sedang dimuat...';
    }
  }

  static String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return m >= 1 && m <= 12 ? months[m] : '';
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> xLabels;
  final Animation<double> progress;
  final Color lineColor;

  _LineChartPainter({
    required this.values,
    required this.xLabels,
    required this.progress,
    required this.lineColor,
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
    if (values.length < 2) return;

    const left = 46.0, right = 12.0, top = 38.0, bottom = 28.0;
    final chart = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).clamp(10, double.infinity);
    final lo = (minV - range * 0.1).floorToDouble();
    final hi = (maxV + range * 0.1).ceilToDouble();

    double yOf(double v) =>
        chart.bottom - (v - lo) / (hi - lo) * chart.height;

    final grid = Paint()
      ..color = const Color(0xFFE9EEEA)
      ..strokeWidth = 1;
    final ticks = [lo, lo + (hi - lo) / 3, lo + (hi - lo) * 2 / 3, hi];
    for (final v in ticks) {
      final y = yOf(v);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      final tp = _tp(v.toInt().toString());
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
          colors: [lineColor.withValues(alpha: 0.22), lineColor.withValues(alpha: 0.0)],
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
        ..color = lineColor,
    );
    canvas.restore();

    double op = (p - 0.9) / 0.1;
    op = op.clamp(0.0, 1.0);
    if (op > 0) {
      final last = pts.last;
      canvas.drawLine(
        last,
        Offset(last.dx, chart.bottom),
        Paint()
          ..strokeWidth = 1.2
          ..color = const Color(0xFF3A2A2A).withValues(alpha: op),
      );
      canvas.drawCircle(last, 8, Paint()..color = lineColor.withValues(alpha: 0.25 * op));
      canvas.drawCircle(last, 4.5, Paint()..color = lineColor.withValues(alpha: op));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.values != values || old.xLabels != xLabels;
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(18)});

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

class _ComparisonRow {
  final String provider;
  final String parameter;
  final String nilai;
  final String unit;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const _ComparisonRow({
    required this.provider,
    required this.parameter,
    required this.nilai,
    required this.unit,
    required this.status,
    required this.statusColor,
    this.onTap,
  });
}
