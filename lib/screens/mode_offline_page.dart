import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'kelola_unduhan_page.dart';

class ModeOfflinePage extends StatelessWidget {

  final VoidCallback? onPanduanTap;

  final VoidCallback? onKontakTap;

  final VoidCallback? onKelolaUnduhanTap;

  const ModeOfflinePage({
    super.key,
    this.onPanduanTap,
    this.onKontakTap,
    this.onKelolaUnduhanTap,
  });

  static const Color _green = Color(0xFF176D59);
  static const Color _greenIcon = Color(0xFF2E7B67);
  static const Color _ink = Color(0xFF0F2A24);
  static const Color _body = Color(0xFF5B6763);
  static const Color _muted = Color(0xFF8A9691);
  static const Color _chipBg = Color(0xFFDDEEE3);
  static const Color _iconBox = Color(0xFFDDEEE3);
  static const Color _cardLine = Color(0xFFD3E4DA);

  static final GlobalKey _kTitle = GlobalKey();
  static final GlobalKey _kChip = GlobalKey();
  static final GlobalKey _kAccess = GlobalKey();
  static final GlobalKey _kManage = GlobalKey();

  List<CoachStep> get _tour => [
        CoachStep(
          target: _kTitle,
          title: 'Mode Offline',
          body: 'Halaman ini muncul saat kamu tidak terhubung ke internet. TEDUH menampilkan data unduhan terakhir yang tersimpan di perangkat.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _kChip,
          title: 'Waktu data terakhir',
          body: 'Menunjukkan kapan data kualitas udara terakhir diperbarui, misalnya 2 jam lalu. Data baru muncul setelah kamu kembali online.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _kAccess,
          title: 'Tetap bisa diakses',
          body: 'Panduan kesehatan dan kontak darurat tetap bisa dibuka tanpa internet. Panggilan telepon tetap memerlukan sinyal.',
          scrollAlignment: 0.3,
        ),
        CoachStep(
          target: _kManage,
          title: 'Kelola Unduhan',
          body: 'Atur data dan panduan yang tersimpan di perangkatmu lewat tombol Kelola Unduhan.',
        ),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'offline',
        tour: _tour,
        guide: PageGuide(content: () => 'Ini halaman Mode Offline. Berisi data kualitas udara terakhir yang tersimpan, yaitu dua jam lalu, serta panduan kesehatan dan kontak darurat yang tetap bisa dibuka tanpa internet. Ada juga tombol Kelola Unduhan. Ucapkan kembali untuk ke halaman sebelumnya.'),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    final double s = MediaQuery.of(context).size.width / 282;

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
              colors: [Color(0xFFE2F1E7), Color(0xFFF0F8F2), Color(0xFFFAFCFA)],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, s),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 18 * s),
                    child: Column(
                      children: [
                        SizedBox(height: 14 * s),
                        _buildIllustration(s),
                        SizedBox(height: 14 * s),
                        KeyedSubtree(
                          key: _kTitle,
                          child: Column(
                            children: [
                              _buildTitle(s),
                              SizedBox(height: 9 * s),
                              _buildDescription(s),
                            ],
                          ),
                        ),
                        SizedBox(height: 14 * s),
                        KeyedSubtree(key: _kChip, child: _buildUpdatedChip(s)),
                        SizedBox(height: 20 * s),
                        KeyedSubtree(
                          key: _kAccess,
                          child: Column(
                            children: [
                              _buildSectionLabel(s),
                              SizedBox(height: 8 * s),
                              _buildAccessCard(
                          s,
                          icon: Icons.menu_book_outlined,
                          title: 'Panduan kesehatan',
                          subtitle: '3 panduan tersimpan · Baca offline',
                          onTap: onPanduanTap,
                        ),
                              SizedBox(height: 6 * s),
                              _buildAccessCard(
                          s,
                          icon: Icons.contact_phone_outlined,
                          title: 'Kontak darurat',
                          subtitle: '2 kontak tersimpan di perangkat',
                          onTap: onKontakTap,
                        ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14 * s),
                        _buildNote(s),
                        SizedBox(height: 18 * s),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(18 * s, 4 * s, 18 * s, 16 * s),
                  child: KeyedSubtree(key: _kManage, child: _buildManageButton(context, s)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18 * s, 10 * s, 18 * s, 4 * s),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: EdgeInsets.all(2 * s),
              child: Icon(Icons.arrow_back_rounded, size: 13 * s, color: _ink),
            ),
          ),
          SizedBox(width: 20 * s),
          Text(
            'Mode Offline',
            style: GoogleFonts.inter(
              fontSize: 9.2 * s,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaf(double s,
      {required double w,
      required double h,
      required Color color,
      required double angle,
      required double left,
      required double top}) {
    return Positioned(
      left: left * s,
      top: top * s,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: w * s,
          height: h * s,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(h * s),
              bottomRight: Radius.circular(h * s),
              topRight: Radius.circular(w * s * 0.25),
              bottomLeft: Radius.circular(w * s * 0.25),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(double s) {
    return SizedBox(
      width: 150 * s,
      height: 150 * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFCFE9D8),
                    Color(0xFFE0F0E5),
                    Color(0x00E8F4EC),
                  ],
                  stops: [0.0, 0.62, 1.0],
                ),
              ),
            ),
          ),
          _leaf(s,
              w: 16,
              h: 44,
              color: const Color(0xFFB9DAC3),
              angle: -0.55,
              left: 20,
              top: 62),
          _leaf(s,
              w: 15,
              h: 40,
              color: const Color(0xFFB9DAC3),
              angle: 0.6,
              left: 112,
              top: 66),

          _leaf(s,
              w: 15,
              h: 34,
              color: const Color(0xFF1F2B27),
              angle: -0.9,
              left: 22,
              top: 52),

          Positioned(
            left: 46 * s,
            top: 18 * s,
            child: Transform.rotate(
              angle: -0.06,
              child: Container(
                width: 58 * s,
                height: 98 * s,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11 * s),
                  border: Border.all(color: const Color(0xFFD9DEDB), width: 2.4 * s),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8 * s,
                      offset: Offset(0, 3 * s),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 5 * s,
                      child: Container(
                        width: 14 * s,
                        height: 2.4 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3E7E5),
                          borderRadius: BorderRadius.circular(2 * s),
                        ),
                      ),
                    ),
                    Icon(Icons.wifi_off_rounded,
                        size: 30 * s, color: const Color(0xFF2F6A5A)),
                  ],
                ),
              ),
            ),
          ),

          _leaf(s,
              w: 18,
              h: 46,
              color: const Color(0xFF2E7B67),
              angle: -0.42,
              left: 40,
              top: 100),
          _leaf(s,
              w: 16,
              h: 40,
              color: const Color(0xFF123F34),
              angle: 0.5,
              left: 62,
              top: 112),
          _leaf(s,
              w: 15,
              h: 38,
              color: const Color(0xFF8FC4A5),
              angle: 0.55,
              left: 98,
              top: 96),
          // Titik hiasan
          Positioned(
            right: 6 * s,
            top: 52 * s,
            child: Container(
              width: 5 * s,
              height: 5 * s,
              decoration: const BoxDecoration(
                color: Color(0xFFEFE9D6),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(double s) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 17 * s,
          fontWeight: FontWeight.w800,
          color: _ink,
        ),
        children: const [
          TextSpan(text: 'Anda Sedang '),
          TextSpan(text: 'Offline', style: TextStyle(color: _green)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * s),
      child: Text(
        'Menampilkan data unduhan terakhir (Cache). Anda tetap dapat '
        'mengakses panduan kesehatan dan kontak darurat secara lokal.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 7.9 * s,
          height: 1.55,
          color: _body,
        ),
      ),
    );
  }

  Widget _buildUpdatedChip(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 4.5 * s),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: const Color(0xFFC3DDCD), width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 8.5 * s, color: _green),
          SizedBox(width: 4 * s),
          Text(
            'Data Terakhir: 2 jam lalu',
            style: GoogleFonts.inter(
              fontSize: 6.6 * s,
              fontWeight: FontWeight.w600,
              color: _green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(double s) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'TETAP BISA DIAKSES',
        style: GoogleFonts.inter(
          fontSize: 6.4 * s,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: _green,
        ),
      ),
    );
  }

  Widget _buildAccessCard(
    double s, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 56 * s,
        padding: EdgeInsets.symmetric(horizontal: 11 * s),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(color: _cardLine, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 5 * s,
              offset: Offset(0, 1.5 * s),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 27 * s,
              height: 27 * s,
              decoration: BoxDecoration(
                color: _iconBox,
                borderRadius: BorderRadius.circular(8 * s),
              ),
              child: Icon(icon, size: 13 * s, color: _greenIcon),
            ),
            SizedBox(width: 10 * s),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 8.2 * s,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 3 * s),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 6.4 * s,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 12 * s, color: _ink),
          ],
        ),
      ),
    );
  }

  Widget _buildNote(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1 * s),
            child: Icon(Icons.info_outline_rounded, size: 7.5 * s, color: _body),
          ),
          SizedBox(width: 6 * s),
          Expanded(
            child: Text(
              'Kontak dapat dilihat offline. Panggilan tetap memerlukan '
              'jaringan seluler.',
              style: GoogleFonts.inter(
                fontSize: 6.3 * s,
                height: 1.5,
                color: _body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageButton(BuildContext context, double s) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onKelolaUnduhanTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KelolaUnduhanPage()),
              ),
      child: Container(
        height: 38 * s,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(color: _cardLine, width: 0.9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_download_outlined, size: 11 * s, color: _green),
            SizedBox(width: 6 * s),
            Text(
              'Kelola Unduhan',
              style: GoogleFonts.inter(
                fontSize: 8 * s,
                fontWeight: FontWeight.w700,
                color: _green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
