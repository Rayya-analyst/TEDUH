import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailArtikelPage extends StatefulWidget {
  final String heroImageAsset;
  final List<String> relatedImageAssets;

  final ValueChanged<int>? onRelatedTap;

  const DetailArtikelPage({
    super.key,
    this.heroImageAsset = 'assets/images/artikel_hero.jpg',
    this.relatedImageAssets = const [
      'assets/images/artikel_terkait_3.jpg', 
      'assets/images/artikel_terkait_5.jpg', 
      'assets/images/artikel_terkait_1.jpg', 
      'assets/images/artikel_terkait_4.jpg', 
      'assets/images/artikel_terkait_2.jpg', 
    ],
    this.onRelatedTap,
  });

  @override
  State<DetailArtikelPage> createState() => _DetailArtikelPageState();
}

class _Related {
  final String title;
  final String duration;
  final int tone; 
  const _Related(this.title, this.duration, this.tone);
}

class _DetailArtikelPageState extends State<DetailArtikelPage> {
  final GlobalKey _kHead = GlobalKey();
  final GlobalKey _kBody = GlobalKey();
  final GlobalKey _kRelated = GlobalKey();
  static const Color _green = Color(0xFF1B5E4B);
  static const Color _greenMid = Color(0xFF176D59);
  static const Color _red = Color(0xFFE5484D);
  static const Color _body = Color(0xFF4A5A55);
  static const Color _muted = Color(0xFF8A9691);

  static const List<_Related> _related = [
    _Related('Memilih masker yang tepat untuk aktivitasmu', '3 menit baca', 2),
    _Related('Udara rumah bersih, napas lebih lega', '5 menit baca', 0),
    _Related('Kebiasaan kecil untuk melindungi napasmu', '4 menit baca', 1),

    _Related('Kenali kualitas udara di sekitarmu', '3 menit baca', 0),
    _Related('Rawat paru-paru, mulai dari hari ini', '4 menit baca', 1),
  ];

  bool _saved = true;

  void _share() {
    Clipboard.setData(const ClipboardData(
        text: 'Kenali bahaya PM2.5, lindungi pernapasanmu.'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Judul artikel disalin')),
    );
  }

  Widget _photo({
    required String asset,
    required Widget fallback,
  }) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => SizedBox.expand(child: fallback),
    );
  }

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'article',
        tour: [
          CoachStep(
            target: _kHead,
            title: 'Judul dan penulis',
            body: 'Judul artikel, kategori, penulis, dan lama membaca ada di bagian atas.',
            scrollAlignment: 0.1,
          ),
          CoachStep(
            target: _kBody,
            title: 'Isi artikel',
            body: 'Penjelasan apa itu PM2.5 dan bagaimana dampaknya bagi tubuh, terutama anak, lansia, dan penderita gangguan pernapasan.',
            scrollAlignment: 0.1,
          ),
          CoachStep(
            target: _kRelated,
            title: 'Artikel terkait',
            body: 'Ketuk artikel lain di bagian ini untuk terus belajar tentang udara dan kesehatan.',
            scrollAlignment: 0.1,
          ),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman artikel. Isinya penjelasan tentang PM2.5: apa itu PM2.5, dan bagaimana dampaknya bagi tubuh. Di bawahnya ada artikel terkait.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final double s = MediaQuery.of(context).size.width / 412;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFDDEEE3),
                Color(0xFFEBF5EE),
                Color(0xFFFAFCFA),
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, s),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 8 * s, bottom: 24 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KeyedSubtree(
                          key: _kHead,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHero(s),
                              SizedBox(height: 22 * s),
                              _buildMeta(s),
                              SizedBox(height: 16 * s),
                              _pad(s, _buildTitle(s)),
                            ],
                          ),
                        ),
                        SizedBox(height: 16 * s),
                        KeyedSubtree(
                          key: _kBody,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        _pad(s, _heading(s, 'Apa itu PM2.5?')),
                        SizedBox(height: 8 * s),
                        _pad(
                          s,
                          _paragraph(
                            s,
                            'PM2.5 adalah partikel halus di udara yang '
                            'berdiameter ≤2,5 mikrometer. Partikel ini berasal '
                            'dari sumber seperti pembakaran sampah, kebakaran '
                            'hutan, dan emisi kendaraan. Ukurannya sangat kecil '
                            'sehingga tidak selalu terlihat oleh mata.',
                          ),
                        ),
                        SizedBox(height: 14 * s),
                        _pad(s, _heading(s, 'Bagaimana dampaknya bagi tubuh?')),
                        SizedBox(height: 8 * s),
                        _pad(
                          s,
                          _paragraph(
                            s,
                            'Saat terhirup, PM2.5 dapat masuk jauh ke paru-paru, '
                            'memperburuk gangguan pernapasan seperti asma, dan '
                            'meningkatkan risiko gangguan jantung. Anak-anak, '
                            'lansia, serta penderita penyakit pernapasan lebih '
                            'rentan terhadap dampaknya. Mengurangi paparan '
                            'membantu melindungi kesehatan mereka.',
                          ),
                        ),
                            ],
                          ),
                        ),
                        SizedBox(height: 22 * s),
                        KeyedSubtree(
                          key: _kRelated,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _pad(s, _heading(s, 'Artikel terkait')),
                              SizedBox(height: 16 * s),
                              _buildRelated(s),
                            ],
                          ),
                        ),
                        SizedBox(height: 22 * s),
                        _buildFooter(s),
                      ],
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

  Widget _pad(double s, Widget child) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: 24 * s), child: child);

  Widget _buildHeader(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * s, 12 * s, 14 * s, 0),
      child: SizedBox(
        height: 36 * s,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: EdgeInsets.all(6 * s),
                child: Icon(Icons.arrow_back_rounded,
                    size: 22 * s, color: const Color(0xFF14231F)),
              ),
            ),
            Expanded(
              child: Text(
                'Udara dan Kesehatan',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.5 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF14231F),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _saved = !_saved),
              child: Padding(
                padding: EdgeInsets.all(6 * s),
                child: Icon(
                  _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 26 * s,
                  color: const Color(0xFF1B5E4B),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _share,
              child: Padding(
                padding: EdgeInsets.all(6 * s),
                child: Icon(Icons.share_outlined,
                    size: 22 * s, color: const Color(0xFF14231F)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Container(
        height: 185 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D6B).withValues(alpha: 0.25),
              blurRadius: 12 * s,
              offset: Offset(0, 5 * s),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28 * s),
          child: _photo(
            asset: widget.heroImageAsset,
            fallback: const CustomPaint(painter: _ScenePainter(0)),
          ),
        ),
      ),
    );
  }

  Widget _buildMeta(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UDARA & KESEHATAN',
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: _greenMid,
            ),
          ),
          SizedBox(height: 5 * s),
          Text(
            'Ditulis oleh dr. Andi • 3 menit baca',
            style: GoogleFonts.inter(fontSize: 12.5 * s, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(double s) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 30 * s,
          fontWeight: FontWeight.w800,
          height: 1.3,
          color: _green,
        ),
        children: const [
          TextSpan(text: 'Kenali '),
          TextSpan(text: 'bahaya PM2.5', style: TextStyle(color: _red)),
          TextSpan(text: ', lindungi pernapasanmu.'),
        ],
      ),
    );
  }

  Widget _heading(double s, String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 19 * s,
        fontWeight: FontWeight.w800,
        color: _green,
      ),
    );
  }

  Widget _paragraph(double s, String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16 * s,
        height: 1.7,
        color: _body,
      ),
    );
  }

  Widget _buildRelated(double s) {
    return SizedBox(
      height: 262 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24 * s),
        itemCount: _related.length,
        separatorBuilder: (_, _) => SizedBox(width: 16 * s),
        itemBuilder: (context, i) {
          final _Related r = _related[i];
          final String asset = i < widget.relatedImageAssets.length
              ? widget.relatedImageAssets[i]
              : '';
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onRelatedTap == null
                ? null
                : () => widget.onRelatedTap!(i),
            child: SizedBox(
              width: 156 * s,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 156 * s,
                    height: 156 * s,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20 * s),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8 * s,
                          offset: Offset(0, 3 * s),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20 * s),
                      child: _photo(
                        asset: asset,
                        fallback: CustomPaint(painter: _ScenePainter(r.tone + 1)),
                      ),
                    ),
                  ),
                  SizedBox(height: 11 * s),
                  Text(
                    r.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.3 * s,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    r.duration,
                    style: GoogleFonts.inter(fontSize: 11 * s, color: _muted),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Column(
        children: [
          Icon(Icons.eco_rounded, size: 40 * s, color: _green),
          SizedBox(height: 4 * s),
          Text(
            'TEDUH',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: 4.5 * s,
              color: _green,
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            'Hidup Sehat, Udara Lebih Baik',
            style: GoogleFonts.inter(fontSize: 12 * s, color: _muted),
          ),
          SizedBox(height: 18 * s),
          Container(height: 1, color: const Color(0xFFDDE6E0)),
        ],
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final int kind;
  const _ScenePainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Offset.zero & size;
    final double w = size.width;
    final double h = size.height;

    final List<Color> sky;
    switch (kind) {
      case 1:
        sky = const [Color(0xFFB9CCD6), Color(0xFFE6ECEC)];
        break;
      case 2:
        sky = const [Color(0xFFB7D99A), Color(0xFFE4EFC8)];
        break;
      case 3:
        sky = const [Color(0xFFEDE6DC), Color(0xFFF7F3EC)];
        break;
      default:
        sky = const [Color(0xFFC3D6DC), Color(0xFFE7EFEA)];
    }
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sky,
        ).createShader(r),
    );

    if (kind == 3) return;

    if (kind == 1) {

      final Paint b = Paint()..color = const Color(0xFF9DB0B8).withValues(alpha: 0.7);
      final math.Random rnd = math.Random(3);
      double x = w * 0.28;
      while (x < w * 0.95) {
        final double bw = w * (0.04 + rnd.nextDouble() * 0.04);
        final double bh = h * (0.18 + rnd.nextDouble() * 0.3);
        canvas.drawRect(Rect.fromLTWH(x, h * 0.62 - bh, bw, bh), b);
        x += bw + w * 0.012;
      }
    } else {

      final Path ridge = Path()
        ..moveTo(0, h * 0.42)
        ..quadraticBezierTo(w * 0.25, h * 0.22, w * 0.5, h * 0.38)
        ..quadraticBezierTo(w * 0.75, h * 0.5, w, h * 0.3)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
          ridge, Paint()..color = const Color(0xFF8FB0A8).withValues(alpha: 0.75));
    }

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.4, w, h * 0.18),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.4, w, h * 0.18)),
    );

    final math.Random rnd = math.Random(kind * 11 + 5);
    final List<Color> greens = kind == 2
        ? const [Color(0xFF3E7A35), Color(0xFF2F6A2E), Color(0xFF558F3E)]
        : const [Color(0xFF2F6A4B), Color(0xFF1F5A3E), Color(0xFF3F7F5A)];
    for (int layer = 0; layer < 3; layer++) {
      final double baseY = h * (0.55 + layer * 0.17);
      final int count = 9 + layer * 3;
      for (int i = 0; i < count; i++) {
        final double cx = (i + rnd.nextDouble()) * w / count;
        final double rad = w * (0.07 + rnd.nextDouble() * 0.05 + layer * 0.02);
        final Paint p = Paint()
          ..color = greens[(i + layer) % greens.length]
              .withValues(alpha: 0.78 + layer * 0.08);
        canvas.drawCircle(Offset(cx, baseY + rnd.nextDouble() * h * 0.05), rad, p);
        canvas.drawCircle(
            Offset(cx + rad * 0.4, baseY - rad * 0.5), rad * 0.8, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.kind != kind;
}
