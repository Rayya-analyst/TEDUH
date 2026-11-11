import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'aktivitas_dalam_ruangan_page.dart';

class _KbColors {
  static const bg = Color(0xFFF5F9F6);
  static const leaf = Color(0xFFE5F0E8);
  static const leafVein = Color(0xFFF1F7F3);
  static const green = Color(0xFF1A6B55);
  static const greenSoft = Color(0xFF2E7B67);
  static const ink = Color(0xFF1F3D36);
  static const text = Color(0xFF3A4A45);
  static const header = Color(0xFF2E3B37);
  static const muted = Color(0xFF7B8984);
  static const red = Color(0xFFF03A3A);
  static const redText = Color(0xFFE8383B);
  static const redBg = Color(0xFFFFD2D2);
  static const redLine = Color(0xFFF28585);
  static const redDivider = Color(0xFFE6B4A0);
  static const featured = Color(0xFFE8F1EA);
  static const mint = Color(0xFFE5F1E8);
  static const cardBorder = Color(0xFFE6EDE8);
}

class KebugaranActivity {
  final String title;
  final String subtitle;
  final String duration;
  const KebugaranActivity(this.title, this.subtitle, this.duration);
}

class RekomendasiKebugaranPage extends StatelessWidget {

  final String userName;
  final String ispuValue;
  final String ispuStatus;
  final String ispuAdvice;
  final String locationLabel;

  final VoidCallback? onFeaturedTap;
  final ValueChanged<KebugaranActivity>? onActivityTap;

  final VoidCallback? onMulaiTap;

  final VoidCallback? onLokasiTap;

  final String illustrationAsset;

  const RekomendasiKebugaranPage({
    super.key,
    this.userName = 'Ahmad',
    this.ispuValue = '142',
    this.ispuStatus = 'Tidak sehat',
    this.ispuAdvice =
        'Utamakan aktivitas di dalam.\nCek ISPU aktual sebelum keluar.',
    this.locationLabel = 'Di dalam ruangan',
    this.onFeaturedTap,
    this.onActivityTap,
    this.onMulaiTap,
    this.onLokasiTap,
    this.illustrationAsset = 'assets/images/peregangan.png',
  });

  static const _jeda = KebugaranActivity(
      'Jeda tenang', 'Duduk nyaman, bernapas sewajarnya.', '5 menit');
  static const _langkah = KebugaranActivity(
      'Langkah santai di rumah', 'Gerak perlahan, sesuai kemampuan.', '8 menit');

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'fitness',
        tour: const [
          CoachStep(title: 'Rekomendasi untukmu', body: 'Ringkasan kondisi udara dan saran gerak yang cocok untukmu hari ini.'),
          CoachStep(title: 'Pilihan untukmu', body: 'Pilihan aktivitas ringan di dalam ruangan, lengkap dengan durasinya, seperti jeda tenang dan langkah santai di rumah.'),
          CoachStep(title: 'Tetap jaga udara bersih', body: 'Pengingat melindungi diri, misalnya memakai masker yang pas bila harus keluar.'),
          CoachStep(title: 'Mulai Peregangan', body: 'Ketuk tombol ini untuk memulai latihan peregangan lembut.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Rekomendasi Kebugaran. Isinya saran gerak sesuai kondisi udara, pilihan aktivitas di dalam ruangan seperti jeda tenang dan langkah santai, pengingat menjaga udara bersih, dan tombol Mulai Peregangan.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final media = MediaQuery.of(context);
    final s = media.size.width / 330;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _KbColors.bg,
        body: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _LeafPainter())),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, s),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 16 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'UNTUKMU, ${userName.toUpperCase()}',
                            style: GoogleFonts.inter(
                              fontSize: 8 * s,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w500,
                              color: _KbColors.greenSoft,
                            ),
                          ),
                          SizedBox(height: 6 * s),
                          Text.rich(
                            TextSpan(
                              text: 'Bergerak ringan,\ntetap ',
                              style: GoogleFonts.poppins(
                                fontSize: 21.5 * s,
                                height: 1.13,
                                letterSpacing: -0.3,
                                fontWeight: FontWeight.w600,
                                color: _KbColors.ink,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'terlindungi.',
                                  style: TextStyle(color: _KbColors.green),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14 * s),
                          _buildIspuCard(s),
                          SizedBox(height: 14 * s),
                          Row(
                            children: [
                              Text(
                                'Pilihan untukmu',
                                style: GoogleFonts.inter(
                                  fontSize: 12.3 * s,
                                  fontWeight: FontWeight.w400,
                                  color: _KbColors.text,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: onLokasiTap ??
                                    () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AktivitasDalamRuanganPage(),
                                          ),
                                        ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4 * s, horizontal: 2 * s),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.home_rounded,
                                          size: 9.5 * s,
                                          color: _KbColors.greenSoft),
                                      SizedBox(width: 3 * s),
                                      Text(
                                        locationLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 7.2 * s,
                                          fontWeight: FontWeight.w500,
                                          color: _KbColors.greenSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10 * s),
                          _buildFeatured(s),
                          SizedBox(height: 10 * s),
                          _buildOption(
                              s,
                              Icon(Icons.favorite_border_rounded,
                                  size: 16 * s, color: _KbColors.green),
                              _jeda),
                          SizedBox(height: 8.5 * s),
                          _buildOption(
                              s,
                              SizedBox(
                                width: 16 * s,
                                height: 16 * s,
                                child: CustomPaint(painter: _FootprintPainter()),
                              ),
                              _langkah),
                          SizedBox(height: 13 * s),
                          _buildTip(s),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20 * s, 8 * s, 20 * s, 18 * s),
                    child: _buildButton(s),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double s) {
    return SizedBox(
      height: 42 * s,
      child: Padding(
        padding: EdgeInsets.only(left: 17 * s, right: 20 * s),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: EdgeInsets.all(4 * s),
                child: Icon(Icons.arrow_back_rounded,
                    size: 17 * s, color: _KbColors.header),
              ),
            ),
            SizedBox(width: 14 * s),
            Text(
              'Rekomendasi Kebugaran',
              style: GoogleFonts.inter(
                fontSize: 11.5 * s,
                fontWeight: FontWeight.w500,
                color: _KbColors.header,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIspuCard(double s) {
    return Container(
      height: 75 * s,
      padding: EdgeInsets.fromLTRB(11.5 * s, 0, 12 * s, 0),
      decoration: BoxDecoration(
        color: _KbColors.redBg,
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: _KbColors.redLine, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54 * s,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ispuValue,
                  style: GoogleFonts.poppins(
                    fontSize: 26 * s,
                    height: 1.0,
                    fontWeight: FontWeight.w500,
                    color: _KbColors.red,
                  ),
                ),
                SizedBox(height: 5 * s),
                Text(
                  'ISPU • ILUSTRASI',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 5.2 * s,
                    fontWeight: FontWeight.w400,
                    color: _KbColors.redText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.5 * s),
          Container(width: 1, height: 37 * s, color: _KbColors.redDivider),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3.5 * s,
                      height: 3.5 * s,
                      decoration: const BoxDecoration(
                        color: _KbColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4 * s),
                    Text(
                      ispuStatus,
                      style: GoogleFonts.inter(
                        fontSize: 9.5 * s,
                        fontWeight: FontWeight.w800,
                        color: _KbColors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5 * s),
                Text(
                  ispuAdvice,
                  style: GoogleFonts.inter(
                    fontSize: 8.3 * s,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: _KbColors.redText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatured(double s) {
    return SizedBox(
      width: double.infinity,
      height: 121 * s,
      child: Material(
        color: _KbColors.featured,
        borderRadius: BorderRadius.circular(16 * s),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onFeaturedTap,
          child: Stack(
            children: [
              Positioned(
                right: 15 * s,
                bottom: 22 * s,
                width: 95 * s,
                height: 76 * s,
                child: Image.asset(
                  illustrationAsset,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (context, error, stackTrace) =>
                      CustomPaint(painter: _StretchPainter()),
                ),
              ),
              Positioned(
                left: 12.5 * s,
                top: 19 * s,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '10 MENIT  •  RINGAN',
                      style: GoogleFonts.inter(
                        fontSize: 6.5 * s,
                        fontWeight: FontWeight.w700,
                        color: _KbColors.green,
                      ),
                    ),
                    SizedBox(height: 7 * s),
                    Text(
                      'Peregangan\nlembut',
                      style: GoogleFonts.inter(
                        fontSize: 14.5 * s,
                        height: 1.24,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w700,
                        color: _KbColors.green,
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    SizedBox(
                      width: 130 * s,
                      child: Text(
                        'Lepaskan tegang di leher,\nbahu, dan punggung.',
                        style: GoogleFonts.inter(
                          fontSize: 8.3 * s,
                          height: 1.65,
                          fontWeight: FontWeight.w400,
                          color: _KbColors.muted,
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
    );
  }

  Widget _buildOption(double s, Widget icon, KebugaranActivity a) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(14 * s),
        onTap: onActivityTap == null ? null : () => onActivityTap!(a),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14 * s),
            border: Border.all(color: _KbColors.cardBorder, width: 1),
          ),
          padding: EdgeInsets.fromLTRB(9 * s, 10 * s, 9 * s, 10 * s),
          child: Row(
            children: [
              Container(
                width: 31 * s,
                height: 31 * s,
                decoration: BoxDecoration(
                  color: _KbColors.mint,
                  borderRadius: BorderRadius.circular(10 * s),
                ),
                child: Center(child: icon),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: GoogleFonts.inter(
                        fontSize: 9.5 * s,
                        fontWeight: FontWeight.w700,
                        color: _KbColors.text,
                      ),
                    ),
                    SizedBox(height: 3.5 * s),
                    Text(
                      a.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 7.5 * s,
                        fontWeight: FontWeight.w400,
                        color: _KbColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 1 * s),
                    child: Text(
                      a.duration,
                      style: GoogleFonts.inter(
                        fontSize: 7.4 * s,
                        fontWeight: FontWeight.w600,
                        color: _KbColors.greenSoft,
                      ),
                    ),
                  ),
                  SizedBox(height: 3 * s),
                  Icon(Icons.chevron_right_rounded,
                      size: 13 * s, color: const Color(0xFF5F6B67)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(double s) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.5 * s, 12 * s, 12 * s, 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFD),
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: _KbColors.cardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.5 * s),
            child: Icon(Icons.verified_user_outlined,
                size: 13.5 * s, color: const Color(0xFF2D6A58)),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tetap jaga udara bersih',
                  style: GoogleFonts.inter(
                    fontSize: 9 * s,
                    fontWeight: FontWeight.w700,
                    color: _KbColors.text,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  'Hindari asap di rumah. Jika harus keluar, gunakan masker '
                  'yang pas, seperti KN95.',
                  style: GoogleFonts.inter(
                    fontSize: 7.6 * s,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: _KbColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(double s) {
    return Material(
      color: _KbColors.green,
      borderRadius: BorderRadius.circular(16 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(16 * s),
        onTap: onMulaiTap,
        child: SizedBox(
          height: 43 * s,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mulai Peregangan',
                style: GoogleFonts.inter(
                  fontSize: 9.8 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14 * s),
              Icon(Icons.play_arrow_outlined,
                  size: 14 * s, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 330;
    canvas.save();
    canvas.scale(k, k);

    final fill = Paint()..color = _KbColors.leaf;

    canvas.drawPath(
      Path()
        ..moveTo(212, 62)
        ..cubicTo(190, 85, 188, 150, 225, 195)
        ..lineTo(285, 195)
        ..cubicTo(290, 120, 260, 75, 212, 62)
        ..close(),
      fill,
    );

    canvas.drawPath(
      Path()
        ..moveTo(340, 20)
        ..cubicTo(290, 42, 262, 110, 272, 195)
        ..lineTo(345, 195)
        ..close(),
      fill,
    );

    final vein = Paint()
      ..color = _KbColors.leafVein
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(242, 104)
        ..quadraticBezierTo(250, 140, 263, 180),
      vein,
    );
    canvas.drawPath(
      Path()
        ..moveTo(310, 87)
        ..quadraticBezierTo(285, 125, 270, 180),
      vein,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FootprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k, k);

    final line = Paint()
      ..color = const Color(0xFF2D6A58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    void foot(Offset sole, Offset heel, double angle) {
      canvas.save();
      canvas.translate(sole.dx, sole.dy);
      canvas.rotate(angle);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 5.4, height: 8.6), line);
      canvas.restore();
      canvas.drawOval(
          Rect.fromCenter(center: heel, width: 4.2, height: 3.6), line);
    }

    foot(const Offset(8.2, 8.4), const Offset(8.6, 15.6), -0.1);
    foot(const Offset(15.6, 11.4), const Offset(15.2, 18.6), 0.1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StretchPainter extends CustomPainter {
  static const _skin = Color(0xFFD6A07C);
  static const _shirt = Color(0xFF9CA88B);
  static const _pants = Color(0xFFF3E6C4);
  static const _hair = Color(0xFF3A2E2B);

  Paint _fill(Color c) => Paint()..color = c;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _oval(Canvas canvas, double cx, double cy, double w, double h, Color c) {
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: w, height: h), _fill(c));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 95;
    canvas.save();
    canvas.scale(k, k);

    final matEdge = const Color(0xFF4E7156);
    canvas.drawPath(
      Path()
        ..moveTo(0.5, 66)
        ..lineTo(70.5, 75)
        ..lineTo(70.5, 77)
        ..lineTo(0.5, 68)
        ..close(),
      _fill(matEdge),
    );
    canvas.drawPath(
      Path()
        ..moveTo(70.5, 75)
        ..lineTo(94.5, 62)
        ..lineTo(94.5, 64)
        ..lineTo(70.5, 77)
        ..close(),
      _fill(matEdge),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0.5, 66)
        ..lineTo(23.8, 58.5)
        ..lineTo(94.5, 62)
        ..lineTo(70.5, 75)
        ..close(),
      _fill(const Color(0xFF5F8466)),
    );

    canvas.drawPath(
      Path()
        ..moveTo(66, 66)
        ..lineTo(74, 66)
        ..lineTo(73, 72)
        ..lineTo(67, 72)
        ..close(),
      _fill(const Color(0xFFC9895F)),
    );
    _oval(canvas, 70, 64.5, 6, 5, const Color(0xFF5E8C5B));

    canvas.drawPath(
      Path()
        ..moveTo(40, 51)
        ..cubicTo(38, 40, 40, 28, 44, 18)
        ..quadraticBezierTo(52, 15, 58, 23)
        ..lineTo(62, 28)
        ..cubicTo(64, 36, 65, 44, 64, 50)
        ..close(),
      _fill(_shirt),
    );

    canvas.drawLine(
        const Offset(60, 27), const Offset(68, 40), _stroke(_shirt, 6.5));
    canvas.drawLine(
        const Offset(67, 38), const Offset(79, 61), _stroke(_skin, 4.4));
    _oval(canvas, 80.5, 62, 7, 3.6, _skin);

    canvas.drawPath(
      Path()
        ..moveTo(20, 51)
        ..quadraticBezierTo(30, 46, 42, 47)
        ..quadraticBezierTo(55, 45, 65, 55)
        ..quadraticBezierTo(66, 64, 52, 66)
        ..quadraticBezierTo(36, 69, 23, 60)
        ..close(),
      _fill(_pants),
    );
    canvas.drawPath(
      Path()
        ..moveTo(28, 57)
        ..quadraticBezierTo(42, 62, 58, 60),
      _stroke(const Color(0xFFDECDA0), 0.8),
    );
    _oval(canvas, 30, 63.5, 13, 6, _skin);
    _oval(canvas, 49, 66.5, 6, 4, _skin);

    canvas.drawLine(
        const Offset(62, 19), const Offset(61.5, 23), _stroke(_skin, 4.2));
    _oval(canvas, 62, 16, 13.5, 14, _skin);
    _oval(canvas, 62, 10.5, 15.5, 10, _hair);
    _oval(canvas, 56.5, 12.5, 6, 6, _hair);
    _oval(canvas, 68, 12.5, 5, 6, _hair);
    _oval(canvas, 62, 8, 8, 5, _hair);

    final eye = _stroke(const Color(0xFF3C2823), 0.7);
    canvas.drawPath(
      Path()
        ..moveTo(58, 16.5)
        ..quadraticBezierTo(59.5, 18, 61, 16.5),
      eye,
    );
    canvas.drawPath(
      Path()
        ..moveTo(63.5, 16)
        ..quadraticBezierTo(65, 17.5, 66.5, 16),
      eye,
    );

    canvas.drawLine(
        const Offset(44, 20), const Offset(45.5, 13), _stroke(_shirt, 6.5));
    canvas.drawLine(
        const Offset(45.5, 13), const Offset(47.5, 6), _stroke(_skin, 4.2));
    canvas.drawPath(
      Path()
        ..moveTo(47.5, 6)
        ..quadraticBezierTo(52, 0.5, 66, 2),
      _stroke(_skin, 3.8),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
