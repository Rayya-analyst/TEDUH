import 'dart:math' as math;
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const bg = Color(0xFFFBFCFA);
  static const green = Color(0xFF0F7B4F);
  static const red = Color(0xFFE8434B);
  static const dark = Color(0xFF1F2D26);
  static const hint = Color(0xFF7C8B82);
  static const bar = Color(0xFFF0F4EF);
  static const leaf = Color(0xFFA8C6A4);
  static const leafLight = Color(0xFFC6DBC2);
  static const grid = Color(0xFFEDEFEC);
}

enum _Level { baik, tidakSehat, berbahaya }

_Level _levelOf(int v) {
  if (v <= 100) return _Level.baik;
  if (v <= 300) return _Level.tidakSehat;
  return _Level.berbahaya;
}

extension _LevelX on _Level {
  String get label => switch (this) {
        _Level.baik => 'Baik',
        _Level.tidakSehat => 'Tidak Sehat',
        _Level.berbahaya => 'Berbahaya',
      };

  Color get accent => switch (this) {
        _Level.baik => const Color(0xFF2E9E5B),
        _Level.tidakSehat => const Color(0xFFE8873A),
        _Level.berbahaya => const Color(0xFFE8434B),
      };

  Color get badgeBg => switch (this) {
        _Level.baik => const Color(0xFFDDF0E0),
        _Level.tidakSehat => const Color(0xFFFBDDB8),
        _Level.berbahaya => const Color(0xFFFAD0D0),
      };

  Color get badgeFg => switch (this) {
        _Level.baik => const Color(0xFF2E7D4F),
        _Level.tidakSehat => const Color(0xFFB5651D),
        _Level.berbahaya => const Color(0xFFD93A3A),
      };

  Color get valueColor => switch (this) {
        _Level.baik => const Color(0xFF3D4A42),
        _Level.tidakSehat => const Color(0xFFA63A32),
        _Level.berbahaya => const Color(0xFFE8434B),
      };

  String get alert => switch (this) {
        _Level.baik => 'Kualitas udara dalam kategori baik',
        _Level.tidakSehat => 'Kualitas udara dalam kategori tidak sehat',
        _Level.berbahaya => 'Kualitas udara mencapai kategori berbahaya',
      };
}

class _Entry {
  final DateTime date;
  final int ispu;
  const _Entry(this.date, this.ispu);
}

class _Report {
  final String id;
  final List<_Entry> chart; 
  final List<_Entry> daily; 
  final int summary;
  const _Report({
    required this.id,
    required this.chart,
    required this.daily,
    required this.summary,
  });

  int get days => chart.length;
}

final DateTime _latest = DateTime(2026, 11, 3);

const List<String> _districts = [
  'Jekan Raya',
  'Pahandut',
  'Bukit Batu',
  'Sabangau',
  'Rakumpit',
];

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];
const _dayNames = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];

String _fmtFull(DateTime d) =>
    '${_dayNames[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

String _fmtShort(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String _fmtRange(DateTimeRange r) {
  final s = r.start;
  final e = r.end;
  final sm = _months[s.month - 1];
  final em = _months[e.month - 1];
  if (s.year == e.year) {
    return '${s.day} $sm – ${e.day} $em ${e.year}';
  }
  return '${s.day} $sm ${s.year} – ${e.day} $em ${e.year}';
}

_Report _designReport() {
  final chartValues = [210, 48, 62, 74, 310, 360, 462];
  final start = DateTime(2026, 10, 28);
  final chart = List.generate(
    7,
    (i) => _Entry(DateTime(start.year, start.month, start.day + i),
        chartValues[i]),
  );
  final daily = [
    _Entry(DateTime(2026, 11, 3), 462),
    _Entry(DateTime(2026, 11, 2), 155),
    _Entry(DateTime(2026, 11, 1), 354),
    _Entry(DateTime(2026, 10, 31), 100),
    _Entry(DateTime(2026, 10, 30), 62),
    _Entry(DateTime(2026, 10, 29), 48),
    _Entry(DateTime(2026, 10, 28), 210),
  ];
  return _Report(id: 'design', chart: chart, daily: daily, summary: 462);
}

_Report _generatedReport(DateTimeRange range, String district) {
  final days = range.end.difference(range.start).inDays + 1;
  final chart = List.generate(days, (i) {
    final d = DateTime(range.start.year, range.start.month, range.start.day + i);
    final rnd = math.Random(
        d.year * 10000 + d.month * 100 + d.day + district.hashCode);
    return _Entry(d, 35 + rnd.nextInt(420));
  });
  final avg =
      (chart.fold<int>(0, (a, b) => a + b.ispu) / chart.length).round();
  return _Report(
    id: '${range.start}-${range.end}-$district',
    chart: chart,
    daily: chart.reversed.toList(),
    summary: avg,
  );
}

enum _Mode { d7, d30, custom }

class AirQualityHistoryPage extends StatefulWidget {
  const AirQualityHistoryPage({super.key});

  @override
  State<AirQualityHistoryPage> createState() => _AirQualityHistoryPageState();
}

class _AirQualityHistoryPageState extends State<AirQualityHistoryPage>
    with TickerProviderStateMixin {
  late final AnimationController _anim; 
  late final AnimationController _chart;

  _Mode _mode = _Mode.d7;
  String _district = 'Jekan Raya';
  DateTimeRange _range = DateTimeRange(
    start: DateTime(2026, 10, 28),
    end: _latest,
  );
  late _Report _report = _designReport();
  bool _showAll = false;

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
      duration: const Duration(milliseconds: 1100),
      animationBehavior: AnimationBehavior.preserve,
    );
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _chart.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _chart.dispose();
    super.dispose();
  }

  void _refresh() {
    final useDesign = _district == 'Jekan Raya' && _mode == _Mode.d7;
    setState(() {
      _report = useDesign
          ? _designReport()
          : _generatedReport(_range, _district);
      _showAll = false;
    });
    _chart.forward(from: 0);
  }

  void _selectMode(_Mode m) {
    if (m == _Mode.custom) {
      _pickRange();
      return;
    }
    if (m == _mode) return;
    _mode = m;
    final days = m == _Mode.d7 ? 7 : 30;
    _range = DateTimeRange(
      start: DateTime(_latest.year, _latest.month, _latest.day - (days - 1)),
      end: _latest,
    );
    _refresh();
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: _latest,
      initialDateRange: _range,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.red,
            onPrimary: Colors.white,
            onSurface: _C.dark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    var range = picked;
    final days = range.end.difference(range.start).inDays + 1;
    if (days > 31) {
      range = DateTimeRange(
        start:
            DateTime(range.end.year, range.end.month, range.end.day - 30),
        end: range.end,
      );
      _toast('Rentang maksimal 31 hari');
    }
    _mode = _Mode.custom;
    _range = range;
    _refresh();
  }

  void _pickDistrict() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E2DB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              for (final d in _districts)
                ListTile(
                  leading: Icon(Icons.location_on_outlined,
                      color: d == _district ? _C.green : _C.hint),
                  title: Text(
                    '$d, Palangka Raya',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          d == _district ? FontWeight.w600 : FontWeight.w400,
                      color: _C.dark,
                    ),
                  ),
                  trailing: d == _district
                      ? const Icon(Icons.check_rounded, color: _C.green)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (d != _district) {
                      _district = d;
                      _refresh();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  List<CoachStep> get _tour => const [
        CoachStep(title: 'Riwayat Kualitas Udara', body: 'Halaman ini menyimpan catatan kualitas udara di lokasimu dari hari ke hari.'),
        CoachStep(title: 'Pilih periode', body: 'Pilih rentang tanggal atau periode yang ingin dilihat. Rentang paling panjang adalah 31 hari.'),
        CoachStep(title: 'Rata-rata dan catatan harian', body: 'Lihat rata-rata ISPU pada periode itu, grafiknya, dan catatan tiap hari. Ketuk Lihat semua atau Lihat ringkas untuk mengatur banyaknya catatan.'),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'riwayat_udara',
        tour: _tour,
        guide: PageGuide(content: () => 'Ini halaman Riwayat Kualitas Udara. Berisi pilihan periode sampai 31 hari, rata-rata ISPU, grafik, dan catatan harian kualitas udara. Data bersumber dari BMKG dan KLH, dan kondisi udara bisa berubah sewaktu-waktu. Ucapkan kembali untuk ke halaman sebelumnya.'),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    final level = _levelOf(_report.summary);
    final visibleDaily =
        _showAll ? _report.daily : _report.daily.take(4).toList();

    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _LeavesPainter(_anim)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _Reveal(
                    animation: _anim,
                    begin: 0.0,
                    end: 0.35,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: _C.dark,
                          iconSize: 26,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          'Riwayat Kualitas Udara',
                          style: GoogleFonts.poppins(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            color: _C.dark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _Reveal(
                    animation: _anim,
                    begin: 0.1,
                    end: 0.45,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pickDistrict,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 18, color: _C.green),
                          const SizedBox(width: 6),
                          Text(
                            '$_district, Palangka Raya',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _C.dark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 20, color: _C.green),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _Reveal(
                    animation: _anim,
                    begin: 0.15,
                    end: 0.5,
                    child: Row(
                      children: [
                        _PeriodChip(
                          label: '7 Hari',
                          selected: _mode == _Mode.d7,
                          onTap: () => _selectMode(_Mode.d7),
                        ),
                        const SizedBox(width: 10),
                        _PeriodChip(
                          label: '30 Hari',
                          selected: _mode == _Mode.d30,
                          onTap: () => _selectMode(_Mode.d30),
                        ),
                        const SizedBox(width: 10),
                        _PeriodChip(
                          label: 'Pilih Tanggal',
                          selected: _mode == _Mode.custom,
                          onTap: () => _selectMode(_Mode.custom),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _Reveal(
                    animation: _anim,
                    begin: 0.2,
                    end: 0.55,
                    child: GestureDetector(
                      onTap: _pickRange,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: _C.bar,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined,
                                size: 18, color: _C.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  _fmtRange(_range),
                                  key: ValueKey(_fmtRange(_range)),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _C.dark,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 20, color: _C.green),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _Reveal(
                    animation: _anim,
                    begin: 0.3,
                    end: 0.75,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: level.accent, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: level.accent.withValues(alpha: 0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rata-rata ISPU',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: _C.hint,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _chart,
                                      builder: (context, _) {
                                        final p = Curves.easeOutCubic
                                            .transform(_chart.value);
                                        return Text(
                                          '${(_report.summary * p).round()}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w700,
                                            color: level.accent,
                                            height: 1.15,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '/ ${_report.days} hari',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: _C.hint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _Badge(
                                label: level.label,
                                bg: level.badgeBg,
                                fg: level.badgeFg,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _BarChart(entries: _report.chart, anim: _chart),
                          const SizedBox(height: 14),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 11),
                            decoration: BoxDecoration(
                              color: level.accent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.eco_outlined,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    level.alert,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _Reveal(
                    animation: _anim,
                    begin: 0.5,
                    end: 0.9,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Catatan harian',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _C.dark,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _showAll = !_showAll),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              _showAll
                                  ? 'Lihat ringkas'
                                  : 'Lihat semua (${_report.days})',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _C.dark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  _Reveal(
                    animation: _anim,
                    begin: 0.55,
                    end: 1.0,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _C.red, width: 1.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              for (int i = 0; i < visibleDaily.length; i++) ...[
                                _DailyRow(
                                  entry: visibleDaily[i],
                                  district: _district,
                                ),
                                if (i != visibleDaily.length - 1)
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: Color(0xFFEFEFEF),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _Reveal(
                    animation: _anim,
                    begin: 0.7,
                    end: 1.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Data kualitas udara bersumber dari BMKG dan KLH. '
                        'Kondisi udara dapat berubah sewaktu-waktu.',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          height: 1.5,
                          color: _C.hint,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _C.red : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.red, width: 1.1),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _C.red.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _C.red,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<_Entry> entries;
  final Animation<double> anim;

  const _BarChart({required this.entries, required this.anim});

  static const double _areaH = 118;
  static const double _maxBarH = 96;
  static const double _axisW = 30;

  Color _barColor(int v) {
    final t = math.pow((v / 480).clamp(0.0, 1.0), 1.5).toDouble();
    return Color.lerp(const Color(0xFFF6BD4F), const Color(0xFFE8505B), t)!;
  }

  @override
  Widget build(BuildContext context) {
    final n = entries.length;
    final dense = n > 10;
    final maxV = entries.map((e) => e.ispu).reduce(math.max);

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Column(
          children: [
            SizedBox(
              height: _areaH,
              child: Stack(
                children: [

                  for (final item in const [
                    (0.0, '100'),
                    (0.5, '50'),
                    (1.0, '0'),
                  ]) ...[
                    Positioned(
                      left: _axisW,
                      right: 0,
                      top: item.$1 * (_areaH - 1),
                      child: Container(height: 1, color: _C.grid),
                    ),
                    Positioned(
                      left: 0,
                      top: item.$1 * (_areaH - 1) - 7,
                      child: SizedBox(
                        width: _axisW - 6,
                        child: Text(
                          item.$2,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _C.hint,
                          ),
                        ),
                      ),
                    ),
                  ],

                  Positioned.fill(
                    left: _axisW,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (int i = 0; i < n; i++)
                          Expanded(
                            child: _bar(i, n, entries[i], maxV, dense),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.only(left: _axisW),
              child: LayoutBuilder(
                builder: (context, c) {
                  final cellW = c.maxWidth / n;
                  return SizedBox(
                    height: 14,
                    child: Stack(
                      children: [
                        for (int i = 0; i < n; i++)
                          if (_showLabel(i, n, dense))
                            Positioned(
                              left: i * cellW + cellW / 2 - 24,
                              width: 48,
                              top: 0,
                              child: _xLabel(i, n, entries[i], dense),
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bar(int i, int n, _Entry e, int maxV, bool dense) {
    final start = (i / n) * 0.5;
    final t = Interval(start, start + 0.5, curve: Curves.easeOutCubic)
        .transform(anim.value);
    final frac = 0.38 + 0.62 * (e.ispu / maxV);
    final h = frac * _maxBarH * t;
    final color = _barColor(e.ispu);
    final isLast = i == n - 1;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!dense)
            Opacity(
              opacity: t,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${e.ispu}',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: isLast ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
          Container(
            width: dense ? 5 : 20,
            height: h,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color, color.withValues(alpha: 0.78)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _showLabel(int i, int n, bool dense) =>
      !dense || i == n - 1 || (i % 7 == 0 && n - 1 - i >= 4);

  Widget _xLabel(int i, int n, _Entry e, bool dense) {
    final isLast = i == n - 1;
    return Text(
      _fmtShort(e.date),
      textAlign: TextAlign.center,
      maxLines: 1,
      softWrap: false,
      style: GoogleFonts.poppins(
        fontSize: dense ? 8.5 : 9,
        fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
        color: isLast ? _C.green : _C.hint,
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final _Entry entry;
  final String district;

  const _DailyRow({required this.entry, required this.district});

  @override
  Widget build(BuildContext context) {
    final level = _levelOf(entry.ispu);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fmtFull(entry.date),
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _C.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Jalan Raya, Palangka Raya',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _C.hint,
                  ),
                ),
              ],
            ),
          ),
          _Badge(label: level.label, bg: level.badgeBg, fg: level.badgeFg),
          const SizedBox(width: 12),
          SizedBox(
            width: 38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.ispu}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: level.valueColor,
                    height: 1.2,
                  ),
                ),
                Text(
                  'ISPU',
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    color: _C.hint,
                    height: 1.1,
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

class _Reveal extends StatelessWidget {
  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  const _Reveal({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _LeavesPainter extends CustomPainter {
  final Animation<double> anim;
  _LeavesPainter(this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Curves.easeOut.transform(anim.value.clamp(0.0, 1.0));

    _leaf(canvas, Offset(w * 1.05, -h * 0.02), w * 0.52, w * 0.19,
        212 * math.pi / 180, _C.leaf.withValues(alpha: 0.85 * p));
    _leaf(canvas, Offset(w * 0.98, -h * 0.01), w * 0.34, w * 0.12,
        192 * math.pi / 180, _C.leafLight.withValues(alpha: 0.7 * p));

    _leaf(canvas, Offset(-w * 0.05, h * 0.99), w * 0.42, w * 0.15,
        32 * math.pi / 180, _C.leaf.withValues(alpha: 0.8 * p));
    _leaf(canvas, Offset(w * 0.0, h * 1.02), w * 0.30, w * 0.11,
        8 * math.pi / 180, _C.leafLight.withValues(alpha: 0.6 * p));
  }

  void _leaf(Canvas canvas, Offset origin, double length, double width,
      double angle, Color color) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(width * 1.05, -length * 0.20, width * 0.95, -length * 0.72, 0,
          -length)
      ..cubicTo(-width * 0.95, -length * 0.72, -width * 1.05, -length * 0.20,
          0, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LeavesPainter old) => false;
}
