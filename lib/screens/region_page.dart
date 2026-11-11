import 'package:flutter/material.dart';
import '../state/app_settings.dart';
import '../services/voice_flow.dart';
import '../services/voice_service.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_page.dart';
import 'location_permission_dialog.dart';

class _RgColors {
  static const green = Color(0xFF176D59);
  static const greenDeep = Color(0xFF1A6B58);
  static const greenText = Color(0xFF1A5C4A);
  static const ink = Color(0xFF0F2A24);
  static const title = Color(0xFF16302A);
  static const body = Color(0xFF6B7B75);
  static const line = Color(0xFFDDE9E1);
  static const mint = Color(0xFFE9F3EC);
  static const selectedBg = Color(0xFFE3F1E6);
}

class RegionOption {
  final String province;
  final String area;
  const RegionOption(this.province, this.area);
}

class RegionPage extends StatefulWidget {

  final ValueChanged<RegionOption>? onSelected;

  final VoidCallback? onUseLocationTap;

  final ValueChanged<LocationPermissionChoice>? onLocationPermission;

  const RegionPage({
    super.key,
    this.onSelected,
    this.onUseLocationTap,
    this.onLocationPermission,
  });

  @override
  State<RegionPage> createState() => _RegionPageState();
}

class _RegionPageState extends State<RegionPage> {
  static const List<RegionOption> _regions = [
    RegionOption('Kalimantan Tengah', 'Kota Palangka Raya'),
    RegionOption('Kalimantan Barat', 'Kabupaten Kubu Raya'),
    RegionOption('Kalimantan Selatan', 'Kabupaten Banjar'),
    RegionOption('Kalimantan Utara', 'Kabupaten Bulungan'),
  ];

  final _searchController = TextEditingController();
  RegionOption _selected = _regions.first;
  String _query = '';
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    if (AppSettings.instance.voiceFlows) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _voiceRegion());
    }
  }

  Future<void> _voiceRegion() async {
    final f = VoiceFlow(() => mounted);
    for (int i = 0; i < 3 && mounted; i++) {
      final a = (await f.ask(
        i == 0
            ? 'Pilih wilayah Anda. Sebutkan salah satu: Kalimantan Tengah, '
                'Kalimantan Barat, Kalimantan Selatan, atau Kalimantan Utara.'
            : 'Mohon sebutkan nama wilayahnya, misalnya Kalimantan Tengah.',
        tries: 1,
      ))
          .toLowerCase();
      if (!mounted) return;
      RegionOption? pick;
      for (final r in _regions) {
        final key = r.province.toLowerCase().split(' ').last;
        if (a.contains(key) || a.contains(r.area.toLowerCase())) pick = r;
      }
      if (pick != null) {
        setState(() => _selected = pick!);
        await f.say('Wilayah ${pick.province}, ${pick.area}.');
        _confirm();
        return;
      }
    }
  }

  Future<void> _voiceLocationChoice() async {
    final f = VoiceFlow(() => mounted && _dialogOpen);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final a = (await f.ask(
      'Izinkan TEDUH mengakses lokasi Anda? Katakan saat aplikasi digunakan, '
      'hanya kali ini, atau jangan izinkan.',
    ))
        .toLowerCase();
    if (!mounted || !_dialogOpen) return;
    LocationPermissionChoice? c;
    if (a.contains('jangan') || a.contains('tidak')) {
      c = LocationPermissionChoice.deny;
    } else if (a.contains('kali ini') || a.contains('sekali')) {
      c = LocationPermissionChoice.onlyThisTime;
    } else if (a.contains('aplikasi') || a.contains('saat') ||
        a.contains('digunakan') || a.contains('izinkan') || a.contains('ya')) {
      c = LocationPermissionChoice.whileUsing;
    }
    if (c != null) Navigator.of(context).pop(c);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RegionOption> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _regions;
    return _regions
        .where((r) =>
            r.province.toLowerCase().contains(q) ||
            r.area.toLowerCase().contains(q))
        .toList();
  }

  void _useCurrentLocation() {
    if (widget.onUseLocationTap != null) {
      widget.onUseLocationTap!();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur lokasi akan dihubungkan.')),
    );
  }

  Future<void> _confirm() async {
    widget.onSelected?.call(_selected);
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context);

    _dialogOpen = true;
    final dialog = showLocationPermissionDialog(context);
    if (AppSettings.instance.voiceFlows) _voiceLocationChoice();
    final choice = await dialog;
    _dialogOpen = false;
    VoiceService.instance.cancelAll();

    if (choice == null || !mounted) return;
    AppSettings.instance.update(
        () => AppSettings.instance.locationChoice = choice.name);
    widget.onLocationPermission?.call(choice);

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final s = media.size.width / 323;
    final items = _visible;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const RepaintBoundary(
              child: CustomPaint(painter: _RgBackgroundPainter()),
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: media.padding.top + 10 * s),
                  _FadeInUp(
                    delayMs: 0,
                    dy: 24 * s,
                    child: _buildTopBar(s),
                  ),
                  SizedBox(height: 25 * s),
                  _FadeInUp(
                    delayMs: 80,
                    dy: 24 * s,
                    child: _buildHeading(s),
                  ),
                  SizedBox(height: 18 * s),
                  _FadeInUp(
                    delayMs: 180,
                    dy: 24 * s,
                    child: _buildSearch(s),
                  ),
                  SizedBox(height: 19 * s),
                  _FadeInUp(
                    delayMs: 260,
                    dy: 24 * s,
                    child: _buildUseLocation(s),
                  ),
                  SizedBox(height: 18 * s),
                  _FadeInUp(
                    delayMs: 320,
                    dy: 24 * s,
                    child: Padding(
                      padding: EdgeInsets.only(left: 19 * s),
                      child: Text(
                        'Wilayah populer',
                        style: GoogleFonts.inter(
                          fontSize: 9.5 * s,
                          fontWeight: FontWeight.w500,
                          color: _RgColors.body,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 11 * s),
                  for (var i = 0; i < items.length; i++)
                    _FadeInUp(
                      key: ValueKey(items[i].province),
                      delayMs: 380 + i * 70,
                      dy: 24 * s,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8 * s),
                        child: _buildItem(s, items[i]),
                      ),
                    ),
                  SizedBox(height: 9 * s),
                  _FadeInUp(
                    delayMs: 680,
                    dy: 24 * s,
                    child: _buildInfoCard(s),
                  ),
                  SizedBox(height: 19 * s),
                  _FadeInUp(
                    delayMs: 760,
                    dy: 24 * s,
                    child: _buildButton(s),
                  ),
                  SizedBox(height: 8 * s),
                  _FadeInUp(
                    delayMs: 820,
                    dy: 12 * s,
                    child: Center(
                      child: Text(
                        'Wilayah dapat diubah kapan saja.',
                        style: GoogleFonts.inter(
                          fontSize: 8 * s,
                          fontWeight: FontWeight.w400,
                          color: _RgColors.body,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 22 * s + media.padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 20 * s, right: 18 * s),
      child: SizedBox(
        height: 22 * s,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: EdgeInsets.all(2 * s),
                child: Icon(Icons.arrow_back_rounded,
                    size: 15 * s, color: _RgColors.greenText),
              ),
            ),
            SizedBox(width: 11 * s),
            Text(
              'Pilih Wilayah',
              style: GoogleFonts.inter(
                fontSize: 11.5 * s,
                fontWeight: FontWeight.w700,
                color: _RgColors.title,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 22 * s,
              height: 22 * s,
              child: const CustomPaint(painter: _RgLogoPainter()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 19 * s, right: 20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Udara sehat, di sekitarmu.',
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 20.5 * s,
                height: 1.25,
                letterSpacing: -0.5,
                fontWeight: FontWeight.w800,
                color: _RgColors.ink,
              ),
            ),
          ),
          SizedBox(height: 5 * s),
          Text(
            'Pilih wilayah untuk mengenal kualitas udara di tempatmu beraktivitas.',
            style: GoogleFonts.inter(
              fontSize: 9.5 * s,
              height: 1.55,
              fontWeight: FontWeight.w400,
              color: _RgColors.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 19 * s, right: 18 * s),
      child: Container(
        height: 40 * s,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E6B45).withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          style: GoogleFonts.inter(
              fontSize: 9.5 * s, color: const Color(0xFF2B3F38)),
          decoration: InputDecoration(
            hintText: 'Cari kota atau kecamatan...',
            hintStyle: GoogleFonts.inter(
              fontSize: 9.5 * s,
              color: const Color(0xFF8A9A93),
            ),
            prefixIcon: Icon(Icons.search_rounded,
                size: 17 * s, color: _RgColors.green),
            prefixIconConstraints:
                BoxConstraints(minWidth: 38 * s, minHeight: 0),
            isDense: true,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 13 * s),
          ),
        ),
      ),
    );
  }

  Widget _buildUseLocation(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 22 * s),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _useCurrentLocation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.my_location_rounded,
                  size: 13 * s, color: _RgColors.green),
              SizedBox(width: 6 * s),
              Text(
                'Gunakan Lokasi Saat Ini',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w700,
                  color: _RgColors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(double s, RegionOption region) {
    final selected = region.province == _selected.province;
    return Padding(
      padding: EdgeInsets.only(left: 19 * s, right: 18 * s),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selected = region),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 55 * s,
          padding: EdgeInsets.only(left: 10 * s, right: 13 * s),
          decoration: BoxDecoration(
            color: selected ? _RgColors.selectedBg : Colors.white,
            borderRadius: BorderRadius.circular(14 * s),
            border: Border.all(
              color: selected ? _RgColors.greenDeep : _RgColors.line,
              width: selected ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E6B45)
                    .withValues(alpha: selected ? 0.10 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 28 * s,
                height: 28 * s,
                decoration: BoxDecoration(
                  color: selected ? _RgColors.greenDeep : _RgColors.mint,
                  borderRadius: BorderRadius.circular(9 * s),
                ),
                child: Icon(
                  selected
                      ? Icons.check_rounded
                      : Icons.location_on_outlined,
                  size: 15 * s,
                  color: selected ? Colors.white : _RgColors.green,
                ),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region.province,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.5 * s,
                        fontWeight: FontWeight.w700,
                        color: _RgColors.title,
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      region.area,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 7.5 * s,
                        fontWeight: FontWeight.w400,
                        color: _RgColors.body,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 16 * s, color: _RgColors.greenText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 19 * s, right: 18 * s),
      child: Container(
        height: 78 * s,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E6B45).withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14 * s),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _RgInfoLeavesPainter(s)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12 * s, 0, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 165 * s,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Satu lokasi, langkah lebih sehat.',
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            fontWeight: FontWeight.w800,
                            color: _RgColors.greenText,
                          ),
                        ),
                        SizedBox(height: 5 * s),
                        Text(
                          'Kenali udara sekitar sebelum memulai aktivitas harianmu.',
                          style: GoogleFonts.inter(
                            fontSize: 8.5 * s,
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                            color: _RgColors.body,
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
      ),
    );
  }

  Widget _buildButton(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 19 * s, right: 18 * s),
      child: SizedBox(
        height: 42 * s,
        child: ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: _RgColors.greenDeep,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14 * s),
            ),
          ),
          child: Text(
            'Pilih Wilayah',
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}


void _rgLeaf(
  Canvas canvas,
  Offset base,
  double len,
  double width,
  double angle,
  Color color, {
  Color? vein,
}) {
  canvas.save();
  canvas.translate(base.dx, base.dy);
  canvas.rotate(angle);
  final path = Path()
    ..moveTo(0, 0)
    ..cubicTo(width * 0.95, -len * 0.22, width * 0.75, -len * 0.80, 0, -len)
    ..cubicTo(-width * 0.75, -len * 0.80, -width * 0.95, -len * 0.22, 0, 0)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
  if (vein != null) {
    final vp = Paint()
      ..color = vein
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, -len * 0.03), Offset(0, -len * 0.88), vp);
    for (final f in [0.28, 0.46, 0.64]) {
      canvas.drawLine(
          Offset(0, -len * f), Offset(width * 0.5, -len * (f + 0.1)), vp);
      canvas.drawLine(
          Offset(0, -len * f), Offset(-width * 0.5, -len * (f + 0.1)), vp);
    }
  }
  canvas.restore();
}

class _RgBackgroundPainter extends CustomPainter {
  const _RgBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE0F0E5), Color(0xFFF1F8F3), Color(0xFFF9FCFA)],
          stops: [0.0, 0.4, 1.0],
        ).createShader(rect),
    );

    _rgLeaf(canvas, Offset(w * 1.02, h * 0.28), h * 0.20, w * 0.20, -0.5,
        const Color(0xFFD8E9D9),
        vein: const Color(0xFFC9DFCB));
    _rgLeaf(canvas, Offset(w * 0.90, h * 0.20), h * 0.12, w * 0.12, -0.15,
        const Color(0xFFDFEEE0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RgInfoLeavesPainter extends CustomPainter {
  final double s;
  const _RgInfoLeavesPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    _rgLeaf(canvas, Offset(w - 28 * s, h + 4 * s), 74 * s, 21 * s, 0.30,
        const Color(0xFFD8EAD8));
    _rgLeaf(canvas, Offset(w - 52 * s, h + 4 * s), 70 * s, 20 * s, -0.12,
        const Color(0xFF8FBF9F),
        vein: const Color(0xFFB5D6BE));
    _rgLeaf(canvas, Offset(w - 36 * s, h + 6 * s), 62 * s, 18 * s, 0.12,
        const Color(0xFFA9CFB4),
        vein: const Color(0xFFC6E0CD));
    _rgLeaf(canvas, Offset(w - 68 * s, h + 4 * s), 54 * s, 16 * s, -0.55,
        const Color(0xFF6FA487));
  }

  @override
  bool shouldRepaint(covariant _RgInfoLeavesPainter old) => old.s != s;
}

class _RgLogoPainter extends CustomPainter {
  const _RgLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final leaf = Path()
      ..moveTo(w * 0.97, h * 0.03)
      ..cubicTo(w * 0.52, h * 0.02, w * 0.06, h * 0.22, w * 0.04, h * 0.62)
      ..cubicTo(w * 0.03, h * 0.82, w * 0.22, h * 0.90, w * 0.42, h * 0.86)
      ..cubicTo(w * 0.80, h * 0.78, w * 0.98, h * 0.45, w * 0.97, h * 0.03)
      ..close();
    canvas.drawPath(leaf, Paint()..color = _RgColors.green);

    final swoosh = Path()
      ..moveTo(w * 0.10, h * 0.98)
      ..cubicTo(w * 0.20, h * 0.62, w * 0.50, h * 0.36, w * 0.80, h * 0.24)
      ..cubicTo(w * 0.56, h * 0.46, w * 0.34, h * 0.70, w * 0.16, h * 1.00)
      ..close();
    canvas.drawPath(swoosh, Paint()..color = const Color(0xFFE6F1EA));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FadeInUp extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double dy;

  const _FadeInUp({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.dy = 24,
  });

  @override
  State<_FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<_FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final v = _animation.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * widget.dy),
            child: child,
          ),
        );
      },
    );
  }
}
