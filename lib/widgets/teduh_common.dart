import 'dart:math' as math;
import '../state/app_settings.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TC {
  static const green = Color(0xFF0F7B4F);
  static const greenDeep = Color(0xFF1E5C45);
  static const dark = Color(0xFF1F3D2F);
  static const hint = Color(0xFF7C9084);
  static const border = Color(0xFFE4ECE6);
  static const iconBox = Color(0xFFE8F3EB);
  static const divider = Color(0xFFEDF2EE);
  static const heroTop = Color(0xFFE6F2E8);
  static const heroBottom = Color(0xFFD8EADB);
}

void showSoon(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('$msg (segera hadir)'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
    ));
}

class Reveal extends StatelessWidget {
  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  const Reveal({
    super.key,
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

class NoteRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const NoteRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: TC.green),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
          ),
        ),
      ],
    );
  }
}

class TeduhPage extends StatefulWidget {
  final String title;
  final bool centerTitle;
  final Widget? trailing;
  final Color background;
  final Color leafColor;
  final FontWeight titleWeight;
  final Widget Function(BuildContext context, Animation<double> anim) builder;

  const TeduhPage({
    super.key,
    required this.title,
    required this.builder,
    this.centerTitle = false,
    this.trailing,
    this.background = const Color(0xFFFBFCFA),
    this.leafColor = const Color(0xFFDCEADA),
    this.titleWeight = FontWeight.w600,
  });

  @override
  State<TeduhPage> createState() => _TeduhPageState();
}

class _TeduhPageState extends State<TeduhPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AppSettings.instance.animBehavior,
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _header() {
    final back = IconButton(
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back_rounded),
      color: TC.dark,
      iconSize: 26,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
    final style = GoogleFonts.poppins(
      fontSize: 17.5,
      fontWeight: widget.titleWeight,
      color: TC.dark,
    );

    if (widget.centerTitle) {
      return SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(alignment: Alignment.centerLeft, child: back),
            Text(widget.title, style: style),
            if (widget.trailing != null)
              Align(
                alignment: Alignment.centerRight,
                child: widget.trailing!,
              ),
          ],
        ),
      );
    }

    return Row(
      children: [
        back,
        const SizedBox(width: 18),
        Expanded(child: Text(widget.title, style: style)),
        if (widget.trailing != null) widget.trailing!,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SoftLeavesPainter(_anim, widget.leafColor),
              ),
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
                    child: _header(),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    child: widget.builder(context, _anim),
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

class SoftLeavesPainter extends CustomPainter {
  final Animation<double> anim;
  final Color color;

  SoftLeavesPainter(this.anim, this.color) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Curves.easeOut.transform(anim.value.clamp(0.0, 1.0));

    _leaf(canvas, Offset(w * 1.05, -h * 0.02), w * 0.55, w * 0.20,
        213 * math.pi / 180, color.withValues(alpha: 0.9 * p));
    _leaf(canvas, Offset(w * 0.98, -h * 0.01), w * 0.36, w * 0.13,
        193 * math.pi / 180, color.withValues(alpha: 0.6 * p));
    _leaf(canvas, Offset(-w * 0.05, h * 0.99), w * 0.44, w * 0.16,
        32 * math.pi / 180, color.withValues(alpha: 0.75 * p));
    _leaf(canvas, Offset(w * 0.01, h * 1.02), w * 0.32, w * 0.12,
        8 * math.pi / 180, color.withValues(alpha: 0.5 * p));
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
  bool shouldRepaint(covariant SoftLeavesPainter old) => false;
}

class LaurelHero extends StatefulWidget {
  final Widget icon;
  final double iconWidth;
  final double iconHeight;
  final bool swing;

  const LaurelHero({
    super.key,
    required this.icon,
    this.iconWidth = 64,
    this.iconHeight = 72,
    this.swing = false,
  });

  @override
  State<LaurelHero> createState() => _LaurelHeroState();
}

class _LaurelHeroState extends State<LaurelHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
      animationBehavior: AppSettings.instance.animBehavior,
    )..repeatUnlessReduced();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final float = math.sin(t * 2 * math.pi) * 3;
        final sway = math.sin(t * 2 * math.pi);

        double angle = 0;
        if (widget.swing && t < 0.30) {
          final env = 1 - t / 0.30;
          angle = math.sin(t * 60) * 0.16 * env;
        }

        return Transform.translate(
          offset: Offset(0, float),
          child: SizedBox(
            width: 170,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(170, 92),
                  painter: _LaurelPainter(sway),
                ),
                Transform.rotate(
                  angle: angle,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: widget.iconWidth,
                    height: widget.iconHeight,
                    child: widget.icon,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LaurelPainter extends CustomPainter {
  final double sway;
  _LaurelPainter(this.sway);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;
    final rx = size.width * 0.34;
    final ry = size.height * 0.46;

    final stem = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFB5D1B1);

    for (final side in [-1, 1]) {
      final from = side < 0 ? 118.0 : 62.0;
      final to = side < 0 ? 238.0 : -58.0;

      final stemPath = Path();
      const steps = 14;
      for (int i = 0; i <= steps; i++) {
        final t = i / steps;
        final rad = (from + (to - from) * t) * math.pi / 180;
        final pt = Offset(cx + rx * math.cos(rad), cy + ry * math.sin(rad));
        if (i == 0) {
          stemPath.moveTo(pt.dx, pt.dy);
        } else {
          stemPath.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(stemPath, stem);

      const count = 6;
      for (int i = 0; i < count; i++) {
        final t = (i + 0.5) / count;
        final deg = from + (to - from) * t;
        final rad = deg * math.pi / 180;
        final pt = Offset(cx + rx * math.cos(rad), cy + ry * math.sin(rad));

        final dir = (to - from) >= 0 ? 1.0 : -1.0;
        final tx = -rx * math.sin(rad) * dir;
        final ty = ry * math.cos(rad) * dir;
        final phi = math.atan2(ty, tx);

        final size0 = 10 + 9 * math.sin(t * math.pi);
        for (final s in [-1, 1]) {
          canvas.save();
          canvas.translate(pt.dx, pt.dy);
          canvas.rotate(phi + math.pi / 2 + s * 0.8 + sway * 0.06 * s);
          final leaf = Path()
            ..moveTo(0, 0)
            ..cubicTo(size0 * 0.42, -size0 * 0.25, size0 * 0.38,
                -size0 * 0.75, 0, -size0)
            ..cubicTo(-size0 * 0.38, -size0 * 0.75, -size0 * 0.42,
                -size0 * 0.25, 0, 0)
            ..close();
          canvas.drawPath(
            leaf,
            Paint()
              ..isAntiAlias = true
              ..color = (s < 0
                      ? const Color(0xFF9CC79A)
                      : const Color(0xFFC0DABD))
                  .withValues(alpha: 0.95),
          );
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LaurelPainter old) => old.sway != sway;
}

