import 'dart:math' as math;
import '../state/app_settings.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'accessibility_page.dart';
import 'air_quality_history_page.dart';
import 'data_profile_page.dart';
import 'map_page.dart';
import 'notification_page.dart';
import 'privacy_security_page.dart';
import 'recommendation_history_page.dart';

class _C {
  static const bg = Color(0xFFF7FAF6);
  static const green = Color(0xFF0F7B4F);
  static const dark = Color(0xFF1F3D2F);
  static const cardBorder = Color(0xFFE4ECE6);
  static const iconBox = Color(0xFFE8F3EB);
  static const divider = Color(0xFFEDF2EE);
  static const chevron = Color(0xFFA5B2A9);
  static const softLeaf = Color(0xFFE2EFDF);
  static const footer = Color(0xFF7C9084);
}

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem(this.icon, this.label);
}

class _MenuSection {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection(this.title, this.items);
}

const List<_MenuSection> _sections = [
  _MenuSection('Akun Saya', [
    _MenuItem(Icons.person_outline_rounded, 'Data Profil'),
    _MenuItem(Icons.location_on_outlined, 'Lokasi Saya'),
  ]),
  _MenuSection('Aktivitas Teduh', [
    _MenuItem(Icons.air_rounded, 'Riwayat Kualitas Udara'),
    _MenuItem(Icons.fact_check_outlined, 'Riwayat Rekomendasi'),
  ]),
  _MenuSection('Pengaturan', [
    _MenuItem(Icons.notifications_none_rounded, 'Notifikasi'),
    _MenuItem(Icons.lock_outline_rounded, 'Privasi dan Keamanan'),
    _MenuItem(Icons.accessibility_new_rounded, 'Aksesibilitas'),
  ]),
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  final String _name = 'Aronisa Sinarzka Dewiputri';

  final _profileKey = GlobalKey();
  final List<GlobalKey> _sectionKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

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

  String _narration() {
    final b = StringBuffer(
        'Ini seluruh isi halaman Profil. Namamu $_name. Ada tiga kelompok menu. ');
    for (final s in _sections) {
      b.write('${s.title}: ${s.items.map((e) => e.label).join(', ')}. ');
    }
    b.write('Kamu bisa berkata buka Data Profil, buka Lokasi Saya, buka '
        'Riwayat, buka Riwayat Rekomendasi, buka Pengaturan '
        'Notifikasi, buka Privasi dan Keamanan, atau buka Aksesibilitas. ');
    return b.toString();
  }

  List<CoachStep> get _tourSteps => [
        CoachStep(
          target: _profileKey,
          title: 'Ini profilmu',
          body: 'Lihat foto dan namamu di sini. Ketuk menu Data Profil '
              'untuk mengubahnya kapan saja.',
          radius: 26,
          scrollAlignment: 0.0,
        ),
        CoachStep(
          target: _sectionKeys[0],
          title: 'Kelola akunmu',
          body: 'Ubah data diri dan atur lokasi supaya informasi kualitas '
              'udara sesuai dengan tempatmu.',
          scrollAlignment: 0.12,
        ),
        CoachStep(
          target: _sectionKeys[1],
          title: 'Pantau aktivitasmu',
          body: 'Lihat riwayat kualitas udara dan rekomendasimu '
              'dalam satu tempat.',
          scrollAlignment: 0.12,
        ),
        CoachStep(
          target: _sectionKeys[2],
          title: 'Atur sesuai kebutuhan',
          body: 'Atur notifikasi, privasi, dan aksesibilitas '
              'sesuai kebutuhanmu.',
          scrollAlignment: 1.0,
        ),
      ];

  void _onTapMenu(String label) {
    final Map<String, Widget Function()> pages = {
      'Data Profil': () => const DataProfilePage(),
      'Lokasi Saya': () => const MapPage(),
      'Riwayat Kualitas Udara': () => const AirQualityHistoryPage(),
      'Riwayat Rekomendasi': () => const RecommendationHistoryPage(),
      'Notifikasi': () => const NotificationPage(),
      'Aksesibilitas': () => const AccessibilityPage(),
      'Privasi dan Keamanan': () => const PrivacySecurityPage(),
    };
    final builder = pages[label];
    if (builder != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => builder()),
      );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('$label (segera hadir)'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
   ));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final avatar = w * 0.28;

    return VoiceScope(
      screen: 'profile',
      tour: _tourSteps,
      guide: PageGuide(
        content: _narration,
        endText: 'Itu seluruh isi halaman Profil. Informasi Bantuan dan FAQ '
            'ada di menu samping. Katakan buka bantuan untuk membukanya.',
      ),
      child: Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SoftLeavesPainter(_anim)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                children: [
                  _Reveal(
                    animation: _anim,
                    begin: 0.0,
                    end: 0.4,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: _C.dark,
                          iconSize: 26,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          'Profil',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _C.dark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'TEDUH',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: _C.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  KeyedSubtree(
                    key: _profileKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Reveal(
                          animation: _anim,
                          begin: 0.1,
                          end: 0.55,
                          child: Container(
                            width: avatar,
                            height: avatar,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF0F6F1),
                              border: Border.all(color: _C.green, width: 2.2),
                              boxShadow: [
                                BoxShadow(
                                  color: _C.green.withValues(alpha: 0.14),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: avatar * 0.5,
                              color: const Color(0xFF86A895),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        _Reveal(
                          animation: _anim,
                          begin: 0.2,
                          end: 0.6,
                          child: Text(
                            _name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                              color: _C.dark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  for (int i = 0; i < _sections.length; i++) ...[
                    _Reveal(
                      animation: _anim,
                      begin: 0.3 + i * 0.15,
                      end: 0.75 + i * 0.12,
                      child: KeyedSubtree(
                        key: _sectionKeys[i],
                        child: _SectionCard(
                          section: _sections[i],
                          onTap: _onTapMenu,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  const SizedBox(height: 4),


                  _Reveal(
                    animation: _anim,
                    begin: 0.75,
                    end: 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.eco_rounded,
                            size: 14, color: _C.green),
                        const SizedBox(width: 6),
                        Text(
                          'Lebih peduli, bernapas lebih tenang.',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: _C.footer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _MenuSection section;
  final void Function(String label) onTap;

  const _SectionCard({required this.section, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                section.title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _C.dark,
                ),
              ),
            ),
            for (int i = 0; i < section.items.length; i++) ...[
              _MenuRow(
                item: section.items[i],
                onTap: () => onTap(section.items[i].label),
              ),
              if (i != section.items.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 62,
                  endIndent: 16,
                  color: _C.divider,
                ),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;

  const _MenuRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: _C.green.withValues(alpha: 0.06),
      highlightColor: _C.green.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _C.iconBox,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(item.icon, size: 17, color: _C.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: _C.dark,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: _C.chevron),
          ],
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
        215 * math.pi / 180, _C.softLeaf.withValues(alpha: 0.9 * p));
    _leaf(canvas, Offset(w * 0.98, -h * 0.01), w * 0.40, w * 0.14,
        195 * math.pi / 180, _C.softLeaf.withValues(alpha: 0.6 * p));

    _leaf(canvas, Offset(-w * 0.04, h * 0.99), w * 0.46, w * 0.16,
        32 * math.pi / 180, _C.softLeaf.withValues(alpha: 0.75 * p));
    _leaf(canvas, Offset(w * 0.02, h * 1.02), w * 0.34, w * 0.12,
        8 * math.pi / 180, _C.softLeaf.withValues(alpha: 0.5 * p));
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
