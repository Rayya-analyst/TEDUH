import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _MC {
  static const bg = Color(0xFFF5F8F4);
  static const dark = Color(0xFF1F4D3A);
  static const darkText = Color(0xFF1F3D2F);
  static const greenTitle = Color(0xFF17664C);
  static const green = Color(0xFF0F7B4F);
  static const button = Color(0xFF1B6B58);
  static const red = Color(0xFFE5384B);
  static const grey = Color(0xFF8A9A91);
  static const greyLight = Color(0xFF9AA59F);
  static const softLeaf = Color(0xFFE2EFDF);
  static const hint = Color(0xFF7C8B82);
  static const sheetDark = Color(0xFF1F2D26);
}

const List<String> _districts = [
  'Jekan Raya',
  'Pahandut',
  'Bukit Batu',
  'Sabangau',
  'Rakumpit',
];

class _AqData {
  final int ispu;
  final List<double> tinggi;
  final List<Color> warna;
  const _AqData(this.ispu, this.tinggi, this.warna);
}

const List<Color> _palet = [
  Color(0xFFB9D8B7),
  Color(0xFFE8CC6C),
  Color(0xFFE8A57A),
  Color(0xFFC98B87),
  Color(0xFFE9454B),
];

Color _warnaSkala(double t) {
  final x = t.clamp(0.0, 1.0) * (_palet.length - 1);
  final i = x.floor().clamp(0, _palet.length - 2);
  return Color.lerp(_palet[i], _palet[i + 1], x - i)!;
}

const _AqData _designAq = _AqData(
  211,
  [13.4, 18.3, 14.7, 23.7, 17.6, 21.1, 26.2, 19.5, 24.3, 20.8, 26.2, 29.4],
  [
    Color(0xFFB9D8B7),
    Color(0xFFB5D6B3),
    Color(0xFFE8CF73),
    Color(0xFFE8CC6C),
    Color(0xFFE8A27D),
    Color(0xFFE7A272),
    Color(0xFFC98B87),
    Color(0xFFC98B87),
    Color(0xFFE9454B),
    Color(0xFFE9454B),
    Color(0xFFE94046),
    Color(0xFFE83B42),
  ],
);

_AqData _aqFor(String district) {
  if (district == 'Jekan Raya') return _designAq;
  final rnd = math.Random(district.hashCode);
  final ispu = 101 + rnd.nextInt(200); 
  final values = List<double>.generate(11, (_) => 40 + rnd.nextInt(260) * 1.0)
    ..add(ispu.toDouble());
  return _AqData(
    ispu,
    [for (final v in values) 13 + 16.4 * ((v - 40) / 260).clamp(0.0, 1.0)],
    [for (final v in values) _warnaSkala((v - 40) / 260)],
  );
}

class MapPage extends StatefulWidget {
  final String wilayah;

  const MapPage({super.key, this.wilayah = 'Kalimantan Tengah'});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late final AnimationController _anim; 
  late final AnimationController _chart;

  String _district = 'Jekan Raya';
  bool _picked = false; 
  late _AqData _aq = _aqFor(_district);

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
                      color: d == _district ? _MC.green : _MC.hint),
                  title: Text(
                    '$d, Palangka Raya',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          d == _district ? FontWeight.w600 : FontWeight.w400,
                      color: _MC.sheetDark,
                    ),
                  ),
                  trailing: d == _district
                      ? const Icon(Icons.check_rounded, color: _MC.green)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (d != _district) {
                      setState(() {
                        _district = d;
                        _picked = true;
                        _aq = _aqFor(d);
                      });
                      _chart.forward(from: 0);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'map',
        tour: const [
          CoachStep(title: 'Wilayah dan lokasi', body: 'Bagian atas menunjukkan wilayahmu. Ketuk Ubah Wilayah untuk memilih kecamatan atau area lain.'),
          CoachStep(title: 'Peta kualitas udara', body: 'Peta menampilkan titik-titik pemantauan dan jalan di sekitarmu. Ketuk bidang pencarian untuk mencari lokasi atau area.'),
          CoachStep(title: 'Kartu kualitas udara', body: 'Kartu ini menunjukkan status udara, nilai ISPU, sumber data, dan waktu pembaruan terakhir untuk lokasi yang dipilih.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Lokasi Saya. Ada wilayah yang aktif dengan tombol Ubah Wilayah, peta titik pemantauan dengan pencarian lokasi, dan kartu kualitas udara berisi status, ISPU, sumber, serta waktu pembaruan.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: _MC.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SoftLeavesPainter(_anim)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _Reveal(
                  animation: _anim,
                  begin: 0.0,
                  end: 0.4,
                  child: _buildAppBar(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Reveal(
                          animation: _anim,
                          begin: 0.1,
                          end: 0.5,
                          child: _buildLokasiHeader(),
                        ),
                        const SizedBox(height: 16),
                        _Reveal(
                          animation: _anim,
                          begin: 0.2,
                          end: 0.65,
                          child: _MapCard(lokasi: '$_district, Kota Palangka Raya'),
                        ),
                        const SizedBox(height: 18),
                        _Reveal(
                          animation: _anim,
                          begin: 0.35,
                          end: 0.8,
                          child: _AirQualityCard(data: _aq, anim: _chart),
                        ),
                        const SizedBox(height: 24),
                        _Reveal(
                          animation: _anim,
                          begin: 0.5,
                          end: 0.9,
                          child: _buildWarning(),
                        ),
                      ],
                    ),
                  ),
                ),
                _Reveal(
                  animation: _anim,
                  begin: 0.6,
                  end: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 24, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _pickDistrict,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _MC.button,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Ubah Wilayah',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 48),
            icon: const Icon(Icons.arrow_back, color: _MC.dark, size: 22),
          ),
          const SizedBox(width: 7),
          Text(
            'Peta',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _MC.dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLokasiHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickDistrict,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LOKASI SAAT INI',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: _MC.grey,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _picked ? '$_district, Palangka Raya' : widget.wilayah,
                        key: ValueKey(_picked ? _district : widget.wilayah),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _MC.greenTitle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down,
                      color: _MC.greenTitle, size: 17),
                ],
              ),
            ],
          ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFCCD0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: _MC.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Terkini',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: _MC.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarning() {
    return Padding(
      padding: const EdgeInsets.only(left: 9),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 228),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Waspada kabut asap karhutla!',
              style: GoogleFonts.poppins(
                color: _MC.red,
                fontWeight: FontWeight.w700,
                fontSize: 10.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hindari aktivitas di luar ruangan dan gunakan masker jika '
              'harus bepergian.',
              style: GoogleFonts.poppins(
                color: const Color(0xFF55635B),
                fontSize: 9.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatefulWidget {
  final String lokasi;
  const _MapCard({required this.lokasi});

  @override
  State<_MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<_MapCard>
    with SingleTickerProviderStateMixin {
  static const List<double> _zooms = [0.8, 1.0, 1.35, 1.8, 2.4];
  static const List<String> _skala = ['300 m', '200 m', '150 m', '100 m', '50 m'];
  static const int _defaultLevel = 1;

  late final AnimationController _pulse; 
  int _level = _defaultLevel;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _zoomIn() {
    if (_level < _zooms.length - 1) setState(() => _level++);
  }

  void _zoomOut() {
    if (_level > 0) setState(() => _level--);
  }

  void _reset() {
    if (_level != _defaultLevel) setState(() => _level = _defaultLevel);
  }

  Widget _street(double w, double h, double cx, double cy, double z,
      String text, double u, double v,
      {bool small = true}) {
    final size = small ? 6.5 : 8.5;
    final left = cx + (u * w - cx) * z;
    final top = cy + (v * h - cy) * z - size * 0.75;
    if (left > w - 14 || left < -90 || top < 0 || top > h - 8) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: left,
      top: top,
      child: Text(
        text,
        softWrap: false,
        style: GoogleFonts.poppins(
          fontSize: size,
          fontWeight: small ? FontWeight.w400 : FontWeight.w500,
          color: small ? const Color(0xFF3FA36A) : const Color(0xFF6B8576),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1020 / 893,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            final cx = w * 0.504;
            final cy = h * 0.570;
            final r = w * 0.1625;

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _zooms[_level]),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              builder: (context, z, _) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ColoredBox(
                        color: const Color(0xFFEEF2EA),
                        child: Transform.scale(
                          scale: z,
                          alignment: Alignment(
                            cx / w * 2 - 1,
                            cy / h * 2 - 1,
                          ),
                          child: CustomPaint(painter: _MapPainter()),
                        ),
                      ),
                    ),

                    _street(w, h, cx, cy, z, 'Jl. Temanggung Tilung', 0.4706,
                        0.319,
                        small: false),
                    _street(w, h, cx, cy, z, 'Jl. Yos Sudarso', 0.036, 0.530),
                    _street(w, h, cx, cy, z, 'Jl. G. Obos', 0.600, 0.644),
                    _street(w, h, cx, cy, z, 'Jl. Garuda', 0.434, 0.838),
                    _street(w, h, cx, cy, z, 'Jl. Tjilik Riwut', 0.694, 0.913),

                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, _) {
                            final v = Curves.easeInOut.transform(_pulse.value);
                            final rr = r * z * (0.86 + 0.28 * v);
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: cx - rr,
                                  top: cy - rr,
                                  width: rr * 2,
                                  height: rr * 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE8434F)
                                          .withValues(alpha: 0.22 - 0.08 * v),
                                      border: Border.all(
                                        color: const Color(0xFFE8434F)
                                            .withValues(
                                                alpha: 0.36 - 0.12 * v),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    Positioned(
                      left: cx - 21,
                      top: cy + 1.3 - 21,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              const Color(0xFF6F8F7B).withValues(alpha: 0.20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: cx - 10,
                      top: cy - 4,
                      child: Container(
                        width: 20,
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF4F6B5B).withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    Positioned(
                      left: cx - 16,
                      top: cy - 42.5,
                      width: 32,
                      height: 44,
                      child: CustomPaint(painter: _PinPainter()),
                    ),

                    Positioned(
                      left: w * 0.523,
                      top: h * 0.675,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              widget.lokasi,
                              key: ValueKey(widget.lokasi),
                              style: GoogleFonts.poppins(
                                color: _MC.red,
                                fontSize: 9,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 17, color: Color(0xFF2E8B5E)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cari lokasi atau area',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF8A958F),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 18,
                          color: const Color(0xFFE6EAE7),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.layers_outlined,
                            size: 19, color: Color(0xFF1B5E49)),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),

                    Positioned(
                      right: 12,
                      bottom: 10.5,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MapCtrl(
                            height: 73.6,
                            child: Column(
                              children: [
                                Expanded(
                                  child: _MapIconTap(
                                    icon: Icons.add,
                                    color: _level < _zooms.length - 1
                                        ? _MC.dark
                                        : const Color(0xFFC3CCC6),
                                    onTap: _level < _zooms.length - 1
                                        ? _zoomIn
                                        : null,
                                  ),
                                ),
                                Container(
                                  width: 17.6,
                                  height: 1,
                                  color: const Color(0xFFE6EBE7),
                                ),
                                Expanded(
                                  child: _MapIconTap(
                                    icon: Icons.remove,
                                    color: _level > 0
                                        ? _MC.dark
                                        : const Color(0xFFC3CCC6),
                                    onTap: _level > 0 ? _zoomOut : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6.4),
                          _MapCtrl(
                            height: 34,
                            child: _MapIconTap(
                              icon: Icons.my_location,
                              color: const Color(0xFF1B7A55),
                              onTap: _reset,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      left: 13.4,
                      bottom: 19,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(26.6, 5),
                            painter: _ScalePainter(),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _skala[_level],
                              key: ValueKey(_level),
                              style: GoogleFonts.poppins(
                                fontSize: 7.5,
                                color: const Color(0xFF8E9A93),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MapCtrl extends StatelessWidget {
  final double height;
  final Widget child;
  const _MapCtrl({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _MapIconTap extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MapIconTap({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(child: Icon(icon, size: 18, color: color)),
      ),
    );
  }
}

class _ScalePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF8E9A93)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    canvas.drawLine(Offset(0, y - 2), Offset(0, y + 2), p);
    canvas.drawLine(Offset(size.width, y - 2), Offset(size.width, y + 2), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cx = 16.0;
    const cy = 16.5;
    const r = 13.5;
    const tipY = 42.5;

    final circle = Path()
      ..addOval(Rect.fromCircle(center: const Offset(cx, cy), radius: r));
    final tail = Path()
      ..moveTo(cx - r * 0.88, cy + r * 0.48)
      ..quadraticBezierTo(cx - r * 0.45, cy + r * 1.45, cx, tipY)
      ..quadraticBezierTo(
          cx + r * 0.45, cy + r * 1.45, cx + r * 0.88, cy + r * 0.48)
      ..close();
    final pin = Path.combine(PathOperation.union, circle, tail);

    canvas.drawPath(
      pin,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.4
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
    canvas.drawPath(
      pin,
      Paint()
        ..color = const Color(0xFFE8434B)
        ..isAntiAlias = true,
    );
    canvas.drawCircle(
      const Offset(cx, cy),
      6.6,
      Paint()
        ..color = Colors.white
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Offset p(double x, double y) =>
        Offset((x - 20) / 1020 * w, (y - 35) / 893 * h);
    double s(double px) => px / 1020 * w;
    Rect rect(double l, double t, double r, double b) =>
        Rect.fromPoints(p(l, t), p(r, b));
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEEF2EA),
    );

    final block = Paint()..color = const Color(0xFFDDE6D8);
    const blocks = <List<double>>[
      [20, 255, 205, 395],
      [20, 455, 175, 625],
      [20, 690, 150, 790],
      [20, 845, 130, 940],
      [245, 272, 448, 388],
      [215, 442, 420, 598],
      [205, 655, 398, 780],
      [770, 275, 940, 430],
      [760, 475, 925, 625],
      [700, 690, 900, 805],
      [985, 285, 1050, 450],
      [985, 510, 1050, 625],
      [320, 35, 500, 70],
      [410, 880, 630, 940],
      [150, 880, 380, 940],
      [690, 840, 1050, 940],
    ];
    for (final b in blocks) {
      canvas.drawRect(rect(b[0], b[1], b[2], b[3]), block);
    }

    final park = Paint()..color = const Color(0xFFD4E3CD);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect(512, 238, 720, 420),
        topLeft: Radius.circular(s(30)),
        topRight: Radius.circular(s(30)),
      ),
      park,
    );
    canvas.drawRect(rect(800, 35, 1050, 195), park);

    Paint river(double width) => Paint()
      ..color = const Color(0xFFD0E6E3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s(width);

    canvas.drawPath(
      Path()
        ..moveTo(p(500, 75).dx, p(500, 75).dy)
        ..cubicTo(p(560, 40).dx, p(560, 40).dy, p(620, 30).dx, p(620, 30).dy,
            p(690, 30).dx, p(690, 30).dy),
      river(32),
    );
    canvas.drawPath(
      Path()
        ..moveTo(p(690, 190).dx, p(690, 190).dy)
        ..cubicTo(p(830, 195).dx, p(830, 195).dy, p(990, 235).dx,
            p(990, 235).dy, p(1050, 300).dx, p(1050, 300).dy),
      river(40),
    );
    canvas.drawPath(
      Path()
        ..moveTo(p(1050, 350).dx, p(1050, 350).dy)
        ..cubicTo(p(990, 390).dx, p(990, 390).dy, p(880, 395).dx,
            p(880, 395).dy, p(760, 385).dx, p(760, 385).dy),
      river(34),
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(490, 492), width: s(440), height: s(84)),
      river(32),
    );
    canvas.drawPath(
      Path()
        ..moveTo(p(300, 750).dx, p(300, 750).dy)
        ..cubicTo(p(420, 735).dx, p(420, 735).dy, p(560, 710).dx,
            p(560, 710).dy, p(700, 672).dx, p(700, 672).dy),
      river(30),
    );
    canvas.drawPath(
      Path()
        ..moveTo(p(20, 830).dx, p(20, 830).dy)
        ..cubicTo(p(90, 845).dx, p(90, 845).dy, p(140, 880).dx,
            p(140, 880).dy, p(170, 940).dx, p(170, 940).dy),
      river(34),
    );

    Paint road(double width) => Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = s(width);

    Path poly(List<List<double>> pts) {
      final path = Path()..moveTo(p(pts[0][0], pts[0][1]).dx, p(pts[0][0], pts[0][1]).dy);
      for (int i = 1; i < pts.length; i++) {
        final o = p(pts[i][0], pts[i][1]);
        path.lineTo(o.dx, o.dy);
      }
      return path;
    }

    final main = road(18);
    canvas.drawPath(poly([[250, 262], [752, 268]]), main);
    canvas.drawPath(poly([[752, 268], [712, 440], [692, 825]]), main);
    canvas.drawPath(poly([[250, 262], [172, 812]]), main);
    canvas.drawPath(poly([[172, 812], [692, 828]]), main);

    final inner = road(15);
    canvas.drawPath(poly([[238, 410], [715, 432]]), inner);
    canvas.drawPath(poly([[197, 612], [700, 622]]), inner);
    canvas.drawPath(
        poly([[470, 262], [440, 412], [418, 614], [402, 826]]), inner);

    final highway = Path()
      ..moveTo(p(1048, 40).dx, p(1048, 40).dy)
      ..cubicTo(p(960, 175).dx, p(960, 175).dy, p(800, 365).dx,
          p(800, 365).dy, p(640, 545).dx, p(640, 545).dy)
      ..cubicTo(p(520, 675).dx, p(520, 675).dy, p(330, 755).dx,
          p(330, 755).dy, p(20, 930).dx, p(20, 930).dy);
    canvas.drawPath(
      highway,
      Paint()
        ..color = const Color(0xFFE3D5AB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s(44),
    );
    canvas.drawPath(
      highway,
      Paint()
        ..color = const Color(0xFFF7EFCF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s(31),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AirQualityCard extends StatelessWidget {
  final _AqData data;
  final Animation<double> anim;

  const _AirQualityCard({required this.data, required this.anim});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5384B), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Kualitas Udara: ',
                        style: TextStyle(color: _MC.greenTitle),
                      ),
                      TextSpan(
                        text: 'Tidak Sehat',
                        style: TextStyle(color: _MC.red),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.info_outline,
                  size: 16, color: Color(0xFF7A8481)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE9444F), Color(0xFFF1949A)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ISPU',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: anim,
                      builder: (context, _) {
                        final p = Curves.easeOutCubic.transform(anim.value);
                        return Text(
                          '${(data.ispu * p).round()}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Udara berasap',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _MC.darkText,
                            ),
                          ),
                        ),
                        Text(
                          '6 jam terakhir',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _MC.greyLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 30,
                      child: AnimatedBuilder(
                        animation: anim,
                        builder: (context, _) {
                          final n = data.tinggi.length;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (int i = 0; i < n; i++) ...[
                                if (i != 0) const SizedBox(width: 4.8),
                                Expanded(
                                  child: Builder(builder: (context) {
                                    final start = (i / n) * 0.5;
                                    final t = Interval(start, start + 0.5,
                                            curve: Curves.easeOutCubic)
                                        .transform(anim.value);
                                    return Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: data.tinggi[i] * t,
                                        decoration: BoxDecoration(
                                          color: data.warna[i],
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(2),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '04.00',
                          style: GoogleFonts.poppins(
                            fontSize: 8.5,
                            color: const Color(0xFFA3ADA7),
                          ),
                        ),
                        Text(
                          'Sekarang',
                          style: GoogleFonts.poppins(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B7A55),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),

          Row(
            children: const [
              _SkalaSegmen(Color(0xFF1F7F52)),
              SizedBox(width: 3.85),
              _SkalaSegmen(Color(0xFFE8CB6C)),
              SizedBox(width: 3.85),
              _SkalaSegmen(Color(0xFFE8A57A)),
              SizedBox(width: 3.85),
              _SkalaSegmen(Color(0xFFC98884)),
              SizedBox(width: 3.85),
              _SkalaSegmen(Color(0xFFEE3A3F)),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Baik · 0–50',
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: _MC.greenTitle,
                ),
              ),
              Text(
                'Berbahaya',
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  color: _MC.greyLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9.5),

          Row(
            children: [
              const Icon(Icons.sync, size: 13, color: Color(0xFF7F8B85)),
              const SizedBox(width: 5),
              Text(
                'Diperbarui 2 menit lalu',
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  color: const Color(0xFF8A958F),
                ),
              ),
              const Spacer(),
              Text(
                'Sumber: KLHK',
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  color: const Color(0xFF8A958F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkalaSegmen extends StatelessWidget {
  final Color color;
  const _SkalaSegmen(this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
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

class _SoftLeavesPainter extends CustomPainter {
  final Animation<double> anim;
  _SoftLeavesPainter(this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Curves.easeOut.transform(anim.value.clamp(0.0, 1.0));

    _leaf(canvas, Offset(w * 1.04, -h * 0.02), w * 0.62, w * 0.22,
        215 * math.pi / 180, _MC.softLeaf.withValues(alpha: 0.9 * p));
    _leaf(canvas, Offset(w * 0.98, -h * 0.01), w * 0.40, w * 0.14,
        195 * math.pi / 180, _MC.softLeaf.withValues(alpha: 0.6 * p));
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
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SoftLeavesPainter old) => false;
}
