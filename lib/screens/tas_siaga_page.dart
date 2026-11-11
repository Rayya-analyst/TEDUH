import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';
import 'readiness_state.dart';
import '../services/voice_service.dart';
import '../state/app_settings.dart';

class TasSiagaPage extends StatelessWidget {
  const TasSiagaPage({super.key});

  static final GlobalKey _kHero = GlobalKey();
  static final GlobalKey _kProgress = GlobalKey();
  static final GlobalKey _kItems = GlobalKey();
  static final GlobalKey _kDaily = GlobalKey();
  static final GlobalKey _kSave = GlobalKey();
  static final GlobalKey _kAdd = GlobalKey();

  List<CoachStep> get _tour => [
        CoachStep(
          target: _kHero,
          title: 'Perlengkapan kabut asap',
          body: 'Halaman ini menyatukan tas siaga dan langkah harianmu dalam satu tempat.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _kProgress,
          title: 'Kesiapan tasmu',
          body: 'Persentase kesiapan tas siagamu. Angkanya berubah setiap kali kamu mencentang item.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _kItems,
          title: 'Centang yang sudah siap',
          body: 'Setiap kategori memuat daftar perlengkapan, seperti masker N95. Ketuk item untuk mencentang.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _kDaily,
          title: 'Langkah harian',
          body: 'Checklist kebiasaan harian seperti memakai masker dan mengecek udara sebelum keluar. Ketuk untuk menandai selesai.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _kSave,
          title: 'Simpan Progress',
          body: 'Ketuk tombol ini untuk menyimpan centangan dan item kustommu di perangkat.',
        ),
        CoachStep(
          target: _kAdd,
          title: 'Tambah Item Kustom',
          body: 'Buat item perlengkapan milikmu sendiri, lalu centang bila sudah siap.',
        ),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'tas_siaga',
        tour: _tour,
        guide: PageGuide(
          content: () {
            final r = ReadinessState.instance;
            final items = r.packItems
                .map((e) => '${e.name}, ${e.checked ? "sudah siap" : "belum siap"}')
                .join('; ');
            return 'Ini halaman Tas Siaga Haze. Kesiapan tasmu ${r.packPercent} persen, ${r.packDone} dari ${r.packTotal} item sudah tercentang. Isinya: $items. Ada tombol Tambah Item Kustom, atau kamu bisa berkata tambah item senter. Ucapkan kembali untuk ke halaman sebelumnya.';
          },
        ),
        child: _scaffold(context),
      );

  Widget _scaffold(BuildContext context) {
    final s = ReadinessState.instance;
    return ReadyScaffold(
      title: 'Tas Siaga Haze',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.backpack_outlined, size: 14, color: RC.grey),
              const SizedBox(width: 8),
              Text(
                'Centang item yang sudah masuk ke tas siagamu.',
                style: GoogleFonts.poppins(fontSize: 10.5, color: RC.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          KeyedSubtree(
            key: _kSave,
            child: ReadyButton(
              label: 'Simpan Progress',
              icon: Icons.save_outlined,
              onTap: () => _saveProgress(context),
            ),
          ),
          const SizedBox(height: 8),
          KeyedSubtree(
            key: _kAdd,
            child: ReadyButton(
              label: 'Tambah Item Kustom',
              icon: Icons.add_rounded,
              color: const Color(0xFF3E6B55),
              onTap: () => _addCustom(context),
            ),
          ),
        ],
      ),
      builder: (context, anim) {
        Widget r(double b, double e, Widget c) =>
            Reveal(animation: anim, begin: b, end: e, child: c);

        return ListenableBuilder(
          listenable: s,
          builder: (context, _) {
            final cats = [kCatAir, kCatMedis, kCatCustom];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                r(
                  0.05,
                  0.45,
                  KeyedSubtree(
                    key: _kHero,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PERLENGKAPAN KABUT ASAP',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          letterSpacing: 0.5,
                          color: RC.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: RC.dark,
                          ),
                          children: const [
                            TextSpan(
                                text: 'Siap lebih awal,\n',
                                style: TextStyle(color: RC.green)),
                            TextSpan(text: 'lebih tenang.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                const SizedBox(height: 16),
                r(0.12, 0.55, KeyedSubtree(key: _kProgress, child: _progressCard(s))),
                const SizedBox(height: 22),
                KeyedSubtree(
                  key: _kItems,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int ci = 0; ci < cats.length; ci++)
                        ..._section(context, s, cats[ci], r, 0.2 + ci * 0.1),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                KeyedSubtree(
                  key: _kDaily,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      r(
                        0.5,
                        0.9,
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Langkah Harian',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: RC.dark,
                                ),
                              ),
                            ),
                            Text('${s.stepsDone}/${s.stepsTotal}',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: RC.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final step in s.steps)
                        r(0.55, 1.0, _stepRow(s, step)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _saveProgress(BuildContext context) async {
    final ok = await ReadinessState.instance.save();
    final msg = ok
        ? 'Progres berhasil disimpan.'
        : 'Progres belum bisa disimpan. Coba lagi.';
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ));
    }
    if (AppSettings.instance.effectiveAutoRead) {
      VoiceService.instance.speak(msg);
    }
  }

  Widget _stepRow(ReadinessState s, ReadyStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => s.toggleStep(step),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RC.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2EA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(step.icon, size: 24, color: const Color(0xFF3E6B55)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: RC.dark,
                        ),
                      ),
                      Text(
                        step.subtitle,
                        style:
                            GoogleFonts.poppins(fontSize: 10.5, color: RC.grey),
                      ),
                    ],
                  ),
                ),
                ReadyCheck(
                    checked: step.done, fill: const Color(0xFF2C5F4A)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _section(BuildContext context, ReadinessState s, String cat,
      Widget Function(double, double, Widget) r, double start) {
    final items = s.packItems.where((e) => e.category == cat).toList();
    if (items.isEmpty) return [];
    final done = items.where((e) => e.checked).length;
    return [
      r(
        start,
        start + 0.4,
        Row(
          children: [
            Expanded(
              child: Text(
                cat,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: RC.dark,
                ),
              ),
            ),
            Text('$done/${items.length}',
                style: GoogleFonts.poppins(fontSize: 11, color: RC.grey)),
          ],
        ),
      ),
      const SizedBox(height: 10),
      for (final item in items)
        r(start + 0.05, start + 0.45, _itemRow(context, s, item)),
      const SizedBox(height: 8),
    ];
  }

  Widget _progressCard(ReadinessState s) {
    final left = s.packTotal - s.packDone;
    final msg = left <= 0
        ? 'Tas siagamu sudah lengkap.'
        : '${numberWord(left)} perlengkapan lagi untuk melengkapi tasmu.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${s.packPercent}% Terpenuhi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RC.green,
                  ),
                ),
              ),
              Text(
                '${s.packDone} dari ${s.packTotal} item',
                style: GoogleFonts.poppins(fontSize: 11, color: RC.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 9, color: const Color(0xFFE3EEE6)),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  widthFactor: s.packFraction.clamp(0.0, 1.0),
                  child: Container(height: 9, color: RC.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(msg,
              style: GoogleFonts.poppins(fontSize: 11, color: RC.grey)),
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, ReadinessState s, PackItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => s.togglePack(item),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RC.border),
            ),
            child: Row(
              children: [
                ReadyCheck(checked: item.checked),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: RC.dark,
                    ),
                  ),
                ),
                if (item.hasDetail)
                  IconButton(
                    onPressed: () => showSoon(context, item.name),
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: RC.grey),
                  ),
                if (item.custom)
                  IconButton(
                    onPressed: () => s.removePack(item),
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: RC.grey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addCustom(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _AddItemDialog(),
    );
    if (name != null) ReadinessState.instance.addCustomItem(name);
  }
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final TextEditingController _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        'Tambah Item Kustom',
        style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w700, color: RC.dark),
      ),
      content: TextField(
        controller: _c,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        style: GoogleFonts.poppins(fontSize: 13.5),
        decoration: InputDecoration(
          hintText: 'Mis. Senter, power bank',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: RC.grey),
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal', style: GoogleFonts.poppins(color: RC.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_c.text),
          child: Text('Tambah',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, color: RC.green)),
        ),
      ],
    );
  }
}
