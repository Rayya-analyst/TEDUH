import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _PuColors {
  static const ink = Color(0xFF1E2B27);
  static const green = Color(0xFF176D59);
  static const muted = Color(0xFF8A938F);
  static const legend = Color(0xFF5E6B66);
}

enum _Level { baik, sedang, tidakSehat, sangatTidakSehat }

extension on _Level {
  String get label => switch (this) {
        _Level.baik => 'Baik',
        _Level.sedang => 'Sedang',
        _Level.tidakSehat => 'Tidak Sehat',
        _Level.sangatTidakSehat => 'Sangat Tidak Sehat',
      };
  Color get color => switch (this) {
        _Level.baik => const Color(0xFF3FA37A),
        _Level.sedang => const Color(0xFFE5B93C),
        _Level.tidakSehat => const Color(0xFFE8872E),
        _Level.sangatTidakSehat => const Color(0xFFD9534F),
      };
  Color get pillBg => switch (this) {
        _Level.baik => const Color(0xFFE0F2EA),
        _Level.sedang => const Color(0xFFFBF3D9),
        _Level.tidakSehat => const Color(0xFFFCEBDD),
        _Level.sangatTidakSehat => const Color(0xFFFBE3E1),
      };
  Color get pillText => switch (this) {
        _Level.baik => const Color(0xFF2F8F69),
        _Level.sedang => const Color(0xFFB08A10),
        _Level.tidakSehat => const Color(0xFFE0802B),
        _Level.sangatTidakSehat => const Color(0xFFD9534F),
      };
}

class _Spot {
  final String name;
  final int value;
  final _Level level;
  final double x; 
  final double y;
  final double size;
  final double halo;
  const _Spot(this.name, this.value, this.level, this.x, this.y, this.size,
      {this.halo = 0});
}

class PetaUdaraPage extends StatefulWidget {

  final String? mapImageAsset;
  final String regionName;

  const PetaUdaraPage({
    super.key,
    this.mapImageAsset,
    this.regionName = 'Kalimantan Tengah',
  });

  @override
  State<PetaUdaraPage> createState() => _PetaUdaraPageState();
}

class _PetaUdaraPageState extends State<PetaUdaraPage> {
  static const List<_Spot> _spots = [
    _Spot('Gedeg', 42, _Level.baik, 68, 118, 21),
    _Spot('Magersari', 86, _Level.sedang, 203, 158, 21),
    _Spot('Prajurit Kulon', 242, _Level.sangatTidakSehat, 59, 261, 22,
        halo: 62),
    _Spot('Mojokerto', 142, _Level.tidakSehat, 152, 258, 30, halo: 46),
  ];

  final TransformationController _controller = TransformationController();
  int _selected = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoom(double factor, Size size) {
    final current = _controller.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(1.0, 3.0);
    if (target <= 1.0) {
      _controller.value = Matrix4.identity();
      return;
    }
    final f = target / current;
    final c = Offset(size.width / 2, size.height / 2);
    final t = Matrix4.translationValues(c.dx, c.dy, 0)
        .multiplied(Matrix4.diagonal3Values(f, f, 1))
        .multiplied(Matrix4.translationValues(-c.dx, -c.dy, 0));
    _controller.value = t.multiplied(_controller.value);
  }

  void _resetView() => _controller.value = Matrix4.identity();

  List<CoachStep> get _tour => const [
        CoachStep(title: 'Peta Kualitas Udara', body: 'Peta menampilkan titik-titik pemantauan di wilayah pilihanmu. Warna tiap titik menunjukkan tingkat kualitas udara, dari baik sampai berbahaya.'),
        CoachStep(title: 'Wilayah pilihan', body: 'Wilayah yang sedang ditampilkan tertulis di bagian atas peta. Ganti wilayah untuk melihat kondisi udara di tempat lain.'),
        CoachStep(title: 'Lihat detail lokasi', body: 'Ketuk sebuah titik atau lokasi untuk melihat nilai udaranya. Data di halaman ini masih berupa ilustrasi.'),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'peta',
        tour: _tour,
        guide: PageGuide(content: () => 'Ini halaman Peta Udara. Berisi peta kualitas udara di wilayah pilihanmu, titik pemantauan berwarna sesuai tingkat bahayanya, dan daftar lokasi di sekitarnya. Data saat ini masih ilustrasi. Ucapkan kembali untuk ke halaman sebelumnya.'),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    final media = MediaQuery.of(context);
    final s = media.size.width / 282;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: media.padding.top + 8 * s),
            _buildTopBar(s),
            SizedBox(height: 18 * s),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * s),
                child: _buildMapCard(s),
              ),
            ),
            SizedBox(height: 20 * s + media.padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 22 * s, right: 18 * s),
      child: SizedBox(
        height: 24 * s,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: EdgeInsets.all(2 * s),
                child: Icon(Icons.arrow_back_rounded,
                    size: 14 * s, color: _PuColors.ink),
              ),
            ),
            SizedBox(width: 14 * s),
            Text(
              'Peta Kualitas Udara',
              style: GoogleFonts.inter(
                fontSize: 11 * s,
                fontWeight: FontWeight.w700,
                color: _PuColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(double s) {
    return LayoutBuilder(
      builder: (context, c) {
        final k = c.maxWidth / 254;
        final size = Size(c.maxWidth, c.maxHeight);
        final spot = _spots[_selected];

        return ClipRRect(
          borderRadius: BorderRadius.circular(22 * s),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _controller,
                  minScale: 1,
                  maxScale: 3,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: widget.mapImageAsset != null
                              ? Image.asset(widget.mapImageAsset!,
                                  fit: BoxFit.cover)
                              : CustomPaint(painter: _MapPainter(k)),
                        ),
                        for (var i = 0; i < _spots.length; i++)
                          _buildMarker(k, i),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 9 * k,
                top: 10 * k,
                child: Container(
                  height: 29 * k,
                  padding: EdgeInsets.symmetric(horizontal: 11 * k),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20 * k),
                    boxShadow: _softShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 11 * k, color: _PuColors.green),
                      SizedBox(width: 5 * k),
                      Text(
                        widget.regionName,
                        style: GoogleFonts.inter(
                          fontSize: 8.5 * k,
                          fontWeight: FontWeight.w700,
                          color: _PuColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                right: 7 * k,
                top: 12 * k,
                child: _squareButton(
                  k,
                  Icon(Icons.layers_outlined,
                      size: 14 * k, color: _PuColors.green),
                  null,
                ),
              ),

              Positioned(
                left: 9 * k,
                top: 48 * k,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6 * k, vertical: 2.5 * k),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8 * k),
                  ),
                  child: Text(
                    'Data ilustrasi',
                    style: GoogleFonts.inter(
                      fontSize: 6.5 * k,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7B8480),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 7 * k,
                top: 239 * k,
                child: Container(
                  width: 29 * k,
                  height: 55 * k,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10 * k),
                    boxShadow: _softShadow,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _zoom(1.4, size),
                          child: Center(
                            child: Icon(Icons.add_rounded,
                                size: 13 * k, color: _PuColors.ink),
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        margin: EdgeInsets.symmetric(horizontal: 7 * k),
                        color: const Color(0xFFE8ECE9),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _zoom(1 / 1.4, size),
                          child: Center(
                            child: Icon(Icons.remove_rounded,
                                size: 13 * k, color: _PuColors.ink),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                right: 7 * k,
                top: 306 * k,
                child: _squareButton(
                  k,
                  Icon(Icons.my_location_rounded,
                      size: 13 * k, color: _PuColors.green),
                  _resetView,
                  height: 28,
                ),
              ),

              Positioned(
                left: 9 * k,
                right: 7 * k,
                bottom: 9 * k,
                child: _buildInfoCard(k, spot),
              ),
            ],
          ),
        );
      },
    );
  }

  List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  Widget _squareButton(double k, Widget icon, VoidCallback? onTap,
      {double height = 29}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 29 * k,
        height: height * k,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10 * k),
          boxShadow: _softShadow,
        ),
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildMarker(double k, int index) {
    final sp = _spots[index];
    final selected = index == _selected;
    final total = (sp.halo > 0 ? sp.halo : sp.size) * k;
    final fontSize = (sp.size >= 28 ? 11 : 8) * k;

    return Positioned(
      left: sp.x * k - total / 2,
      top: sp.y * k - total / 2,
      width: total,
      height: total,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => setState(() => _selected = index),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (sp.halo > 0)
              Container(
                width: sp.halo * k,
                height: sp.halo * k,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sp.level.color.withValues(alpha: 0.20),
                ),
              ),
            AnimatedScale(
              scale: selected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: sp.size * k,
                height: sp.size * k,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sp.level.color,
                  border: Border.all(
                      color: Colors.white, width: (sp.size >= 28 ? 2.5 : 2) * k),
                  boxShadow: [
                    BoxShadow(
                      color: sp.level.color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${sp.value}',
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(double k, _Spot sp) {
    Widget legend(Color color, String text) => Padding(
          padding: EdgeInsets.only(bottom: 5 * k),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5 * k,
                height: 5 * k,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 6 * k),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 7 * k,
                  fontWeight: FontWeight.w400,
                  color: _PuColors.legend,
                ),
              ),
            ],
          ),
        );

    return Container(
      height: 124 * k,
      padding: EdgeInsets.fromLTRB(13 * k, 12 * k, 13 * k, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * k),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'WILAYAH PILIHAN',
                style: GoogleFonts.inter(
                  fontSize: 6.3 * k,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500,
                  color: _PuColors.muted,
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    EdgeInsets.symmetric(horizontal: 7 * k, vertical: 2.5 * k),
                decoration: BoxDecoration(
                  color: sp.level.pillBg,
                  borderRadius: BorderRadius.circular(10 * k),
                ),
                child: Text(
                  sp.level.label,
                  style: GoogleFonts.inter(
                    fontSize: 6.5 * k,
                    fontWeight: FontWeight.w700,
                    color: sp.level.pillText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * k),
          Text(
            '${sp.name} - ISPU ${sp.value} (${sp.level.label})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11 * k,
              fontWeight: FontWeight.w700,
              color: _PuColors.ink,
            ),
          ),
          SizedBox(height: 8 * k),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110 * k,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    legend(_Level.baik.color, 'Baik'),
                    legend(_Level.tidakSehat.color, 'Tidak sehat'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  legend(_Level.sedang.color, 'Sedang'),
                  legend(_Level.sangatTidakSehat.color, 'Sangat tidak sehat'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final double k;
  const _MapPainter(this.k);

  void _road(Canvas canvas, Path path, double width,
      {Color color = Colors.white, Color outline = const Color(0xFFDAD8D0)}) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width + 2
        ..color = outline,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width
        ..color = color,
    );
  }

  void _text(Canvas canvas, String text, Offset center, double fontSize,
      Color color,
      {FontWeight weight = FontWeight.w500,
      bool italic = false,
      double rotate = 0}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: weight,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotate != 0) canvas.rotate(rotate);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEFEEE9));

    canvas.save();
    canvas.scale(k);

    final park = Paint()..color = const Color(0xFFDCE7CC);
    canvas.drawPath(
      Path()
        ..moveTo(-10, 292)
        ..lineTo(70, 280)
        ..lineTo(92, 318)
        ..lineTo(-10, 345)
        ..close(),
      park,
    );
    canvas.drawPath(
      Path()
        ..moveTo(176, 286)
        ..lineTo(270, 266)
        ..lineTo(270, 336)
        ..lineTo(196, 340)
        ..close(),
      park,
    );
    canvas.drawPath(
      Path()
        ..moveTo(214, 30)
        ..lineTo(270, 24)
        ..lineTo(270, 80)
        ..close(),
      Paint()..color = const Color(0xFFE3ECD5),
    );

    final river = Path()
      ..moveTo(-10, 150)
      ..cubicTo(50, 134, 110, 182, 170, 172)
      ..cubicTo(212, 166, 240, 178, 270, 194);
    canvas.drawPath(
      river,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFC2E2DE),
    );
    canvas.drawPath(
      river,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFB6DCD8),
    );

    for (final p in [
      [8.0, 80.0, 232.0, 92.0],
      [12.0, 124.0, 240.0, 140.0],
      [8.0, 224.0, 262.0, 238.0],
      [12.0, 262.0, 246.0, 272.0],
      [30.0, 306.0, 206.0, 318.0],
    ]) {
      _road(canvas, Path()..moveTo(p[0], p[1])..lineTo(p[2], p[3]), 5.5);
    }

    for (final p in [
      [50.0, 70.0, 44.0, 300.0],
      [84.0, 76.0, 90.0, 318.0],
      [160.0, 88.0, 168.0, 330.0],
      [198.0, 98.0, 208.0, 300.0],
      [234.0, 96.0, 248.0, 210.0],
    ]) {
      _road(canvas, Path()..moveTo(p[0], p[1])..lineTo(p[2], p[3]), 5.5);
    }

    for (final p in [
      [14.0, 176.0, 84.0, 204.0],
      [168.0, 206.0, 238.0, 226.0],
      [88.0, 156.0, 160.0, 130.0],
    ]) {
      _road(canvas, Path()..moveTo(p[0], p[1])..lineTo(p[2], p[3]), 3.5);
    }

    final main = Path()
      ..moveTo(116, 46)
      ..lineTo(124, 300)
      ..lineTo(130, 352);
    _road(canvas, main, 9.5);
    canvas.drawPath(
      main,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3
        ..color = const Color(0xFFF1E6BE),
    );

    const dark = Color(0xFF55574F);
    const grey = Color(0xFF7D807A);
    _text(canvas, 'Gedeg', const Offset(27, 79), 7, grey);
    _text(canvas, 'Magersari', const Offset(179, 118), 7, grey);
    _text(canvas, 'Sungai Brantas', const Offset(39, 189), 5.5,
        const Color(0xFF5FA8A2),
        italic: true);
    _text(canvas, 'Prajurit Kulon', const Offset(38, 216), 7.5, grey);
    _text(canvas, 'Mojokerto', const Offset(102, 215), 11, dark,
        weight: FontWeight.w500);
    _text(canvas, 'Kranggan', const Offset(157, 324), 7, grey);
    _text(canvas, 'Jl. Gajah Mada', const Offset(176, 262), 5.5, grey);
    _text(canvas, 'Jl. Veteran', const Offset(124, 147), 5.5, grey,
        rotate: -1.52);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.k != k;
}
