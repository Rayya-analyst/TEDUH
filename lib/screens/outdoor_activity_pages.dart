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

class OutdoorDetailStep {
  final String title;
  final String desc;
  final int minutes;
  const OutdoorDetailStep(this.title, this.desc, this.minutes);
}

class OutdoorSessionStep {
  final String title;
  final String desc;
  final int minutes;

  final String? coach;
  const OutdoorSessionStep(this.title, this.desc, this.minutes, {this.coach});
}

class OutdoorActivity {
  final String title;
  final String desc;
  final IconData icon;
  final String photoAsset;
  final String illustrationAsset;
  final String duration;
  final String level;
  final List<String> benefits;
  final List<String> before;
  final List<OutdoorDetailStep> detailSteps;
  final String detailNote;
  final String sessionSubtitle;
  final List<OutdoorSessionStep> sessionSteps;
  final String safety;

  const OutdoorActivity({
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
    required this.sessionSteps,
    required this.safety,
  });
}

const List<OutdoorActivity> kOutdoorActivities = [
  OutdoorActivity(
    title: 'Jalan Santai',
    desc: 'Mulai hari dengan langkah santai untuk meningkatkan sirkulasi darah '
        'dan membangkitkan energi tubuh.',
    icon: Icons.directions_walk_rounded,
    photoAsset: 'assets/images/activities/jalan_santai.jpg',
    illustrationAsset: 'assets/images/activities/session_jalan_santai.png',
    duration: '15 menit',
    level: 'Ringan',
    benefits: [
      'Menambah langkah dengan ritme nyaman.',
      'Memberi jeda segar dari rutinitas.',
      'Membantu tubuh terasa lebih bertenaga.',
    ],
    before: [
      'Cek cuaca dan kualitas udara sebelum keluar.',
      'Pakai alas kaki nyaman dengan sol tidak licin.',
      'Pilih rute datar yang aman dan bawa air minum.',
    ],
    detailSteps: [
      OutdoorDetailStep('Awali perlahan',
          'Mulai dengan langkah pendek. Tegakkan badan secara alami dan biarkan lengan mengayun santai.', 3),
      OutdoorDetailStep('Temukan ritmemu',
          'Berjalan dengan kecepatan yang masih nyaman untuk mengobrol. Perhatikan pijakan dan lalu lintas.', 5),
      OutdoorDetailStep('Nikmati perjalanan',
          'Pertahankan langkah ringan. Amati lingkungan tanpa kehilangan perhatian pada jalur di depan.', 5),
      OutdoorDetailStep('Perlambat langkah',
          'Turunkan kecepatan secara bertahap. Berhenti di tempat aman dan minum sesuai kebutuhan.', 2),
    ],
    detailNote: 'Bila udara buruk, hujan deras, atau jalur licin, tunda jalan '
        'santai dan pilih aktivitas di dalam ruangan.',
    sessionSubtitle: 'Intensitas ringan · 12 menit · 4 gerakan',
    sessionSteps: [
      OutdoorSessionStep('Jalan perlahan',
          'Mulai dengan langkah pendek agar tubuh beradaptasi.', 2),
      OutdoorSessionStep('Langkah nyaman',
          'Jaga ritme santai; Anda masih bisa berbicara dengan nyaman.', 6,
          coach: 'Melangkah dengan ritme alami. Rilekskan bahu dan jaga '
              'pandangan ke depan.'),
      OutdoorSessionStep('Ayun lengan',
          'Tetap berjalan. Ayunkan lengan alami tanpa mengangkat bahu.', 2),
      OutdoorSessionStep('Perlambat langkah',
          'Kurangi kecepatan bertahap sambil mengatur napas.', 2),
    ],
    safety: 'Pilih jalur rata, tidak licin, dan jauh dari lalu lintas. Gunakan '
        'alas kaki yang nyaman dan cukup minum. Segera berhenti jika pusing, '
        'nyeri, atau sesak.',
  ),

  OutdoorActivity(
    title: 'Jogging',
    desc: 'Tingkatkan denyut jantung dan kekuatan kaki dengan intensitas yang '
        'terukur untuk kesehatan jantung.',
    icon: Icons.directions_run_rounded,
    photoAsset: 'assets/images/activities/jogging.jpg',
    illustrationAsset: 'assets/images/activities/session_jogging.png',
    duration: '20 menit',
    level: 'Sedang',
    benefits: [
      'Melatih daya tahan secara bertahap.',
      'Mengajak otot kaki bergerak lebih aktif.',
      'Membantu menyegarkan suasana hati.',
    ],
    before: [
      'Cek kualitas udara, cuaca, dan kondisi tubuh.',
      'Gunakan sepatu lari yang nyaman dan terikat baik.',
      'Pilih jalur rata; siapkan air dan rute pulang.',
    ],
    detailSteps: [
      OutdoorDetailStep('Pemanasan berjalan',
          'Mulai berjalan santai, lalu sedikit lebih cepat. Gerakkan pergelangan kaki dan bahu dengan lembut.', 4),
      OutdoorDetailStep('Mulai lari kecil',
          'Jogging dengan langkah pendek dan bahu rileks. Selingi jalan kaki kapan pun kamu membutuhkannya.', 6),
      OutdoorDetailStep('Jaga ritme terukur',
          'Lanjutkan lari kecil pada ritme yang masih memungkinkan berbicara dalam kalimat pendek. Hindari mengejar kecepatan.', 6),
      OutdoorDetailStep('Pendinginan berjalan',
          'Beralih ke jalan kaki dan perlambat bertahap. Setelah berhenti, minum sesuai kebutuhan.', 4),
    ],
    detailNote: 'Jangan memaksakan kecepatan. Berhenti bila muncul nyeri, '
        'pusing, atau sesak yang tidak biasa.',
    sessionSubtitle: 'Intensitas sedang · 12 menit · 4 gerakan',
    sessionSteps: [
      OutdoorSessionStep('Jalan pemanasan',
          'Berjalan santai, lalu naikkan ritme secara bertahap.', 3),
      OutdoorSessionStep('Joging ringan',
          'Lari pelan dengan langkah pendek. Masih bisa bicara singkat.', 4,
          coach: 'Ambil langkah pendek dan ringan. Jaga napas tetap nyaman, '
              'tanpa memaksa.'),
      OutdoorSessionStep('Jalan pemulihan',
          'Kembali berjalan agar napas dan detak jantung mereda.', 2),
      OutdoorSessionStep('Jalan pendinginan',
          'Perlambat langkah hingga tubuh terasa lebih rileks.', 3),
    ],
    safety: 'Pakai sepatu lari dan pilih lintasan rata yang tidak ramai. Minum '
        'secukupnya; turunkan ritme saat lelah. Segera berhenti jika pusing, '
        'nyeri dada, atau sesak.',
  ),

  OutdoorActivity(
    title: 'Bersepeda',
    desc: 'Aktivitas kardio yang menyenangkan untuk menguatkan kaki dan '
        'menikmati udara pagi dengan lebih santai.',
    icon: Icons.directions_bike_rounded,
    photoAsset: 'assets/images/activities/bersepeda.jpg',
    illustrationAsset: 'assets/images/activities/session_bersepeda.png',
    duration: '25 menit',
    level: 'Sedang',
    benefits: [
      'Melatih daya tahan dengan kayuhan teratur.',
      'Mengaktifkan otot kaki tanpa berlari.',
      'Memberi kesempatan menikmati lingkungan.',
    ],
    before: [
      'Kenakan helm dan cek rem serta tekanan ban.',
      'Atur sadel agar posisi duduk terasa nyaman.',
      'Cek udara dan cuaca; pilih jalur aman, bawa air.',
    ],
    detailSteps: [
      OutdoorDetailStep('Kayuh dengan ringan',
          'Mulai di jalur datar dengan gigi ringan. Biasakan posisi tangan, bahu, dan pandangan ke depan.', 5),
      OutdoorDetailStep('Bangun ritme kayuhan',
          'Tambah ritme secara perlahan hingga terasa sedang. Jaga jarak dengan pengguna jalan lainnya.', 8),
      OutdoorDetailStep('Pertahankan kenyamanan',
          'Kayuh stabil tanpa mengejar kecepatan. Kurangi ritme di tikungan atau tanjakan; turun dan tuntun bila perlu.', 8),
      OutdoorDetailStep('Akhiri perlahan',
          'Gunakan kayuhan ringan lalu berhenti di tempat aman. Turun dari sepeda dan minum secukupnya.', 4),
    ],
    detailNote: 'Utamakan keselamatan, bukan jarak. Hindari jalan padat atau '
        'licin dan berhenti bila tubuh terasa tidak nyaman.',
    sessionSubtitle: 'Intensitas sedang · 16 menit · 4 gerakan',
    sessionSteps: [
      OutdoorSessionStep('Kayuh pemanasan',
          'Mulai dengan gigi ringan dan kecepatan rendah di jalur rata.', 4),
      OutdoorSessionStep('Kayuh stabil',
          'Jaga kayuhan nyaman, tanpa mengejar kecepatan.', 8,
          coach: 'Kayuh dengan ritme ringan dan stabil. Pandangan ke depan, '
              'kedua tangan di setang.'),
      OutdoorSessionStep('Kayuh santai',
          'Kurangi kecepatan dan tetap perhatikan pengguna jalan.', 2),
      OutdoorSessionStep('Kayuh pendinginan',
          'Kayuh perlahan, lalu berhenti di tempat aman dan datar.', 2),
    ],
    safety: 'Wajib gunakan helm. Cek rem dan ban, pilih jalur aman, serta bawa '
        'air minum. Jangan melihat layar saat bersepeda; berhenti dahulu. '
        'Berhenti jika pusing atau sesak.',
  ),

  OutdoorActivity(
    title: 'Bermain di Taman',
    desc: 'Aktivitas santai di luar ruangan yang membantu meningkatkan mood '
        'dan kualitas tidur dengan gerakan alami.',
    icon: Icons.park_rounded,
    photoAsset: 'assets/images/activities/taman.jpg',
    illustrationAsset: 'assets/images/activities/session_taman.png',
    duration: '30 menit',
    level: 'Ringan',
    benefits: [
      'Menambah gerak melalui permainan ringan.',
      'Memberi waktu untuk menikmati ruang hijau.',
      'Menciptakan momen menyenangkan bersama.',
    ],
    before: [
      'Pilih taman yang aman, teduh, dan tidak licin.',
      'Cek udara dan cuaca; bawa air serta topi.',
      'Siapkan bola ringan bila ingin bermain bersama.',
    ],
    detailSteps: [
      OutdoorDetailStep('Kenali area bermain',
          'Berjalan santai mengelilingi area. Pilih permukaan rata yang jauh dari kendaraan dan benda tajam.', 5),
      OutdoorDetailStep('Mainkan gerak ringan',
          'Coba lempar-tangkap bola pelan bersama teman atau keluarga. Bila sendiri, jalanlah sambil menjelajah taman.', 10),
      OutdoorDetailStep('Eksplorasi dengan santai',
          'Selingi langkah ke samping, meraih lengan, dan permainan sederhana tanpa lompatan. Ambil jeda minum saat perlu.', 10),
      OutdoorDetailStep('Tutup dengan tenang',
          'Perlambat gerakan lalu berjalan ke tempat teduh. Duduk sejenak dan rapikan perlengkapan sebelum pulang.', 5),
    ],
    detailNote: 'Pilih permainan yang terasa nyaman, bukan kompetitif. '
        'Beristirahat di tempat teduh bila mulai kepanasan atau lelah.',
    sessionSubtitle: 'Rekreasi ringan · 8 menit · 4 gerakan',
    sessionSteps: [
      OutdoorSessionStep('Jalan keliling',
          'Berjalan santai di area taman yang rata sambil melihat sekitar.', 2),
      OutdoorSessionStep('Langkah ke samping',
          'Dua langkah ke kanan, lalu ke kiri. Tidak perlu melompat.', 2,
          coach: 'Melangkah ke kanan, rapatkan kaki. Ulangi ke kiri dengan '
              'lutut sedikit lentur.'),
      OutdoorSessionStep('Ayun lengan santai',
          'Berdiri nyaman. Ayun kedua lengan perlahan ke depan-belakang.', 2),
      OutdoorSessionStep('Jalan santai',
          'Akhiri dengan berjalan pelan sambil merilekskan tubuh.', 2),
    ],
    safety: 'Tidak perlu alat khusus. Pilih area rata, tidak licin, dan cukup '
        'lapang; jaga jarak dari orang lain. Minum secukupnya. Berhenti jika '
        'pusing, nyeri, atau sesak.',
  ),
];

void openOutdoorActivityDetail(BuildContext context, String title) {
  final matches = kOutdoorActivities.where((a) => a.title == title);
  if (matches.isEmpty) {
    showSoon(context, title);
    return;
  }
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => OutdoorActivityDetailPage(activity: matches.first),
  ));
}

const _kBg = Color(0xFFF4FAF6);
const _kGreen = Color(0xFF0F7B4F);
const _kGreenDeep = Color(0xFF1E6B50);
const _kTile = Color(0xFFDDF0E5);
const _kGrey = Color(0xFF7C8A82);

class OutdoorActivityDetailPage extends StatefulWidget {
  final OutdoorActivity activity;
  const OutdoorActivityDetailPage({super.key, required this.activity});

  @override
  State<OutdoorActivityDetailPage> createState() =>
      _OutdoorActivityDetailPageState();
}

class _OutdoorActivityDetailPageState extends State<OutdoorActivityDetailPage>
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
        screen: 'act_detail_out',
        tour: const [
          CoachStep(title: 'Tentang aktivitas', body: 'Nama aktivitas, durasi, dan tingkat intensitasnya ada di bagian atas, beserta penjelasan singkat tujuannya.'),
          CoachStep(title: 'Manfaat', body: 'Tiga manfaat yang kamu dapat setelah melakukan aktivitas ini.'),
          CoachStep(title: 'Persiapan', body: 'Hal yang perlu disiapkan sebelum mulai, misalnya tempat, pakaian, air minum, dan kondisi udara.'),
          CoachStep(title: 'Gerakan dan langkah', body: 'Urutan gerakan yang akan dipandu satu per satu, lengkap dengan cara melakukannya.'),
          CoachStep(title: 'Catatan keselamatan', body: 'Berhentilah bila terasa nyeri, pusing, atau sesak, dan jangan memaksakan gerakan.'),
          CoachStep(title: 'Mulai aktivitas', body: 'Ketuk tombol mulai di bagian bawah untuk memulai sesi aktivitas.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman detail aktivitas luar ruangan. Berisi durasi dan intensitas, manfaat, persiapan termasuk cek kualitas udara, urutan gerakan, catatan keselamatan, dan tombol untuk memulai. Katakan kembali untuk memilih aktivitas lain.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final a = widget.activity;
    return Scaffold(
      backgroundColor: _kBg,
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
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _kGreenDeep,
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
                            fontSize: 13, height: 1.6, color: _kGrey),
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
                                      size: 20, color: _kGreen),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13, color: TC.dark),
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
                                fontSize: 11.5, color: _kGrey),
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
          child: Icon(icon, size: 22, color: color ?? TC.dark),
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
                  color: TC.dark,
                ),
              ),
              Text(
                'Detail aktivitas',
                style: GoogleFonts.poppins(fontSize: 11, color: _kGrey),
              ),
            ],
          ),
        ),
        _circle(
          _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          () => setState(() => _saved = !_saved),
          color: _saved ? _kGreen : null,
        ),
      ],
    );
  }

  Widget _hero(OutdoorActivity a) {
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
                    colors: [Color(0xFFBFE3CC), Color(0xFF7FC39B)],
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
                'Outdoor',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kGreenDeep,
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
        color: _kTile,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: _kGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(fontSize: 11, color: _kGrey)),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: TC.dark,
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
          color: TC.dark,
        ),
      );

  Widget _beforeCard(OutdoorActivity a) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_outlined,
                  size: 22, color: _kGreen),
              const SizedBox(width: 10),
              Text(
                'Sebelum mulai',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TC.dark,
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
                          color: _kGreen, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      b,
                      style: GoogleFonts.poppins(
                          fontSize: 12.5, height: 1.5, color: TC.dark),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepRow(int i, OutdoorDetailStep s) {
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
                const BoxDecoration(color: _kTile, shape: BoxShape.circle),
            child: Text(
              (i + 1).toString().padLeft(2, '0'),
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _kGreenDeep,
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
                          color: TC.dark,
                        ),
                      ),
                    ),
                    Text(
                      '${s.minutes} menit',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _kGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  s.desc,
                  style: GoogleFonts.poppins(
                      fontSize: 12, height: 1.55, color: _kGrey),
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
        color: _kTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite_border_rounded, size: 20, color: _kGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                  fontSize: 12, height: 1.55, color: TC.dark),
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
        color: _kBg,
        border: Border(top: BorderSide(color: TC.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _kGreen.withValues(alpha: 0.4),
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    OutdoorActivitySessionPage(activity: widget.activity),
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
            style: GoogleFonts.poppins(fontSize: 11, color: _kGrey),
          ),
        ],
      ),
    );
  }
}

class OutdoorActivitySessionPage extends StatefulWidget {
  final OutdoorActivity activity;
  const OutdoorActivitySessionPage({super.key, required this.activity});

  @override
  State<OutdoorActivitySessionPage> createState() =>
      _OutdoorActivitySessionPageState();
}

class _OutdoorActivitySessionPageState
    extends State<OutdoorActivitySessionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Timer? _timer;
  final ScrollController _scroll = ScrollController();
  int _step = 0;
  late int _remaining;
  bool _paused = false;

  List<OutdoorSessionStep> get _steps => widget.activity.sessionSteps;
  int get _total => _steps[_step].minutes * 60;

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
    final home = await showActivityReward(context, indoor: false);
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

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    final cur = _steps[_step];
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF6),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _r(0.0, 0.3, _topBar()),
              const SizedBox(height: 18),
              _r(0.05, 0.4, _titleRow(a)),
              const SizedBox(height: 16),
              _r(0.1, 0.45, _progress()),
              const SizedBox(height: 16),
              _r(0.15, 0.55, _illustration(a)),
              const SizedBox(height: 16),
              _r(
                0.2,
                0.6,
                Column(
                  children: [
                    Text(
                      cur.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: _kGreenDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cur.coach ?? cur.desc,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 12.5, height: 1.55, color: _kGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _r(0.28, 0.68, Center(child: _timerRing())),
              const SizedBox(height: 18),
              _r(0.36, 0.76, _controls()),
              const SizedBox(height: 12),
              _r(
                0.4,
                0.8,
                Center(
                  child: TextButton.icon(
                    onPressed: _finish,
                    icon: const Icon(Icons.check_box_outlined,
                        size: 18, color: _kGreen),
                    label: Text(
                      'Selesai',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kGreen,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _r(0.5, 0.88, _locationCard()),
              const SizedBox(height: 22),
              _r(0.56, 0.92, _stepsHeader()),
              const SizedBox(height: 12),
              for (int i = 0; i < _steps.length; i++)
                _r(0.6 + i * 0.07, 0.96 + i * 0.01, _stepTile(i)),
              const SizedBox(height: 14),
              _r(0.85, 1.0, _safety(a)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'TEDUH',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kGreenDeep,
                ),
              ),
              TextSpan(
                text: ' ACTION',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                  color: _kGreen,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          'AKTIVITAS BERLANGSUNG',
          style: GoogleFonts.poppins(
              fontSize: 10.5, letterSpacing: 0.6, color: _kGrey),
        ),
      ],
    );
  }

  Widget _titleRow(OutdoorActivity a) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          elevation: 1.5,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.maybePop(context),
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.arrow_back_rounded, size: 22, color: TC.dark),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.title,
                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: _kGreenDeep,
                ),
              ),
              Text(
                a.sessionSubtitle,
                style: GoogleFonts.poppins(fontSize: 11.5, color: _kGrey),
              ),
            ],
          ),
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
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _kGreen,
              ),
            ),
            const Spacer(),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _paused ? const Color(0xFFD6A53F) : _kGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _paused ? 'Dijeda' : 'Sedang berlangsung',
              style: GoogleFonts.poppins(fontSize: 11, color: _kGreen),
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
                    color: i < _step
                        ? _kGreen
                        : (i == _step
                            ? const Color(0xFF7FB89B)
                            : const Color(0xFFDCE6DE)),
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

  Widget _illustration(OutdoorActivity a) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3E9),
        borderRadius: BorderRadius.circular(26),
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.asset(
          a.illustrationAsset,
          height: 210,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco_rounded, size: 40, color: Color(0xFF9CC79A)),
              const SizedBox(width: 18),
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                    color: Color(0xFFCDE8D5), shape: BoxShape.circle),
                child: Icon(a.icon, size: 62, color: _kGreen),
              ),
              const SizedBox(width: 18),
              const Icon(Icons.eco_rounded, size: 32, color: Color(0xFFB5D1B1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timerRing() {
    return SizedBox(
      width: 164,
      height: 164,
      child: CustomPaint(
        painter: _RingPainter(_remaining / _total),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gerakan ${_step + 1}/${_steps.length}',
                  style: GoogleFonts.poppins(fontSize: 11, color: _kGrey)),
              Text(
                _mmss(_remaining),
                style: GoogleFonts.poppins(
                  fontSize: 34,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                  color: _kGreenDeep,
                ),
              ),
              Text('dari ${_mmss(_total)}',
                  style: GoogleFonts.poppins(fontSize: 11, color: _kGrey)),
            ],
          ),
        ),
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
              backgroundColor: _kGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFEBEFEB),
              disabledForegroundColor: const Color(0xFFA7B1AA),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
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

  Widget _locationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4E4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: Color(0xFF6B6A2A)),
              const SizedBox(width: 8),
              Text(
                'Jekan Raya, Palangka Raya',
                style: GoogleFonts.poppins(fontSize: 12, color: TC.dark),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Kalimantan Tengah · Data udara langsung tidak tersedia',
            style: GoogleFonts.poppins(fontSize: 10.5, color: _kGrey),
          ),
          const SizedBox(height: 8),
          Text(
            'Aktivitas luar ruang hanya jika kualitas udara setempat berstatus '
            'Baik menurut sumber pemantauan terbaru. Periksa sebelum mulai; '
            'jika tidak aman atau belum diketahui, tunda aktivitas luar ruang.',
            style: GoogleFonts.poppins(
                fontSize: 11.5, height: 1.55, color: TC.dark),
          ),
        ],
      ),
    );
  }

  Widget _stepsHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Langkah demi langkah',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: TC.dark,
            ),
          ),
        ),
        Text(
          '${_steps.length} gerakan',
          style: GoogleFonts.poppins(fontSize: 11, color: _kGrey),
        ),
      ],
    );
  }

  Widget _stepTile(int i) {
    final s = _steps[i];
    final done = i < _step;
    final active = i == _step;

    Widget leading;
    if (done) {
      leading = Container(
        width: 30,
        height: 30,
        decoration:
            const BoxDecoration(color: _kGreenDeep, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
      );
    } else if (active) {
      leading = Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration:
            const BoxDecoration(color: _kGreenDeep, shape: BoxShape.circle),
        child: Text('${i + 1}',
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
      );
    } else {
      leading = Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Text('${i + 1}',
            style: GoogleFonts.poppins(fontSize: 12, color: _kGrey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE7F3EA) : const Color(0xFFF1F5F1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFFBFDCC9) : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: 12),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: TC.dark,
                          ),
                        ),
                      ),
                      Text('${s.minutes} mnt',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: _kGrey)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.desc,
                    style: GoogleFonts.poppins(
                        fontSize: 11.5, height: 1.5, color: _kGrey),
                  ),
                  if (active) ...[
                    const SizedBox(height: 4),
                    Text(
                      'SEDANG DILAKUKAN',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: _kGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _safety(OutdoorActivity a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_user_outlined, size: 20, color: _kGreen),
            const SizedBox(width: 10),
            Text(
              'Utamakan keselamatan',
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: TC.dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          a.safety,
          style: GoogleFonts.poppins(fontSize: 12, height: 1.6, color: _kGrey),
        ),
        const SizedBox(height: 8),
        Text(
          'Pelan tak apa. Nyaman yang utama.',
          style: GoogleFonts.poppins(fontSize: 11.5, color: _kGreen),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  _RingPainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
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
        ..color = const Color(0xFFE6F1EA),
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
        ..color = _kGreen,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.fraction != fraction;
}
