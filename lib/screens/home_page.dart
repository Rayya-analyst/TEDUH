import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detail_artikel_page.dart';
import 'mode_offline_page.dart';
import 'peringatan_udara.dart';
import 'map_page.dart';
import 'sumber_pemantauan_page.dart';
import 'air_quality_history_page.dart';
import '../state/app_settings.dart';
import '../widgets/teduh_drawer.dart';
import '../widgets/teduh_header.dart';
import '../widgets/voice_scope.dart';

class _HomeColors {
  static const green = Color(0xFF176D59);
  static const red = Color(0xFFE5383B);

  static const ink = Color(0xFF0F2A24);
  static const brandGreen = Color(0xFF18705A);
  static const accent = Color(0xFF2E7B67);
  static const iconGreen = Color(0xFF3A8A72);
  static const section = Color(0xFF1F4A3F);
  static const subtle = Color(0xFF9AA7A2);
  static const alert = Color(0xFFE5484D);
  static const cardTitle = Color(0xFF1E7360);
  static const cardBg = Color(0xFFFFE2E2);
  static const cardLine = Color(0xFFEA5E5E);
  static const stepBg = Color(0xFFFFF0F0);
  static const body = Color(0xFF3D4A46);
  static const statValue = Color(0xFF26352F);
  static const divider = Color(0xFFDCDDDA);
  static const quickFill = Color(0xFFDFEDE3);
  static const quickLine = Color(0xFF5E9A85);
  static const pageTop = Color(0xFFDDEEE2);
  static const pageMid = Color(0xFFEEF6F0);
  static const pageBottom = Color(0xFFF7FAF7);
}

class HomePage extends StatelessWidget {
  final String userName;
  final String subtitle;
  final String location;
  final String dateText;
  final String airStatus;
  final String ispuValue;
  final String ispuLabel;
  final String airDescription;
  final String pm25;
  final String temperature;
  final String humidity;
  final String sourceText;
  final String drawerMemberLabel;


  final int? alertIspu;
  final String alertRegion;

  final bool showDailyNotification;
  final int dailyNotificationIspu;

  final VoidCallback? onMenuTap;
  final ValueChanged<HomeMenuItem>? onDrawerItemTap;

  final VoidCallback? onLogoutTap;

  final VoidCallback? onNotificationTap;
  final VoidCallback? onLocationTap;

  final VoidCallback? onPetaUdaraTap;
  final VoidCallback? onRiwayatTap;

  final VoidCallback? onModeOfflineTap;

  final VoidCallback? onSumberPemantauanTap;
  final VoidCallback? onHealthStepTap;
  final VoidCallback? onLihatSemuaTap;
  final VoidCallback? onArticleTap;

  const HomePage({
    super.key,
    this.userName = 'Arsinka',
    this.subtitle = 'Panduan perlindungan',
    this.location = 'Jekan Raya, Palangka Raya',
    this.dateText = '3 Nov 2026, 12.00',
    this.airStatus = 'Berbahaya',
    this.ispuValue = '275,2',
    this.ispuLabel = '462 ISPU',
    this.airDescription = 'Partikel halus akibat kabut asap',
    this.pm25 = '275,2 µg/m³',
    this.temperature = '27°C',
    this.humidity = '80%',
    this.sourceText = 'Sumber: BMKG dan KLH • 3 November 2026',
    this.drawerMemberLabel = 'Premium Member',
    this.alertIspu = 168,
    this.alertRegion = 'Kalimantan Tengah',
    this.showDailyNotification = true,
    this.dailyNotificationIspu = 211,
    this.onMenuTap,
    this.onDrawerItemTap,
    this.onLogoutTap,
    this.onNotificationTap,
    this.onLocationTap,
    this.onPetaUdaraTap,
    this.onRiwayatTap,
    this.onModeOfflineTap,
    this.onSumberPemantauanTap,
    this.onHealthStepTap,
    this.onLihatSemuaTap,
    this.onArticleTap,
  });

  static final GlobalKey _kHeader = GlobalKey();
  static final GlobalKey _kLocation = GlobalKey();
  static final GlobalKey _kAir = GlobalKey();
  static final GlobalKey _kQuick = GlobalKey();
  static final GlobalKey _kHealth = GlobalKey();
  static final GlobalKey _kArticle = GlobalKey();

  static List<CoachStep> get _tour => [
        CoachStep(
          target: _kHeader,
          title: 'Menu dan notifikasi',
          body: 'Ikon tiga garis membuka menu ke semua fitur. Ikon lonceng '
              'membuka riwayat notifikasi dan peringatan udara.',
          radius: 22,
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _kLocation,
          title: 'Lokasimu',
          body: 'Wilayah yang dipantau ditampilkan di sini. Ketuk untuk '
              'mengganti lokasi.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _kAir,
          title: 'Kondisi udara saat ini',
          body: 'Lihat angka ISPU, PM2.5, suhu, dan kelembapan. Tulisan dan '
              'ikon menjelaskan tingkat bahayanya, bukan hanya warna.',
          radius: 26,
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _kQuick,
          title: 'Menu cepat',
          body: 'Buka Peta Udara, Riwayat kualitas udara, Mode Offline, dan '
              'Sumber Pemantauan. Pilih sumber data, dan angka di beranda '
              'langsung ikut berubah.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _kHealth,
          title: 'Langkah kesehatan',
          body: 'Saran tindakan yang sesuai kondisi udara saat ini. Ketuk '
              'untuk membaca panduan lengkapnya.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _kArticle,
          title: 'Artikel pilihan',
          body: 'Bacaan singkat tentang udara bersih dan kesehatan '
              'pernapasan. Ketuk Lihat Semua untuk artikel lainnya.',
          scrollAlignment: 0.3,
        ),
      ];

  String _narration() {
    final pm = pm25.replaceAll('µg/m³', 'mikrogram per meter kubik');
    final src = sourceText.replaceAll('•', ',');
    return 'Ini seluruh isi TEDUH NOW. Di bagian atas ada ikon menu dan ikon '
        'lonceng untuk notifikasi. Wilayah yang dipantau adalah $location, '
        'data $dateText. '
        'Kondisi udara saat ini $airStatus. Angka ISPU $ispuLabel. '
        '$airDescription. PM2.5 $pm, suhu $temperature, dan kelembapan '
        '$humidity. $src. '
        'Di bawahnya ada empat menu cepat: Peta Udara, Riwayat, Mode Offline, '
        'dan Sumber Pemantauan. Kamu bisa berkata buka Peta Udara, buka '
        'Riwayat, buka Mode Offline, atau buka Sumber Pemantauan. '
        'Langkah sehat hari ini: Hindari paparan kabut asap. Hindari '
        'aktivitas luar ruangan, tutup jendela, dan pantau perkembangan kabut '
        'asap. '
        'Di bagian bawah ada artikel pilihan: Kenali bahaya PM2.5, lindungi '
        'pernapasanmu, bacaan sekitar tiga menit. ';
  }

  PageGuide get _guide => PageGuide(
        content: _narration,
        nextScreen: 'action',
        nextLabel: 'TEDUH ACTION',
        nextHint: 'berisi rekomendasi aktivitas dan langkah perlindungan yang '
            'menyesuaikan kondisi udara.',
      );

  HomePage _withSource(AirSnapshot a) {
    final bool custom = a.source != MonitoringSource.klhk;
    return HomePage(
      userName: userName,
      subtitle: subtitle,
      location: location,
      dateText: dateText,
      airStatus: airStatus,
      ispuValue: custom ? a.ispuValue : ispuValue,
      ispuLabel: custom ? a.ispuLabel : ispuLabel,
      airDescription: airDescription,
      pm25: custom ? a.pm25 : pm25,
      temperature: temperature,
      humidity: humidity,
      sourceText: custom ? a.sourceText : sourceText,
      drawerMemberLabel: drawerMemberLabel,
      alertIspu: alertIspu,
      alertRegion: alertRegion,
      showDailyNotification: showDailyNotification,
      dailyNotificationIspu: dailyNotificationIspu,
      onMenuTap: onMenuTap,
      onDrawerItemTap: onDrawerItemTap,
      onLogoutTap: onLogoutTap,
      onNotificationTap: onNotificationTap,
      onLocationTap: onLocationTap,
      onPetaUdaraTap: onPetaUdaraTap,
      onRiwayatTap: onRiwayatTap,
      onModeOfflineTap: onModeOfflineTap,
      onSumberPemantauanTap: onSumberPemantauanTap,
      onHealthStepTap: onHealthStepTap,
      onLihatSemuaTap: onLihatSemuaTap,
      onArticleTap: onArticleTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final view = _withSource(AppSettings.instance.snapshot);
        return VoiceScope(
          screen: 'now',
          tour: _tour,
          guide: view._guide,
          child: view._buildView(context),
        );
      },
    );
  }

  Widget _buildView(BuildContext context) {
    final media = MediaQuery.of(context);
    final s = media.size.width / 297;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _HomeColors.pageBottom,
        drawerScrimColor: const Color(0x6B1A2622),
        drawer: TeduhDrawer(
          current: HomeMenuItem.now,
          memberLabel: drawerMemberLabel,
          onItemTap: onDrawerItemTap,
          onLogoutTap: onLogoutTap,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _HomeColors.pageTop,
                    _HomeColors.pageMid,
                    _HomeColors.pageBottom,
                  ],
                  stops: [0.0, 0.32, 0.55],
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Stack(
                children: [

                  Positioned(
                    top: media.padding.top + 22 * s,
                    right: 0,
                    width: 85 * s,
                    height: 100 * s,
                    child: const CustomPaint(painter: _TopLeafPainter()),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: media.padding.top + 14),
                      _FadeInUp(
                        delayMs: 0,
                        dy: 24 * s,
                        child: KeyedSubtree(key: HomePage._kHeader, child: _buildTopBar(context, s)),
                      ),
                      SizedBox(height: 25.5 * s),
                      _FadeInUp(
                        delayMs: 100,
                        dy: 24 * s,
                        child: KeyedSubtree(key: HomePage._kLocation, child: _buildLocationRow(s)),
                      ),
                      SizedBox(height: 13 * s),
                      _FadeInUp(
                        delayMs: 200,
                        dy: 24 * s,
                        child: KeyedSubtree(key: HomePage._kAir, child: _buildAirCard(s)),
                      ),
                      SizedBox(height: 15.8 * s),
                      _FadeInUp(
                        delayMs: 300,
                        dy: 24 * s,
                        child: Padding(
                          padding: EdgeInsets.only(left: 17.5 * s),
                          child: Text(
                            'Jaga diri & lingkungan',
                            style: GoogleFonts.inter(
                              fontSize: 12.4 * s,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: _HomeColors.section,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * s),
                      KeyedSubtree(
                          key: HomePage._kQuick,
                          child: _buildQuickMenu(context, s)),
                      SizedBox(height: 14.5 * s),
                      _FadeInUp(
                        delayMs: 600,
                        dy: 24 * s,
                        child: KeyedSubtree(key: HomePage._kHealth, child: _buildHealthStepCard(s)),
                      ),
                      SizedBox(height: 19.3 * s),
                      _FadeInUp(
                        delayMs: 700,
                        dy: 24 * s,
                        child: _buildRecommendationHeader(s),
                      ),
                      SizedBox(height: 8.3 * s),
                      _FadeInUp(
                        delayMs: 800,
                        dy: 24 * s,
                        child: KeyedSubtree(key: HomePage._kArticle, child: _buildArticle(context, s)),
                      ),
                      SizedBox(height: 40 * s + media.padding.bottom),
                    ],
                  ),
                ],
              ),
            ),
            AirAlertLayer(
              alertIspu: alertIspu,
              alertRegion: alertRegion,
              showDailyNotification: showDailyNotification,
              dailyIspu: dailyNotificationIspu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Builder(
        builder: (ctx) => TeduhHeader(
          accent: 'NOW',
          subtitle: '$subtitle · $userName',
          onMenu: onMenuTap ?? () => Scaffold.of(ctx).openDrawer(),
          onNotification: onNotificationTap,
        ),
      ),
    );
  }

  Widget _buildLocationRow(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 17.5 * s, right: 23 * s),
      child: SizedBox(
        height: 14 * s,
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLocationTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 11 * s, color: _HomeColors.iconGreen),
                      SizedBox(width: 4.5 * s),
                      Flexible(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 8.8 * s,
                            fontWeight: FontWeight.w700,
                            color: _HomeColors.section,
                          ),
                        ),
                      ),
                      SizedBox(width: 5 * s),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 10 * s, color: _HomeColors.iconGreen),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              dateText,
              style: GoogleFonts.inter(
                fontSize: 7.3 * s,
                fontWeight: FontWeight.w700,
                color: _HomeColors.alert,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirCard(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 17.5 * s, right: 22.25 * s),
      child: Container(
        decoration: BoxDecoration(
          color: _HomeColors.cardBg,
          borderRadius: BorderRadius.circular(15 * s),
          border: Border.all(color: _HomeColors.cardLine, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _HomeColors.alert.withValues(alpha: 0.10),
              blurRadius: 12 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.25 * s, 14.7 * s, 14.25 * s, 12.1 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Kualitas Udara: ',
                      style: GoogleFonts.inter(
                        fontSize: 13.8 * s,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: _HomeColors.cardTitle,
                      ),
                      children: [
                        TextSpan(
                          text: airStatus,
                          style: const TextStyle(color: _HomeColors.alert),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 11 * s),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        ispuValue,
                        style: GoogleFonts.inter(
                          fontSize: 35 * s,
                          height: 1.0,
                          letterSpacing: -1.6,
                          fontWeight: FontWeight.w800,
                          color: _HomeColors.alert,
                        ),
                      ),
                      SizedBox(width: 7 * s),
                      Text(
                        ispuLabel,
                        style: GoogleFonts.inter(
                          fontSize: 7.6 * s,
                          fontWeight: FontWeight.w700,
                          color: _HomeColors.alert,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 9.5 * s),
                  Text(
                    airDescription,
                    style: GoogleFonts.inter(
                      fontSize: 8.1 * s,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      color: _HomeColors.body,
                    ),
                  ),
                  SizedBox(height: 9.5 * s),
                  Container(height: 1, color: _HomeColors.divider),
                  SizedBox(height: 8.9 * s),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 78.75 * s, child: _stat(s, 'PM2.5', pm25)),
                      SizedBox(
                          width: 79.25 * s, child: _stat(s, 'Suhu', temperature)),
                      Expanded(child: _stat(s, 'Kelembapan', humidity)),
                    ],
                  ),
                  SizedBox(height: 8.9 * s),
                  Text(
                    sourceText,
                    style: GoogleFonts.inter(
                      fontSize: 6.6 * s,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      color: _HomeColors.subtle,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 1 * s,
              top: 25 * s,
              width: 67 * s,
              height: 82 * s,
              child: CustomPaint(painter: _MaskedManPainter()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(double s, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 7.2 * s,
            height: 1.2,
            fontWeight: FontWeight.w400,
            color: _HomeColors.subtle,
          ),
        ),
        SizedBox(height: 3.4 * s),
        Text(
          value,
          maxLines: 1,
          style: GoogleFonts.inter(
            fontSize: 9.3 * s,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: _HomeColors.statValue,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMenu(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.only(left: 13.65 * s, right: 19.3 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _quickItem(
            s,
            _QuickKind.map,
            'Peta Udara',
            onPetaUdaraTap ??
                () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const MapPage()),
                    ),
            350,
          ),
          _quickItem(
            s,
            _QuickKind.history,
            'Riwayat',
            onRiwayatTap ??
                () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AirQualityHistoryPage()),
                    ),
            420,
          ),
          _quickItem(
            s,
            _QuickKind.offline,
            'Mode Offline',
            onModeOfflineTap ??
                () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ModeOfflinePage()),
                    ),
            490,
          ),
          _quickItem(
            s,
            _QuickKind.source,
            'Sumber Pemantauan',
            onSumberPemantauanTap ??
                () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SumberPemantauanPage()),
                    ),
            560,
          ),
        ],
      ),
    );
  }

  Widget _quickItem(double s, _QuickKind kind, String label,
      VoidCallback? onTap, int delayMs) {
    return Expanded(
      child: _FadeInUp(
        delayMs: delayMs,
        dy: 24 * s,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: 38.5 * s,
                height: 38.5 * s,
                decoration: BoxDecoration(
                  color: _HomeColors.quickFill,
                  borderRadius: BorderRadius.circular(11 * s),
                  border: Border.all(color: _HomeColors.quickLine, width: 1.2),
                ),
                child: Center(
                  child: SizedBox(
                    width: 17 * s,
                    height: 17 * s,
                    child: CustomPaint(painter: _QuickIconPainter(kind)),
                  ),
                ),
              ),
              SizedBox(height: 7 * s),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: GoogleFonts.inter(
                  fontSize: 8 * s,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: _HomeColors.section,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStepCard(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 17.5 * s, right: 22.25 * s),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onHealthStepTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(11 * s, 11.5 * s, 10 * s, 11.5 * s),
          decoration: BoxDecoration(
            color: _HomeColors.stepBg,
            borderRadius: BorderRadius.circular(13 * s),
            border: Border.all(color: _HomeColors.cardLine, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 31.75 * s,
                height: 31.75 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFDFB),
                  borderRadius: BorderRadius.circular(9 * s),
                  border: Border.all(color: _HomeColors.iconGreen, width: 1.2),
                ),
                child: Icon(Icons.air_rounded,
                    size: 17 * s, color: _HomeColors.accent),
              ),
              SizedBox(width: 9 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LANGKAH SEHAT HARI INI',
                      style: GoogleFonts.inter(
                        fontSize: 6.2 * s,
                        height: 1.2,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w800,
                        color: _HomeColors.alert,
                      ),
                    ),
                    SizedBox(height: 3.8 * s),
                    Text.rich(
                      TextSpan(
                        text: 'Hindari paparan ',
                        style: GoogleFonts.inter(
                          fontSize: 10.3 * s,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: _HomeColors.cardTitle,
                        ),
                        children: const [
                          TextSpan(
                            text: 'kabut asap.',
                            style: TextStyle(color: _HomeColors.alert),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.9 * s),
                    Text(
                      'Hindari aktivitas luar ruangan. Tutup jendela dan '
                      'pantau perkembangan kabut asap.',
                      style: GoogleFonts.inter(
                        fontSize: 7.7 * s,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        color: _HomeColors.body,
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

  Widget _buildRecommendationHeader(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 17.5 * s, right: 23.75 * s),
      child: Row(
        children: [
          Text(
            'Rekomendasi',
            style: GoogleFonts.inter(
              fontSize: 12.4 * s,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: _HomeColors.section,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onLihatSemuaTap,
            child: Text(
              'Lihat semua',
              style: GoogleFonts.inter(
                fontSize: 8.6 * s,
                fontWeight: FontWeight.w700,
                color: _HomeColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticle(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.only(left: 17.5 * s, right: 23.75 * s),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onArticleTap ??
            () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const DetailArtikelPage()),
                ),
        child: Row(
          children: [
            Container(
              width: 58.5 * s,
              height: 58.5 * s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * s),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D6B).withValues(alpha: 0.28),
                    blurRadius: 4 * s,
                    offset: Offset(0, 2.5 * s),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12 * s),
                child: CustomPaint(painter: _ForestPainter()),
              ),
            ),
            SizedBox(width: 9.5 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UDARA & KESEHATAN',
                    style: GoogleFonts.inter(
                      fontSize: 6.2 * s,
                      height: 1.2,
                      letterSpacing: 0.7,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4F9A82),
                    ),
                  ),
                  SizedBox(height: 4.3 * s),
                  Text(
                    'Kenali bahaya PM2.5, lindungi pernapasanmu.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.4 * s,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F3D36),
                    ),
                  ),
                  SizedBox(height: 4.3 * s),
                  Text(
                    'Panduan praktis • 3 menit baca',
                    style: GoogleFonts.inter(
                      fontSize: 7 * s,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      color: _HomeColors.subtle,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4 * s),
            Icon(Icons.chevron_right_rounded,
                size: 15 * s, color: const Color(0xFF5E9E8A)),
          ],
        ),
      ),
    );
  }
}

class _HamburgerPainter extends CustomPainter {
  const _HamburgerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _HomeColors.brandGreen
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round;
    for (final f in [0.08, 0.5, 0.92]) {
      canvas.drawLine(
          Offset(0, size.height * f), Offset(size.width, size.height * f), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopLeafPainter extends CustomPainter {
  const _TopLeafPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 85;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(k, k);
    _homeLeaf(canvas, const Offset(92, 108), 118, 36, -0.62,
        const Color(0xFFD7E9DC),
        vein: const Color(0xFFE4F1E8));
    _homeLeaf(canvas, const Offset(100, 96), 76, 24, -0.1,
        const Color(0xFFDDEDE1),
        vein: const Color(0xFFE9F4EC));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _QuickKind { map, history, offline, source }

class _QuickIconPainter extends CustomPainter {
  final _QuickKind kind;
  const _QuickIconPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k, k);

    final p = Paint()
      ..color = const Color(0xFF2D7A66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (kind) {
      case _QuickKind.map:

        canvas.drawPath(
          Path()
            ..moveTo(12, 14.6)
            ..cubicTo(12, 14.6, 6.8, 10.8, 6.8, 8)
            ..arcTo(Rect.fromCircle(center: const Offset(12, 8), radius: 5.2),
                3.14159265, 3.14159265, false)
            ..cubicTo(17.2, 10.8, 12, 14.6, 12, 14.6)
            ..close(),
          p,
        );
        canvas.drawCircle(const Offset(12, 8), 1.8, p);
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(12, 18), width: 17, height: 5.6),
          p,
        );
        break;
      case _QuickKind.history:

        for (final b in const [
          [6.0, 16.0],
          [10.0, 14.0],
          [14.0, 12.0],
          [18.0, 10.0],
        ]) {
          canvas.drawLine(Offset(b[0], 20.5), Offset(b[0], b[1]), p);
        }
        canvas.drawPath(
          Path()
            ..moveTo(3.5, 12.5)
            ..lineTo(8.5, 8.5)
            ..lineTo(12.5, 10.5)
            ..lineTo(19.5, 4.5),
          p,
        );
        canvas.drawLine(const Offset(19.5, 4.5), const Offset(16.2, 4.8), p);
        canvas.drawLine(const Offset(19.5, 4.5), const Offset(19.2, 7.8), p);
        break;
      case _QuickKind.offline:
        canvas.drawPath(
          Path()
            ..moveTo(12, 3)
            ..lineTo(19, 5.8)
            ..lineTo(19, 12)
            ..cubicTo(19, 16.4, 15.8, 19.8, 12, 21)
            ..cubicTo(8.2, 19.8, 5, 16.4, 5, 12)
            ..lineTo(5, 5.8)
            ..close(),
          p,
        );
        canvas.drawCircle(const Offset(12, 12), 2.4, p);
        canvas.drawLine(const Offset(4.5, 4.5), const Offset(19.5, 20), p);
        break;
      case _QuickKind.source:
        canvas.drawLine(const Offset(3.5, 6), const Offset(20.5, 6), p);
        canvas.drawLine(const Offset(3.5, 11.5), const Offset(10, 11.5), p);
        canvas.drawLine(const Offset(3.5, 17), const Offset(10, 17), p);
        canvas.drawCircle(const Offset(15.5, 14.5), 3, p);
        canvas.drawLine(const Offset(17.8, 16.8), const Offset(20.5, 19.5), p);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _QuickIconPainter old) => old.kind != kind;
}

void _homeLeaf(
  Canvas canvas,
  Offset base,
  double len,
  double width,
  double angle,
  Color color, {
  Color? vein,
}) {
  canvas.save();
  canvas.translate(base.dx, base.dy);
  canvas.rotate(angle);
  final path = Path()
    ..moveTo(0, 0)
    ..cubicTo(width * 0.95, -len * 0.22, width * 0.75, -len * 0.80, 0, -len)
    ..cubicTo(-width * 0.75, -len * 0.80, -width * 0.95, -len * 0.22, 0, 0)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
  if (vein != null) {
    final vp = Paint()
      ..color = vein
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, -len * 0.05), Offset(0, -len * 0.85), vp);
    for (final f in [0.28, 0.46, 0.64]) {
      canvas.drawLine(
          Offset(0, -len * f), Offset(width * 0.55, -len * (f + 0.12)), vp);
      canvas.drawLine(
          Offset(0, -len * f), Offset(-width * 0.55, -len * (f + 0.12)), vp);
    }
  }
  canvas.restore();
}

class _MaskedManPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 78;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(k, k);

    _homeLeaf(canvas, const Offset(68, 96), 62, 24, 0.22,
        const Color(0xFFD3E6CE),
        vein: const Color(0xFFB5D2B0));
    _homeLeaf(canvas, const Offset(60, 96), 46, 18, -0.25,
        const Color(0xFFBBD7B7),
        vein: const Color(0xFF9FC29A));
    _homeLeaf(canvas, const Offset(10, 96), 40, 15, -0.55,
        const Color(0xFFC8DFC2),
        vein: const Color(0xFFA9CCA3));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(55, 57, 15, 36), const Radius.circular(5)),
      Paint()..color = const Color(0xFF9A7653),
    );

    final jacket = Path()
      ..moveTo(18, 96)
      ..lineTo(20, 63)
      ..quadraticBezierTo(22, 52, 33, 49)
      ..lineTo(47, 49)
      ..quadraticBezierTo(58, 52, 60, 63)
      ..lineTo(62, 96)
      ..close();
    canvas.drawPath(jacket, Paint()..color = const Color(0xFF1F6B55));

    canvas.drawPath(
      Path()
        ..moveTo(35, 49)
        ..lineTo(45, 49)
        ..lineTo(40, 60)
        ..close(),
      Paint()..color = const Color(0xFFF2F2EE),
    );
    canvas.drawLine(
      const Offset(40, 60),
      const Offset(40, 96),
      Paint()
        ..color = const Color(0xFF165240)
        ..strokeWidth = 0.9,
    );
    canvas.drawLine(
      const Offset(52, 52),
      const Offset(55, 96),
      Paint()
        ..color = const Color(0xFF14503F)
        ..strokeWidth = 2.2,
    );

    canvas.drawRect(
      const Rect.fromLTWH(36, 42, 8, 9),
      Paint()..color = const Color(0xFFD9A07A),
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(40, 26), width: 24, height: 22),
      Paint()..color = const Color(0xFF2B2420),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(40, 33), width: 21, height: 23),
      Paint()..color = const Color(0xFFE2AE86),
    );

    final eye = Paint()..color = const Color(0xFF2B2420);
    canvas.drawCircle(const Offset(35.5, 31), 1.1, eye);
    canvas.drawCircle(const Offset(44.5, 31), 1.1, eye);

    final loop = Paint()
      ..color = const Color(0xFFCFD8D5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(const Offset(30.5, 36), const Offset(28.5, 33), loop);
    canvas.drawLine(const Offset(49.5, 36), const Offset(51.5, 33), loop);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(30.5, 34, 19, 11), const Radius.circular(3.5)),
      Paint()..color = const Color(0xFFF4F7F6),
    );
    final pleat = Paint()
      ..color = const Color(0xFFD6DFDC)
      ..strokeWidth = 0.7;
    canvas.drawLine(const Offset(32, 37.5), const Offset(48, 37.5), pleat);
    canvas.drawLine(const Offset(32, 40), const Offset(48, 40), pleat);
    canvas.drawLine(const Offset(32, 42.5), const Offset(48, 42.5), pleat);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 62;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA8CBB0), Color(0xFF5E9273), Color(0xFF244A38)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );
    canvas.save();
    canvas.scale(k, k);

    final trunk = Paint()
      ..color = const Color(0xFF7FA58B).withValues(alpha: 0.55)
      ..strokeWidth = 1.4;
    canvas.drawLine(const Offset(14, 0), const Offset(16, 62), trunk);
    canvas.drawLine(const Offset(40, 0), const Offset(38, 62), trunk);
    canvas.drawLine(const Offset(52, 8), const Offset(50, 62), trunk);

    _homeLeaf(canvas, const Offset(6, 64), 44, 12, 0.95,
        const Color(0xFF234F3B));
    _homeLeaf(canvas, const Offset(58, 64), 46, 12, -0.9,
        const Color(0xFF2B5C45));
    _homeLeaf(canvas, const Offset(30, 66), 40, 11, 0.1,
        const Color(0xFF3A7457));
    _homeLeaf(canvas, const Offset(18, 66), 30, 9, -0.6,
        const Color(0xFF1F4634));
    _homeLeaf(canvas, const Offset(46, 66), 30, 9, 0.6,
        const Color(0xFF1F4634));
    _homeLeaf(canvas, const Offset(34, 66), 22, 7, -0.2,
        const Color(0xFF6FA283));

    canvas.drawCircle(
      const Offset(40, 14),
      16,
      Paint()..color = const Color(0xFFE9F3EC).withValues(alpha: 0.35),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FadeInUp extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double dy;

  const _FadeInUp({
    required this.child,
    this.delayMs = 0,
    this.dy = 24,
  });

  @override
  State<_FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<_FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final v = _animation.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * widget.dy),
            child: child,
          ),
        );
      },
    );
  }
}
