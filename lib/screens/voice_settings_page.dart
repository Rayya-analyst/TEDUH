import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/siren_service.dart';
import '../services/voice_service.dart';
import '../state/app_settings.dart';
import '../widgets/teduh_common.dart';

class VoiceSettingsPage extends StatefulWidget {
  const VoiceSettingsPage({super.key});

  @override
  State<VoiceSettingsPage> createState() => _VoiceSettingsPageState();
}

class _VoiceSettingsPageState extends State<VoiceSettingsPage> {
  AppSettings get _s => AppSettings.instance;
  bool _testingSiren = false;
  final SectionKeys _sk = SectionKeys(6);

  List<CoachStep> get _tour => [
        CoachStep(
          target: _sk.keys[1],
          title: 'Suara dan navigasi',
          body: 'Nyalakan Navigasi Suara untuk membuka halaman dengan bicara. Baca Otomatis membacakan hasil analisis. Geser Kecepatan Suara, lalu ketuk Coba suara.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _sk.keys[3],
          title: 'Sirene peringatan',
          body: 'Saat udara berbahaya, TEDUH membunyikan sirene dan bergetar, dan pesannya juga tertulis di layar. Ketuk Uji sirene untuk mencoba bunyinya.',
          scrollAlignment: 0.3,
        ),
      ];


  @override
  void initState() {
    super.initState();
    _s.addListener(_onChange);
  }

  @override
  void dispose() {
    _s.removeListener(_onChange);
    VoiceService.instance.stopSpeaking();
    SirenService.instance.stop();
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  Widget _switch(String title, String subtitle, bool value,
      ValueChanged<bool>? onChanged) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: TC.dark)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.poppins(fontSize: 10, color: TC.hint)),
                ],
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: TC.greenDeep,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, thickness: 1, indent: 16, endIndent: 16, color: TC.divider);

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TC.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: children),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(t,
            style: GoogleFonts.poppins(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: TC.dark)),
      );

  @override
  Widget build(BuildContext context) {
    final speaking = VoiceService.instance.state == VoiceState.speaking;
    return VoiceScope(
      screen: 'voice_settings',
      tour: _tour,
      guide: PageGuide(
        content: () => 'Ini halaman Pengaturan Suara. Berisi Navigasi Suara, Baca Otomatis, Kecepatan Suara dengan tombol Coba suara, dan Sirene peringatan dengan tombol Uji sirene. Kamu bisa berkata suara lebih cepat, suara lebih lambat, matikan sirene, atau nyalakan sirene. Ucapkan kembali untuk ke halaman sebelumnya.',
      ),
      child: TeduhPage(
      title: 'Pengaturan Suara',
      builder: (context, anim) {
        _sk.reset();
        Widget r(double b, double e, Widget c) =>
            Reveal(animation: anim, begin: b, end: e, child: _sk.wrap(c));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            r(0.0, 0.5, _label('Suara & navigasi')),
            r(0.1, 0.6, _card([
              _switch(
                'Navigasi Suara',
                _s.effectiveVoiceNav
                    ? 'Aktif · Langsung ucapkan perintah, tanpa menekan tombol'
                    : 'Nonaktif',
                _s.effectiveVoiceNav,
                _s.disabilityMode
                    ? null
                    : (v) => _s.update(() => _s.voiceNavigation = v),
              ),
              _divider(),
              _switch(
                'Baca Otomatis',
                _s.effectiveAutoRead
                    ? 'Aktif · Hasil analisis dibacakan saat halaman dibuka'
                    : 'Nonaktif · Ketuk tombol Dengarkan untuk membaca',
                _s.effectiveAutoRead,
                (_s.disabilityMode || _s.screenReader)
                    ? null
                    : (v) => _s.update(() => _s.autoRead = v),
              ),
              _divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Kecepatan Suara',
                              style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: TC.dark)),
                        ),
                        Text(
                          _s.speechRate < 0.4
                              ? 'Lambat'
                              : _s.speechRate > 0.6
                                  ? 'Cepat'
                                  : 'Normal',
                          style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: TC.greenDeep),
                        ),
                      ],
                    ),
                    Slider(
                      value: _s.speechRate,
                      min: 0.25,
                      max: 0.8,
                      divisions: 11,
                      activeColor: TC.greenDeep,
                      label: _s.speechRate.toStringAsFixed(2),
                      onChanged: (v) => _s.update(() => _s.speechRate = v),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => speaking
                            ? VoiceService.instance.stopSpeaking()
                            : VoiceService.instance.speak(
                                'Halo, ini contoh suara TEDUH. Kualitas udara '
                                'hari ini perlu diperhatikan.'),
                        icon: Icon(
                            speaking
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            size: 18),
                        label: Text(speaking ? 'Hentikan' : 'Coba suara'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TC.greenDeep,
                          side: const BorderSide(color: TC.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])),
            const SizedBox(height: 18),
            r(0.3, 0.7, _label('Peringatan siaga')),
            r(0.4, 0.9, _card([
              _switch(
                'Sirene Peringatan',
                _s.sirenEnabled
                    ? 'Aktif · Bunyi sirene + getar saat udara berbahaya'
                    : 'Nonaktif · Hanya getar dan peringatan di layar',
                _s.sirenEnabled,
                (v) => _s.update(() => _s.sirenEnabled = v),
              ),
              _divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: (!_s.sirenEnabled || _testingSiren)
                        ? null
                        : () async {
                            HapticFeedback.selectionClick();
                            setState(() => _testingSiren = true);
                            await SirenService.instance.test();
                            if (mounted) setState(() => _testingSiren = false);
                          },
                    icon: const Icon(Icons.campaign_rounded, size: 18),
                    label: Text(_testingSiren
                        ? 'Menguji sirene...'
                        : 'Uji sirene 3 detik'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB3261E),
                      side: const BorderSide(color: TC.border),
                    ),
                  ),
                ),
              ),
            ])),
            const SizedBox(height: 22),
            r(0.7, 1.0, const NoteRow(
              icon: Icons.hearing_disabled_outlined,
              text: 'Peringatan selalu ada versi teks dan getarannya juga.',
            )),
          ],
        );
      },
    ));
  }
}
