import 'screens/readiness_state.dart';
import 'dart:async' show unawaited;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state/app_settings.dart';
import 'state/monitoring_state.dart';
import 'screens/region_page.dart';
import 'screens/home_page.dart';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/accessibility_intro_page.dart';
import 'services/ai/teduh_ai_orchestrator.dart';
import 'services/google_auth_service.dart';
import 'services/offline_data_service.dart';
import 'services/user_profile_service.dart';
import 'services/voice_flow.dart';
import 'services/voice_service.dart';
import 'state/app_nav.dart';
import 'widgets/accessibility_shell.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await AppSettings.instance.load();
  await ReadinessState.instance.load();
  await UserProfileService.instance.loadProfile();
  unawaited(MonitoringState.instance.initialize());
  unawaited(OfflineDataService.instance.initialize());
  await TeduhAiOrchestrator.instance.initialize();
  VoiceService.instance.attach();
  runApp(const TeduhApp());
}

class TeduhColors {
  static const bgTop = Color(0xFFBFE0B8);
  static const bgMid = Color(0xFFF0F6E1);
  static const bgBottom = Color(0xFFB4D8AE);
  static const logoCircle = Color(0xFFF5F9EC);
  static const logoLeaf = Color(0xFF14695A);
  static const title = Color(0xFF14593F);
  static const tagline = Color(0xFF3F7A55);
  static const progressFill = Color(0xFF145238);
  static const progressTrack = Color(0xFF7FAA84);
}

class TeduhApp extends StatelessWidget {
  const TeduhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final s = AppSettings.instance;
        return MaterialApp(
          title: 'TEDUH',
          navigatorKey: teduhNavKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            visualDensity: s.disabilityMode
                ? const VisualDensity(horizontal: 1, vertical: 1)
                : VisualDensity.standard,
            materialTapTargetSize:
                s.disabilityMode ? MaterialTapTargetSize.padded : null,
            pageTransitionsTheme: s.reduceMotion
                ? const PageTransitionsTheme(builders: {
                    TargetPlatform.android: NoTransitionsBuilder(),
                    TargetPlatform.iOS: NoTransitionsBuilder(),
                    TargetPlatform.windows: NoTransitionsBuilder(),
                    TargetPlatform.macOS: NoTransitionsBuilder(),
                    TargetPlatform.linux: NoTransitionsBuilder(),
                  })
                : null,
          ),
          builder: (context, child) => AccessibilityShell(child: child),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro; 
  late final AnimationController _loop; 
  late final AnimationController _progress; 

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
      animationBehavior: AppSettings.instance.animBehavior,
    );
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
      animationBehavior: AppSettings.instance.animBehavior,
    )..repeatUnlessReduced();
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
      animationBehavior: AppSettings.instance.animBehavior,
    );

    _intro.forward();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        _progress.forward().whenComplete(_goNext);
      }
    });
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? true;

    if (!mounted) return;

    if (user != null && rememberMe) {
      await UserProfileService.instance.loadProfile();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ));
      return;
    }

    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => const AccessibilityIntroPage(),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final circleD = w * 0.417;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TeduhColors.bgTop,
                  TeduhColors.bgMid,
                  TeduhColors.bgMid,
                  TeduhColors.bgBottom,
                ],
                stops: [0.0, 0.42, 0.58, 1.0],
              ),
            ),
          ),

          RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: LeavesPainter(intro: _intro, loop: _loop),
            ),
          ),

          Align(
            alignment: const Alignment(0, -0.02),
            child: AnimatedBuilder(
              animation: Listenable.merge([_intro, _loop]),
              builder: (context, _) {
                final t = _intro.value;
                final logoScale = Interval(0.05, 0.50, curve: Curves.elasticOut)
                    .transform(t);
                final logoFade =
                    Interval(0.05, 0.25, curve: Curves.easeOut).transform(t);
                final iconProg =
                    Interval(0.30, 0.70, curve: Curves.easeOutBack)
                        .transform(t);
                final titleP =
                    Interval(0.55, 0.85, curve: Curves.easeOutCubic)
                        .transform(t);
                final tagP = Interval(0.70, 1.0, curve: Curves.easeOutCubic)
                    .transform(t);

                final float =
                    math.sin(_loop.value * 2 * math.pi) * 4; 

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, float),
                      child: Opacity(
                        opacity: logoFade,
                        child: Transform.scale(
                          scale: logoScale.clamp(0.0, 1.4),
                          child: SizedBox(
                            width: circleD,
                            height: circleD,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                for (int i = 0; i < 2; i++)
                                  _PulseRing(
                                    progress:
                                        (_loop.value * 1.5 + i * 0.5) % 1.0,
                                    baseSize: circleD,
                                    enabled: t > 0.6,
                                  ),
                                Container(
                                  width: circleD,
                                  height: circleD,
                                  decoration: BoxDecoration(
                                    color: TeduhColors.logoCircle,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2E6B45)
                                            .withValues(alpha: 0.18),
                                        blurRadius: 28,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: (1 - iconProg) * -0.6 +
                                          math.sin(_loop.value *
                                                  2 *
                                                  math.pi) *
                                              0.04,
                                      child: Transform.scale(
                                        scale: 0.4 + 0.6 * iconProg,
                                        child: SizedBox(
                                          width: circleD * 0.52,
                                          height: circleD * 0.52,
                                          child: CustomPaint(
                                            painter: LeafLogoPainter(
                                                reveal: iconProg
                                                    .clamp(0.0, 1.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.012),
                    Opacity(
                      opacity: titleP,
                      child: Transform.translate(
                        offset: Offset(0, (1 - titleP) * 24),
                        child: Text(
                          'TEDUH',
                          style: GoogleFonts.poppins(
                            fontSize: w * 0.112,
                            fontWeight: FontWeight.w700,
                            letterSpacing: w * 0.006,
                            color: TeduhColors.title,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.006),
                    Opacity(
                      opacity: tagP,
                      child: Transform.translate(
                        offset: Offset(0, (1 - tagP) * 18),
                        child: Text(
                          'Bernafas Lebih Sehat di Udara yang\nLebih Baik',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: w * 0.039,
                            fontWeight: FontWeight.w400,
                            color: TeduhColors.tagline,
                            height: 1.75,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: h * 0.066,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_intro, _progress]),
                builder: (context, _) {
                  final appear = Interval(0.7, 1.0).transform(_intro.value);
                  final p = Curves.easeInOutCubic.transform(_progress.value);
                  final barW = w * 0.424;
                  return Opacity(
                    opacity: appear,
                    child: SizedBox(
                      width: barW,
                      height: 3.5,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  TeduhColors.progressTrack.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            width: barW * (0.38 + 0.62 * p),
                            decoration: BoxDecoration(
                              color: TeduhColors.progressFill,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double progress;
  final double baseSize;
  final bool enabled;

  const _PulseRing({
    required this.progress,
    required this.baseSize,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    final s = baseSize * (1.0 + 0.55 * progress);
    final o = (1 - progress) * 0.28;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF4E9A62).withValues(alpha: o),
          width: 1.6,
        ),
      ),
    );
  }
}

class LeafLogoPainter extends CustomPainter {
  final double reveal;
  LeafLogoPainter({required this.reveal});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(x * w, y * h);

    final leaf = Path()
      ..moveTo(p(0.97, 0.03).dx, p(0.97, 0.03).dy)
      ..cubicTo(w * 0.52, h * 0.02, w * 0.06, h * 0.22, w * 0.04, h * 0.62)
      ..cubicTo(w * 0.03, h * 0.82, w * 0.22, h * 0.90, w * 0.42, h * 0.86)
      ..cubicTo(w * 0.80, h * 0.78, w * 0.98, h * 0.45, w * 0.97, h * 0.03)
      ..close();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        0, h * (1 - reveal), w, h * reveal + 1));
    canvas.drawPath(
      leaf,
      Paint()
        ..color = TeduhColors.logoLeaf
        ..isAntiAlias = true,
    );

    final swoosh = Path()
      ..moveTo(w * 0.10, h * 0.98)
      ..cubicTo(w * 0.20, h * 0.62, w * 0.50, h * 0.36, w * 0.80, h * 0.24)
      ..cubicTo(w * 0.56, h * 0.46, w * 0.34, h * 0.70, w * 0.16, h * 1.00)
      ..close();
    canvas.drawPath(
      swoosh,
      Paint()
        ..color = TeduhColors.logoCircle
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LeafLogoPainter old) => old.reveal != reveal;
}

class _LeafSpec {
  final double fx; 
  final double fy; 
  final double len; 
  final double wid; 
  final double angle; 
  final Color c1; 
  final Color c2; 
  final double opacity;
  final double phase; 
  final double amp = 0.035; 

  const _LeafSpec(this.fx, this.fy, this.len, this.wid, this.angle, this.c1,
      this.c2,
      {this.opacity = 1.0, this.phase = 0});
}

const List<_LeafSpec> _leafSpecs = [

  _LeafSpec(-0.02, 0.00, 0.46, 0.15, 104, Color(0xFF7CBB72), Color(0xFF2F8052),
      phase: 0.2),
  _LeafSpec(-0.05, 0.075, 0.36, 0.12, 158, Color(0xFF9CCB84), Color(0xFF4E9A5A),
      phase: 1.1),
  _LeafSpec(-0.04, -0.01, 0.50, 0.19, 138, Color(0xFFB0DA94), Color(0xFF58A25C),
      phase: 2.0),

  _LeafSpec(0.64, -0.02, 0.44, 0.15, 188, Color(0xFFA2D48E), Color(0xFF4C9C5E),
      phase: 0.7),
  _LeafSpec(1.06, -0.02, 0.62, 0.22, 222, Color(0xFF3F9B62), Color(0xFF14594A),
      phase: 1.6),
  _LeafSpec(1.04, 0.27, 0.36, 0.13, 292, Color(0xFF86C47A), Color(0xFF3F8F5A),
      phase: 2.6),

  _LeafSpec(0.00, 1.02, 0.58, 0.20, 24, Color(0xFF2B7D50), Color(0xFF17604A),
      phase: 0.4),
  _LeafSpec(0.10, 1.03, 0.52, 0.17, 10, Color(0xFF8FC27C), Color(0xFF3E8F5A),
      opacity: 0.75, phase: 1.3),
  _LeafSpec(0.20, 1.04, 0.46, 0.15, -8, Color(0xFFB4DB9A), Color(0xFF6DB070),
      opacity: 0.6, phase: 2.2),

  _LeafSpec(0.52, 1.04, 0.72, 0.25, 20, Color(0xFFB2DA92), Color(0xFF3E955C),
      phase: 0.9),
  _LeafSpec(0.76, 1.04, 0.58, 0.20, 2, Color(0xFF5DAA68), Color(0xFF1F6E4F),
      phase: 1.9),
  _LeafSpec(1.02, 1.02, 0.40, 0.14, -24, Color(0xFF3D9461), Color(0xFF17604A),
      phase: 2.9),
];

class LeavesPainter extends CustomPainter {
  final Animation<double> intro;
  final Animation<double> loop;

  LeavesPainter({required this.intro, required this.loop})
      : super(repaint: Listenable.merge([intro, loop]));

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    for (int i = 0; i < _leafSpecs.length; i++) {
      final s = _leafSpecs[i];

      final delay = i * 0.035;
      final raw = ((intro.value - delay) / 0.55).clamp(0.0, 1.0);
      final p = Curves.easeOutCubic.transform(raw);
      if (p <= 0) continue;

      final base = Offset(s.fx * w, s.fy * h);
      final dir = (base - center);
      final dirN = dir / dir.distance;
      final slide = dirN * ((1 - p) * w * 0.28);

      final sway = math.sin(loop.value * 2 * math.pi + s.phase) * s.amp;
      final angle = s.angle * math.pi / 180 + sway + (1 - p) * 0.25;

      _drawLeaf(
        canvas,
        origin: base + slide,
        length: s.len * w,
        width: s.wid * w,
        angle: angle,
        c1: s.c1,
        c2: s.c2,
        opacity: s.opacity * p,
      );
    }
  }

  void _drawLeaf(
    Canvas canvas, {
    required Offset origin,
    required double length,
    required double width,
    required double angle,
    required Color c1,
    required Color c2,
    required double opacity,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);

    final L = length;
    final W = width;

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(W * 1.05, -L * 0.20, W * 0.95, -L * 0.72, 0, -L)
      ..cubicTo(-W * 0.95, -L * 0.72, -W * 1.05, -L * 0.20, 0, 0)
      ..close();

    final fill = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          c1.withValues(alpha: opacity),
          c2.withValues(alpha: opacity),
        ],
      ).createShader(Rect.fromLTWH(-W, -L, W * 2, L));
    canvas.drawPath(path, fill);

    final half = Path()
      ..moveTo(0, 0)
      ..cubicTo(W * 1.05, -L * 0.20, W * 0.95, -L * 0.72, 0, -L)
      ..close();
    canvas.drawPath(
      half,
      Paint()
        ..isAntiAlias = true
        ..color = Colors.black.withValues(alpha: 0.06 * opacity),
    );

    final vein = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.20 * opacity);

    canvas.drawLine(Offset(0, -L * 0.02), Offset(0, -L * 0.94), vein);
    for (double t = 0.18; t <= 0.80; t += 0.12) {
      final y = -L * t;
      final spread = W * 0.62 * (1 - t * 0.75);
      final up = L * 0.10;
      canvas.drawLine(Offset(0, y), Offset(spread, y - up), vein);
      canvas.drawLine(Offset(0, y), Offset(-spread, y - up), vein);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LeavesPainter old) => false;
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordTersembunyi = true;
  bool _sedangLogin = false;
  bool _sedangLoginGoogle = false;
  bool _ingatSaya = true;

  Future<void> _muatDataIngatSaya() async {
    try {
      final p = await SharedPreferences.getInstance();
      final remember = p.getBool('remember_me') ?? true;
      final savedEmail = p.getString('saved_email');
      final savedPass = p.getString('saved_password');

      if (mounted) {
        setState(() {
          _ingatSaya = remember;
          if (remember) {
            if (savedEmail != null && savedEmail.isNotEmpty) {
              emailController.text = savedEmail;
            }
            if (savedPass != null && savedPass.isNotEmpty) {
              passwordController.text = savedPass;
            }
          }
        });
      }
    } catch (_) {}
  }

  Future<bool> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      tampilkanPesan('Email dan kata sandi harus diisi!');
      return false;
    }
    setState(() => _sedangLogin = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return true;

      try {
        final p = await SharedPreferences.getInstance();
        await p.setBool('remember_me', _ingatSaya);
        if (_ingatSaya) {
          await p.setString('saved_email', email);
          await p.setString('saved_password', password);
        } else {
          await p.remove('saved_email');
          await p.remove('saved_password');
        }
      } catch (_) {}

      await UserProfileService.instance.loadProfile();

      if (!mounted) return true;
      tampilkanPesan('Login berhasil.');
      VoiceSession.welcomePending = AppSettings.instance.voiceFlows;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RegionPage()),
        (route) => false,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (!mounted) return false;
      final pesan = switch (e.code) {
        'invalid-email' => 'Format email tidak valid.',
        'user-not-found' => 'Akun dengan email tersebut tidak ditemukan.',
        'wrong-password' || 'invalid-credential' => 'Email atau kata sandi salah.',
        'user-disabled' => 'Akun ini telah dinonaktifkan.',
        'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
        'network-request-failed' => 'Koneksi internet bermasalah.',
        _ => e.message ?? 'Login gagal (${e.code}).',
      };
      tampilkanPesan(pesan);
    } catch (e) {
      if (!mounted) return false;
      tampilkanPesan('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _sedangLogin = false);
    }
    return false;
  }

  Future<void> _loginDenganGoogle() async {
    setState(() => _sedangLoginGoogle = true);
    try {
      final res = await GoogleAuthService.instance.signInWithGoogle(context);
      if (!mounted) return;

      if (res.success) {
        tampilkanPesan(res.message ?? 'Login Google berhasil.');
        VoiceSession.welcomePending = AppSettings.instance.voiceFlows;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RegionPage()),
          (route) => false,
        );
      } else if (!res.isCancelled) {
        tampilkanPesan(res.message ?? 'Gagal masuk dengan Google.');
      }
    } catch (e) {
      if (mounted) tampilkanPesan('Terjadi kesalahan Google Login: $e');
    } finally {
      if (mounted) setState(() => _sedangLoginGoogle = false);
    }
  }

  bool _voiceRunning = false;
  String _lastMsg = '';

  @override
  void initState() {
    super.initState();
    _muatDataIngatSaya();
    final pe = VoiceSession.pendingEmail;
    if (pe != null) emailController.text = pe;
    if (AppSettings.instance.voiceFlows) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _voiceLogin());
    } else {
      VoiceSession.pendingEmail = null;
    }
  }

  Future<void> _openRegister() async {
    VoiceService.instance.cancelAll();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (!mounted) return;
    if (AppSettings.instance.voiceFlows) {
      _voiceLogin();
    } else if (VoiceSession.pendingEmail != null) {
      emailController.text = VoiceSession.pendingEmail!;
      VoiceSession.pendingEmail = null;
    }
  }

  Future<void> _voiceLogin() async {
    if (_voiceRunning || !mounted) return;
    _voiceRunning = true;
    final f = VoiceFlow(() => mounted);
    try {
      final pe = VoiceSession.pendingEmail;
      final pp = VoiceSession.pendingPassword;
      if (pe != null && pp != null) {
        emailController.text = pe;
        passwordController.text = pp;
        VoiceSession.pendingEmail = null;
        VoiceSession.pendingPassword = null;
        await f.say('Akun berhasil dibuat. Saya masukkan akun Anda sekarang.');
        if (await _login()) return;
        await f.say(_lastMsg);
      } else {
        final has = await f.askYesNo(
          'Selamat datang di halaman masuk TEDUH. Apakah Anda sudah memiliki '
          'akun? Jawab sudah, atau belum.',
          yes: const ['sudah', 'punya', 'ada'],
          no: const ['belum', 'daftar', 'tidak'],
        );
        if (!mounted) return;
        if (has == false) {
          _voiceRunning = false;
          await _openRegister();
          return;
        }
      }
      for (int attempt = 0; attempt < 4 && mounted; attempt++) {
        final eRaw = await f.ask(
          'Sebutkan email Anda. Cukup bagian depannya, misalnya nama dan '
          'angka. Saya akan menambahkan gmail titik com.',
        );
        if (eRaw.isEmpty) continue;
        final email = VoiceFlow.emailFromSpeech(eRaw);
        emailController.text = email;
        if (mounted) setState(() {});
        await f.say('Email Anda $email.');
        final pRaw = await f.ask('Sebutkan kata sandi Anda.');
        if (pRaw.isEmpty) continue;
        passwordController.text = VoiceFlow.passwordFromSpeech(pRaw);
        if (mounted) setState(() {});
        await f.say('Sedang masuk.');
        if (await _login()) return;
        await f.say('$_lastMsg Mari coba lagi.');
      }
    } finally {
      _voiceRunning = false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void tampilkanPesan(String pesan) {
    _lastMsg = pesan;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  Widget _label(String teks) {
    return Text(
      teks,
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF31594C),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 11,
        color: const Color(0xFF94A59C),
      ),
      prefixIcon: Icon(
        icon,
        size: 17,
        color: const Color(0xFF438D78),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE9E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE9E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF438D78),
          width: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 0.52, 1.0],
            colors: [
              Color(0xFFE0F1E6),
              Color(0xFFF4F9F5),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.107),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 115,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CustomPaint(
                                  painter: LeafLogoPainter(reveal: 1),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'TEDUH',
                                style: GoogleFonts.poppins(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: const Color(0xFF176D59),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hidup Sehat, Udara Sehat',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF176D59),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Selamat datang ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF176D59),
                          ),
                        ),
                        TextSpan(
                          text: 'kembali',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF183D32),
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: width * 0.057),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Masuk untuk memulai hari yang lebih sehat.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF81968C),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _label('Email atau Nomor Telepon'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: _inputDecoration(
                      hint: 'nama@email.com',
                      icon: Icons.mail_outline,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _label('Kata Sandi'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordController,
                    obscureText: passwordTersembunyi,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: _inputDecoration(
                      hint: 'Masukkan kata sandi',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordTersembunyi = !passwordTersembunyi;
                          });
                        },
                        icon: Icon(
                          passwordTersembunyi
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 17,
                          color: const Color(0xFFB8C1BD),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _ingatSaya,
                          activeColor: const Color(0xFF176D59),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onChanged: (val) {
                            setState(() => _ingatSaya = val ?? true);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() => _ingatSaya = !_ingatSaya);
                        },
                        child: Text(
                          'Ingat saya',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF334E43),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: (_sedangLogin || _sedangLoginGoogle) ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF176D59),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: _sedangLogin
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Masuk',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Color(0xFFDCE9E1)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        child: Text(
                          'atau masuk dengan',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF82968C),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Color(0xFFDCE9E1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: (_sedangLogin || _sedangLoginGoogle) ? null : _loginDenganGoogle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF31594C),
                        side: const BorderSide(color: Color(0xFFDCE9E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: _sedangLoginGoogle
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF176D59)),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CustomPaint(painter: _GoogleLogoPainter()),
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'Lanjutkan dengan Google',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF82968C),
                          ),
                        ),
                        GestureDetector(
                          onTap: _openRegister,
                          child: Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF176D59),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 55),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 12,
                          color: Color(0xFF428A73),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Data pribadimu aman bersama TEDUH.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: const Color(0xFF91A49A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sandiController = TextEditingController();
  final TextEditingController konfirmasiController = TextEditingController();

  DateTime? tanggalLahir;
  String gender = 'Perempuan';
  bool sandiTersembunyi = true;
  bool konfirmasiTersembunyi = true;
  bool setuju = false;
  bool _sedangDaftar = false;

  static const Color hijau = Color(0xFF176D59);
  static const Color teks = Color(0xFF31594C);
  static const Color garis = Color(0xFFDCE4E1);
  static const Color hint = Color(0xFF9AA9A2);

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    sandiController.dispose();
    konfirmasiController.dispose();
    super.dispose();
  }

  String _lastMsg = '';

  @override
  void initState() {
    super.initState();
    if (AppSettings.instance.voiceFlows) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _voiceRegister());
    }
  }

  Future<String> _need(VoiceFlow f, String prompt) => f.ask(prompt, tries: 3);

  Future<void> _voiceRegister() async {
    final f = VoiceFlow(() => mounted);
    await f.say('Halaman daftar akun TEDUH. Saya akan menanyakan datamu '
        'satu per satu.');

    final nama = await _need(f, 'Sebutkan nama lengkap Anda.');
    if (!mounted || nama.isEmpty) return _voiceGiveUp(f);
    namaController.text = nama;
    setState(() {});

    DateTime? tgl;
    for (int i = 0; i < 3 && tgl == null && mounted; i++) {
      final raw = await _need(f,
          'Sebutkan tanggal lahir Anda, misalnya dua belas Maret dua ribu satu.');
      tgl = VoiceFlow.dateFromSpeech(_numberWordsToDigits(raw));
      if (tgl == null && raw.isNotEmpty) {
        await f.say('Tanggal belum terbaca. Coba sebut tanggal, bulan, lalu tahun.');
      }
    }
    if (!mounted || tgl == null) return _voiceGiveUp(f);
    setState(() => tanggalLahir = tgl);

    final g = (await _need(f, 'Jenis kelamin Anda? Katakan laki-laki atau perempuan.')).toLowerCase();
    if (!mounted) return;
    setState(() => gender = (g.contains('laki') || g.contains('pria')) ? 'Laki-laki' : 'Perempuan');

    final eRaw = await _need(f,
        'Sebutkan email Anda. Cukup bagian depannya, saya tambahkan gmail titik com.');
    if (!mounted || eRaw.isEmpty) return _voiceGiveUp(f);
    final email = VoiceFlow.emailFromSpeech(eRaw);
    emailController.text = email;
    setState(() {});
    await f.say('Email Anda $email.');

    String sandi = '';
    for (int i = 0; i < 3 && mounted; i++) {
      final s1 = VoiceFlow.passwordFromSpeech(
          await _need(f, 'Sebutkan kata sandi, minimal delapan karakter.'));
      if (s1.length < 8) {
        await f.say('Kata sandi minimal delapan karakter.');
        continue;
      }
      final s2 = VoiceFlow.passwordFromSpeech(
          await _need(f, 'Ucapkan sekali lagi kata sandi tadi untuk konfirmasi.'));
      if (s1 == s2) {
        sandi = s1;
        break;
      }
      await f.say('Kata sandi tidak sama. Mari ulangi.');
    }
    if (!mounted || sandi.isEmpty) return _voiceGiveUp(f);
    sandiController.text = sandi;
    konfirmasiController.text = sandi;
    setState(() {});

    final ok = await f.askYesNo(
      'Apakah Anda menyetujui Syarat dan Ketentuan serta Kebijakan Privasi '
      'TEDUH? Jawab setuju, atau tidak.',
      yes: const ['setuju'],
    );
    if (!mounted) return;
    if (ok != true) {
      await f.say('Pendaftaran membutuhkan persetujuan. Silakan ketuk '
          'Daftar bila sudah siap.');
      return;
    }
    setState(() => setuju = true);
    await f.say('Terima kasih. Sedang membuat akunmu.');
    await _daftar();
    if (mounted && _lastMsg.isNotEmpty) {
      await f.say('$_lastMsg Periksa kembali data, lalu ketuk Daftar.');
    }
  }

  Future<void> _voiceGiveUp(VoiceFlow f) async {
    if (!mounted) return;
    await f.say('Aku belum bisa mendengar jawabanmu. Kamu bisa mengisi '
        'secara manual.');
  }

  static String _numberWordsToDigits(String s) {
    const w = {
      'satu': '1', 'dua': '2', 'tiga': '3', 'empat': '4', 'lima': '5',
      'enam': '6', 'tujuh': '7', 'delapan': '8', 'sembilan': '9',
      'sepuluh': '10', 'sebelas': '11', 'dua belas': '12',
    };
    var t = ' ${s.toLowerCase()} ';
    t = t.replaceAll('dua ribu satu', '2001');
    w.forEach((k, v) => t = t.replaceAll(' $k ', ' $v '));
    return t.trim();
  }

  void _pesan(String pesan) {
    _lastMsg = pesan;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  String get _tanggalText {
    if (tanggalLahir == null) return 'Pilih tanggal lahir';
    final d = tanggalLahir!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Pilih tanggal lahir',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: hijau,
              onPrimary: Colors.white,
              onSurface: teks,
            ),
          ),
          child: child!,
        );
      },
    );
    if (hasil != null) setState(() => tanggalLahir = hasil);
  }

  InputDecoration _dekorasi({
    required String hintText,
    required IconData ikon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 10, color: hint),
      prefixIcon: Icon(ikon, size: 16, color: const Color(0xFF8A9B93)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFEFFFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: garis, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: garis, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF55A58C), width: 1.3),
      ),
    );
  }

  Widget _label(String value) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: teks,
          ),
        ),
      );

  Widget _kolom({
    required String label,
    required String hintText,
    required IconData ikon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            style: GoogleFonts.poppins(fontSize: 11, color: teks),
            decoration: _dekorasi(
              hintText: hintText,
              ikon: ikon,
              suffix: suffix,
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderButton(String value, IconData ikon) {
    final aktif = gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = value),
        child: Container(
          height: 37,
          decoration: BoxDecoration(
            color: aktif ? const Color(0xFFE2FFF2) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: aktif ? const Color(0xFF55A98D) : garis,
              width: aktif ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ikon,
                size: 15,
                color: aktif ? hijau : const Color(0xFF98A69F),
              ),
              const SizedBox(width: 7),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
                  color: aktif ? hijau : const Color(0xFF87958E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _tampilkanPopupAkunBerhasil() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x990D2923),
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 34),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x260B3028),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 142,
                    height: 142,
                    child: CustomPaint(
                      painter: _AkunBerhasilIllustrationPainter(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Akun Berhasil Dibuat!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF25483F),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Akun Anda telah aktif. Sekarang Anda dapat '
                    'menikmati semua fitur kesehatan dan rekomendasi '
                    'terbaik dari TEDUH',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      height: 1.65,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF82938D),
                    ),
                  ),
                  const SizedBox(height: 17),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF176F5B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Future<void> _tampilkanPopupAkunSudahTerdaftar() async {
    final w = MediaQuery.of(context).size.width;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x990D2923),
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(horizontal: w * 0.075),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                w * 0.054,
                w * 0.0575,
                w * 0.054,
                w * 0.157,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(w * 0.06),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x260B3028),
                    blurRadius: 22,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: w * 0.153,
                    height: w * 0.153,
                    child: const CustomPaint(
                      painter: _AkunTerdaftarWarningPainter(),
                    ),
                  ),
                  SizedBox(height: w * 0.064),
                  Text(
                    'Akun Sudah Terdaftar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: w * 0.0447,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E2B27),
                    ),
                  ),
                  SizedBox(height: w * 0.04),
                  Text(
                    'Email yang Anda masukkan sudah terdaftar '
                    'dalam sistem TEDUH. Silakan masuk ke akun '
                    'Anda atau gunakan email lain.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: w * 0.0335,
                      height: 1.65,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5E6B66),
                    ),
                  ),
                  SizedBox(height: w * 0.118),
                  SizedBox(
                    width: double.infinity,
                    height: w * 0.134,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D6B55),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.034),
                        ),
                      ),
                      child: Text(
                        'Ke Halaman Login',
                        style: GoogleFonts.inter(
                          fontSize: w * 0.0335,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _daftar() async {
  if (namaController.text.trim().isEmpty ||
      tanggalLahir == null ||
      emailController.text.trim().isEmpty ||
      sandiController.text.isEmpty ||
      konfirmasiController.text.isEmpty) {
    _pesan('Mohon lengkapi semua data terlebih dahulu.');
    return;
  }

  if (sandiController.text.length < 8) {
    _pesan('Kata sandi minimal 8 karakter.');
    return;
  }

  if (sandiController.text != konfirmasiController.text) {
    _pesan('Konfirmasi kata sandi tidak sama.');
    return;
  }

  if (!setuju) {
    _pesan('Silakan setujui Syarat dan Ketentuan serta Kebijakan Privasi.');
    return;
  }

  setState(() => _sedangDaftar = true);

  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: sandiController.text,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Akun gagal dibuat.');
    }

    await user.updateDisplayName(namaController.text.trim());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'nama': namaController.text.trim(),
      'email': emailController.text.trim(),
      'tanggalLahir': Timestamp.fromDate(tanggalLahir!),
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    VoiceSession.pendingEmail = emailController.text.trim();
    if (AppSettings.instance.voiceFlows) {
      VoiceSession.pendingPassword = sandiController.text;
      Navigator.of(context).pop();
    } else {
      await _tampilkanPopupAkunBerhasil();
    }
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    if (e.code == 'email-already-in-use') {
      await _tampilkanPopupAkunSudahTerdaftar();
    } else {
      final pesan = switch (e.code) {
        'invalid-email' => 'Format email tidak valid.',
        'weak-password' => 'Kata sandi terlalu lemah.',
        'network-request-failed' => 'Koneksi internet bermasalah.',
        _ => e.message ?? 'Pendaftaran gagal (${e.code}).',
      };

      _pesan(pesan);
    }
  } catch (e) {
    if (!mounted) return;
    _pesan('Terjadi kesalahan: $e');
  } finally {
    if (mounted) {
      setState(() => _sedangDaftar = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.30, 0.62, 1],
                colors: [
                  Color(0xFFDDF0E4),
                  Color(0xFFF4F8F5),
                  Colors.white,
                  Colors.white,
                ],
              ),
            ),
          ),
          Positioned(
            left: -22,
            bottom: -25,
            child: IgnorePointer(
              child: CustomPaint(
                size: const Size(115, 115),
                painter: _RegisterLeafCornerPainter(),
              ),
            ),
          ),
          Positioned(
            right: -22,
            bottom: -25,
            child: IgnorePointer(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: CustomPaint(
                  size: const Size(115, 115),
                  painter: _RegisterLeafCornerPainter(),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 58,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    size: 20,
                                    color: Color(0xFF42665A),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 34,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 23,
                                        height: 23,
                                        child: CustomPaint(
                                          painter: LeafLogoPainter(reveal: 1),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'TEDUH',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                          color: hijau,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Hidup Sehat, Udara Lebih Baik',
                                    style: GoogleFonts.poppins(
                                      fontSize: 8,
                                      color: const Color(0xFF4B8A73),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Daftar Akun',
                          style: GoogleFonts.poppins(
                            fontSize: 21,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF176D59),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mulai langkah kecil untuk hidup lebih sehat dan lingkungan\\nyang lebih baik bersama TEDUH.',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            height: 1.35,
                            color: const Color(0xFF8A9B93),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _kolom(
                          label: 'Nama Lengkap',
                          hintText: 'Masukkan nama lengkap Anda',
                          ikon: Icons.person_outline,
                          controller: namaController,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 8),
                        _label('Tanggal Lahir'),
                        GestureDetector(
                          onTap: _pilihTanggal,
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEFFFE),
                              border: Border.all(color: garis),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 16,
                                  color: Color(0xFF8A9B93),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _tanggalText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: tanggalLahir == null ? hint : teks,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_month,
                                  size: 16,
                                  color: Color(0xFF8A9B93),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _label('Gender'),
                        Row(
                          children: [
                            _genderButton('Perempuan', Icons.female),
                            const SizedBox(width: 8),
                            _genderButton('Laki-laki', Icons.male),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _kolom(
                          label: 'Email',
                          hintText: 'Masukkan email Anda',
                          ikon: Icons.mail_outline,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 8),
                        _kolom(
                          label: 'Sandi',
                          hintText: 'Minimal 8 karakter',
                          ikon: Icons.lock_outline,
                          controller: sandiController,
                          obscure: sandiTersembunyi,
                          suffix: IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(
                              () => sandiTersembunyi = !sandiTersembunyi,
                            ),
                            icon: Icon(
                              sandiTersembunyi
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 16,
                              color: const Color(0xFF8A9B93),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _kolom(
                          label: 'Konfirmasi Sandi',
                          hintText: 'Ulangi kata sandi Anda',
                          ikon: Icons.lock_outline,
                          controller: konfirmasiController,
                          obscure: konfirmasiTersembunyi,
                          suffix: IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(
                              () => konfirmasiTersembunyi =
                                  !konfirmasiTersembunyi,
                            ),
                            icon: Icon(
                              konfirmasiTersembunyi
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 16,
                              color: const Color(0xFF8A9B93),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: setuju,
                                onChanged: (v) =>
                                    setState(() => setuju = v ?? false),
                                activeColor: hijau,
                                side: const BorderSide(color: garis, width: 1.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text.rich(
                                  TextSpan(
                                    style: GoogleFonts.poppins(
                                      fontSize: 8.5,
                                      height: 1.35,
                                      color: const Color(0xFF87968F),
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Saya menyetujui ',
                                      ),
                                      TextSpan(
                                        text: 'Syarat dan Ketentuan',
                                        style: const TextStyle(
                                          color: hijau,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const TextSpan(text: ' serta '),
                                      TextSpan(
                                        text: 'Kebijakan\nPrivasi',
                                        style: const TextStyle(
                                          color: hijau,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _sedangDaftar ? null : _daftar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hijau,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: _sedangDaftar
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Daftar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text.rich(
                              TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: const Color(0xFF87968F),
                                ),
                                children: [
                                  const TextSpan(text: 'Sudah punya akun? '),
                                  TextSpan(
                                    text: 'Masuk',
                                    style: const TextStyle(
                                      color: hijau,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterLeafCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEAF4EE)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.08, size.height)
      ..cubicTo(
        size.width * 0.02, size.height * 0.56,
        size.width * 0.12, size.height * 0.16,
        size.width * 0.43, size.height * 0.08,
      )
      ..cubicTo(
        size.width * 0.40, size.height * 0.42,
        size.width * 0.60, size.height * 0.60,
        size.width * 0.95, size.height * 0.62,
      )
      ..cubicTo(
        size.width * 0.82, size.height * 0.92,
        size.width * 0.48, size.height * 1.02,
        size.width * 0.08, size.height,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RegisterLeafCornerPainter oldDelegate) => false;
}


class _AkunBerhasilIllustrationPainter extends CustomPainter {
  const _AkunBerhasilIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final mint = Paint()..color = const Color(0xFFE6F4ED);
    canvas.drawCircle(center, 59, mint);

    final yellow = Paint()..color = const Color(0xFFF2C85E);
    canvas.drawCircle(Offset(18, 60), 4, yellow);
    canvas.drawCircle(Offset(112, 19), 3, yellow);
    canvas.drawCircle(Offset(126, 83), 3, yellow);

    final leafPaint = Paint()
      ..color = const Color(0xFF8BCDB1)
      ..style = PaintingStyle.fill;
    final leafLine = Paint()
      ..color = const Color(0xFF4B9B7D)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leaf1 = Path()
      ..moveTo(24, 42)
      ..quadraticBezierTo(9, 25, 15, 9)
      ..quadraticBezierTo(31, 14, 27, 39)
      ..close();
    final leaf2 = Path()
      ..moveTo(25, 42)
      ..quadraticBezierTo(31, 17, 49, 13)
      ..quadraticBezierTo(49, 34, 25, 42)
      ..close();
    canvas.drawPath(leaf1, leafPaint);
    canvas.drawPath(leaf2, leafPaint);
    canvas.drawLine(const Offset(25, 42), const Offset(19, 17), leafLine);
    canvas.drawLine(const Offset(25, 42), const Offset(43, 18), leafLine);

    final shield = Path()
      ..moveTo(center.dx, 34)
      ..quadraticBezierTo(center.dx + 19, 45, center.dx + 34, 46)
      ..lineTo(center.dx + 32, 77)
      ..quadraticBezierTo(center.dx + 28, 96, center.dx, 108)
      ..quadraticBezierTo(center.dx - 28, 96, center.dx - 32, 77)
      ..lineTo(center.dx - 34, 46)
      ..quadraticBezierTo(center.dx - 19, 45, center.dx, 34)
      ..close();

    final shadow = Paint()..color = const Color(0xFF0D493B);
    final shieldFill = Paint()..color = const Color(0xFF176F55);
    canvas.drawPath(shield, shadow);
    canvas.drawPath(shield, shieldFill);

    final check = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final checkPath = Path()
      ..moveTo(center.dx - 14, 69)
      ..lineTo(center.dx - 3, 80)
      ..lineTo(center.dx + 18, 58);
    canvas.drawPath(checkPath, check);

    canvas.save();
    canvas.translate(107, 104);
    canvas.scale(0.48);
    final smallLeaf = Path()
      ..moveTo(0, 14)
      ..quadraticBezierTo(-8, -2, 1, -12)
      ..quadraticBezierTo(11, -3, 0, 14)
      ..close();
    canvas.drawPath(smallLeaf, leafPaint);
    canvas.drawLine(const Offset(0, 14), const Offset(1, -8), leafLine);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _AkunTerdaftarWarningPainter extends CustomPainter {
  const _AkunTerdaftarWarningPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()..color = const Color(0xFFFBF2DF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(17)),
      bg,
    );

    final warning = Paint()
      ..color = const Color(0xFFD9A65B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    final triangle = Path()
      ..moveTo(size.width * 0.50, size.height * 0.27)
      ..lineTo(size.width * 0.79, size.height * 0.73)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.79,
        size.width * 0.74,
        size.height * 0.79,
      )
      ..lineTo(size.width * 0.26, size.height * 0.79)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.79,
        size.width * 0.21,
        size.height * 0.73,
      )
      ..close();
    canvas.drawPath(triangle, warning);

    final exclamation = Paint()
      ..color = const Color(0xFFD9A65B)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.43),
      Offset(size.width * 0.50, size.height * 0.60),
      exclamation,
    );
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.68),
      1.3,
      Paint()..color = const Color(0xFFD9A65B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnbColors {
  static const green = Color(0xFF176D59);
  static const greenDark = Color(0xFF1D6B55);
  static const tagline = Color(0xFF2A7357);
  static const label = Color(0xFF5F7F70);
  static const body = Color(0xFF5B6B63);
  static const skip = Color(0xFF7B8B83);
  static const leafPale = Color(0xFFE3F0DD);
  static const leafPale2 = Color(0xFFD3E7CC);
  static const pill = Color(0xFFDDEFD9);
}

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoiceFlow.onboardingStep(
        alive: () => mounted,
        text: 'Selamat datang di TEDUH. Pantau Udara Real-Time. Dapatkan informasi kualitas udara ISPU yang akurat di sekitar lokasimu sebelum memulai aktivitas luar ruangan.',
        onNext: _next,
        onSkip: _skip,
        nextWord: 'lanjut',
      );
    });
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      animationBehavior: AppSettings.instance.animBehavior,
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
      animationBehavior: AppSettings.instance.animBehavior,
    )..repeatUnlessReduced();
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _next() {
    Navigator.of(context).pushReplacement(_onbRoute(const OnboardingScreen2()));
  }

  void _skip() {
    Navigator.of(context).pushReplacement(_onbRoute(const LoginScreen()));
  }

  Widget _reveal(double begin, double end, Widget child, {double dy = 20}) {
    final t = Interval(begin, end, curve: Curves.easeOutCubic)
        .transform(_intro.value);
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final padL = w * 0.079;
    final padR = w * 0.072;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _OnbBackgroundPainter()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: IntrinsicHeight(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_intro, _loop]),
                        builder: (context, _) {
                          final sway = math.sin(_loop.value * 2 * math.pi);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: h * 0.035),

                              _reveal(
                                0.0,
                                0.5,
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: w * 0.092,
                                          height: w * 0.092,
                                          child: CustomPaint(
                                            painter: _OnbLogoPainter(),
                                          ),
                                        ),
                                        SizedBox(width: w * 0.022),
                                        Text(
                                          'TEDUH',
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.082,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: w * 0.003,
                                            color: _OnbColors.green,
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: h * 0.006),
                                    Text(
                                      'Hidup Sehat, Udara Sehat',
                                      style: GoogleFonts.inter(
                                        fontSize: w * 0.036,
                                        fontWeight: FontWeight.w500,
                                        color: _OnbColors.tagline,
                                      ),
                                    ),
                                  ],
                                ),
                                dy: 14,
                              ),

                              SizedBox(height: h * 0.034),

                              _reveal(
                                0.15,
                                0.75,
                                SizedBox(
                                  width: w,
                                  height: (w * 0.72).clamp(180.0, 300.0),
                                  child: _buildIllustration(w, sway),
                                ),
                                dy: 24,
                              ),

                              SizedBox(height: h * 0.026),

                              _reveal(
                                0.35,
                                0.95,
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      padL, 0, padR + w * 0.02, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'KENALI UDARA ANDA',
                                        style: GoogleFonts.inter(
                                          fontSize: w * 0.0265,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.6,
                                          color: _OnbColors.label,
                                        ),
                                      ),
                                      SizedBox(height: h * 0.014),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Pantau Udara Real-Time',
                                          maxLines: 1,
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.08,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.6,
                                            color: _OnbColors.green,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: h * 0.018),
                                      Text(
                                        'Dapatkan informasi kualitas udara (ISPU) yang akurat dan terpercaya di sekitar lokasi Anda secara instan sebelum memulai aktivitas luar ruangan.',
                                        style: GoogleFonts.inter(
                                          fontSize: w * 0.0385,
                                          fontWeight: FontWeight.w400,
                                          height: 1.75,
                                          color: _OnbColors.body,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                dy: 22,
                              ),

                              SizedBox(height: h * 0.02),
                              const Spacer(),

                              _reveal(
                                0.5,
                                1.0,
                                Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(padL, 0, padR, 0),
                                  child: Row(
                                    children: [
                                      const _OnbDot(active: true),
                                      const SizedBox(width: 6),
                                      const _OnbDot(active: false),
                                      const SizedBox(width: 6),
                                      const _OnbDot(active: false),
                                      const Spacer(),
                                      _buildNextButton(w),
                                    ],
                                  ),
                                ),
                                dy: 16,
                              ),

                              SizedBox(height: h * 0.008),

                              _reveal(
                                0.5,
                                1.0,
                                Padding(
                                  padding: EdgeInsets.only(right: padR + 6),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: _skip,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Text(
                                          'Lewati',
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w500,
                                            color: _OnbColors.skip,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                dy: 10,
                              ),

                              SizedBox(height: h * 0.015),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(double w) {
    return Material(
      color: _OnbColors.greenDark,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _next,
        child: Container(
          width: w * 0.365,
          height: w * 0.138,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _OnbColors.greenDark.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lanjut',
                style: GoogleFonts.inter(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: w * 0.058),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(double w, double sway) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _OnbIllustrationPainter(sway: sway)),
        ),

        Positioned(
          left: w * 0.23,
          top: w * 0.063 + sway * 3,
          width: w * 0.575,
          child: Container(
            padding: EdgeInsets.fromLTRB(w * 0.05, w * 0.045, w * 0.05, w * 0.045),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAF3E6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E6B45).withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'ISPU',
                      style: GoogleFonts.inter(
                        fontSize: w * 0.026,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: const Color(0xFF2F6F58),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.air_rounded,
                        size: w * 0.06, color: const Color(0xFF6FB394)),
                  ],
                ),
                SizedBox(height: w * 0.008),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '22',
                      style: GoogleFonts.inter(
                        fontSize: w * 0.155,
                        fontWeight: FontWeight.w500,
                        color: _OnbColors.green,
                        height: 1.05,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: w * 0.027, vertical: w * 0.013),
                      decoration: BoxDecoration(
                        color: _OnbColors.pill,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: _OnbColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Baik',
                            style: GoogleFonts.inter(
                              fontSize: w * 0.029,
                              fontWeight: FontWeight.w600,
                              color: _OnbColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.012),
                Text(
                  'Udara bersih, napas lebih lega.',
                  style: GoogleFonts.inter(
                    fontSize: w * 0.0285,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF5E7A6C),
                  ),
                ),
                SizedBox(height: w * 0.03),
                Row(
                  children: [
                    for (final col in const [
                      Color(0xFF176D59),
                      Color(0xFF8FBF8F),
                      Color(0xFFC5DC8A),
                      Color(0xFFE8C77D),
                      Color(0xFFE3A58C),
                    ])
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: col,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: w * 0.012),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: _OnbColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          left: w * 0.35,
          top: w * 0.57 - sway * 3,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.045, vertical: w * 0.032),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFEAF3E6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E6B45).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _OnbColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: w * 0.022),
                Text(
                  'Udara di sekitar Anda',
                  style: GoogleFonts.inter(
                    fontSize: w * 0.029,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D4A3E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnbDot extends StatelessWidget {
  final bool active;
  const _OnbDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 7 : 6,
      height: active ? 7 : 6,
      decoration: BoxDecoration(
        color: active ? _OnbColors.green : const Color(0xFFD9DEDB),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _OnbLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final leaf = Path()
      ..moveTo(w * 0.97, h * 0.03)
      ..cubicTo(w * 0.52, h * 0.02, w * 0.06, h * 0.22, w * 0.04, h * 0.62)
      ..cubicTo(w * 0.03, h * 0.82, w * 0.22, h * 0.90, w * 0.42, h * 0.86)
      ..cubicTo(w * 0.80, h * 0.78, w * 0.98, h * 0.45, w * 0.97, h * 0.03)
      ..close();
    canvas.drawPath(leaf, Paint()..color = TeduhColors.logoLeaf);

    final swoosh = Path()
      ..moveTo(w * 0.10, h * 0.98)
      ..cubicTo(w * 0.20, h * 0.62, w * 0.50, h * 0.36, w * 0.80, h * 0.24)
      ..cubicTo(w * 0.56, h * 0.46, w * 0.34, h * 0.70, w * 0.16, h * 1.00)
      ..close();
    canvas.drawPath(swoosh, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _onbDrawLeaf(
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
  canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
  if (vein != null) {
    final vp = Paint()
      ..color = vein
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, -len * 0.04), Offset(0, -len * 0.82), vp);
    for (final f in [0.30, 0.50, 0.68]) {
      canvas.drawLine(Offset(0, -len * f), Offset(width * 0.42, -len * (f + 0.12)), vp);
      canvas.drawLine(Offset(0, -len * f), Offset(-width * 0.42, -len * (f + 0.12)), vp);
    }
  }
  canvas.restore();
}

class _OnbBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final glow = Rect.fromLTWH(0, 0, w * 0.55, h);
    canvas.drawRect(
      glow,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xCCDCEBD6), Color(0x00FFFFFF)],
        ).createShader(glow),
    );

    _onbDrawLeaf(canvas, Offset(w * 1.0, h * 0.20), h * 0.10, w * 0.06,
        -math.pi * 0.62, const Color(0xFFE9F3E4));
    _onbDrawLeaf(canvas, Offset(w * 0.96, h * 0.16), h * 0.06, w * 0.04,
        -math.pi * 0.45, const Color(0xFFEEF6EA));

    _onbDrawLeaf(canvas, Offset(w * 0.0, h * 0.985), h * 0.10, w * 0.07,
        math.pi * 0.20, const Color(0xFFE3F0DD));
    _onbDrawLeaf(canvas, Offset(w * 0.02, h * 0.995), h * 0.06, w * 0.045,
        math.pi * 0.42, const Color(0xFFEAF4E5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnbIllustrationPainter extends CustomPainter {
  final double sway;
  _OnbIllustrationPainter({required this.sway});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFDCEBD6).withValues(alpha: 0.9);
    canvas.drawCircle(Offset(w * 0.52, w * 0.38), w * 0.36, ring);
    canvas.drawCircle(Offset(w * 0.52, w * 0.38), w * 0.28, ring..color = const Color(0xFFE6F1E1));

    _onbDrawLeaf(canvas, Offset(w * 0.80, w * 0.50 + sway * 2), w * 0.40,
        w * 0.13, 0.30, _OnbColors.leafPale);
    _onbDrawLeaf(canvas, Offset(w * 0.28, w * 0.20), w * 0.17, w * 0.07,
        -0.55, _OnbColors.leafPale);

    _onbDrawLeaf(canvas, Offset(w * 0.18, w * 0.64 - sway * 2), w * 0.17,
        w * 0.07, -0.75, _OnbColors.leafPale2,
        vein: const Color(0xFFBBD8B2));

    final dot = Paint()..color = const Color(0xFFCFE4C8);
    canvas.drawCircle(Offset(w * 0.78, -w * 0.005), 2, dot);
    canvas.drawCircle(Offset(w * 0.87, w * 0.50), 2.5, dot);
  }

  @override
  bool shouldRepaint(covariant _OnbIllustrationPainter old) =>
      old.sway != sway;
}

class HalamanUtamaSementara extends StatelessWidget {
  const HalamanUtamaSementara({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nama = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email ?? 'Pengguna');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Halo, $nama',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TeduhColors.title,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ini halaman utama sementara.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: TeduhColors.tagline,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Keluar'),
            ),
          ],
        ),
      ),
    );
  }
}

Route<void> _onbRoute(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (_, anim, _, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}

class OnboardingScreen2 extends StatefulWidget {
  const OnboardingScreen2({super.key});

  @override
  State<OnboardingScreen2> createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoiceFlow.onboardingStep(
        alive: () => mounted,
        text: 'Siaga Kabut Asap. Lindungi pernapasan Anda dan keluarga dengan panduan kesiapsiagaan darurat serta peta posko kesehatan saat terjadi krisis kabut asap.',
        onNext: _next,
        onSkip: _skip,
        nextWord: 'lanjut',
      );
    });
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      animationBehavior: AppSettings.instance.animBehavior,
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
      animationBehavior: AppSettings.instance.animBehavior,
    )..repeatUnlessReduced();
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _next() {
    Navigator.of(context).pushReplacement(_onbRoute(const OnboardingScreen3()));
  }

  void _skip() {
    Navigator.of(context).pushReplacement(_onbRoute(const LoginScreen()));
  }

  Widget _reveal(double begin, double end, Widget child, {double dy = 20}) {
    final t = Interval(begin, end, curve: Curves.easeOutCubic)
        .transform(_intro.value);
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final padL = w * 0.079;
    final padR = w * 0.072;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _OnbBackgroundPainter()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: IntrinsicHeight(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_intro, _loop]),
                        builder: (context, _) {
                          final sway = math.sin(_loop.value * 2 * math.pi);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: h * 0.035),

                              _reveal(
                                0.0,
                                0.5,
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: w * 0.092,
                                          height: w * 0.092,
                                          child: CustomPaint(
                                            painter: _OnbLogoPainter(),
                                          ),
                                        ),
                                        SizedBox(width: w * 0.022),
                                        Text(
                                          'TEDUH',
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.082,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: w * 0.003,
                                            color: _OnbColors.green,
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: h * 0.006),
                                    Text(
                                      'Hidup Sehat, Udara Sehat',
                                      style: GoogleFonts.inter(
                                        fontSize: w * 0.036,
                                        fontWeight: FontWeight.w500,
                                        color: _OnbColors.tagline,
                                      ),
                                    ),
                                  ],
                                ),
                                dy: 14,
                              ),

                              SizedBox(height: h * 0.034),

                              _reveal(
                                0.15,
                                0.75,
                                SizedBox(
                                  width: w,
                                  height: (w * 0.72).clamp(180.0, 300.0),
                                  child: _buildIllustration(w, sway),
                                ),
                                dy: 24,
                              ),

                              SizedBox(height: h * 0.026),

                              _reveal(
                                0.35,
                                0.95,
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      padL, 0, padR + w * 0.02, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PERLINDUNGAN SAAT KRISIS',
                                        style: GoogleFonts.inter(
                                          fontSize: w * 0.0265,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.6,
                                          color: _OnbColors.green,
                                        ),
                                      ),
                                      SizedBox(height: h * 0.014),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Siaga Kabut Asap',
                                          maxLines: 1,
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.08,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.6,
                                            color: _OnbColors.green,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: h * 0.018),
                                      Text(
                                        'Lindungi sistem pernapasan Anda dan keluarga dengan panduan kesiapsiagaan darurat serta peta evakuasi posko kesehatan saat terjadi krisis kabut asap kebakaran hutan.',
                                        style: GoogleFonts.inter(
                                          fontSize: w * 0.0385,
                                          fontWeight: FontWeight.w400,
                                          height: 1.75,
                                          color: _OnbColors.body,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                dy: 22,
                              ),

                              SizedBox(height: h * 0.02),
                              const Spacer(),

                              _reveal(
                                0.5,
                                1.0,
                                Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(padL, 0, padR, 0),
                                  child: Row(
                                    children: [
                                      const _OnbDot(active: false),
                                      const SizedBox(width: 6),
                                      const _OnbDot(active: true),
                                      const SizedBox(width: 6),
                                      const _OnbDot(active: false),
                                      const Spacer(),
                                      Material(
                                        color: _OnbColors.greenDark,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          onTap: _next,
                                          child: Container(
                                            width: w * 0.365,
                                            height: w * 0.138,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _OnbColors.greenDark
                                                      .withValues(alpha: 0.25),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Lanjut',
                                                  style: GoogleFonts.inter(
                                                    fontSize: w * 0.04,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
                                                    Icons
                                                        .arrow_forward_rounded,
                                                    color: Colors.white,
                                                    size: w * 0.058),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                dy: 16,
                              ),

                              SizedBox(height: h * 0.008),

                              _reveal(
                                0.5,
                                1.0,
                                Padding(
                                  padding: EdgeInsets.only(right: padR + 6),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: _skip,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Text(
                                          'Lewati',
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w500,
                                            color: _OnbColors.skip,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                dy: 10,
                              ),

                              SizedBox(height: h * 0.015),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(double w, double sway) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _OnbHousePainter(sway: sway)),
        ),

        Positioned(
          left: w * 0.30,
          top: w * 0.57 - sway * 3,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.04, vertical: w * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFEAF3E6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E6B45).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined,
                    size: w * 0.04, color: _OnbColors.green),
                SizedBox(width: w * 0.02),
                Text(
                  'Anda & keluarga terlindungi',
                  style: GoogleFonts.inter(
                    fontSize: w * 0.028,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D4A3E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnbHousePainter extends CustomPainter {
  final double sway;
  _OnbHousePainter({required this.sway});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    Offset p(double u, double v) => Offset(u * w, v * w);
    const green = Color(0xFF176D59);

    canvas.drawCircle(p(0.21, 0.128), w * 0.095, Paint()..color = const Color(0xFFFBF1E0));
    final peach = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFF2D6AA);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.17, w * 0.118, w * 0.33, w * 0.158),
          Radius.circular(w * 0.02)),
      peach,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.715, w * 0.115, w * 0.845, w * 0.165),
          Radius.circular(w * 0.025)),
      peach,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.73, w * 0.225, w * 0.83, w * 0.25),
          Radius.circular(w * 0.0125)),
      peach,
    );

    _onbDrawLeaf(canvas, p(0.12, 0.44), w * 0.26, w * 0.09, -0.35,
        _OnbColors.leafPale);

    final c = p(0.471, 0.266);
    canvas.drawCircle(
      c,
      w * 0.26,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFE3F0DD),
    );
    final circleRect = Rect.fromCircle(center: c, radius: w * 0.23);
    canvas.drawCircle(
      c,
      w * 0.23,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFEAF4E6)],
        ).createShader(circleRect),
    );
    canvas.drawCircle(
      c,
      w * 0.23,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFDCEBD6),
    );

    final hill = Paint()..color = const Color(0xFFDCEBD6).withValues(alpha: 0.75);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.15, w * 0.28)
        ..lineTo(w * 0.29, w * 0.11)
        ..lineTo(w * 0.43, w * 0.28)
        ..close(),
      hill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.50, w * 0.28)
        ..lineTo(w * 0.62, w * 0.15)
        ..lineTo(w * 0.76, w * 0.28)
        ..close(),
      hill,
    );

    canvas.save();
    canvas.translate(0, sway * 2);

    final body = Path()
      ..moveTo(w * 0.30, w * 0.48)
      ..lineTo(w * 0.30, w * 0.268)
      ..lineTo(w * 0.4745, w * 0.13)
      ..lineTo(w * 0.65, w * 0.268)
      ..lineTo(w * 0.65, w * 0.48)
      ..quadraticBezierTo(w * 0.65, w * 0.50, w * 0.63, w * 0.50)
      ..lineTo(w * 0.32, w * 0.50)
      ..quadraticBezierTo(w * 0.30, w * 0.50, w * 0.30, w * 0.48)
      ..close();
    canvas.drawShadow(body, const Color(0xFF2E6B45).withValues(alpha: 0.35), 10, false);
    final bodyRect = Rect.fromLTRB(w * 0.30, w * 0.13, w * 0.65, w * 0.50);
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F7EE)],
        ).createShader(bodyRect),
    );

    final win = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.335, w * 0.31, w * 0.405, w * 0.38),
        Radius.circular(w * 0.008));
    canvas.drawRRect(win, Paint()..color = const Color(0xFFB9D9B8));
    final cross = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6;
    canvas.drawLine(p(0.37, 0.31), p(0.37, 0.38), cross);
    canvas.drawLine(p(0.335, 0.345), p(0.405, 0.345), cross);

    final door = Path()
      ..moveTo(w * 0.43, w * 0.50)
      ..lineTo(w * 0.43, w * 0.41)
      ..arcToPoint(p(0.52, 0.41), radius: Radius.circular(w * 0.045))
      ..lineTo(w * 0.52, w * 0.50)
      ..close();
    canvas.drawPath(door, Paint()..color = const Color(0xFFE2EEE0));
    canvas.drawCircle(p(0.505, 0.455), 1.6, Paint()..color = green);

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.266, w * 0.272)
        ..lineTo(w * 0.471, w * 0.103)
        ..lineTo(w * 0.683, w * 0.272),
      Paint()
        ..color = green
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.042
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(0, -sway * 3);
    final sx = w * 0.55;
    final sy = w * 0.282;
    final sw = w * 0.206;
    final sh = w * 0.221;
    Path shield(double x, double y, double ww, double hh) => Path()
      ..moveTo(x + ww * 0.5, y)
      ..cubicTo(x + ww * 0.65, y + hh * 0.10, x + ww * 0.85, y + hh * 0.14,
          x + ww, y + hh * 0.14)
      ..lineTo(x + ww, y + hh * 0.52)
      ..cubicTo(x + ww, y + hh * 0.78, x + ww * 0.75, y + hh * 0.93,
          x + ww * 0.5, y + hh)
      ..cubicTo(x + ww * 0.25, y + hh * 0.93, x, y + hh * 0.78, x,
          y + hh * 0.52)
      ..lineTo(x, y + hh * 0.14)
      ..cubicTo(x + ww * 0.15, y + hh * 0.14, x + ww * 0.35, y + hh * 0.10,
          x + ww * 0.5, y)
      ..close();

    final bw = w * 0.014;
    final outer = shield(sx - bw, sy - bw, sw + bw * 2, sh + bw * 2);
    canvas.drawShadow(outer, const Color(0xFF1D4F3A).withValues(alpha: 0.45), 9, false);
    canvas.drawPath(outer, Paint()..color = Colors.white);
    canvas.drawPath(shield(sx, sy, sw, sh), Paint()..color = green);

    canvas.drawPath(
      Path()
        ..moveTo(sx + sw * 0.28, sy + sh * 0.50)
        ..lineTo(sx + sw * 0.44, sy + sh * 0.65)
        ..lineTo(sx + sw * 0.74, sy + sh * 0.34),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();

    final dot = Paint()..color = const Color(0xFFCFE4C8);
    canvas.drawCircle(p(0.73, 0.006), 2, dot);
    canvas.drawCircle(p(0.756, 0.53), 2.5, dot);
  }

  @override
  bool shouldRepaint(covariant _OnbHousePainter old) => old.sway != sway;
}

class OnboardingScreen3 extends StatefulWidget {
  const OnboardingScreen3({super.key});

  @override
  State<OnboardingScreen3> createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoiceFlow.onboardingStep(
        alive: () => mounted,
        text: 'Langkah kecil, manfaat besar. Biasakan memeriksa kualitas udara, memakai masker saat perlu, dan menjaga kebugaran.',
        onNext: _start,
        onSkip: _start,
        nextWord: 'mulai',
      );
    });
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      animationBehavior: AppSettings.instance.animBehavior,
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
      animationBehavior: AppSettings.instance.animBehavior,
    )..repeatUnlessReduced();
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _start() {
    Navigator.of(context).pushReplacement(_onbRoute(const LoginScreen()));
  }

  Widget _reveal(double begin, double end, Widget child, {double dy = 20}) {
    final t = Interval(begin, end, curve: Curves.easeOutCubic)
        .transform(_intro.value);
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final padL = w * 0.079;
    final padR = w * 0.072;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _OnbBackgroundPainter()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: IntrinsicHeight(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_intro, _loop]),
                        builder: (context, _) {
                          final sway = math.sin(_loop.value * 2 * math.pi);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: h * 0.035),

                              _reveal(
                                0.0,
                                0.5,
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: w * 0.092,
                                          height: w * 0.092,
                                          child: CustomPaint(
                                            painter: _OnbLogoPainter(),
                                          ),
                                        ),
                                        SizedBox(width: w * 0.022),
                                        Text(
                                          'TEDUH',
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.082,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: w * 0.003,
                                            color: _OnbColors.green,
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: h * 0.006),
                                    Text(
                                      'Hidup Sehat, Udara Sehat',
                                      style: GoogleFonts.inter(
                                        fontSize: w * 0.036,
                                        fontWeight: FontWeight.w500,
                                        color: _OnbColors.tagline,
                                      ),
                                    ),
                                  ],
                                ),
                                dy: 14,
                              ),

                              SizedBox(height: h * 0.034),

                              _reveal(
                                0.15,
                                0.75,
                                SizedBox(
                                  width: w,
                                  height: (w * 0.72).clamp(180.0, 300.0),
                                  child: _buildIllustration(w, sway),
                                ),
                                dy: 24,
                              ),

                              SizedBox(height: h * 0.026),

                              _reveal(
                                0.35,
                                0.95,
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      padL, 0, padR + w * 0.02, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'LANGKAH KECIL, MANFAAT BESAR',
                                        style: GoogleFonts.inter(
                                          fontSize: w * 0.0265,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.6,
                                          color: _OnbColors.green,
                                        ),
                                      ),
                                      SizedBox(height: h * 0.014),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Lebih Sehat, Setiap Hari',
                                          maxLines: 1,
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.08,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.6,
                                            color: _OnbColors.green,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: h * 0.018),
                                      Text(
                                        'Temukan rekomendasi kesehatan yang sesuai dengan kebutuhan Anda. Bangun kebiasaan protektif harian agar setiap napas terasa lebih aman dan nyaman.',
                                        style: GoogleFonts.inter(
                                          fontSize: w * 0.0385,
                                          fontWeight: FontWeight.w400,
                                          height: 1.75,
                                          color: _OnbColors.body,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                dy: 22,
                              ),

                              SizedBox(height: h * 0.02),
                              const Spacer(),

                              _reveal(
                                0.5,
                                1.0,
                                Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(padL, 0, padR, 0),
                                  child: Row(
                                    children: [
                                      const _OnbDot(active: false),
                                      const SizedBox(width: 6),
                                      const _OnbDot(active: false),
                                      const SizedBox(width: 6),
                                      const _OnbDot(active: true),
                                      const Spacer(),
                                      Material(
                                        color: _OnbColors.greenDark,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          onTap: _start,
                                          child: Container(
                                            width: w * 0.455,
                                            height: w * 0.138,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _OnbColors.greenDark
                                                      .withValues(alpha: 0.25),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Mulai Sekarang',
                                                  style: GoogleFonts.inter(
                                                    fontSize: w * 0.04,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
                                                    Icons
                                                        .arrow_forward_rounded,
                                                    color: Colors.white,
                                                    size: w * 0.058),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                dy: 16,
                              ),

                              SizedBox(height: h * 0.008),

                              _reveal(
                                0.5,
                                1.0,
                                Padding(
                                  padding: EdgeInsets.only(right: padR + 6),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: _start,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Text(
                                          'Lewati',
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w500,
                                            color: _OnbColors.skip,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                dy: 10,
                              ),

                              SizedBox(height: h * 0.015),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(double w, double s, IconData icon) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: _OnbColors.leafPale,
        borderRadius: BorderRadius.circular(s * 0.3),
      ),
      child: Icon(icon, size: s * 0.58, color: _OnbColors.green),
    );
  }

  Widget _habitRow(double w, IconData icon, String label) {
    return Row(
      children: [
        _iconBox(w, w * 0.072, icon),
        SizedBox(width: w * 0.026),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: w * 0.0285,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D4A3E),
            ),
          ),
        ),
        Container(
          width: w * 0.05,
          height: w * 0.05,
          decoration: const BoxDecoration(
            color: _OnbColors.green,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: w * 0.036, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildIllustration(double w, double sway) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _OnbHabitPainter()),
        ),

        Positioned(
          left: w * 0.195,
          top: w * 0.078 + sway * 3,
          width: w * 0.54,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                w * 0.04, w * 0.036, w * 0.04, w * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAF3E6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E6B45).withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBox(w, w * 0.084, Icons.favorite_border_rounded),
                    SizedBox(width: w * 0.028),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Untuk Anda',
                            style: GoogleFonts.inter(
                              fontSize: w * 0.0345,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3B30),
                            ),
                          ),
                          Text(
                            'Langkah sehat hari ini',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: w * 0.0235,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF8A9A92),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.028),
                Container(height: 1, color: const Color(0xFFE8EFE9)),
                SizedBox(height: w * 0.03),
                _habitRow(w, Icons.water_drop_outlined, 'Cukupi air minum'),
                SizedBox(height: w * 0.03),
                _habitRow(w, Icons.air_rounded, 'Jeda untuk bernapas'),
                SizedBox(height: w * 0.03),
                _habitRow(
                    w, Icons.verified_user_outlined, 'Pakai masker saat perlu'),
              ],
            ),
          ),
        ),

        Positioned(
          left: w * 0.138,
          top: w * 0.027 - sway * 2,
          child: Transform.rotate(
            angle: -0.17,
            child: Container(
              width: w * 0.11,
              height: w * 0.11,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(w * 0.032),
                border: Border.all(color: const Color(0xFFEAF3E6), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E6B45).withValues(alpha: 0.16),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(Icons.favorite_border_rounded,
                  size: w * 0.058, color: _OnbColors.green),
            ),
          ),
        ),

        Positioned(
          left: w * 0.32,
          top: w * 0.57 - sway * 3,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.04, vertical: w * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFEAF3E6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E6B45).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_outlined,
                    size: w * 0.04, color: _OnbColors.green),
                SizedBox(width: w * 0.02),
                Text(
                  '3 langkah baik hari ini',
                  style: GoogleFonts.inter(
                    fontSize: w * 0.028,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D4A3E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnbHabitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w * 0.476, w * 0.37);
    final r = w * 0.29;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFEAF4E6), Color(0xFFDCEBD6)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      c,
      r * 1.12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFE6F1E1),
    );

    final dot = Paint()..color = const Color(0xFFCFE4C8);
    canvas.drawCircle(Offset(w * 0.713, w * 0.009), 2, dot);
    canvas.drawCircle(Offset(w * 0.733, w * 0.52), 2.5, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
   

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48, size.height / 48);

    canvas.drawPath(
      Path()
        ..moveTo(45.12, 24.5)
        ..cubicTo(45.12, 22.94, 44.98, 21.44, 44.72, 20)
        ..lineTo(24, 20)
        ..lineTo(24, 28.51)
        ..lineTo(35.84, 28.51)
        ..cubicTo(35.33, 31.26, 33.78, 33.59, 31.45, 35.15)
        ..lineTo(31.45, 40.67)
        ..lineTo(38.56, 40.67)
        ..cubicTo(42.72, 36.84, 45.12, 31.2, 45.12, 24.5)
        ..close(),
      Paint()..color = const Color(0xFF4285F4),
    );
    canvas.drawPath(
      Path()
        ..moveTo(24, 46)
        ..cubicTo(29.94, 46, 34.92, 44.03, 38.56, 40.67)
        ..lineTo(31.45, 35.15)
        ..cubicTo(29.48, 36.47, 26.96, 37.25, 24, 37.25)
        ..cubicTo(18.27, 37.25, 13.42, 33.38, 11.69, 28.18)
        ..lineTo(4.34, 28.18)
        ..lineTo(4.34, 33.88)
        ..cubicTo(7.96, 41.07, 15.4, 46, 24, 46)
        ..close(),
      Paint()..color = const Color(0xFF34A853),
    );
    canvas.drawPath(
      Path()
        ..moveTo(11.69, 28.18)
        ..cubicTo(11.25, 26.86, 11, 25.45, 11, 24)
        ..cubicTo(11, 22.55, 11.25, 21.14, 11.69, 19.82)
        ..lineTo(11.69, 14.12)
        ..lineTo(4.34, 14.12)
        ..cubicTo(2.85, 17.09, 2, 20.45, 2, 24)
        ..cubicTo(2, 27.55, 2.85, 30.91, 4.34, 33.88)
        ..lineTo(11.69, 28.18)
        ..close(),
      Paint()..color = const Color(0xFFFBBC05),
    );
    canvas.drawPath(
      Path()
        ..moveTo(24, 10.75)
        ..cubicTo(27.23, 10.75, 30.13, 11.86, 32.41, 14.04)
        ..lineTo(38.72, 7.73)
        ..cubicTo(34.91, 4.18, 29.93, 2, 24, 2)
        ..cubicTo(15.4, 2, 7.96, 6.93, 4.34, 14.12)
        ..lineTo(11.69, 19.82)
        ..cubicTo(13.42, 14.62, 18.27, 10.75, 24, 10.75)
        ..close(),
      Paint()..color = const Color(0xFFEA4335),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
