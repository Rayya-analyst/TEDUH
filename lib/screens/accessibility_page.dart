import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_settings.dart';
import '../state/disability_profile.dart';
import '../widgets/teduh_common.dart';
import 'voice_settings_page.dart';

class AccessibilityPage extends StatefulWidget {
  const AccessibilityPage({super.key});

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
  static const List<String> _sizeLabels = AppSettings.sizeLabels;
  static const List<int> _sizePercents = AppSettings.sizePercents;

  static const Color _accent = Color(0xFF2F8F63);
  static const Color _trackOff = Color(0xFFDDEBE2);
  static const Color _chipBg = Color(0xFFE4F2EA);

  AppSettings get _s => AppSettings.instance;
  int get _sizeIdx => _s.textSizeIdx;
  bool get _contrast => _s.highContrast;
  bool get _darkMode => _s.darkMode;
  bool get _reduceMotion => _s.reduceMotion;
  bool get _screenReader => _s.screenReader;
  bool get _disabilityMode => _s.disabilityMode;
  String get _language => _s.language;

  @override
  void initState() {
    super.initState();
    _s.addListener(_onChange);
  }

  @override
  void dispose() {
    _s.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  void _tick() => HapticFeedback.selectionClick();

  final SectionKeys _sk = SectionKeys(4);

  List<CoachStep> get _tour => [
        CoachStep(
          target: _sk.keys[0],
          title: 'Nyaman untuk setiap orang',
          body: 'Halaman ini menyesuaikan TEDUH dengan kebutuhanmu. Semua perubahan langsung diterapkan ke seluruh aplikasi.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _sk.keys[2],
          title: 'Pengaturan kenyamanan',
          body: 'Atur Ukuran Tampilan, Kontras Warna, Mode Gelap, Kurangi Animasi, Pembaca Layar, dan Mode Disabilitas. Ada juga Bahasa Sederhana, Perintah Suara, dan Pengaturan Suara untuk sirene dan kecepatan bicara.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _sk.keys[3],
          title: 'Tersimpan otomatis',
          body: 'Pilihanmu disimpan otomatis dan tetap berlaku saat aplikasi dibuka lagi.',
          scrollAlignment: 0.5,
        ),
      ];

  @override
  Widget build(BuildContext context) =>
      VoiceScope(
        screen: 'a11y',
        tour: _tour,
        guide: PageGuide(
          content: () => 'Ini halaman Aksesibilitas. Berisi Ukuran Tampilan dari delapan puluh sampai seratus tiga puluh persen, Kontras Warna, Mode Gelap, Kurangi Animasi, Pembaca Layar, dan Mode Disabilitas. Ada juga Bahasa Sederhana, Perintah Suara, dan Pengaturan Suara. Kamu bisa berkata perbesar teks, mode gelap, kontras tinggi, atau kurangi animasi. Semua perubahan tersimpan otomatis. Ucapkan kembali untuk ke halaman sebelumnya.',
        ),
        child: _page(context),
      );

  Widget _page(BuildContext context) {
    return TeduhPage(
      title: 'Aksesibilitas',
      builder: (context, anim) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            key: _sk.keys[0],
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
                    iconHeight: 60,
                    icon: CustomPaint(painter: _AccessPainter()),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nyaman untuk setiap orang',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TC.greenDeep,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sesuaikan TEDUH dengan kebutuhanmu, agar setiap '
                    'informasi mudah dinikmati.',
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
            key: _sk.keys[1],
animation: anim,
            begin: 0.3,
            end: 0.7,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Kenyamanan penggunaan',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: TC.dark,
                    ),
                  ),
                ),
                Text(
                  'Sesuai pilihanmu',
                  style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Reveal(
            key: _sk.keys[2],
animation: anim,
            begin: 0.4,
            end: 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                  _buildTextSize(),
                  _divider(),
                  _SwitchRow(
                    title: 'Kontras Warna',
                    subtitle: _contrast
                        ? 'Aktif · Kontras tinggi'
                        : 'Nonaktif · Warna standar',
                    value: _contrast,
                    onChanged: (v) {
                      _tick();
                      _s.update(() => _s.highContrast = v);
                    },
                  ),
                  _divider(),
                  _SwitchRow(
                    title: 'Mode Tampilan',
                    subtitle: _darkMode
                        ? 'Aktif · Mode gelap'
                        : 'Nonaktif · Mode terang',
                    value: _darkMode,
                    onChanged: (v) {
                      _tick();
                      _s.update(() => _s.darkMode = v);
                    },
                  ),
                  _divider(),
                  _SwitchRow(
                    title: 'Kurangi Animasi',
                    subtitle: _reduceMotion
                        ? 'Dikurangi · Tanpa transisi'
                        : 'Aktif · Transisi lembut',
                    value: _reduceMotion,
                    onChanged: (v) {
                      _tick();
                      _s.update(() => _s.reduceMotion = v);
                    },
                  ),
                  _divider(),
                  _SwitchRow(
                    title: 'Pembaca Layar',
                    subtitle: _screenReader
                        ? 'Aktif · TEDUH membacakan isi halaman'
                        : 'Nonaktif · Gunakan TalkBack/VoiceOver',
                    value: _screenReader,
                    onChanged: (v) {
                      _tick();
                      _s.update(() => _s.screenReader = v);
                    },
                  ),
                  _divider(),
                  _SwitchRow(
                    title: 'Mode Disabilitas',
                    subtitle: _disabilityMode
                        ? 'Aktif · ${_s.dType.shortLabel}'
                        : 'Nonaktif · Pilih jenis disabilitas agar TEDUH menyesuaikan',
                    value: _disabilityMode,
                    onChanged: (v) {
                      _tick();
                      if (v) {
                        _pickType();
                      } else {
                        _s.applyDisabilityType(DisabilityType.none);
                      }
                    },
                  ),
                  _divider(),
                  _NavRow(
                    title: 'Jenis Disabilitas',
                    subtitle: _disabilityMode
                        ? '${_s.dType.label} · ketuk untuk mengganti'
                        : 'Belum dipilih · ketuk untuk memilih',
                    onTap: () {
                      _tick();
                      _pickType();
                    },
                  ),
                  _divider(),
                  _SwitchRow(
                    title: 'Bahasa Sederhana',
                    subtitle: _s.effectiveSimpleLanguage
                        ? 'Aktif · Kalimat pendek, tanpa istilah teknis'
                        : 'Nonaktif · Istilah standar',
                    value: _s.effectiveSimpleLanguage,
                    onChanged: (v) {
                      _tick();
                      _s.update(() => _s.simpleLanguage = v);
                    },
                  ),
                  _divider(),
                  _SwitchRow(
                    title: 'Perintah Suara',
                    subtitle: _s.effectiveVoiceNav
                        ? 'Aktif · Langsung ucapkan perintah, tanpa menekan tombol'
                        : 'Nonaktif · Ucapkan "Buka TEDUH NOW", dll.',
                    value: _s.effectiveVoiceNav,
                    onChanged: (v) {
                      _tick();
                      _s.update(() => _s.voiceNavigation = v);
                    },
                  ),
                  _divider(),
                  _NavRow(
                    title: 'Pengaturan Suara',
                    subtitle: 'Kecepatan suara, baca otomatis, sirene',
                    onTap: () {
                      _tick();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const VoiceSettingsPage(),
                        ),
                      );
                    },
                  ),
                  _divider(),
                  _buildLanguage(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          Reveal(
            key: _sk.keys[3],
animation: anim,
            begin: 0.7,
            end: 1.0,
            child: const NoteRow(
              icon: Icons.check_circle_outline_rounded,
              text: 'Pengaturan kenyamanan tersimpan otomatis.',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickType() async {
    final picked = await showModalBottomSheet<DisabilityType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jenis disabilitas',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TC.dark)),
              const SizedBox(height: 4),
              Text('TEDUH akan menyesuaikan tampilan, suara, dan panduan.',
                  style: GoogleFonts.poppins(
                      fontSize: 11.5, height: 1.5, color: TC.hint)),
              const SizedBox(height: 10),
              for (final t in const [
                DisabilityType.blind,
                DisabilityType.lowVision,
                DisabilityType.deaf,
                DisabilityType.speech,
                DisabilityType.motor,
                DisabilityType.cognitive,
                DisabilityType.multiple,
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.label,
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(t.adaptation,
                      style: GoogleFonts.poppins(
                          fontSize: 11, height: 1.4, color: TC.hint)),
                  trailing: _s.dType == t && _s.disabilityMode
                      ? const Icon(Icons.check_circle_rounded,
                          color: TC.green)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(t),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) _s.applyDisabilityType(picked);
  }

  Widget _divider() => const Divider(
        height: 1,
        thickness: 1,
        indent: 16,
        endIndent: 16,
        color: TC.divider,
      );

  Widget _buildTextSize() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ukuran Teks',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: TC.dark,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _chipBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(a),
                      child: child,
                    ),
                  ),
                  child: Text(
                    '${_sizeLabels[_sizeIdx]} · ${_sizePercents[_sizeIdx]}%',
                    key: ValueKey(_sizeIdx),
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: TC.greenDeep,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'A',
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: TC.dark,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: _accent,
                    inactiveTrackColor: _trackOff,
                    thumbShape: const _RingThumbShape(),
                    overlayColor: _accent.withValues(alpha: 0.12),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 18),
                    tickMarkShape: SliderTickMarkShape.noTickMark,
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: _sizeIdx.toDouble(),
                    min: 0,
                    max: (_sizeLabels.length - 1).toDouble(),
                    divisions: _sizeLabels.length - 1,
                    onChanged: (v) {
                      final i = v.round();
                      if (i != _sizeIdx) {
                        _tick();
                        _s.update(() => _s.textSizeIdx = i);
                      }
                    },
                  ),
                ),
              ),
              Text(
                'A',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: TC.dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Bahasa',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: TC.dark,
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Pilih bahasa',
            color: Colors.white,
            elevation: 6,
            offset: const Offset(0, 38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: TC.border),
            ),
            onOpened: _tick,
            onSelected: (v) {
              _tick();
              _s.update(() => _s.language = v);
            },
            itemBuilder: (_) => [
              for (final l in const ['Indonesia', 'English'])
                PopupMenuItem<String>(
                  value: l,
                  height: 38,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: l == _language
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: TC.dark,
                          ),
                        ),
                      ),
                      if (l == _language)
                        const Icon(Icons.check_rounded,
                            size: 16, color: TC.greenDeep),
                    ],
                  ),
                ),
            ],
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 7, 8, 7),
              decoration: BoxDecoration(
                color: _chipBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      _language,
                      key: ValueKey(_language),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TC.greenDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: TC.greenDeep),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
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
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, a) =>
                        FadeTransition(opacity: a, child: child),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [...previous, ?current],
                    ),
                    child: Text(
                      subtitle,
                      key: ValueKey(subtitle),
                      style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
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

class _RingThumbShape extends SliderComponentShape {
  const _RingThumbShape();

  static const double _radius = 9;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius + 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final r = _radius + 1.5 * activationAnimation.value;

    canvas.drawCircle(
      center.translate(0, 1),
      r + 1,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawCircle(center, r, Paint()..color = Colors.white);

    canvas.drawCircle(
      center,
      r - 1.25,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..isAntiAlias = true
        ..color = const Color(0xFF2F8F63),
    );
  }
}

class _AccessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const color = Color(0xFF1F6B4F);

    final fill = Paint()
      ..isAntiAlias = true
      ..color = color;
    final stroke = Paint()
      ..isAntiAlias = true
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w * 0.15;

    canvas.drawCircle(Offset(w * 0.5, h * 0.14), w * 0.115, fill);

    final arms = Path()
      ..moveTo(w * 0.10, h * 0.34)
      ..quadraticBezierTo(w * 0.5, h * 0.44, w * 0.90, h * 0.34);
    canvas.drawPath(arms, stroke);

    canvas.drawLine(
      Offset(w * 0.5, h * 0.40),
      Offset(w * 0.5, h * 0.64),
      stroke,
    );

    canvas.drawLine(
      Offset(w * 0.5, h * 0.62),
      Offset(w * 0.30, h * 0.92),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.62),
      Offset(w * 0.70, h * 0.92),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _NavRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: TC.hint),
          ],
        ),
      ),
    );
  }
}
