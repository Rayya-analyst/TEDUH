import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../state/app_settings.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';
import '../widgets/teduh_drawer.dart';
import '../widgets/teduh_header.dart';
import '../widgets/voice_scope.dart';
import 'readiness_state.dart';
import 'rencana_darurat_page.dart';
import 'tas_siaga_page.dart';

class TeduhReadyPage extends StatefulWidget {
  const TeduhReadyPage({super.key});

  @override
  State<TeduhReadyPage> createState() => _TeduhReadyPageState();
}

class _TeduhReadyPageState extends State<TeduhReadyPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AppSettings.instance.animBehavior,
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  final List<GlobalKey> _tk = List<GlobalKey>.generate(4, (_) => GlobalKey());

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
          title: 'Tingkat kesiapanmu',
          body: 'Persentase ini dihitung dari item tas dan langkah harian di '
              'Tas Siaga Haze. Angkanya naik saat kamu menyelesaikan '
              'checklist.',
          radius: 26,
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _tk[2],
          title: 'Tas Siaga Haze',
          body: 'Daftar perlengkapan seperti masker N95 dan checklist langkah '
              'harian. Centang yang sudah siap, tambah item sendiri, lalu '
              'ketuk Simpan Progress.',
          scrollAlignment: 0.3,
        ),
        CoachStep(
          target: _tk[3],
          title: 'Rencana Darurat',
          body: 'Langkah saat kabut asap terjadi, dan tempat menyimpan '
              'kontak darurat keluarga.',
          scrollAlignment: 0.4,
        ),
      ];

  String _narration() {
    final r = ReadinessState.instance;
    return 'Ini seluruh isi TEDUH READY. Tingkat kesiapanmu saat ini '
        '${r.overallPercent} persen, dihitung dari item tas dan langkah harian '
        'di Tas Siaga Haze. Ada dua menu. Pertama, Tas Siaga Haze, berisi '
        'daftar perlengkapan seperti masker N95, sudah ${r.packDone} dari '
        '${r.packTotal} item tercentang, ditambah checklist langkah harian, '
        '${r.stepsDone} dari ${r.stepsTotal} selesai, serta tombol Simpan '
        'Progress. Kedua, Rencana Darurat, berisi langkah saat kabut asap '
        'terjadi dan tempat menyimpan kontak darurat keluarga. Kamu bisa '
        'berkata buka Tas Siaga, buka Rencana Darurat, atau tambah item '
        'senter untuk menambah perlengkapan. ';
  }

  Widget _r(double b, double e, Widget child) =>
      Reveal(animation: _anim, begin: b, end: e, child: child);

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return VoiceScope(
      screen: 'ready',
      tour: _tour,
      guide: PageGuide(
        content: _narration,
        nextScreen: 'profile',
        nextLabel: 'Preferensi Profil',
        nextHint: 'berisi data dirimu, riwayat, dan pengaturan seperti '
            'notifikasi, privasi, dan aksesibilitas.',
      ),
      child: Scaffold(
      key: _scaffoldKey,
      drawerScrimColor: const Color(0x6B1A2622),
      drawer: const TeduhDrawer(current: HomeMenuItem.ready),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F4EA), Color(0xFFF2F9F4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: ListenableBuilder(
              listenable: ReadinessState.instance,
              builder: (context, _) {
                final percent = ReadinessState.instance.overallPercent;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _r(0.0, 0.3, KeyedSubtree(key: _tk[0], child: _topBar())),
                    const SizedBox(height: 26),
                    _r(0.08, 0.5, KeyedSubtree(key: _tk[1], child: _hero(percent))),
                    const SizedBox(height: 22),
                    _r(
                      0.2,
                      0.6,
                      Text(
                        'Mulai Persiapanmu',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: RC.dark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _r(
                      0.28,
                      0.7,
                      KeyedSubtree(
                        key: _tk[2],
                        child: _menuCard(
                        Icons.backpack_outlined,
                        'Tas Siaga Haze',
                        'Daftar perlengkapan penting yang perlu kamu siapkan.',
                        () => _open(const TasSiagaPage()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _r(
                      0.36,
                      0.78,
                      KeyedSubtree(
                        key: _tk[3],
                        child: _menuCard(
                        Icons.assignment_outlined,
                        'Rencana Darurat',
                        'Panduan tindakan saat kabut asap terjadi di sekitarmu.',
                        () => _open(const RencanaDaruratPage()),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _topBar() {
    return TeduhHeader(
      accent: 'READY',
      subtitle: 'Kenali langkah perlindungan diri',
      onMenu: () => _scaffoldKey.currentState?.openDrawer(),
    );
  }

  Widget _hero(int percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: RC.tile,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 15, color: RC.green),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'KESIAPSIAGAAN KABUT ASAP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: RC.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 112,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: RC.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Kesiapan',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: RC.dark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$percent%',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: RC.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          Container(height: 5, color: const Color(0xFFDDEBE0)),
                          FractionallySizedBox(
                            widthFactor: (percent / 100).clamp(0.0, 1.0),
                            child: Container(height: 5, color: RC.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 24,
                height: 1.22,
                fontWeight: FontWeight.w800,
                color: RC.dark,
              ),
              children: const [
                TextSpan(text: 'Siapkan Dirimu\nMenghadapi '),
                TextSpan(
                    text: 'Kabut Asap', style: TextStyle(color: RC.green)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Persiapkan perlengkapan dan rencana darurat agar kamu lebih siap '
            'menghadapi kondisi kualitas udara yang buruk.',
            style:
                GoogleFonts.poppins(fontSize: 12, height: 1.6, color: RC.grey),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
      IconData icon, String title, String desc, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: RC.tile,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 25, color: RC.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: RC.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: GoogleFonts.poppins(
                          fontSize: 11.5, height: 1.45, color: RC.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 24, color: RC.green),
            ],
          ),
        ),
      ),
    );
  }
}
