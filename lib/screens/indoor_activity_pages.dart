import '../widgets/teduh_drawer.dart';
import '../state/app_settings.dart';
import '../services/voice_service.dart';
import 'package:flutter/services.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';
import 'reward_popup.dart';

class IndoorDetailStep {
  final String title;
  final String desc;
  final int minutes;
  const IndoorDetailStep(this.title, this.desc, this.minutes);
}

class IndoorSessionStep {
  final String title;
  final String desc;

  final String? coach;
  const IndoorSessionStep(this.title, this.desc, {this.coach});
}

class IndoorActivity {
  final String title;
  final String desc;
  final IconData icon;
  final String photoAsset;
  final String illustrationAsset;
  final String duration;
  final String level;
  final List<String> benefits;
  final List<String> before;
  final List<IndoorDetailStep> detailSteps;
  final String detailNote;
  final String sessionSubtitle;
  final int stepSeconds;
  final String tagline;
  final String sessionIntro;
  final List<IndoorSessionStep> sessionSteps;
  final String safety;

  const IndoorActivity({
    required this.title,
    required this.desc,
    required this.icon,
    required this.photoAsset,
    required this.illustrationAsset,
    required this.duration,
    required this.level,
    required this.benefits,
    required this.before,
    required this.detailSteps,
    required this.detailNote,
    required this.sessionSubtitle,
    required this.stepSeconds,
    required this.tagline,
    required this.sessionIntro,
    required this.sessionSteps,
    required this.safety,
  });
}

const String _kStopLine = 'Berhenti bila terasa nyeri, pusing, atau sesak. '
    'Jangan memaksakan gerakan.';

const List<IndoorActivity> kIndoorActivities = [
  IndoorActivity(
    title: 'Yoga Ringan',
    desc: 'Gerakan lembut untuk meningkatkan fleksibilitas, mengurangi stres, '
        'dan memulihkan tubuh setelah aktivitas.',
    icon: Icons.self_improvement_rounded,
    photoAsset: 'assets/images/activities/yoga.jpg',
    illustrationAsset: 'assets/images/activities/session_yoga.png',
    duration: '20 menit',
    level: 'Ringan',
    benefits: [
      'Membantu tubuh terasa lebih lentur.',
      'Memberi ruang untuk melepas ketegangan.',
      'Melatih kesadaran gerak dan napas.',
    ],
    before: [
      'Siapkan matras di lantai yang rata dan tidak licin.',
      'Gunakan pakaian yang leluasa untuk bergerak.',
      'Pilih ruang tenang dengan sirkulasi udara baik.',
    ],
    detailSteps: [
      IndoorDetailStep('Temukan posisi nyaman',
          'Duduk tegak dengan bahu rileks. Bernapas alami sambil merasakan tumpuan tubuh di matras.', 3),
      IndoorDetailStep('Lenturkan tubuh perlahan',
          'Putar bahu, miringkan badan bergantian, lalu lakukan gerak kucing–sapi dengan jangkauan yang nyaman.', 5),
      IndoorDetailStep('Alirkan gerakan lembut',
          'Bergantian antara posisi meja, duduk di tumit, dan berdiri tegak. Gunakan bantal bila perlu; hindari menekan sendi.', 8),
      IndoorDetailStep('Akhiri dengan rileks',
          'Berbaring atau duduk dengan penyangga. Lemaskan bahu dan kaki, lalu kembali bergerak secara perlahan.', 4),
    ],
    detailNote: 'Tidak perlu mencapai pose tertentu. Kurangi jangkauan atau '
        'berhenti bila terasa nyeri atau pusing.',
    sessionSubtitle: '3 menit · 4 gerakan · Intensitas ringan',
    stepSeconds: 45,
    tagline: 'Tenang, tanpa terburu-buru.',
    sessionIntro: 'Siapkan matras di area tenang. Lakukan setiap gerakan '
        'selama 45 detik, tanpa memaksakan rentang tubuh.',
    sessionSteps: [
      IndoorSessionStep('Duduk memanjang',
          'Duduk bersila atau luruskan kaki bila lebih nyaman. Letakkan tangan di lutut, panjangkan punggung, dan bernapas alami.',
          coach: 'Duduk bersila dengan nyaman. Panjangkan punggung dan '
              'biarkan bahu rileks.'),
      IndoorSessionStep('Condong ke samping',
          'Letakkan satu tangan di matras. Angkat lengan lain dan condong sedikit ke samping. Kembali ke tengah, lalu bergantian sisi perlahan.'),
      IndoorSessionStep('Putar dada lembut',
          'Letakkan tangan di paha. Putar dada sedikit ke kanan tanpa menarik lutut, kembali ke tengah, lalu ke kiri. Pinggul tetap menapak.'),
      IndoorSessionStep('Buka dada duduk',
          'Letakkan tangan di sisi pinggul. Arahkan dada sedikit ke depan dan turunkan bahu. Kembali netral, lalu ulangi perlahan tanpa mendongak.'),
    ],
    safety: 'Pastikan matras tidak bergeser, lantai tidak licin, dan ruang '
        'bebas hambatan. Gunakan alas duduk tipis bila perlu. Pilih rentang '
        'gerak sesuai kemampuan; hindari tarikan atau putaran dalam.',
  ),

  IndoorActivity(
    title: 'Peregangan',
    desc: 'Melepaskan ketegangan otot dan meningkatkan kelenturan tubuh '
        'sebelum atau setelah aktivitas utama.',
    icon: Icons.accessibility_new_rounded,
    photoAsset: 'assets/images/activities/peregangan.jpg',
    illustrationAsset: 'assets/images/activities/session_peregangan.png',
    duration: '10 menit',
    level: 'Ringan',
    benefits: [
      'Mengurangi rasa kaku setelah lama duduk.',
      'Membantu gerak sendi terasa lebih leluasa.',
      'Memberi jeda aktif di sela rutinitas.',
    ],
    before: [
      'Sediakan ruang untuk merentangkan kedua lengan.',
      'Letakkan kursi kokoh di dekatmu sebagai tumpuan.',
      'Awali dengan gerakan kecil, tanpa memantul.',
    ],
    detailSteps: [
      IndoorDetailStep('Hangatkan tubuh',
          'Jalan di tempat dengan santai. Ayunkan lengan kecil-kecil dan biarkan bahu tetap rileks.', 2),
      IndoorDetailStep('Regangkan tubuh atas',
          'Putar bahu perlahan, rentangkan lengan, lalu miringkan badan ke kanan dan kiri tanpa memaksa.', 3),
      IndoorDetailStep('Lenturkan kaki',
          'Dengan bantuan kursi, regangkan betis dan paha bergantian. Beri sedikit tekukan pada lutut.', 3),
      IndoorDetailStep('Kembali rileks',
          'Longgarkan tangan dan kaki. Berdiri atau duduk nyaman sambil bernapas seperti biasa.', 2),
    ],
    detailNote: 'Rasa tertarik ringan cukup; peregangan tidak seharusnya '
        'terasa sakit. Hentikan gerakan bila tidak nyaman.',
    sessionSubtitle: '2 menit · 4 gerakan · Intensitas ringan',
    stepSeconds: 30,
    tagline: 'Lembut, bukan dipaksakan.',
    sessionIntro: 'Beri ruang untuk kedua lengan. Berdiri dengan lutut rileks '
        'dan lakukan tiap gerakan selama 30 detik.',
    sessionSteps: [
      IndoorSessionStep('Putar bahu perlahan',
          'Berdiri dengan kaki selebar pinggul. Angkat bahu sedikit, putar ke belakang, lalu turunkan. Ulangi putaran kecil tanpa mengencangkan leher.',
          coach: 'Berdiri stabil, kaki selebar pinggul. Putar kedua bahu ke '
              'belakang dengan lembut.'),
      IndoorSessionStep('Rentangkan punggung atas',
          'Satukan kedua tangan di depan dada. Dorong telapak perlahan ke depan dan lebarkan punggung atas. Lepaskan, lalu ulangi tanpa membungkuk dalam.'),
      IndoorSessionStep('Buka lengan dan dada',
          'Tekuk siku di samping tubuh. Buka lengan sedikit ke luar sambil merapatkan tulang belikat dengan lembut. Bahu tetap turun, lalu kembali rileks.'),
      IndoorSessionStep('Jangkau samping bergantian',
          'Geser satu tangan di sisi paha sambil memiringkan tubuh sedikit. Kembali tegak, lalu ganti sisi. Kedua kaki tetap menapak dan pinggul stabil.'),
    ],
    safety: 'Gunakan lantai tidak licin dan ruang bebas hambatan. Kursi stabil '
        'boleh menjadi pegangan ringan. Sesuaikan jangkauan dengan '
        'kemampuan, jangan memantul atau menarik bahu terlalu jauh.',
  ),

  IndoorActivity(
    title: 'Latihan Pernapasan',
    desc: 'Latihan napas yang membantu menenangkan pikiran, mengurangi stres, '
        'dan meningkatkan kualitas istirahat.',
    icon: Icons.spa_rounded,
    photoAsset: 'assets/images/activities/pernapasan.jpg',
    illustrationAsset: 'assets/images/activities/session_pernapasan.png',
    duration: '10 menit',
    level: 'Ringan',
    benefits: [
      'Membantu perhatian kembali ke saat ini.',
      'Memberi jeda tenang dari kesibukan.',
      'Mendukung tubuh terasa lebih rileks.',
    ],
    before: [
      'Duduk di kursi atau alas dengan punggung nyaman.',
      'Longgarkan pakaian yang terasa terlalu ketat.',
      'Pilih tempat tenang dengan udara yang nyaman.',
    ],
    detailSteps: [
      IndoorDetailStep('Atur posisi duduk',
          'Letakkan kaki pada tumpuan dan tangan di paha. Turunkan bahu; mata boleh terbuka atau terpejam.', 2),
      IndoorDetailStep('Amati napas alami',
          'Rasakan udara masuk dan keluar tanpa mengubahnya. Perhatikan gerakan dada atau perut dengan lembut.', 2),
      IndoorDetailStep('Bernapas lebih tenang',
          'Tarik napas pelan, lalu embuskan dengan nyaman. Biarkan napas mengalir tanpa menahan atau memaksakan panjangnya.', 4),
      IndoorDetailStep('Kembali ke sekitar',
          'Biarkan napas kembali alami. Gerakkan jari, lihat sekeliling, lalu bangkit perlahan saat sudah siap.', 2),
    ],
    detailNote: 'Jika terasa pusing atau sesak, hentikan latihan dan kembali '
        'bernapas alami. Jangan memaksakan tarikan napas dalam.',
    sessionSubtitle: '4 menit · 4 gerakan · Intensitas ringan',
    stepSeconds: 60,
    tagline: 'Napas mengalir, tanpa ditahan.',
    sessionIntro: 'Pilih kursi stabil dan duduk nyaman. Ikuti setiap tahap '
        'selama 1 menit; tidak perlu menahan napas.',
    sessionSteps: [
      IndoorSessionStep('Temukan posisi nyaman',
          'Duduk dengan kaki menapak dan punggung nyaman. Letakkan satu tangan di perut. Amati napas alami tanpa mengubahnya terlebih dahulu.',
          coach: 'Duduk di kursi, telapak kaki menapak. Letakkan satu tangan '
              'di perut, rilekskan bahu.'),
      IndoorSessionStep('Tarik napas lembut',
          'Tarik napas perlahan lewat hidung sekitar 3 hitungan jika nyaman. Hembuskan secara alami. Ulangi tanpa menarik napas terlalu dalam atau menahannya.'),
      IndoorSessionStep('Hembuskan perlahan',
          'Tarik napas dengan nyaman, lalu hembuskan lembut sekitar 4 hitungan. Langsung lanjut ke napas berikutnya, tanpa jeda menahan napas.'),
      IndoorSessionStep('Kembali ke ritme alami',
          'Lepaskan hitungan. Biarkan napas mengalir dengan ritme sendiri, rilekskan tangan, dan rasakan kaki menapak. Buka pandangan perlahan bila mata terpejam.'),
    ],
    safety: 'Letakkan kursi di lantai tidak licin dan ruang bebas hambatan. '
        'Sesuaikan hitungan dengan kemampuan; kembali ke napas alami bila '
        'terasa tidak nyaman. Jangan menahan atau memaksa napas dalam.',
  ),

  IndoorActivity(
    title: 'Aktivitas Indoor',
    desc: 'Pilihan aman untuk hari berkualitas udara tidak sehat, tetap '
        'menjaga tubuh aktif tanpa paparan polusi luar.',
    icon: Icons.fitness_center_rounded,
    photoAsset: 'assets/images/activities/indoor.jpg',
    illustrationAsset: 'assets/images/activities/session_indoor.png',
    duration: '15 menit',
    level: 'Ringan',
    benefits: [
      'Menambah gerak ringan tanpa keluar rumah.',
      'Mengaktifkan kaki dan bahu setelah duduk.',
      'Membantu menjaga rutinitas tetap aktif.',
    ],
    before: [
      'Rapikan lantai dari kabel dan benda kecil.',
      'Siapkan kursi kokoh tanpa roda untuk tumpuan.',
      'Pilih ruangan nyaman dan jauh dari asap.',
    ],
    detailSteps: [
      IndoorDetailStep('Mulai dari langkah kecil',
          'Jalan di tempat perlahan, lalu putar bahu. Jaga langkah rendah dan pijakan tetap lembut.', 3),
      IndoorDetailStep('Melangkah ke samping',
          'Lakukan langkah kanan–kiri bergantian sambil mengayun lengan. Berpegangan pada kursi bila perlu.', 5),
      IndoorDetailStep('Gerakkan kaki dan lengan',
          'Bergantian mengangkat tumit dan menekuk siku. Sisipkan jalan di tempat; semua gerakan tanpa lompatan.', 5),
      IndoorDetailStep('Turunkan ritme',
          'Perkecil langkah sampai berhenti. Duduk bila perlu dan rilekskan bahu sambil bernapas alami.', 2),
    ],
    detailNote: 'Jaga gerakan tetap ringan sehingga masih nyaman berbicara. '
        'Ambil jeda atau berhenti bila lelah atau tidak nyaman.',
    sessionSubtitle: '3 menit · 4 gerakan · Intensitas ringan',
    stepSeconds: 45,
    tagline: 'Langkah kecil, ritme nyaman.',
    sessionIntro: 'Kosongkan area sekitar. Kursi stabil boleh dipakai sebagai '
        'pegangan. Lakukan tiap langkah selama 45 detik.',
    sessionSteps: [
      IndoorSessionStep('Jalan kecil di tempat',
          'Berdiri tegak lalu angkat kaki rendah bergantian. Satu kaki selalu menapak. Pegang sandaran kursi stabil bila perlu, tanpa menarik kursinya.',
          coach: 'Angkat kaki rendah secara bergantian. Tetap tegak, dengan '
              'satu kaki selalu menapak.'),
      IndoorSessionStep('Sentuh kaki ke samping',
          'Sentuhkan ujung kaki kanan sedikit ke samping, lalu kembali. Ganti kaki kiri. Jaga tubuh tetap di tengah dan buat langkah kecil tanpa lompatan.'),
      IndoorSessionStep('Jalan dengan ayunan lengan',
          'Lanjutkan jalan kecil sambil mengayun lengan rendah dan santai. Bila memakai kursi, ayunkan hanya lengan yang bebas. Jaga langkah tetap pelan.'),
      IndoorSessionStep('Perlambat langkah',
          'Kecilkan angkatan kaki dan turunkan ritme secara bertahap. Rilekskan bahu, bernapas alami, lalu akhiri dengan kedua kaki menapak stabil.'),
    ],
    safety: 'Pastikan lantai tidak licin dan ruang bebas karpet lepas atau '
        'hambatan. Gunakan kursi kokoh tanpa roda bila perlu. Sesuaikan '
        'kecepatan dan tinggi langkah dengan kemampuan; tidak perlu melompat.',
  ),
];

void openIndoorActivityDetail(BuildContext context, String title) {
  final matches = kIndoorActivities.where((a) => a.title == title);
  if (matches.isEmpty) {
    showSoon(context, title);
    return;
  }
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => IndoorActivityDetailPage(activity: matches.first),
  ));
}

const _iBg = Color(0xFFFFFAF4);
const _iOrange = Color(0xFFDB6A2C);
const _iTile = Color(0xFFFAE7D8);
const _iDark = Color(0xFF22392E);
const _iGrey = Color(0xFF7B8A80);
const _iBorder = Color(0xFFE9E4DA);

String _fmtDur(int seconds) {
  if (seconds >= 60 && seconds % 60 == 0) return '${seconds ~/ 60} menit';
  return '$seconds detik';
}

class IndoorActivityDetailPage extends StatefulWidget {
  final IndoorActivity activity;
  const IndoorActivityDetailPage({super.key, required this.activity});

  @override
  State<IndoorActivityDetailPage> createState() =>
      _IndoorActivityDetailPageState();
}

class _IndoorActivityDetailPageState extends State<IndoorActivityDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AnimationBehavior.preserve,
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _r(double b, double e, Widget child) =>
      Reveal(animation: _anim, begin: b, end: e, child: child);

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'act_detail_in',
        tour: const [
          CoachStep(title: 'Tentang aktivitas', body: 'Nama aktivitas, durasi, dan tingkat intensitasnya ada di bagian atas, beserta penjelasan singkat tujuannya.'),
          CoachStep(title: 'Manfaat', body: 'Tiga manfaat yang kamu dapat setelah melakukan aktivitas ini.'),
          CoachStep(title: 'Persiapan', body: 'Hal yang perlu disiapkan sebelum mulai, misalnya tempat, pakaian, air minum, dan kondisi udara.'),
          CoachStep(title: 'Gerakan dan langkah', body: 'Urutan gerakan yang akan dipandu satu per satu, lengkap dengan cara melakukannya.'),
          CoachStep(title: 'Catatan keselamatan', body: 'Berhentilah bila terasa nyeri, pusing, atau sesak, dan jangan memaksakan gerakan.'),
          CoachStep(title: 'Mulai aktivitas', body: 'Ketuk tombol mulai di bagian bawah untuk memulai sesi aktivitas.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman detail aktivitas dalam ruangan. Berisi durasi dan intensitas, manfaat, persiapan, urutan gerakan, catatan keselamatan, dan tombol untuk memulai. Katakan mulai untuk memulai, atau kembali.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final a = widget.activity;
    return Scaffold(
      backgroundColor: _iBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: _r(0.0, 0.35, _header()),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _r(0.05, 0.45, _hero(a)),
                    const SizedBox(height: 18),
                    _r(
                      0.12,
                      0.5,
                      Text(
                        a.title,
                        style: GoogleFonts.poppins(
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          color: _iDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _r(
                      0.16,
                      0.55,
                      Text(
                        a.desc,
                        style: GoogleFonts.poppins(
                            fontSize: 13, height: 1.6, color: _iGrey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _r(
                      0.2,
                      0.6,
                      Row(
                        children: [
                          Expanded(
                              child: _infoTile(
                                  Icons.schedule_rounded, 'Durasi', a.duration)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _infoTile(Icons.monitor_heart_outlined,
                                  'Intensitas', a.level)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _r(0.28, 0.68, _sectionTitle('Manfaat untukmu')),
                    const SizedBox(height: 10),
                    _r(
                      0.3,
                      0.7,
                      Column(
                        children: [
                          for (final b in a.benefits)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded,
                                      size: 20, color: _iOrange),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13, color: _iDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _r(0.4, 0.8, _beforeCard(a)),
                    const SizedBox(height: 22),
                    _r(
                      0.48,
                      0.88,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Langkah demi langkah'),
                          const SizedBox(height: 2),
                          Text(
                            'Ikuti ritmemu, nikmati setiap gerakan.',
                            style: GoogleFonts.poppins(
                                fontSize: 11.5, color: _iGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < a.detailSteps.length; i++)
                      _r(0.52 + i * 0.07, 0.92 + i * 0.02,
                          _stepRow(i, a.detailSteps[i])),
                    const SizedBox(height: 8),
                    _r(0.8, 1.0, _noteCard(a.detailNote)),
                  ],
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap, {Color? color}) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: color ?? _iDark),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        _circle(Icons.arrow_back_rounded, () => Navigator.maybePop(context)),
        Expanded(
          child: Column(
            children: [
              Text(
                'TEDUH ACTION',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: _iDark,
                ),
              ),
              Text(
                'Detail aktivitas',
                style: GoogleFonts.poppins(fontSize: 11, color: _iGrey),
              ),
            ],
          ),
        ),
        _circle(
          _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          () => setState(() => _saved = !_saved),
          color: _saved ? _iOrange : null,
        ),
      ],
    );
  }

  Widget _hero(IndoorActivity a) {
    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.asset(
              a.photoAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF6C9A6), Color(0xFFE59A68)],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(a.icon, size: 84, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Indoor',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _iOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _iTile,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: _iOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(fontSize: 11, color: _iGrey)),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _iDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: _iDark,
        ),
      );

  Widget _beforeCard(IndoorActivity a) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _iBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_outlined,
                  size: 22, color: _iOrange),
              const SizedBox(width: 10),
              Text(
                'Sebelum mulai',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _iDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final b in a.before)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 4),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                          color: _iOrange, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      b,
                      style: GoogleFonts.poppins(
                          fontSize: 12.5, height: 1.5, color: _iDark),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepRow(int i, IndoorDetailStep s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: _iTile, shape: BoxShape.circle),
            child: Text(
              (i + 1).toString().padLeft(2, '0'),
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _iOrange,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _iDark,
                        ),
                      ),
                    ),
                    Text(
                      '${s.minutes} menit',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _iOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  s.desc,
                  style: GoogleFonts.poppins(
                      fontSize: 12, height: 1.55, color: _iGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _iTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite_border_rounded, size: 20, color: _iOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                  fontSize: 12, height: 1.55, color: _iDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: _iBg,
        border: Border(top: BorderSide(color: _iBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _iOrange,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _iOrange.withValues(alpha: 0.4),
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    IndoorActivitySessionPage(activity: widget.activity),
              )),
              icon: const Icon(Icons.play_arrow_outlined, size: 24),
              label: Text(
                'Mulai Aktivitas',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bergerak nyaman, tanpa terburu-buru.',
            style: GoogleFonts.poppins(fontSize: 11, color: _iGrey),
          ),
        ],
      ),
    );
  }
}

class IndoorActivitySessionPage extends StatefulWidget {
  final IndoorActivity activity;
  const IndoorActivitySessionPage({super.key, required this.activity});

  @override
  State<IndoorActivitySessionPage> createState() =>
      _IndoorActivitySessionPageState();
}

class _IndoorActivitySessionPageState extends State<IndoorActivitySessionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Timer? _timer;
  final ScrollController _scroll = ScrollController();
  int _step = 0;
  late int _remaining;
  bool _paused = false;

  List<IndoorSessionStep> get _steps => widget.activity.sessionSteps;
  int get _total => widget.activity.stepSeconds;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AnimationBehavior.preserve,
    )..forward();
    _remaining = _total;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _tick() {
    if (_paused || !mounted) return;
    if (_remaining > 0) {
      setState(() => _remaining--);
    } else {
      _next();
    }
  }

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() {
        _step++;
        _remaining = _total;
      });
      _announceStep();
    } else {
      _finish();
    }
  }

  void _announceStep() {
    HapticFeedback.mediumImpact();
    if (_scroll.hasClients) {
      _scroll.animateTo(0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic);
    }
    final cur = _steps[_step];
    final msg = 'Gerakan ${_step + 1} dari ${_steps.length}: ${cur.title}';
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ));
    }
    if (AppSettings.instance.effectiveAutoRead) {
      VoiceService.instance.speak('$msg. ${cur.coach ?? cur.desc}');
    }
  }

  Future<void> _finish() async {
    _timer?.cancel();
    if (!mounted) return;
    final nav = Navigator.of(context);
    final home = await showActivityReward(context, indoor: true);
    if (home == true) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => TeduhNav.pageFor(HomeMenuItem.action)),
        (r) => r.isFirst,
      );
    } else {
      nav.pop();
      nav.pop();
    }
  }

  Widget _r(double b, double e, Widget child) =>
      Reveal(animation: _anim, begin: b, end: e, child: child);

  String _mmss(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  String get _hint {
    if (_paused) return 'Dijeda';
    if (_step == 0) return 'Mulai dengan perlahan';
    if (_step == _steps.length - 1) return 'Hampir selesai';
    return 'Tetap tenang';
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EE),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _r(0.0, 0.3, _topBar()),
              const SizedBox(height: 14),
              _r(0.05, 0.4, _title(a)),
              const SizedBox(height: 14),
              _r(0.1, 0.45, _progress()),
              const SizedBox(height: 14),
              _r(0.15, 0.55, _heroCard(a)),
              const SizedBox(height: 14),
              _r(0.25, 0.65, _timerCard(a)),
              const SizedBox(height: 14),
              _r(0.33, 0.73, _controls()),
              const SizedBox(height: 4),
              _r(
                0.37,
                0.77,
                Center(
                  child: TextButton.icon(
                    onPressed: _finish,
                    icon: const Icon(Icons.check_rounded,
                        size: 18, color: _iGrey),
                    label: Text(
                      'Selesai',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _iGrey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _r(
                0.45,
                0.85,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah demi langkah',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _iDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.sessionIntro,
                      style: GoogleFonts.poppins(
                          fontSize: 12, height: 1.55, color: _iGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (int i = 0; i < _steps.length; i++)
                _r(0.5 + i * 0.07, 0.9 + i * 0.025, _stepCard(i)),
              const SizedBox(height: 6),
              _r(0.8, 1.0, _safety(a)),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Bergerak pelan. Beri ruang untuk dirimu.',
                  style: GoogleFonts.poppins(fontSize: 11, color: _iGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        const Icon(Icons.eco_outlined, size: 20, color: _iOrange),
        const SizedBox(width: 8),
        Text(
          'TEDUH ACTION',
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: _iDark,
          ),
        ),
        const Spacer(),
        Text(
          'SESI INDOOR',
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: const Color(0xFF6F8A74),
          ),
        ),
      ],
    );
  }

  Widget _title(IndoorActivity a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          a.title,
          style: GoogleFonts.poppins(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: _iDark,
          ),
        ),
        Text(
          a.sessionSubtitle,
          style: GoogleFonts.poppins(fontSize: 11.5, color: _iGrey),
        ),
      ],
    );
  }

  Widget _progress() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Gerakan ${_step + 1}/${_steps.length}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _iDark,
              ),
            ),
            const Spacer(),
            Text(
              _hint,
              style: GoogleFonts.poppins(fontSize: 11.5, color: _iGrey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < _steps.length; i++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        i <= _step ? _iOrange : const Color(0xFFE2E6DD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (i != _steps.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }

  Widget _heroCard(IndoorActivity a) {
    final cur = _steps[_step];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 195,
            width: double.infinity,
            color: const Color(0xFFE6EBDD),
            alignment: Alignment.center,
            child: Image.asset(
              a.illustrationAsset,
              height: 195,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                    color: Color(0xFFD3DCC8), shape: BoxShape.circle),
                child: Icon(a.icon, size: 60, color: _iOrange),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cur.title,
                  style: GoogleFonts.poppins(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: _iDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cur.coach ?? cur.desc,
                  style: GoogleFonts.poppins(
                      fontSize: 12.5, height: 1.55, color: _iGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerCard(IndoorActivity a) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _IndoorRingPainter(_remaining / _total),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _mmss(_remaining),
                      style: GoogleFonts.poppins(
                        fontSize: 29,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: _iDark,
                      ),
                    ),
                    Text('Gerakan ${_step + 1}/${_steps.length}',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: _iGrey)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _iTile,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _paused ? 'Dijeda' : 'Sedang berjalan',
                    style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: _iOrange),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  a.tagline,
                  style: GoogleFonts.poppins(
                    fontSize: 15.5,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: _iDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_fmtDur(_total)} per gerakan',
                  style: GoogleFonts.poppins(fontSize: 11, color: _iGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controls() {
    Widget btn(String label, IconData icon, bool enabled, VoidCallback tap) {
      return Expanded(
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? _iOrange : Colors.white,
              foregroundColor: enabled ? Colors.white : _iDark,
              disabledBackgroundColor: Colors.white,
              disabledForegroundColor: _iDark,
              elevation: 0,
              side: enabled ? null : const BorderSide(color: _iBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: enabled ? tap : null,
            icon: Icon(icon, size: 20),
            label: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn('Jeda', Icons.pause_rounded, !_paused,
            () => setState(() => _paused = true)),
        const SizedBox(width: 12),
        btn('Lanjutkan', Icons.play_arrow_outlined, _paused,
            () => setState(() => _paused = false)),
      ],
    );
  }

  Widget _stepCard(int i) {
    final s = _steps[i];
    final active = i == _step;
    final done = i < _step;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: done ? const Color(0xFFFBFAF6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _iOrange : _iBorder,
            width: active ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (active)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'GERAKAN AKTIF',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: const Color(0xFF5E8A6B),
                            ),
                          ),
                        ),
                      Text(
                        s.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _iDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EEE4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: Color(0xFF4F6B58)),
                      const SizedBox(width: 4),
                      Text(
                        _fmtDur(_total),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4F6B58),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              s.desc,
              style: GoogleFonts.poppins(
                  fontSize: 12.5, height: 1.6, color: _iGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _safety(IndoorActivity a) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5ECDF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 20, color: Color(0xFF3E6B4F)),
              const SizedBox(width: 10),
              Text(
                'Utamakan rasa nyaman',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _iDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            a.safety,
            style: GoogleFonts.poppins(
                fontSize: 12, height: 1.6, color: const Color(0xFF5A6B60)),
          ),
          const SizedBox(height: 10),
          Text(
            _kStopLine,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.6,
              fontWeight: FontWeight.w700,
              color: _iDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndoorRingPainter extends CustomPainter {
  final double fraction;
  _IndoorRingPainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xFFF6E3D5),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = _iOrange,
    );
  }

  @override
  bool shouldRepaint(covariant _IndoorRingPainter old) =>
      old.fraction != fraction;
}
