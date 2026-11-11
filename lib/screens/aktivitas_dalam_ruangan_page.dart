import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _AkColors {
  static const bg = Color(0xFFF6F9F6);
  static const green = Color(0xFF1A6B55);
  static const greenSoft = Color(0xFF2E7B67);
  static const iconGreen = Color(0xFF2D6A58);
  static const header = Color(0xFF2E4A42);
  static const text = Color(0xFF3A4A45);
  static const headline = Color(0xFF2A4540);
  static const muted = Color(0xFF9AA7A2);
  static const hero = Color(0xFFE1EFE5);
  static const heroLeafLight = Color(0xFFE7F2EA);
  static const heroLeafDark = Color(0xFFD8EADC);
  static const pageLeafA = Color(0xFFEAF3EC);
  static const pageLeafB = Color(0xFFE4EFE7);
  static const mint = Color(0xFFE3F0E7);
  static const amberBg = Color(0xFFFDEFD6);
  static const amberText = Color(0xFFB8801F);
}

enum AktivitasBadge { direkomendasikan, wajib, aman }

enum AktivitasIcon { air, jendela, peregangan }

class AktivitasItem {
  final AktivitasIcon icon;
  final String title;
  final String description;
  final String badgeLabel;
  final AktivitasBadge badge;

  final bool badgeAfterDescription;

  const AktivitasItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeLabel,
    required this.badge,
    this.badgeAfterDescription = false,
  });
}

class AktivitasDalamRuanganPage extends StatelessWidget {
  final String roomStatus;
  final String headline;
  final String description;
  final String sectionTitle;
  final String guideCountLabel;
  final List<AktivitasItem> items;

  final ValueChanged<AktivitasItem>? onItemTap;

  final VoidCallback? onCekAlatTap;

  const AktivitasDalamRuanganPage({
    super.key,
    this.roomStatus = 'Kondisi Ruangan: Optimal',
    this.headline = 'Tetap terlindungi, meski\ndi dalam rumah.',
    this.description =
        'Saat polusi atau kabut asap tinggi, jaga udara ruangan\n'
            'dan pilih aktivitas ringan.',
    this.sectionTitle = 'Langkah untuk ruangan Anda',
    this.guideCountLabel = '4 panduan',
    this.items = defaultItems,
    this.onItemTap,
    this.onCekAlatTap,
  });

  static const defaultItems = <AktivitasItem>[
    AktivitasItem(
      icon: AktivitasIcon.air,
      title: 'Minum Air yang Cukup',
      description: 'Minum air putih secara rutin untuk menjaga tubuh.',
      badgeLabel: 'Direkomendasikan',
      badge: AktivitasBadge.direkomendasikan,
      badgeAfterDescription: true,
    ),
    AktivitasItem(
      icon: AktivitasIcon.jendela,
      title: 'Tutup Rapat Jendela & Ventilasi',
      description: 'Batasi masuknya asap dan polusi dari luar.',
      badgeLabel: 'Wajib',
      badge: AktivitasBadge.wajib,
    ),
    AktivitasItem(
      icon: AktivitasIcon.peregangan,
      title: 'Lakukan Peregangan / Yoga Ringan',
      description: 'Gerak perlahan selama 10–15 menit.',
      badgeLabel: 'Aman',
      badge: AktivitasBadge.aman,
    ),
  ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'indoor',
        tour: const [
          CoachStep(title: 'Kondisi ruangan', body: 'Menunjukkan apakah ruanganmu optimal dan pesan singkat agar tetap terlindungi di dalam rumah.'),
          CoachStep(title: 'Langkah untuk ruangan', body: 'Empat panduan: minum air yang cukup, tutup rapat jendela dan ventilasi, peregangan atau yoga ringan, dan cek alat pembersih udara. Label menunjukkan tingkat pentingnya.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Aktivitas Dalam Ruangan. Ada kondisi ruangan dan empat langkah: minum air yang cukup, tutup rapat jendela dan ventilasi, peregangan atau yoga ringan, dan cek alat pembersih udara.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final media = MediaQuery.of(context);
    final s = media.size.width / 308;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _AkColors.bg,
        body: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _PageLeafPainter())),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, s),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(18 * s, 12 * s, 18 * s, 16 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHero(s),
                          SizedBox(height: 14 * s),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                sectionTitle,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5 * s,
                                  fontWeight: FontWeight.w400,
                                  color: _AkColors.text,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                guideCountLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 7.5 * s,
                                  fontWeight: FontWeight.w400,
                                  color: _AkColors.muted,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10 * s),
                          for (var i = 0; i < items.length; i++) ...[
                            if (i > 0) SizedBox(height: 10.5 * s),
                            _buildItem(s, items[i]),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18 * s, 8 * s, 18 * s, 16 * s),
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
        padding: EdgeInsets.only(left: 16 * s, right: 18 * s),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: EdgeInsets.all(4 * s),
                child: Icon(Icons.arrow_back_rounded,
                    size: 16 * s, color: _AkColors.header),
              ),
            ),
            SizedBox(width: 18 * s),
            Text(
              'Aktivitas Dalam Ruangan',
              style: GoogleFonts.inter(
                fontSize: 11 * s,
                letterSpacing: -0.2,
                fontWeight: FontWeight.w700,
                color: _AkColors.header,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(double s) {
    return Container(
      decoration: BoxDecoration(
        color: _AkColors.hero,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HeroLeafPainter())),
          Padding(
            padding: EdgeInsets.fromLTRB(15 * s, 15 * s, 15 * s, 14.5 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 22 * s,
                  padding: EdgeInsets.only(left: 8 * s, right: 9 * s),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFDFB),
                    borderRadius: BorderRadius.circular(11 * s),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_outlined,
                          size: 10 * s, color: _AkColors.greenSoft),
                      SizedBox(width: 6 * s),
                      Text(
                        roomStatus,
                        style: GoogleFonts.inter(
                          fontSize: 7.5 * s,
                          fontWeight: FontWeight.w700,
                          color: _AkColors.greenSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 9.5 * s),
                Text(
                  headline,
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    height: 1.33,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w400,
                    color: _AkColors.headline,
                  ),
                ),
                SizedBox(height: 9 * s),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 8.2 * s,
                    height: 1.65,
                    fontWeight: FontWeight.w400,
                    color: _AkColors.greenSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(double s, AktivitasItem item) {
    final badge = _badge(s, item);
    final desc = Text(
      item.description,
      style: GoogleFonts.inter(
        fontSize: 7.2 * s,
        height: 1.25,
        fontWeight: FontWeight.w400,
        color: _AkColors.muted,
      ),
    );

    final List<Widget> body = item.badgeAfterDescription
        ? [desc, SizedBox(height: 5.5 * s), badge]
        : [badge, SizedBox(height: 6.5 * s), desc];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15 * s),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2A24).withValues(alpha: 0.07),
            blurRadius: 14 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * s),
        child: InkWell(
          borderRadius: BorderRadius.circular(15 * s),
          onTap: onItemTap == null ? null : () => onItemTap!(item),
          child: Padding(
            padding: EdgeInsets.fromLTRB(9.75 * s, 10.5 * s, 12 * s, 10.5 * s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30 * s,
                  height: 30 * s,
                  decoration: BoxDecoration(
                    color: _AkColors.mint,
                    borderRadius: BorderRadius.circular(9 * s),
                  ),
                  child: Center(child: _iconFor(item.icon, s)),
                ),
                SizedBox(width: 9.5 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 0.5 * s),
                        child: Text(
                          item.title,
                          style: GoogleFonts.inter(
                            fontSize: 10.2 * s,
                            height: 1.2,
                            letterSpacing: -0.15,
                            fontWeight: FontWeight.w700,
                            color: _AkColors.header,
                          ),
                        ),
                      ),
                      SizedBox(height: 6 * s),
                      ...body,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(double s, AktivitasItem item) {
    final isWajib = item.badge == AktivitasBadge.wajib;
    return Container(
      height: 16 * s,
      padding: EdgeInsets.symmetric(horizontal: 8 * s),
      decoration: BoxDecoration(
        color: isWajib ? _AkColors.amberBg : _AkColors.mint,
        borderRadius: BorderRadius.circular(8 * s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.badgeLabel,
            style: GoogleFonts.inter(
              fontSize: 7 * s,
              fontWeight: FontWeight.w700,
              color: isWajib ? _AkColors.amberText : _AkColors.greenSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconFor(AktivitasIcon icon, double s) {
    final painter = switch (icon) {
      AktivitasIcon.air => _WaterGlassPainter(),
      AktivitasIcon.jendela => _WindowPainter(),
      AktivitasIcon.peregangan => _PersonPainter(),
    };
    return SizedBox(
      width: 16 * s,
      height: 16 * s,
      child: CustomPaint(painter: painter),
    );
  }

  Widget _buildButton(double s) {
    return Material(
      color: _AkColors.green,
      borderRadius: BorderRadius.circular(15 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(15 * s),
        onTap: onCekAlatTap,
        child: SizedBox(
          height: 37 * s,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Cek Alat Pembersih Udara',
                style: GoogleFonts.inter(
                  fontSize: 9.8 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10 * s),
              Icon(Icons.arrow_forward_rounded,
                  size: 11 * s, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 308;
    canvas.save();
    canvas.scale(k, k);
    canvas.drawCircle(
        const Offset(300, 18), 62, Paint()..color = _AkColors.pageLeafA);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(310, 78), width: 70, height: 84),
      Paint()..color = _AkColors.pageLeafB,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    canvas.translate(w * 0.83, h * 0.32);
    canvas.rotate(-0.25);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: w * 0.19, height: h * 0.66),
      Paint()..color = _AkColors.heroLeafLight,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(w * 0.98, h * 0.62);
    canvas.rotate(0.15);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: w * 0.2, height: h * 0.78),
      Paint()..color = _AkColors.heroLeafDark,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Paint _line(double w) => Paint()
  ..color = _AkColors.iconGreen
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

class _WaterGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k, k);
    final p = _line(1.6);

    canvas.drawOval(const Rect.fromLTRB(5.2, 3.2, 18.8, 7.4), p);
    canvas.drawPath(
      Path()
        ..moveTo(5.2, 5.3)
        ..lineTo(6.8, 18.6)
        ..quadraticBezierTo(12, 22.2, 17.2, 18.6)
        ..lineTo(18.8, 5.3),
      p,
    );

    canvas.drawPath(
      Path()
        ..moveTo(5.9, 10.6)
        ..quadraticBezierTo(12, 14, 18.1, 10.6),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(6.4, 14.6)
        ..quadraticBezierTo(12, 18, 17.6, 14.6),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WindowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k, k);
    final p = _line(1.6);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTRB(3.5, 4, 20.5, 20), const Radius.circular(2)),
      p,
    );
    canvas.drawLine(const Offset(3.5, 9.4), const Offset(20.5, 9.4), p);
    canvas.drawLine(const Offset(9.6, 9.4), const Offset(9.6, 20), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PersonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k, k);
    final p = _line(1.7);

    canvas.drawCircle(const Offset(12, 4.6), 1.9, p);
    canvas.drawPath(
      Path()
        ..moveTo(5.8, 8.6)
        ..quadraticBezierTo(12, 10.6, 18.2, 8.6),
      p,
    );
    canvas.drawLine(const Offset(12, 10), const Offset(12, 14.6), p);
    canvas.drawLine(const Offset(12, 14.6), const Offset(8.6, 20.4), p);
    canvas.drawLine(const Offset(12, 14.6), const Offset(15.4, 20.4), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
