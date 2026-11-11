import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/help_faq_page.dart';
import '../screens/profile_page.dart';
import '../screens/teduh_action_page.dart';
import '../screens/teduh_ready_page.dart';

enum HomeMenuItem {
  now,
  action,
  ready,
  profile,
  help,
}

class _DC {
  static const green = Color(0xFF176D59);
  static const accent = Color(0xFF2E7B67);
  static const alert = Color(0xFFE5484D);
}

class TeduhNav {
  TeduhNav._();

  static Widget pageFor(HomeMenuItem item) {
    switch (item) {
      case HomeMenuItem.action:
        return const TeduhActionPage();
      case HomeMenuItem.ready:
        return const TeduhReadyPage();
      case HomeMenuItem.profile:
        return const ProfilePage();
      case HomeMenuItem.help:
        return const HelpFaqPage();
      case HomeMenuItem.now:
        throw StateError('TEDUH NOW adalah halaman dasar, bukan route baru.');
    }
  }

  static void go(BuildContext context, HomeMenuItem target, HomeMenuItem current) {
    if (target == current) return;
    final navigator = Navigator.of(context);
    if (target == HomeMenuItem.now) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => pageFor(target)),
      (route) => route.isFirst,
    );
  }
}

class TeduhDrawer extends StatelessWidget {
  final HomeMenuItem current;
  final String memberLabel;

  final ValueChanged<HomeMenuItem>? onItemTap;
  final VoidCallback? onLogoutTap;

  const TeduhDrawer({
    super.key,
    required this.current,
    this.memberLabel = 'Premium Member',
    this.onItemTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final d = screenWidth / 297;

    Widget sectionLabel(String text) => Padding(
          padding: EdgeInsets.only(left: 14.5 * d),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 9.8 * d,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: _DC.green,
            ),
          ),
        );

    Widget item(
      BuildContext ctx,
      HomeMenuItem id,
      _SideIcon icon,
      String label, {
      required double textLeft,
    }) {
      final selected = id == current;
      final color = selected ? _DC.green : _DC.accent;
      return Padding(
        padding: EdgeInsets.only(left: 12 * d, right: 11.5 * d),
        child: Material(
          color: selected ? const Color(0xFFEEF6F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(13 * d),
          child: InkWell(
            borderRadius: BorderRadius.circular(13 * d),
            onTap: () {
              Scaffold.of(ctx).closeDrawer();
              if (selected) return;
              if (onItemTap != null) {
                onItemTap!(id);
              } else {
                TeduhNav.go(ctx, id, current);
              }
            },
            child: SizedBox(
              height: 38.75 * d,
              child: Row(
                children: [
                  SizedBox(width: 11.5 * d),
                  SizedBox(
                    width: 15 * d,
                    height: 15 * d,
                    child: CustomPaint(painter: _SideIconPainter(icon, color)),
                  ),
                  SizedBox(width: (textLeft - 12 - 11.5 - 15) * d),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10 * d,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  if (selected)
                    Padding(
                      padding: EdgeInsets.only(right: 11.5 * d),
                      child: Container(
                        width: 4.5 * d,
                        height: 4.5 * d,
                        decoration: const BoxDecoration(
                          color: _DC.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Drawer(
      width: screenWidth * 0.75,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Builder(
          builder: (ctx) => LayoutBuilder(
            builder: (context, c) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 6.5 * d),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 16.25 * d),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Scaffold.of(ctx).closeDrawer(),
                              child: SizedBox(
                                width: 24 * d,
                                height: 24 * d,
                                child: Icon(Icons.close_rounded,
                                    size: 12 * d,
                                    color: const Color(0xFF2B3A35)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.25 * d),
                        Padding(
                          padding: EdgeInsets.only(left: 20 * d),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18.75 * d,
                                height: 17 * d,
                                child: const CustomPaint(
                                    painter: _LeafLogoPainter()),
                              ),
                              SizedBox(width: 5.25 * d),
                              Text(
                                'TEDUH',
                                style: GoogleFonts.inter(
                                  fontSize: 16.8 * d,
                                  height: 1.0,
                                  letterSpacing: 2.5 * d,
                                  fontWeight: FontWeight.w800,
                                  color: _DC.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 11 * d),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.75 * d),
                            child: Container(
                              height: 16.25 * d,
                              padding: EdgeInsets.only(
                                  left: 6.75 * d, right: 7 * d),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF6F1),
                                borderRadius: BorderRadius.circular(8.2 * d),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded,
                                      size: 9.5 * d, color: _DC.green),
                                  SizedBox(width: 3.75 * d),
                                  Text(
                                    memberLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 8 * d,
                                      fontWeight: FontWeight.w700,
                                      color: _DC.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 17.5 * d),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 12 * d, right: 11.25 * d),
                          child: Container(
                              height: 1, color: const Color(0xFFE3ECE7)),
                        ),
                        SizedBox(height: 13.1 * d),
                        sectionLabel('MENU UTAMA'),
                        SizedBox(height: 4.6 * d),
                        item(ctx, HomeMenuItem.now, _SideIcon.now, 'TEDUH NOW',
                            textLeft: 50),
                        SizedBox(height: 3.75 * d),
                        item(ctx, HomeMenuItem.action, _SideIcon.action,
                            'TEDUH ACTION',
                            textLeft: 51.25),
                        SizedBox(height: 3.75 * d),
                        item(ctx, HomeMenuItem.ready, _SideIcon.ready,
                            'TEDUH READY',
                            textLeft: 47.75),
                        SizedBox(height: 6.6 * d),
                        sectionLabel('PREFERENSI'),
                        SizedBox(height: 3.5 * d),
                        item(ctx, HomeMenuItem.profile, _SideIcon.profile,
                            'Profil',
                            textLeft: 48),
                        SizedBox(height: 10.95 * d),
                        sectionLabel('INFORMASI'),
                        SizedBox(height: 8.25 * d),
                        item(ctx, HomeMenuItem.help, _SideIcon.help,
                            'Pusat Bantuan Dan FAQ',
                            textLeft: 48),
                        const Spacer(),
                        SizedBox(height: 16 * d),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 12 * d),
                            child: SizedBox(
                              width: 110 * d,
                              height: 37.5 * d,
                              child: OutlinedButton(
                                onPressed: () {
                                  Scaffold.of(ctx).closeDrawer();
                                  _logout(ctx);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: _DC.alert,
                                  side: const BorderSide(
                                      color: _DC.alert, width: 1.1),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13 * d),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 12.5 * d,
                                      height: 12.5 * d,
                                      child: const CustomPaint(
                                          painter: _LogoutIconPainter()),
                                    ),
                                    SizedBox(width: 8.75 * d),
                                    Text(
                                      'Keluar',
                                      style: GoogleFonts.inter(
                                        fontSize: 10 * d,
                                        fontWeight: FontWeight.w700,
                                        color: _DC.alert,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 19.5 * d),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    if (onLogoutTap != null) {
      onLogoutTap!();
      return;
    }
    final navigator = Navigator.of(context, rootNavigator: true);
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    navigator.pushNamedAndRemoveUntil('/', (route) => false);
  }
}

class _LeafLogoPainter extends CustomPainter {
  const _LeafLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final leaf = Path()
      ..moveTo(w * 0.98, h * 0.02)
      ..cubicTo(w * 0.55, h * 0.00, w * 0.05, h * 0.20, w * 0.02, h * 0.62)
      ..cubicTo(w * 0.01, h * 0.84, w * 0.22, h * 0.94, w * 0.44, h * 0.90)
      ..cubicTo(w * 0.82, h * 0.82, w * 1.00, h * 0.46, w * 0.98, h * 0.02)
      ..close();
    canvas.drawPath(leaf, Paint()..color = _DC.green);

    final swoosh = Path()
      ..moveTo(w * 0.04, h * 1.00)
      ..cubicTo(w * 0.18, h * 0.62, w * 0.50, h * 0.34, w * 0.84, h * 0.20)
      ..cubicTo(w * 0.58, h * 0.44, w * 0.34, h * 0.70, w * 0.14, h * 1.04)
      ..close();
    canvas.drawPath(swoosh, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _SideIcon { now, action, ready, profile, help }

class _SideIconPainter extends CustomPainter {
  final _SideIcon icon;
  final Color color;
  const _SideIconPainter(this.icon, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k, k);

    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (icon) {
      case _SideIcon.now:

        canvas.drawArc(
          Rect.fromCircle(center: const Offset(8.2, 8.8), radius: 3.4),
          1.5,
          4.6,
          false,
          p,
        );
        for (final r in const [
          [8.2, 2.2, 8.2, 3.6],
          [2.4, 8.8, 3.8, 8.8],
          [4.1, 4.7, 5.1, 5.7],
          [12.3, 4.7, 11.3, 5.7],
        ]) {
          canvas.drawLine(Offset(r[0], r[1]), Offset(r[2], r[3]), p);
        }
        canvas.drawPath(
          Path()
            ..moveTo(8.2, 20.2)
            ..cubicTo(4.8, 20.2, 4.8, 14.8, 8.6, 14.6)
            ..cubicTo(9.2, 11.4, 14.4, 10.6, 15.6, 14)
            ..cubicTo(19.8, 13.4, 21.4, 19.2, 17.8, 20.2)
            ..close(),
          p,
        );
        break;
      case _SideIcon.action:

        canvas.drawPath(
          Path()
            ..moveTo(7.4, 14.4)
            ..cubicTo(4.2, 14.4, 4.2, 9.6, 7.8, 9.4)
            ..cubicTo(8.4, 5.2, 14.6, 4.6, 15.8, 8.6)
            ..cubicTo(19.8, 8.4, 20.8, 14.2, 16.8, 14.4)
            ..close(),
          p,
        );
        canvas.drawLine(const Offset(6, 17.6), const Offset(18, 17.6), p);
        canvas.drawLine(const Offset(8.6, 20.6), const Offset(15.4, 20.6), p);
        break;
      case _SideIcon.ready:
        canvas.drawCircle(const Offset(12, 12), 9, p);
        canvas.drawPath(
          Path()
            ..moveTo(7.8, 12.4)
            ..lineTo(10.8, 15.3)
            ..lineTo(16.4, 9.2),
          p,
        );
        break;
      case _SideIcon.profile:
        canvas.drawCircle(const Offset(12, 12), 9, p);
        canvas.drawCircle(const Offset(12, 9.8), 2.8, p);
        canvas.drawPath(
          Path()
            ..moveTo(6.4, 18.4)
            ..cubicTo(7.4, 14.6, 16.6, 14.6, 17.6, 18.4),
          p,
        );
        break;
      case _SideIcon.help:
        canvas.drawCircle(const Offset(12, 12), 9, p);
        canvas.drawPath(
          Path()
            ..moveTo(9.3, 9.6)
            ..cubicTo(9.3, 6.4, 14.7, 6.4, 14.7, 9.6)
            ..cubicTo(14.7, 11.5, 12, 11.7, 12, 13.8),
          p,
        );
        canvas.drawCircle(
          const Offset(12, 16.6),
          0.95,
          Paint()..color = color,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _SideIconPainter old) =>
      old.icon != icon || old.color != color;
}

class _LogoutIconPainter extends CustomPainter {
  const _LogoutIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k, k);
    final p = Paint()
      ..color = _DC.alert
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      Path()
        ..moveTo(10.5, 3.5)
        ..lineTo(6.2, 3.5)
        ..quadraticBezierTo(3.5, 3.5, 3.5, 6.2)
        ..lineTo(3.5, 17.8)
        ..quadraticBezierTo(3.5, 20.5, 6.2, 20.5)
        ..lineTo(10.5, 20.5),
      p,
    );
    canvas.drawLine(const Offset(9.5, 12), const Offset(21, 12), p);
    canvas.drawPath(
      Path()
        ..moveTo(16.6, 7.6)
        ..lineTo(21, 12)
        ..lineTo(16.6, 16.4),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
