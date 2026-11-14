import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/monitoring_state.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';

class SumberPemantauanPage extends StatelessWidget {
  const SumberPemantauanPage({super.key});

  static const Color _green = Color(0xFF176D59);
  static const Color _ink = Color(0xFF0F2A24);
  static const Color _body = Color(0xFF5B6763);
  static const Color _muted = Color(0xFF8A9691);
  static const Color _pageBg = Color(0xFFF3F8F4);

  static final GlobalKey _kKlhk = GlobalKey();
  static final GlobalKey _kSatelit = GlobalKey();
  static final GlobalKey _kPerbedaan = GlobalKey();

  List<CoachStep> get _tour => [
        CoachStep(
          target: _kKlhk,
          title: 'Sumber ISPU resmi: KLHK',
          body: 'Angka ISPU di TEDUH berasal dari stasiun pemantau resmi '
              'Kementerian Lingkungan Hidup dan Kehutanan (KLHK).',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _kSatelit,
          title: 'Sentinel & Copernicus',
          body: 'Data satelit dipakai hanya untuk analisis atmosfer di AI '
              'Analysis, bukan sebagai angka ISPU resmi.',
          scrollAlignment: 0.4,
        ),
        CoachStep(
          target: _kPerbedaan,
          title: 'Mengapa bisa berbeda?',
          body: 'Stasiun KLHK mengukur di permukaan lokasi stasiun. '
              'Satelit memodelkan atmosfer secara regional. Metode, '
              'ketinggian, dan resolusi keduanya berbeda.',
          scrollAlignment: 0.7,
        ),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'sumber',
        tour: _tour,
        guide: PageGuide(
          content: () => 'Ini halaman Sumber Data ISPU. Angka ISPU di TEDUH '
              'berasal dari stasiun pemantau resmi KLHK. Data satelit '
              'Sentinel dan Copernicus digunakan hanya untuk analisis '
              'atmosfer di AI Analysis, bukan sebagai ISPU resmi. '
              'Ucapkan kembali untuk ke halaman sebelumnya.',
        ),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    final double s = MediaQuery.of(context).size.width / 285;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, s),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(19 * s, 16 * s, 19 * s, 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageTitle(s),
                      SizedBox(height: 20 * s),
                      KeyedSubtree(key: _kKlhk, child: _buildKlhkCard(s)),
                      SizedBox(height: 14 * s),
                      KeyedSubtree(key: _kSatelit, child: _buildSatelitCard(s)),
                      SizedBox(height: 14 * s),
                      _buildOsmGibsCard(s),
                      SizedBox(height: 14 * s),
                      _buildNasaFirmsCard(s),
                      SizedBox(height: 20 * s),
                      _buildAttribution(s),
                      SizedBox(height: 20 * s),
                      KeyedSubtree(key: _kPerbedaan, child: _buildMultiSourceExplanation(s)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12 * s, 12 * s, 12 * s, 0),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: EdgeInsets.all(4 * s),
              child: Icon(Icons.arrow_back_rounded, size: 13 * s, color: _ink),
            ),
          ),
          SizedBox(width: 10 * s),
          Text(
            'Sumber Data',
            style: GoogleFonts.inter(
              fontSize: 8.5 * s,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTitle(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUMBER ISPU',
          style: GoogleFonts.inter(
            fontSize: 5.6 * s,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: _green,
          ),
        ),
        SizedBox(height: 5 * s),
        Text.rich(
          TextSpan(
            style: GoogleFonts.inter(
              fontSize: 16 * s,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: const Color(0xFF123F34),
            ),
            children: const [
              TextSpan(text: 'Transparansi '),
              TextSpan(
                text: 'Sumber Data.',
                style: TextStyle(color: _green),
              ),
            ],
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          'TEDUH beroperasi dengan Free-First Data Architecture. Memadukan model '
          'atmosfer CAMS & meteorologi Open-Meteo, citra satelit NASA GIBS, peta OpenStreetMap, '
          'titik panas NASA FIRMS, dan arsip Cloud Firestore.',
          style: GoogleFonts.inter(
            fontSize: 7.5 * s,
            height: 1.55,
            color: _body,
          ),
        ),
      ],
    );
  }

  Widget _buildKlhkCard(double s) {
    return AnimatedBuilder(
      animation: MonitoringState.instance,
      builder: (ctx, child) {
        final mon = MonitoringState.instance;
        final site = mon.selectedSite;
        final region = mon.selectedRegion;
        final reading = mon.currentReading;

        return _InfoCard(
          s: s,
          icon: Icons.storage_rounded,
          iconColor: _green,
          iconBg: const Color(0xFFCFE6D8),
          badgeText: 'ARSIP & CACHE DATA',
          badgeColor: _green,
          title: 'Arsip Firestore / Stasiun',
          subtitle: 'Cloud Firestore TEDUH (Penyimpanan Snapshot & Cache)',
          children: [
            _InfoRow(s: s, label: 'Stasiun / Arsip', value: site.stationName),
            _InfoRow(s: s, label: 'Wilayah', value: region.province),
            _InfoRow(
              s: s,
              label: 'Status data',
              value: mon.isLoading
                  ? 'Memuat...'
                  : reading != null
                      ? 'Tersedia di cache'
                      : mon.errorMessage != null
                          ? 'Gagal memuat cache — fallback CAMS aktif'
                          : 'Otomatis fallback ke Open-Meteo',
            ),
            _InfoRow(
              s: s,
              label: 'Diperbarui',
              value: reading != null
                  ? _formatTimestamp(reading.observedAt)
                  : '—',
            ),
            _InfoRow(s: s, label: 'Karakteristik', value: 'Data arsip/cache lokal'),
            _InfoRow(s: s, label: 'Catatan ilmiah', value: 'Bukan koneksi streaming stasiun langsung'),
            _InfoRow(
                s: s,
                label: 'Standar baku',
                value: 'Permen LHK No. 14 Tahun 2020'),
          ],
        );
      },
    );
  }

  Widget _buildSatelitCard(double s) {
    return _InfoCard(
      s: s,
      icon: Icons.satellite_alt_outlined,
      iconColor: const Color(0xFF2E5FA3),
      iconBg: const Color(0xFFD6E4F7),
      badgeText: 'HANYA UNTUK ANALISIS AI',
      badgeColor: const Color(0xFF2E5FA3),
      title: 'Sentinel & Copernicus (CAMS)',
      subtitle: 'European Space Agency / Copernicus CAMS via Open-Meteo',
      children: [
        _InfoRow(
          s: s,
          label: 'Digunakan untuk',
          value: 'Analisis atmosfer di AI Analysis — bukan ISPU resmi',
        ),
        _InfoRow(s: s, label: 'Parameter', value: 'PM2.5, PM10, NO₂, O₃, CO (estimasi model)'),
        _InfoRow(s: s, label: 'Cakupan', value: 'Regional / nasional (~10–25 km resolusi)'),
        _InfoRow(s: s, label: 'Metode', value: 'Pemodelan atmosfer & asimilasi data satelit'),
        _InfoRow(s: s, label: 'Lisensi', value: 'CC BY 4.0 (Copernicus)'),
      ],
    );
  }

  Widget _buildOsmGibsCard(double s) {
    return _InfoCard(
      s: s,
      icon: Icons.map_outlined,
      iconColor: const Color(0xFF7C3AED),
      iconBg: const Color(0xFFEDE9FE),
      badgeText: 'PETA & CITRA SATELIT',
      badgeColor: const Color(0xFF7C3AED),
      title: 'OpenStreetMap & NASA GIBS',
      subtitle: 'OpenStreetMap Foundation & NASA EOSDIS Global Imagery',
      children: [
        _InfoRow(
          s: s,
          label: 'Digunakan untuk',
          value: 'Peta dasar wilayah, pencarian lokasi, batas administratif, dan layer citra satelit bumi',
        ),
        _InfoRow(s: s, label: 'Layanan', value: 'Tile Server OSM (WMS/WMTS) & NASA GIBS Imagery'),
        _InfoRow(s: s, label: 'Biaya & Lisensi', value: '100% Gratis & Terbuka (ODbL / Public Domain)'),
        _InfoRow(s: s, label: 'Status koneksi', value: 'Aktif · Publik Tanpa API Key'),
        _InfoRow(s: s, label: 'Endpoint', value: 'tile.openstreetmap.org & gibs.earthdata.nasa.gov'),
      ],
    );
  }

  Widget _buildNasaFirmsCard(double s) {
    return _InfoCard(
      s: s,
      icon: Icons.local_fire_department_outlined,
      iconColor: const Color(0xFFDC2626),
      iconBg: const Color(0xFFFEE2E2),
      badgeText: 'DETEKSI TITIK API (HOTSPOT)',
      badgeColor: const Color(0xFFDC2626),
      title: 'NASA FIRMS',
      subtitle: 'Fire Information for Resource Management System (VIIRS / MODIS)',
      children: [
        _InfoRow(
          s: s,
          label: 'Digunakan untuk',
          value: 'Pemantauan titik panas termal kebakaran hutan dan lahan (karhutla)',
        ),
        _InfoRow(s: s, label: 'Instrumen', value: 'Sensor VIIRS (Suomi NPP & NOAA-20) / MODIS (Aqua & Terra)'),
        _InfoRow(s: s, label: 'Resolusi deteksi', value: '375 meter (VIIRS I-Band) — radiasi panas permukaan'),
        _InfoRow(s: s, label: 'Status akses', value: 'Aktif · MAP_KEY Terkonfigurasi'),
        _InfoRow(s: s, label: 'Catatan penting', value: 'Hotspot termal menunjukkan sumber panas, bukan nilai PM2.5 atau ISPU'),
      ],
    );
  }

  Widget _buildAttribution(double s) {
    return Text(
      '© Kementerian LHK — Jaringan ISPU Nasional\n'
      '© Copernicus Atmosphere Monitoring Service (CAMS), European Union, 2024\n'
      '© Open-Meteo (CC BY 4.0)\n'
      '© OpenStreetMap contributors (ODbL)\n'
      '© NASA Earth Science Data and Information System (EOSDIS)',
      style: GoogleFonts.inter(fontSize: 5.5 * s, height: 1.6, color: _muted),
    );
  }

  String _formatTimestamp(DateTime t) {
    final bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][t.month];
    return '${t.day} $bulan ${t.year} · '
        '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')} WIB';
  }

  Widget _buildMultiSourceExplanation(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F4),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: const Color(0xFFB2D8C8), width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.layers_outlined, size: 10 * s, color: _green),
              SizedBox(width: 6 * s),
              Text(
                'Mengapa TEDUH menggunakan banyak sumber?',
                style: GoogleFonts.inter(
                  fontSize: 7.5 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF123F34),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * s),
          Text(
            'Setiap sumber data memiliki kekuatan dan cakupan yang saling melengkapi. '
            'TEDUH menggabungkannya dalam arsitektur Free-First agar pemantauan tetap akurat, '
            'menyeluruh, dan bebas dari ketergantungan API komersial berbayar:',
            style: GoogleFonts.inter(fontSize: 7 * s, height: 1.55, color: _body),
          ),
          SizedBox(height: 10 * s),
          _ExplanationBullet(
            s: s,
            icon: Icons.cloud_outlined,
            color: const Color(0xFF2E5FA3),
            label: 'Open-Meteo & Copernicus CAMS',
            desc: 'Penyedia utama polutan atmosfer (PM2.5, PM10, O₃, NO₂, CO) dan cuaca berbasis model ilmiah ECMWF. Gratis tanpa batas key.',
          ),
          SizedBox(height: 8 * s),
          _ExplanationBullet(
            s: s,
            icon: Icons.storage_rounded,
            color: _green,
            label: 'Cloud Firestore TEDUH',
            desc: 'Cache penyimpanan lokal & arsip riwayat harian agar kamu tetap bisa memantau kondisi saat offline atau jaringan lambat.',
          ),
          SizedBox(height: 8 * s),
          _ExplanationBullet(
            s: s,
            icon: Icons.map_outlined,
            color: const Color(0xFF7C3AED),
            label: 'OpenStreetMap & NASA GIBS',
            desc: 'Menampilkan visual peta batas wilayah dan citra tutupan awan satelit secara interaktif tanpa biaya lisensi Google Maps.',
          ),
          SizedBox(height: 8 * s),
          _ExplanationBullet(
            s: s,
            icon: Icons.local_fire_department_outlined,
            color: const Color(0xFFDC2626),
            label: 'NASA FIRMS',
            desc: 'Sensor inframerah satelit untuk melacak titik kebakaran hutan (karhutla) aktif di seluruh kepulauan Indonesia secara real-time.',
          ),
          SizedBox(height: 16 * s),
          Divider(height: 1, thickness: 0.8, color: const Color(0xFFB2D8C8)),
          SizedBox(height: 14 * s),
          Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 10 * s, color: const Color(0xFF8A6A00)),
              SizedBox(width: 6 * s),
              Text(
                'Mengapa angkanya bisa berbeda antar sumber?',
                style: GoogleFonts.inter(
                  fontSize: 7.5 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5A4500),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * s),
          _PerbedaanBullet(
            s: s,
            text: 'Stasiun fisik mengukur udara di permukaan tanah tepat pada titik koordinat sensor berada.',
          ),
          _PerbedaanBullet(
            s: s,
            text: 'Copernicus CAMS memodelkan volume atmosfer regional dengan kisi piksel seluas ~10–25 km².',
          ),
          _PerbedaanBullet(
            s: s,
            text: 'Metode pengukuran, elevasi sensor, serta jadwal update satelit memiliki siklus waktu yang berbeda secara teknis.',
          ),
          _PerbedaanBullet(
            s: s,
            text: 'Titik api NASA FIRMS merekam anomali suhu termal tanah, sehingga tidak bisa langsung dihitung sebagai kadar PM2.5 tanpa pemodelan dispersi asap.',
          ),
          _PerbedaanBullet(
            s: s,
            text: 'Oleh sebab itu, TEDUH menyajikan setiap data secara transparan sesuai karakternya dan tidak mencampuradukkannya menjadi satu angka rancu.',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final double s;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String badgeText;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _InfoCard({
    required this.s,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.badgeText,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(14 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30 * s,
                      height: 30 * s,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(8 * s),
                      ),
                      child: Icon(icon, size: 15 * s, color: iconColor),
                    ),
                    SizedBox(width: 10 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 8 * s,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F2A24),
                            ),
                          ),
                          SizedBox(height: 2 * s),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 6 * s,
                              color: const Color(0xFF8A9691),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * s),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20 * s),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 5.5 * s,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: const Color(0xFFE8F0EA)),
          Padding(
            padding: EdgeInsets.all(14 * s),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final double s;
  final String label;
  final String value;

  const _InfoRow({required this.s, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90 * s,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 6.5 * s,
                color: const Color(0xFF8A9691),
              ),
            ),
          ),
          SizedBox(width: 6 * s),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 6.5 * s,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F2A24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerbedaanBullet extends StatelessWidget {
  final double s;
  final String text;

  const _PerbedaanBullet({required this.s, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3 * s),
            child: Container(
              width: 4 * s,
              height: 4 * s,
              decoration: const BoxDecoration(
                color: Color(0xFF8A6A00),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 7 * s),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 7 * s,
                height: 1.5,
                color: const Color(0xFF5A4500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationBullet extends StatelessWidget {
  final double s;
  final IconData icon;
  final Color color;
  final String label;
  final String desc;

  const _ExplanationBullet({
    required this.s,
    required this.icon,
    required this.color,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20 * s,
          height: 20 * s,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6 * s),
          ),
          child: Icon(icon, size: 11 * s, color: color),
        ),
        SizedBox(width: 10 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 7.5 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF123F34),
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 7 * s,
                  height: 1.5,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
