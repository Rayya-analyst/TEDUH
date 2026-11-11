import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart' show OnboardingScreen1;
import '../services/voice_flow.dart';
import '../services/voice_service.dart';
import '../state/app_settings.dart';
import '../state/disability_profile.dart';

class AccessibilityIntroPage extends StatefulWidget {
  const AccessibilityIntroPage({super.key});

  @override
  State<AccessibilityIntroPage> createState() => _AccessibilityIntroPageState();
}

class _AccessibilityIntroPageState extends State<AccessibilityIntroPage>
    with SingleTickerProviderStateMixin {
  static const Color _green = Color(0xFF176D59);
  static const Color _ink = Color(0xFF1F3D34);
  static const Color _muted = Color(0xFF6F8279);
  static const Color _bg = Color(0xFFF7FBF8);

  late final AnimationController _pulse;
  bool _decided = false;
  int _stage = 0; 

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      animationBehavior: AppSettings.instance.animBehavior,
    )..repeatUnlessReduced(reverse: true);
    VoiceService.instance.addListener(_onVoice);
    WidgetsBinding.instance.addPostFrameCallback((_) => _voiceFlow());
  }

  @override
  void dispose() {
    VoiceService.instance.removeListener(_onVoice);
    VoiceService.instance.cancelAll();
    _pulse.dispose();
    super.dispose();
  }

  void _onVoice() {
    if (mounted) setState(() {});
  }

  Future<void> _voiceFlow() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted || _decided) return;
    final f = VoiceFlow(() => mounted && !_decided && _stage == 0);
    final a = AppSettings.instance;

    if (a.disabilityMode) {
      if (a.effectiveAutoRead) {
        await f.say('Mode aksesibilitas ${a.dType.shortLabel} masih aktif.');
      }
      _goOnboarding();
      return;
    }

    final yes = await f.askYesNo(
      'Selamat datang di TEDUH. Apakah Anda penyandang disabilitas atau '
      'membutuhkan bantuan aksesibilitas? Jika ya, katakan aktifkan. '
      'Jika tidak, katakan tidak, atau lewati.',
      yes: const ['aktifkan', 'butuh', 'perlu', 'disabilitas', 'tunanetra', 'buta'],
      no: const ['lewati', 'normal', 'tidak', 'tanpa'],
    );
    if (!mounted || _decided || _stage != 0) return;
    if (yes == true) {
      await _activate();
    } else if (yes == false) {
      await _continueNormal();
    }
  }

  Future<void> _activate() async {
    if (_decided || _stage == 1) return;
    await VoiceService.instance.cancelAll();
    if (!mounted) return;
    setState(() => _stage = 1);
    _askType();
  }

  static const String _typeQuestion =
      'Apa jenis disabilitas Anda, supaya TEDUH bisa menyesuaikan? '
      'Katakan: tunanetra jika tidak bisa melihat. Low vision jika sulit '
      'melihat. Tunarungu jika sulit mendengar. Tunawicara jika sulit '
      'berbicara. Tunadaksa jika sulit menggerakkan tangan. Intelektual jika '
      'sulit memahami. Atau ganda jika lebih dari satu.';

  Future<void> _askType() async {
    final f = VoiceFlow(() => mounted && !_decided && _stage == 1);
    for (int i = 0; i < 4; i++) {
      final heard = await f.ask(
        i == 0
            ? _typeQuestion
            : 'Maaf, jenis disabilitas belum dikenali. Coba sebutkan lagi, '
                'misalnya tunanetra, low vision, tunarungu, tunawicara, '
                'tunadaksa, intelektual, atau ganda.',
        tries: 1,
      );
      if (!mounted || _decided) return;
      final type = DisabilityType.parse(heard);
      if (type == null) continue;
      final ok = await f.askYesNo(
        'Anda memilih ${type.shortLabel}. Apakah benar? Katakan ya atau tidak.',
      );
      if (!mounted || _decided) return;
      if (ok == true) {
        await _chooseType(type);
        return;
      }
    }
  }

  Future<void> _chooseType(DisabilityType type) async {
    if (_decided) return;
    _decided = true;
    await VoiceService.instance.cancelAll();
    final a = AppSettings.instance;
    a.applyDisabilityType(type);
    final msg = 'Baik, TEDUH disesuaikan untuk ${type.shortLabel}. '
        '${type.adaptation}';
    if (a.effectiveAutoRead) {
      await VoiceService.instance.speak(msg);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 4),
        ),
      );
      await Future<void>.delayed(const Duration(seconds: 3));
    }
    _goOnboarding();
  }

  Future<void> _continueNormal() async {
    if (_decided) return;
    _decided = true;
    await VoiceService.instance.cancelAll();
    _goOnboarding();
  }

  void _goOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, _, _) => const OnboardingScreen1(),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  List<Widget> _typeCards() {
    const items = <(DisabilityType, IconData, String)>[
      (DisabilityType.blind, Icons.visibility_off_rounded,
          'Tidak bisa melihat. Seluruh halaman dijelaskan dengan suara.'),
      (DisabilityType.lowVision, Icons.zoom_in_rounded,
          'Sulit melihat. Teks besar, kontras tinggi, dan suara.'),
      (DisabilityType.deaf, Icons.hearing_disabled_rounded,
          'Sulit mendengar. Semua informasi berupa teks dan getar.'),
      (DisabilityType.speech, Icons.voice_over_off_rounded,
          'Sulit berbicara. Semua lewat sentuhan dan ketikan.'),
      (DisabilityType.motor, Icons.accessible_rounded,
          'Sulit menggerakkan tangan. Dikendalikan dengan suara.'),
      (DisabilityType.cognitive, Icons.psychology_alt_rounded,
          'Sulit memahami. Bahasa sederhana dan langkah pelan.'),
      (DisabilityType.multiple, Icons.layers_rounded,
          'Lebih dari satu. Semua dukungan diaktifkan.'),
    ];
    return [
      Text(
        'Jenis disabilitas apa yang kamu alami?',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontSize: 17, fontWeight: FontWeight.w700, color: _ink),
      ),
      const SizedBox(height: 6),
      Text(
        'Pilih satu, atau sebutkan dengan suara. TEDUH akan menyesuaikan diri.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 12.5, height: 1.5, color: _muted),
      ),
      const SizedBox(height: 14),
      for (final it in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Semantics(
            button: true,
            label: '${it.$1.shortLabel}. ${it.$3}',
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _chooseType(it.$1),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE4ECE6)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F3EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(it.$2, color: _green, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it.$1.shortLabel,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _ink)),
                            Text(it.$3,
                                style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    height: 1.4,
                                    color: _muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      TextButton(
        onPressed: _continueNormal,
        child: Text('Bukan, lanjutkan seperti biasa',
            style: GoogleFonts.poppins(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: _green)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final v = VoiceService.instance;
    final listening = v.state == VoiceState.listening;
    final speaking = v.state == VoiceState.speaking;
    final status = listening
        ? 'Mendengarkan jawabanmu...'
        : speaking
            ? 'TEDUH sedang berbicara...'
            : 'Ketuk pilihan di bawah, atau jawab dengan suara';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco_rounded, color: _green, size: 34),
                  const SizedBox(width: 8),
                  Text('TEDUH',
                      style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: _green)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Hidup Sehat, Udara Sehat',
                  style: GoogleFonts.poppins(fontSize: 12.5, color: _green)),
              const SizedBox(height: 28),
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final k = listening ? _pulse.value : 0.0;
                  return Container(
                    width: 150 + 14 * k,
                    height: 150 + 14 * k,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _green.withValues(alpha: 0.08 + 0.08 * k),
                      border: Border.all(
                          color: _green.withValues(alpha: 0.25), width: 1.2),
                    ),
                    child: Center(
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          listening
                              ? Icons.mic_rounded
                              : Icons.accessibility_new_rounded,
                          size: 56,
                          color: _green,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 26),
              Semantics(
                header: true,
                child: Text('Sesuaikan TEDUH untukmu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
              ),
              const SizedBox(height: 10),
              if (_stage == 1) ..._typeCards() else ...[
              Text(
                'Apakah kamu membutuhkan fitur aksesibilitas? Kami bisa '
                'menyesuaikan seluruh aplikasi dengan kebutuhanmu.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13.5, height: 1.55, color: _muted),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4ECE6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final t in const [
                      'Panduan yang sesuai kebutuhanmu',
                      'Teks, suara, dan tampilan yang menyesuaikan',
                      'Masuk dan daftar tanpa kesulitan',
                      'Peringatan udara berbahaya lewat suara, getar, atau layar',
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 18, color: _green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(t,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12.5, color: _ink)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              ],
              const SizedBox(height: 14),
              Semantics(
                liveRegion: true,
                child: Text(
                  v.transcript.isNotEmpty && listening
                      ? '“${v.transcript}”'
                      : status,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _green),
                ),
              ),
              const SizedBox(height: 16),
              if (_stage == 0) ...[
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _activate,
                  icon: const Icon(Icons.record_voice_over_rounded),
                  label: Text('Ya, aktifkan aksesibilitas',
                      style: GoogleFonts.poppins(
                          fontSize: 14.5, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _continueNormal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F3EB),
                    foregroundColor: _green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text('Tidak, lanjutkan seperti biasa',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
              ],
              const SizedBox(height: 10),
              Text('Bisa diubah kapan saja di Profil › Aksesibilitas.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 11, color: _muted)),
            ],
          ),
        ),
      ),
    );
  }
}
