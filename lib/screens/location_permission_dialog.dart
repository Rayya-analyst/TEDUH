import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LocationPermissionChoice { whileUsing, onlyThisTime, deny }

class _LpColors {
  static const green = Color(0xFF1A6B58);
  static const title = Color(0xFF0F3D33);
  static const body = Color(0xFF7A8C85);
  static const gray = Color(0xFF6B7B75);
  static const softBtn = Color(0xFFEEF5F1);
}

Future<LocationPermissionChoice?> showLocationPermissionDialog(
  BuildContext context,
) {
  return showGeneralDialog<LocationPermissionChoice>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Izin lokasi',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondary) =>
        const LocationPermissionDialog(),
    transitionBuilder: (context, animation, secondary, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: curved,
            builder: (context, _) => BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 6 * curved.value,
                sigmaY: 6 * curved.value,
              ),
              child: ColoredBox(
                color: const Color(0xFF2C3D37)
                    .withValues(alpha: 0.42 * curved.value),
              ),
            ),
          ),
          FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
              child: child,
            ),
          ),
        ],
      );
    },
  );
}

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 412;

    void pick(LocationPermissionChoice c) => Navigator.of(context).pop(c);

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30 * s),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 30 * s,
                offset: Offset(0, 10 * s),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 9 * s),
              SizedBox(
                width: 160 * s,
                height: 130 * s,
                child: const CustomPaint(painter: _LocationIllustrationPainter()),
              ),
              SizedBox(height: 17 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Text(
                  'Izinkan TEDUH Mengakses\nLokasi Anda?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20.5 * s,
                    height: 1.3,
                    letterSpacing: -0.3,
                    fontWeight: FontWeight.w700,
                    color: _LpColors.title,
                  ),
                ),
              ),
              SizedBox(height: 13.5 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * s),
                child: Text(
                  'TEDUH memerlukan akses lokasi untuk memberikan data '
                  'kualitas udara (ISPU) real-time dan peringatan polusi di '
                  'sekitar Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5 * s,
                    height: 1.68,
                    fontWeight: FontWeight.w400,
                    color: _LpColors.body,
                  ),
                ),
              ),
              SizedBox(height: 19.5 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: _button(
                  s,
                  label: 'Saat aplikasi digunakan',
                  height: 54,
                  background: _LpColors.green,
                  foreground: Colors.white,
                  onTap: () => pick(LocationPermissionChoice.whileUsing),
                ),
              ),
              SizedBox(height: 8 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: _button(
                  s,
                  label: 'Hanya kali ini',
                  height: 48,
                  background: _LpColors.softBtn,
                  foreground: _LpColors.green,
                  onTap: () => pick(LocationPermissionChoice.onlyThisTime),
                ),
              ),
              SizedBox(height: 12 * s),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => pick(LocationPermissionChoice.deny),
                child: SizedBox(
                  height: 36 * s,
                  width: 200 * s,
                  child: Center(
                    child: Text(
                      'Jangan izinkan',
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w600,
                        color: _LpColors.gray,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 27 * s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(
    double s, {
    required String label,
    required double height,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(18 * s),
        onTap: onTap,
        child: SizedBox(
          height: height * s,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.3 * s,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationIllustrationPainter extends CustomPainter {
  const _LocationIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 160;
    canvas.save();
    canvas.scale(k, k);

    Paint fill(Color c) => Paint()..color = c;

    canvas.drawPath(
      Path()
        ..moveTo(0.8, 0.8)
        ..lineTo(18, 0.8)
        ..lineTo(3, 26)
        ..close(),
      fill(const Color(0xFFE2EFDC)),
    );

    canvas.drawPath(
      Path()
        ..moveTo(146, 1)
        ..cubicTo(155, 12, 162, 26, 160, 41)
        ..cubicTo(157, 80, 125, 115, 90, 128)
        ..cubicTo(85, 110, 86, 90, 90, 70)
        ..cubicTo(95, 50, 105, 35, 120, 22)
        ..cubicTo(130, 14, 138, 7, 146, 1)
        ..close(),
      fill(const Color(0xFFD0E5D9)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(159, 46)
        ..cubicTo(150, 86, 120, 116, 90, 128)
        ..cubicTo(98, 100, 125, 68, 159, 46)
        ..close(),
      fill(const Color(0xFFE1EEDB)),
    );

    canvas.drawPath(
      Path()
        ..moveTo(160, 57)
        ..cubicTo(140, 58, 124, 68, 110, 88)
        ..cubicTo(126, 84, 146, 74, 160, 57)
        ..close(),
      fill(const Color(0xFFB7D5C3)),
    );

    canvas.drawPath(
      Path()
        ..moveTo(55, 104)
        ..cubicTo(70, 118, 90, 125, 102, 128)
        ..lineTo(60, 128)
        ..close(),
      fill(const Color(0xFFD2E6DB)),
    );

    canvas.drawPath(
      Path()
        ..moveTo(17.5, 0.8)
        ..cubicTo(5, 10, -2, 30, 0, 55)
        ..cubicTo(3, 85, 25, 115, 45, 128)
        ..cubicTo(55, 118, 60, 108, 59, 100)
        ..cubicTo(58, 70, 56, 45, 52, 31)
        ..cubicTo(40, 18, 28, 8, 17.5, 0.8)
        ..close(),
      fill(const Color(0xFFB5D3C0)),
    );

    const c = Offset(83, 65);
    canvas.drawCircle(c, 45, fill(const Color(0xFFEFF6F1).withValues(alpha: 0.72)));
    canvas.drawCircle(
      c,
      45,
      Paint()
        ..color = const Color(0xFFBBD8C8).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
    canvas.drawCircle(
      c,
      32,
      Paint()
        ..color = const Color(0xFF9CC7B2).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    final thin = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawLine(const Offset(2.5, 31), const Offset(86, 116), thin);
    canvas.drawLine(const Offset(19, 54), const Offset(89, 119), thin);
    canvas.drawLine(const Offset(159, 57), const Offset(90, 118), thin);
    canvas.drawLine(const Offset(159, 59), const Offset(94, 118), thin);

    final box = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 48, height: 48),
      const Radius.circular(14),
    );
    canvas.drawRRect(box, fill(_LpColors.green));

    canvas.save();
    canvas.translate(c.dx - 10, c.dy - 12.5);
    final pin = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(10, 24)
        ..cubicTo(10, 24, 1.2, 16, 1.2, 9.8)
        ..arcTo(Rect.fromCircle(center: const Offset(10, 9.8), radius: 8.8),
            3.14159265, 3.14159265, false)
        ..cubicTo(18.8, 16, 10, 24, 10, 24)
        ..close(),
      pin,
    );
    canvas.drawCircle(const Offset(10, 9.8), 3.2, pin);
    canvas.restore();

    canvas.drawCircle(const Offset(120.5, 57), 3.4, fill(Colors.white));
    canvas.drawCircle(const Offset(120.5, 57), 1.7, fill(const Color(0xFF14503F)));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
