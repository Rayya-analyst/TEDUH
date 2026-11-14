import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../state/app_settings.dart';
import '../models/air_quality_snapshot.dart';
import '../services/air_quality_decision_engine.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';
import '../widgets/context_card.dart';
import '../widgets/teduh_drawer.dart';
import '../widgets/teduh_header.dart';
import '../services/voice_service.dart';
import '../widgets/voice_scope.dart';
import 'ai_analysis_page.dart';
import '../models/air_quality_models.dart';
import '../state/monitoring_state.dart';
import 'ai_assistant_page.dart';

class TeduhActionPage extends StatefulWidget {
  const TeduhActionPage({super.key});

  @override
  State<TeduhActionPage> createState() => _TeduhActionPageState();
}

class _TeduhActionPageState extends State<TeduhActionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _bg = Color(0xFFF6F6F3);
  static const _danger = Color(0xFFB3261E);
  static const _dangerDeep = Color(0xFF8E1B1B);
  static const _dangerTint = Color(0xFFFDECE8);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AppSettings.instance.animBehavior,
    )..forward();
  }

  final List<GlobalKey> _tk = List<GlobalKey>.generate(7, (_) => GlobalKey());

  List<CoachStep> get _tour => [
        CoachStep(
          target: _tk[0],
          title: 'Menu dan notifikasi',
          body: 'Ikon tiga garis membuka menu fitur. Ikon lonceng membuka '
              'riwayat notifikasi.',
          radius: 22,
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _tk[1],
          title: 'Ringkasan kondisi udara',
          body: 'Ringkasan situasi udara dan tindakan utama yang disarankan '
              'untukmu hari ini.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _tk[2],
          title: 'Rekomendasi sesuai aktivitasmu',
          body: 'Pilih kegiatanmu: sekolah, bekerja, olahraga, perjalanan, '
              'atau di rumah. Saran langsung menyesuaikan. Ketuk tombol '
              'hijau untuk melihat alasan lengkap rekomendasi.',
          radius: 26,
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _tk[3],
          title: 'Dampak ke kesehatan',
          body: 'Penjelasan singkat apa arti kondisi udara ini bagi '
              'pernapasanmu.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _tk[4],
          title: 'Aktivitas yang disarankan',
          body: 'Pilihan kegiatan yang aman dan yang sebaiknya ditunda saat '
              'udara seperti ini.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _tk[5],
          title: 'Langkah perlindungan',
          body: 'Urutan langkah yang bisa langsung kamu lakukan, dari '
              'masker sampai menjaga udara di rumah.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _tk[6],
          title: 'Tanya Asisten AI',
          body: 'Punya pertanyaan tentang udara atau kesehatan? Tanyakan '
              'langsung, bisa diketik maupun dengan suara.',
          scrollAlignment: 0.3,
        ),
      ];

  String _narration() {
    final v = VoiceService.instance;
    return 'Ini seluruh isi TEDUH ACTION. Di bagian atas ada ringkasan '
        'kondisi udara. ${v.airSummary()} '
        'Di bawahnya kamu memilih aktivitasmu: sekolah, bekerja, olahraga, '
        'perjalanan, atau di rumah, lalu saran langsung menyesuaikan. '
        '${v.recommendationSummary()} '
        'Setelah itu ada penjelasan dampak kondisi udara bagi pernapasanmu, '
        'daftar aktivitas yang aman dan yang sebaiknya ditunda, serta '
        'langkah perlindungan dari memakai masker sampai menjaga udara di '
        'rumah. Di bagian bawah ada kartu Tanya Asisten AI. '
        'Kamu bisa berkata apa rekomendasi untuk saya, atau buka Asisten AI. ';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([MonitoringState.instance, AppSettings.instance]),
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    Widget k(int i, Widget w) => KeyedSubtree(key: _tk[i], child: w);
    final sections = <Widget>[
      k(0, _header(context)),
      _simulationLabel(),
      k(1, _hero()),
      _decisionSummaryCard(context),
      k(2, const ContextRecommendationCard()),
      _planTitle(),
      k(3, _healthCard()),
      k(4, _activityCard()),
      _stepsTitle(),
      k(5, _stepsCard()),
      k(6, _askAiCard(context)),
      _disclaimer(),
    ];

    return VoiceScope(
      screen: 'action',
      tour: _tour,
      guide: PageGuide(
        content: _narration,
        nextScreen: 'ready',
        nextLabel: 'TEDUH READY',
        nextHint: 'berisi kesiapsiagaan kabut asap: Tas Siaga, Rencana '
            'Darurat, dan Progres Kesiapsiagaan.',
      ),
      child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: _bg,
      drawerScrimColor: const Color(0x6B1A2622),
      drawer: const TeduhDrawer(current: HomeMenuItem.action),
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: _bg,
            elevation: 0,
            pinned: true,
            floating: true,
            snap: true,
            toolbarHeight: 64,
            automaticallyImplyLeading: false,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: _bg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SafeArea(
                bottom: false,
                child: KeyedSubtree(
                  key: _tk[0],
                  child: _header(context),
                ),
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 1; i < sections.length; i++) ...[
                Reveal(
                  animation: _ctrl,
                  begin: _begin(i),
                  end: _begin(i) + 0.4,
                  child: sections[i],
                ),
                SizedBox(height: _gapAfter(i)),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }

  double _begin(int i) {
    final b = i * 0.06;
    return b > 0.6 ? 0.6 : b;
  }

  double _gapAfter(int i) {
    switch (i) {
      case 0:
        return 14;
      case 1:
        return 10;
      case 2:
        return 20;
      case 3:
        return 16;
      case 7:
        return 10;
      case 11:
        return 0;
      default:
        return 16;
    }
  }

  Widget _header(BuildContext context) {
    return TeduhHeader(
      accent: 'ACTION',
      subtitle: 'Panduan perlindungan personal',
      onMenu: () => _scaffoldKey.currentState?.openDrawer(),
    );
  }

  Widget _simulationLabel() {
    final reading = MonitoringState.instance.currentReading;
    final snap = AppSettings.instance.snapshot;

    final String sourceLabel;
    final String timeLabel;
    if (reading != null) {
      sourceLabel = reading.provenanceText;
      final t = reading.observedAt;
      final bulan = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ][t.month];
      timeLabel = '${t.day} $bulan ${t.year} · ${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')} WIB';
    } else {
      sourceLabel = snap.sourceName;
      timeLabel = snap.updatedAt;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: TC.hint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$sourceLabel · $timeLabel',
              style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final mon = MonitoringState.instance;
    final reading = mon.currentReading;
    final snap = AppSettings.instance.snapshot;

    final String statusText = reading != null ? reading.categoryLabel.toUpperCase() : snap.status.toUpperCase();
    final String ispuStr = reading != null
        ? (reading.officialIspu != null ? '${reading.officialIspu}' : (reading.pm25 != null ? reading.pm25!.toStringAsFixed(1).replaceAll('.', ',') : '--'))
        : '${snap.ispu}';
    final String unitStr = reading != null && reading.officialIspu == null && reading.pm25 != null ? 'µg/m³ PM2.5' : 'ISPU';
    final String locationHeader = mon.locationName.toUpperCase();
    final String headline = reading != null && reading.category == IspuCategory.baik
        ? 'Udara dalam kondisi aman.'
        : 'Utamakan ruang yang aman.';
    final String desc = reading != null
        ? 'Sumber: ${reading.provenanceText}. Konsentrasi PM2.5: ${reading.formattedPm25}.'
        : 'Asap Karhutla terindikasi mendominasi partikel. ${snap.pm25}; paparan berisiko.';

    final String dateStr = reading != null
        ? '${reading.observedAt.day} Nov ${reading.observedAt.year} · ${reading.observedAt.hour.toString().padLeft(2, '0')}.${reading.observedAt.minute.toString().padLeft(2, '0')} WIB'
        : snap.updatedAt;

    final bool isHealthy = reading != null && (reading.category == IspuCategory.baik || reading.category == IspuCategory.sedang);
    final List<Color> bgGradient = isHealthy
        ? const [Color(0xFF1E5B4B), Color(0xFF133E33)]
        : const [Color(0xFF8A2A22), Color(0xFF5C1616)];
    final Color badgeBg = isHealthy ? const Color(0xFF2E7B67) : const Color(0xFFB42323);
    final Color footerBg = isHealthy ? const Color(0xFF16473B) : const Color(0xFFB04A4A);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.55,
                child: Image.asset(
                  'assets/images/karhutla.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              locationHeader,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            ispuStr,
                            style: GoogleFonts.poppins(
                              fontSize: ispuStr.length > 3 ? 46 : 66,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            unitStr,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        headline,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        desc,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          height: 1.55,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                  color: footerBg,
                  child: Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _decisionSummaryCard(BuildContext context) {
    final mon = MonitoringState.instance;
    final reading = mon.currentReading;
    final snap = AppSettings.instance.snapshot;

    final pm25val = reading?.pm25;
    final ispuVal = reading?.officialIspu ?? snap.ispu;
    final pollutants = <String, PollutantValue>{};
    if (pm25val != null) {
      pollutants['pm2_5'] = PollutantValue(
        value: pm25val,
        unit: 'µg/m³',
        providerId: reading!.sourceId,
        timestamp: reading.observedAt,
        dataType: reading.observationType,
        confidence: reading.observationType == ObservationType.station
            ? DataConfidence.stationMeasured
            : DataConfidence.modelEstimate,
      );
    }

    final snapshotForEngine = AirQualitySnapshot(
      locationId: 'region-${mon.selectedRegion.regionId}',
      latitude: mon.selectedSite.latitude,
      longitude: mon.selectedSite.longitude,
      locationName: mon.locationName,
      province: mon.selectedRegion.province,
      city: mon.selectedRegion.regency,
      timestamp: reading?.observedAt ?? DateTime.now(),
      pollutants: pollutants,
      ispu: ispuVal > 0
          ? IspuResult(
              ispuValue: ispuVal,
              category: IspuCategory.fromIspu(ispuVal),
              dominantPollutant: reading?.criticalPollutant ?? 'PM2.5',
              calculationSource: reading?.sourceId ?? 'unknown',
              isOfficialStation: reading?.observationType == ObservationType.station,
            )
          : null,
      sourceMetadata: SourceMetadata(
        totalProvidersTried: 1,
        totalProvidersSucceeded: reading != null ? 1 : 0,
        hasOfficialStationData: reading?.observationType == ObservationType.station,
        hasModelData: reading?.observationType == ObservationType.model,
        hasSatelliteData: false,
        snapshotCreatedAt: DateTime.now(),
        providerStatus: {},
      ),
    );

    final decision = AirQualityDecisionEngine.decide(snapshot: snapshotForEngine);
    final cat = decision.category;
    final isDanger = cat == IspuCategory.berbahaya || cat == IspuCategory.sangatTidakSehat;
    final isModerate = cat == IspuCategory.tidakSehat;

    final Color badgeBg = isDanger
        ? const Color(0xFFB3261E)
        : (isModerate ? const Color(0xFFB05A14) : const Color(0xFF1B6B58));

    final String decisionTitle = decision.recommendations.isNotEmpty
        ? decision.recommendations.first
        : (isDanger
            ? 'Isolasi Ruang Bersih & Gunakan N95'
            : (isModerate
                ? 'Batasi Aktivitas Luar & Kenakan Masker'
                : 'Aman untuk Aktivitas Luar Ruangan Normal'));

    final String decisionSubtitle = decision.reasonText.length > 200
        ? '${decision.reasonText.substring(0, 200)}...'
        : decision.reasonText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDanger ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
                      size: 13,
                      color: badgeBg,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'RINGKASAN KEPUTUSAN',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: badgeBg,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'ISPU $ispuVal',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: badgeBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            decisionTitle,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: TC.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            decisionSubtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.5,
              color: TC.hint,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEFF3F0)),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Perlu penjelasan mendalam?',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: TC.hint,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AiAnalysisPage()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: const Color(0xFFE8F3EA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.analytics_outlined, size: 14, color: TC.greenDeep),
                label: Text(
                  'Lihat Analisis Lengkap',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: TC.greenDeep,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RENCANA PERLINDUNGAN ANDA',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: TC.greenDeep,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kurangi paparan.',
            style: GoogleFonts.poppins(
              fontSize: 26,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: TC.dark,
            ),
          ),
          Text(
            'Jaga setiap napas.',
            style: GoogleFonts.poppins(
              fontSize: 26,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: TC.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lakukan langkah berikut sekarang. Jangan menunggu '
            'gejala muncul untuk berlindung.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.55,
              color: TC.hint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.health_and_safety_outlined,
                  size: 22, color: TC.greenDeep),
              const SizedBox(width: 10),
              Text(
                'Perlindungan kesehatan',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TC.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.groups_outlined,
            iconBg: _dangerTint,
            iconColor: _danger,
            title: 'Semua orang perlu terlindungi',
            body: 'Anak, lansia, ibu hamil, serta penderita asma '
                'atau penyakit jantung perlu perhatian ekstra.',
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.medication_outlined,
            iconBg: TC.iconBox,
            iconColor: TC.green,
            title: 'Siapkan obat rutin',
            body: 'Simpan obat dan inhaler sesuai resep. Jangan '
                'mengubah dosis tanpa arahan tenaga kesehatan.',
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _dangerTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Sesak berat, bibir kebiruan, atau nyeri dada: segera cari '
              'pertolongan medis / IGD.',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                height: 1.5,
                color: _dangerDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ActivityContent _activityContentFor(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:
        return _ActivityContent(
          badge: 'AMAN BERAKTIVITAS',
          badgeBg: const Color(0xFFE6F4EE),
          badgeText: const Color(0xFF176D59),
          headline: 'Udara bersih, bagus untuk aktivitas.',
          body: 'Kualitas udara saat ini baik. Anda dapat beraktivitas '
              'di luar ruangan dengan normal.',
          checks: const [
            _CheckRow(ok: true, text: 'Olahraga luar ruang diperbolehkan.'),
            _CheckRow(ok: true, text: 'Aktivitas luar seperti biasa.'),
            _CheckRow(ok: true, text: 'Ventilasi ruangan tetap dianjurkan.'),
          ],
        );
      case IspuCategory.sedang:
        return _ActivityContent(
          badge: 'PANTAU KONDISI',
          badgeBg: const Color(0xFFFFF8E0),
          badgeText: const Color(0xFF856D14),
          headline: 'Udara cukup baik, pantau kondisi.',
          body: 'Kualitas udara sedang. Kelompok sensitif seperti anak-anak, '
              'lansia, dan penderita asma perlu berhati-hati.',
          checks: const [
            _CheckRow(ok: true, text: 'Aktivitas luar masih aman untuk sebagian besar orang.'),
            _CheckRow(ok: false, text: 'Olahraga berat di luar: batasi durasinya.'),
            _CheckRow(ok: true, text: 'Kelompok sensitif: kurangi waktu di luar.'),
          ],
        );
      case IspuCategory.tidakSehat:
        return _ActivityContent(
          badge: 'BATASI AKTIVITAS LUAR',
          badgeBg: const Color(0xFFFFF0E0),
          badgeText: const Color(0xFFB05A14),
          headline: 'Kurangi aktivitas di luar ruangan.',
          body: 'Kualitas udara tidak sehat. Batasi durasi di luar, '
              'terutama aktivitas fisik berat. Gunakan masker N95 jika harus keluar.',
          checks: const [
            _CheckRow(ok: false, text: 'Hindari olahraga berat di luar ruangan.'),
            _CheckRow(ok: false, text: 'Batasi waktu di luar — gunakan masker N95.'),
            _CheckRow(ok: true, text: 'Aktivitas ringan di dalam ruangan dianjurkan.'),
          ],
        );
      case IspuCategory.sangatTidakSehat:
      case IspuCategory.berbahaya:
        return _ActivityContent(
          badge: 'TETAP DI DALAM',
          badgeBg: _dangerTint,
          badgeText: _dangerDeep,
          headline: 'Di dalam bukan berarti bebas asap.',
          body: 'Pilih satu ruang dengan pintu dan jendela tertutup. '
              'Gunakan penyaring HEPA bila ada dan AC dengan '
              'sirkulasi dalam.',
          checks: const [
            _CheckRow(ok: false, text: 'Tunda olahraga, termasuk lari di teras.'),
            _CheckRow(ok: false, text: 'Hindari rokok, dupa, dan menggoreng.'),
            _CheckRow(ok: true, text: 'Pilih aktivitas ringan dan istirahat.'),
          ],
        );
      case IspuCategory.tidakTersedia:
        return _ActivityContent(
          badge: 'MEMUAT DATA',
          badgeBg: const Color(0xFFEEEEEE),
          badgeText: const Color(0xFF6B7A74),
          headline: 'Memuat data kualitas udara...',
          body: 'Data ISPU sedang dimuat dari stasiun KLHK. '
              'Rekomendasi akan muncul setelah data tersedia.',
          checks: const [
            _CheckRow(ok: true, text: 'Pantau kondisi setelah data tersedia.'),
          ],
        );
    }
  }

  Widget _activityCard() {
    return AnimatedBuilder(
      animation: MonitoringState.instance,
      builder: (ctx, child) {
        final reading = MonitoringState.instance.currentReading;
        final cat = reading?.category ?? IspuCategory.tidakTersedia;
        final content = _activityContentFor(cat);

        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'AKTIVITAS HARI INI',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: TC.hint,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: content.badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      content.badge,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: content.badgeText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                content.headline,
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: TC.dark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                content.body,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  height: 1.55,
                  color: TC.hint,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 1, color: TC.divider),
              const SizedBox(height: 14),
              ...content.checks.expand((w) => [w, const SizedBox(height: 12)]),
            ],
          ),
        );
      },
    );
  }

  Widget _stepsTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Ingat lima langkah TEDUH',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: TC.dark,
        ),
      ),
    );
  }

  Widget _stepsCard() {
    const steps = <List<String>>[
      [
        'T',
        'Tutup jalur masuk asap',
        'Tutup celah pintu dan jendela. Kurangi udara luar yang masuk ke rumah.'
      ],
      [
        'E',
        'Elakkan aktivitas luar',
        'Tunda perjalanan dan aktivitas fisik. Keluar hanya bila benar-benar perlu.'
      ],
      [
        'D',
        'Dahulukan yang rentan',
        'Dampingi keluarga yang berisiko. Pantau batuk, mengi, dan kesulitan bernapas.'
      ],
      [
        'U',
        'Upayakan udara tersaring',
        'Nyalakan HEPA. Jika asap tetap masuk, cari tempat berlindung dengan udara lebih bersih.'
      ],
      [
        'H',
        'Hubungi bantuan saat perlu',
        'Untuk gejala berat, segera ke IGD. Masker bukan pengganti tempat berlindung.'
      ],
    ];

    return _Card(
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _LetterRow(
              letter: steps[i][0],
              title: steps[i][1],
              body: steps[i][2],
            ),
            if (i != steps.length - 1) const _SoftDivider(),
          ],
        ],
      ),
    );
  }

  Widget _askAiCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F5C46),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5E6D8),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.auto_awesome_outlined,
                    size: 22, color: Color(0xFF1F5C46)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masih ragu harus apa?',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Panduan tenang, sesuai kebutuhan Anda.',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PillButton(
            label: 'Tanya Asisten AI',
            background: const Color(0xFFD5E6D8),
            foreground: const Color(0xFF1F5C46),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiAssistantPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  String _userFacingSource(AirReading? reading) {
    if (reading == null) return 'Memuat data dari stasiun KLHK...';
    final prov = reading.provenanceText;
    if (prov.toLowerCase().contains('firestore') ||
        prov.toLowerCase().contains('firebase') ||
        prov.toLowerCase().contains('teduh-app')) {
      return 'KLHK · Stasiun ${MonitoringState.instance.selectedSite.stationName}';
    }
    return prov;
  }

  Widget _disclaimer() {
    final reading = MonitoringState.instance.currentReading;
    final sourceText = _userFacingSource(reading);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Panduan umum, bukan diagnosis medis. '
        'Sumber: $sourceText. '
        'Ikuti arahan resmi setempat jika kondisi memburuk.',
        style: GoogleFonts.poppins(
          fontSize: 9.5,
          height: 1.55,
          color: TC.hint,
        ),
      ),
    );
  }
}

class _ActivityContent {
  final String badge;
  final Color badgeBg;
  final Color badgeText;
  final String headline;
  final String body;
  final List<_CheckRow> checks;

  const _ActivityContent({
    required this.badge,
    required this.badgeBg,
    required this.badgeText,
    required this.headline,
    required this.body,
    required this.checks,
  });
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, thickness: 1, color: TC.divider),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;

  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: TC.dark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  height: 1.55,
                  color: TC.hint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LetterRow extends StatelessWidget {
  final String letter;
  final String title;
  final String body;

  const _LetterRow({
    required this.letter,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TC.iconBox,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            letter,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: TC.greenDeep,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: TC.dark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  height: 1.55,
                  color: TC.hint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  final bool ok;
  final String text;

  const _CheckRow({required this.ok, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
          size: 18,
          color: ok ? TC.greenDeep : const Color(0xFFB3261E),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 11.5, color: TC.dark),
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
              Icon(Icons.north_east_rounded, size: 18, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
