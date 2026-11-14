import 'dart:io';
import 'dart:math' as math;
import '../state/app_settings.dart';
import '../services/user_profile_service.dart';
import '../services/user_points_service.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/coach_marks.dart';
import '../widgets/teduh_drawer.dart';
import '../widgets/teduh_header.dart';
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

  String get _name => UserProfileService.instance.displayName;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _headerKey = GlobalKey();
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

  Widget _buildAvatarImage(double size, String? photoUrl, String name) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
        return ClipOval(
          child: Image.network(
            photoUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildFallbackAvatar(size, name),
          ),
        );
      }
      final file = File(photoUrl);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildFallbackAvatar(size, name),
          ),
        );
      }
    }
    return _buildFallbackAvatar(size, name);
  }

  Widget _buildFallbackAvatar(double size, String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: _C.green,
        ),
      ),
    );
  }

  List<CoachStep> get _tourSteps => [
        CoachStep(
          target: _headerKey,
          title: 'Menu dan notifikasi',
          body: 'Ikon tiga garis membuka menu samping. Ikon lonceng membuka '
              'riwayat notifikasi.',
          radius: 22,
          scrollAlignment: 0.0,
        ),
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
    return ListenableBuilder(
      listenable: UserProfileService.instance,
      builder: (context, _) {
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
      key: _scaffoldKey,
      backgroundColor: _C.bg,
      drawerScrimColor: const Color(0x6B1A2622),
      drawer: const TeduhDrawer(current: HomeMenuItem.profile),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SoftLeavesPainter(_anim)),
            ),
          ),
          NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                backgroundColor: _C.bg,
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
                    color: _C.bg,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SafeArea(
                    bottom: false,
                    child: KeyedSubtree(
                      key: _headerKey,
                      child: TeduhHeader(
                        accent: 'PROFIL',
                        subtitle: 'Pengaturan akun dan preferensi',
                        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: Column(
                children: [
                  KeyedSubtree(
                    key: _profileKey,
                    child: AnimatedBuilder(
                      animation: UserProfileService.instance,
                      builder: (context, _) {
                        final photoUrl = UserProfileService.instance.photoUrl;
                        final name = UserProfileService.instance.displayName;
                        final email = UserProfileService.instance.email;

                        return Column(
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
                                child: _buildAvatarImage(avatar, photoUrl, name),
                              ),
                            ),

                            const SizedBox(height: 14),

                            _Reveal(
                              animation: _anim,
                              begin: 0.2,
                              end: 0.6,
                              child: Column(
                                children: [
                                  Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w600,
                                      color: _C.dark,
                                    ),
                                  ),
                                  if (email.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      email,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w400,
                                        color: _C.footer,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  _Reveal(
                    animation: _anim,
                    begin: 0.25,
                    end: 0.65,
                    child: _buildPointsCard(context),
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
      },
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return AnimatedBuilder(
      animation: UserPointsService.instance,
      builder: (context, _) {
        final pts = UserPointsService.instance.points;
        final target = UserPointsService.instance.currentTarget;
        final count = UserPointsService.instance.activitiesCompleted;
        final rank = UserPointsService.instance.rankTitle;
        final progress = (target > 0 ? pts / target : 0.0).clamp(0.0, 1.0);
        final percent = (progress * 100).round();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF3F9F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD6E8DC)),
            boxShadow: [
              BoxShadow(
                color: _C.green.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F3E7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: _C.green,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Poin & Kebugaran',
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: _C.dark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _showPointsExplanation(context),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Color(0xFF7C9084),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          rank,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: _C.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F3E7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$pts Poin',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _C.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$count sesi aktivitas selesai',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF5A7263),
                    ),
                  ),
                  Text(
                    '$percent% ke target ($target poin)',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5A7263),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE2EFE6),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE2A32E)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPointsExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: _C.green, size: 24),
            const SizedBox(width: 8),
            Text(
              'Tentang Poin TEDUH',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _C.dark,
              ),
            ),
          ],
        ),
        content: Text(
          'Poin dihitung dari setiap panduan aktivitas kebugaran & perlindungan yang kamu selesaikan (indoor saat ISPU buruk, outdoor saat ISPU bersih).\n\nPoin dimulai dari 0 dan terus bertambah untuk memotivasi konsistensi menjaga kesehatan paru-paru serta membuka medali pencapaian gaya hidup sehat.',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            height: 1.5,
            color: const Color(0xFF4A5F53),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Mengerti',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: _C.green,
              ),
            ),
          ),
        ],
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
