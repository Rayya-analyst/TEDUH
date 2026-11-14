import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/air_quality_models.dart';
import '../state/monitoring_state.dart';
import 'ai_assistant_page.dart';
import 'context_recommendation_page.dart';
import 'detail_artikel_page.dart';
import 'mode_offline_page.dart';
import 'peringatan_udara.dart';
import 'map_page.dart';
import 'region_page.dart';
import 'sumber_pemantauan_page.dart';
import 'air_quality_history_page.dart';
import '../state/app_settings.dart';
import '../services/user_profile_service.dart';
import '../widgets/teduh_drawer.dart';
import '../widgets/teduh_header.dart';
import '../widgets/voice_scope.dart';

class AirCardTheme {
  final Color bg;
  final Color border;
  final Color titleColor;
  final Color valueColor;
  final Color shadowColor;
  final Color badgeBg;
  final Color stepBg;

  const AirCardTheme({
    required this.bg,
    required this.border,
    required this.titleColor,
    required this.valueColor,
    required this.shadowColor,
    required this.badgeBg,
    required this.stepBg,
  });

  factory AirCardTheme.fromCategory(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return const AirCardTheme(
          bg: Color(0xFFE8F5E9),
          border: Color(0xFF81C784),
          titleColor: Color(0xFF1B5E20),
          valueColor: Color(0xFF2E7D32),
          shadowColor: Color(0x1A2E7D32),
          badgeBg: Color(0xFF2E7D32),
          stepBg: Color(0xFFF1F8E9),
        );
      case IspuCategory.sedang:
        return const AirCardTheme(
          bg: Color(0xFFFFFDE7),
          border: Color(0xFFFFD54F),
          titleColor: Color(0xFFF57F17),
          valueColor: Color(0xFFE65100),
          shadowColor: Color(0x1AE65100),
          badgeBg: Color(0xFFF9A825),
          stepBg: Color(0xFFFFFDE7),
        );
      case IspuCategory.tidakSehat:
        return const AirCardTheme(
          bg: Color(0xFFFFF3E0),
          border: Color(0xFFFFB74D),
          titleColor: Color(0xFFE65100),
          valueColor: Color(0xFFD84315),
          shadowColor: Color(0x1AD84315),
          badgeBg: Color(0xFFEF6C00),
          stepBg: Color(0xFFFFF8E1),
        );
      case IspuCategory.sangatTidakSehat:
        return const AirCardTheme(
          bg: Color(0xFFFFEBEE),
          border: Color(0xFFE57373),
          titleColor: Color(0xFFC62828),
          valueColor: Color(0xFFB71C1C),
          shadowColor: Color(0x1AB71C1C),
          badgeBg: Color(0xFFC62828),
          stepBg: Color(0xFFFFEBEE),
        );
      case IspuCategory.berbahaya:
        return const AirCardTheme(
          bg: Color(0xFFFFCDD2),
          border: Color(0xFFEF5350),
          titleColor: Color(0xFF8E1B1B),
          valueColor: Color(0xFF6B0E0E),
          shadowColor: Color(0x2B8E1B1B),
          badgeBg: Color(0xFF8E1B1B),
          stepBg: Color(0xFFFFF0F0),
        );
      case IspuCategory.tidakTersedia:
        return const AirCardTheme(
          bg: Color(0xFFECEFF1),
          border: Color(0xFFCFD8DC),
          titleColor: Color(0xFF455A64),
          valueColor: Color(0xFF37474F),
          shadowColor: Color(0x1A455A64),
          badgeBg: Color(0xFF607D8B),
          stepBg: Color(0xFFECEFF1),
        );
    }
  }
}

class _HomeColors {
  static const accent = Color(0xFF2E7B67);
  static const iconGreen = Color(0xFF3A8A72);
  static const section = Color(0xFF1F4A3F);
  static const subtle = Color(0xFF9AA7A2);
  static const cardTitle = Color(0xFF1E7360);
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
  final IspuCategory airCategory;
  final String ispuValue;
  final String ispuLabel;
  final String airDescription;
  final String pm25;
  final String temperature;
  final String humidity;
  final String sourceText;

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
    this.airCategory = IspuCategory.berbahaya,
    this.ispuValue = '275,2',
    this.ispuLabel = '462 ISPU',
    this.airDescription = 'Partikel halus akibat kabut asap',
    this.pm25 = '275,2 µg/m³',
    this.temperature = '27°C',
    this.humidity = '80%',
    this.sourceText = 'Sumber: BMKG dan KLH • 3 November 2026',
    this.alertIspu,
    this.alertRegion = '',
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
              'Sumber Pemantauan. Menampilkan informasi sumber data ISPU '
              'dari stasiun resmi KLHK.',
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

  HomePage _withSource(AirSnapshot a, BuildContext context) {
    final mon = MonitoringState.instance;
    final reading = mon.currentReading;

    final String currentLocation = AppSettings.instance.locationName.isNotEmpty
        ? AppSettings.instance.locationName
        : (mon.locationName.isNotEmpty ? mon.locationName : a.location);
    final currentUserName = UserProfileService.instance.shortName;

    int displayIspu = a.ispu;
    String displayStatus = a.status;
    String displayIspuValue = a.ispuValue;
    String displayIspuLabel = a.ispuLabel;
    String displayPm25 = a.pm25;
    String displaySourceText = a.sourceText;
    String displayDate = a.updatedAt;

    if (reading != null) {
      displayStatus = reading.categoryLabel;
      displaySourceText = 'Sumber: ${reading.provenanceText}';
      final dt = reading.observedAt;
      displayDate = '${dt.day} Nov ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';

      if (reading.officialIspu != null) {
        displayIspu = reading.officialIspu!;
        displayIspuValue = displayIspu.toString();
        displayIspuLabel = '$displayIspu ISPU';
        displayPm25 = reading.formattedPm25;
      } else if (reading.pm25 != null) {
        displayIspu = reading.pm25!.round();
        displayIspuValue = reading.pm25!.toStringAsFixed(1).replaceAll('.', ',');
        displayIspuLabel = 'µg/m³ PM2.5';
        displayPm25 = reading.formattedPm25;
      }
    }

    final bool isThreatening = displayIspu >= 300;
    IspuCategory category;
    if (reading != null) {
      category = reading.category;
    } else {
      if (displayIspu <= 0 && displayIspuValue == '--') {
        category = IspuCategory.tidakTersedia;
      } else if (displayIspu <= 50) {
        category = IspuCategory.baik;
      } else if (displayIspu <= 100) {
        category = IspuCategory.sedang;
      } else if (displayIspu <= 200) {
        category = IspuCategory.tidakSehat;
      } else if (displayIspu <= 300) {
        category = IspuCategory.sangatTidakSehat;
      } else {
        category = IspuCategory.berbahaya;
      }
    }

    return HomePage(
      userName: currentUserName,
      subtitle: 'Panduan perlindungan · $currentUserName',
      location: currentLocation,
      dateText: displayDate,
      airStatus: displayStatus,
      airCategory: category,
      ispuValue: displayIspuValue,
      ispuLabel: displayIspuLabel,
      airDescription: a.airDescription,
      pm25: displayPm25,
      temperature: a.temperature,
      humidity: a.humidity,
      sourceText: displaySourceText,
      alertIspu: isThreatening ? displayIspu : null,
      alertRegion: currentLocation,
      showDailyNotification: displayIspu >= 200,
      dailyNotificationIspu: displayIspu,
      onMenuTap: onMenuTap,
      onDrawerItemTap: onDrawerItemTap,
      onLogoutTap: onLogoutTap,
      onNotificationTap: onNotificationTap,
      onLocationTap: onLocationTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegionPage()),
              ),
      onPetaUdaraTap: onPetaUdaraTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MapPage(wilayah: currentLocation)),
              ),
      onRiwayatTap: onRiwayatTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AirQualityHistoryPage()),
              ),
      onModeOfflineTap: onModeOfflineTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModeOfflinePage()),
              ),
      onSumberPemantauanTap: onSumberPemantauanTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SumberPemantauanPage()),
              ),
      onHealthStepTap: onHealthStepTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContextRecommendationPage()),
              ),
      onLihatSemuaTap: onLihatSemuaTap,
      onArticleTap: onArticleTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppSettings.instance, UserProfileService.instance, MonitoringState.instance]),
      builder: (context, _) {
        final view = _withSource(AppSettings.instance.snapshot, context);
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
          onItemTap: onDrawerItemTap,
          onLogoutTap: onLogoutTap,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AiAssistantPage()),
            );
          },
          backgroundColor: const Color(0xFF1F6B4F),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.auto_awesome_rounded, size: 20),
          label: Text(
            'Tanya TEDUH AI',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
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
                color: AirCardTheme.fromCategory(airCategory).valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirCard(double s) {
    final theme = AirCardTheme.fromCategory(airCategory);
    return Padding(
      padding: EdgeInsets.only(left: 17.5 * s, right: 22.25 * s),
      child: Container(
        decoration: BoxDecoration(
          color: theme.bg,
          borderRadius: BorderRadius.circular(15 * s),
          border: Border.all(color: theme.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
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
                          style: TextStyle(color: theme.valueColor),
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
                          color: theme.valueColor,
                        ),
                      ),
                      SizedBox(width: 7 * s),
                      Text(
                        ispuLabel,
                        style: GoogleFonts.inter(
                          fontSize: 7.6 * s,
                          fontWeight: FontWeight.w700,
                          color: theme.valueColor,
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
    final theme = AirCardTheme.fromCategory(airCategory);
    String stepTitle;
    String stepBody;
    switch (airCategory) {
      case IspuCategory.baik:
        stepTitle = 'Nikmati udara bersih.';
        stepBody = 'Sangat baik untuk aktivitas luar ruangan, olahraga, dan ventilasi alami rumah.';
        break;
      case IspuCategory.sedang:
        stepTitle = 'Kondisi udara cukup aman.';
        stepBody = 'Aman beraktivitas normal. Kelompok sangat sensitif perhatikan bila langit mulai berasap.';
        break;
      case IspuCategory.tidakSehat:
        stepTitle = 'Kurangi aktivitas di luar.';
        stepBody = 'Kelompok sensitif sebaiknya gunakan masker saat keluar dan tutup ventilasi jika berasap.';
        break;
      case IspuCategory.sangatTidakSehat:
        stepTitle = 'Hindari paparan asap luar.';
        stepBody = 'Gunakan respirator N95 bila terpaksa keluar. Tutup jendela dan hidupkan sirkulasi dalam.';
        break;
      case IspuCategory.berbahaya:
        stepTitle = 'Bahaya kabut asap pekat.';
        stepBody = 'Hindari aktivitas luar ruangan. Tetap di ruang berfilter dan pantau perkembangan kabut asap.';
        break;
      case IspuCategory.tidakTersedia:
        stepTitle = 'Kondisi udara sedang dipantau.';
        stepBody = 'Menghubungkan ke pemantauan udara untuk rekomendasi perlindungan kesehatan personal.';
        break;
    }

    return Padding(
      padding: EdgeInsets.only(left: 17.5 * s, right: 22.25 * s),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onHealthStepTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(11 * s, 11.5 * s, 10 * s, 11.5 * s),
          decoration: BoxDecoration(
            color: theme.stepBg,
            borderRadius: BorderRadius.circular(13 * s),
            border: Border.all(color: theme.border, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 31.75 * s,
                height: 31.75 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFDFB),
                  borderRadius: BorderRadius.circular(9 * s),
                  border: Border.all(color: theme.border, width: 1.2),
                ),
                child: Icon(Icons.air_rounded,
                    size: 17 * s, color: theme.valueColor),
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
                        color: theme.valueColor,
                      ),
                    ),
                    SizedBox(height: 3.8 * s),
                    Text(
                      stepTitle,
                      style: GoogleFonts.inter(
                        fontSize: 10.3 * s,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: theme.titleColor,
                      ),
                    ),
                    SizedBox(height: 3.9 * s),
                    Text(
                      stepBody,
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
