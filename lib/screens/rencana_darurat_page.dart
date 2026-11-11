import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';
import 'readiness_state.dart';

class _PlanStep {
  final String title;
  final String desc;
  final bool danger;
  const _PlanStep(this.title, this.desc, {this.danger = false});
}

const List<_PlanStep> _planSteps = [
  _PlanStep('Pantau informasi resmi',
      'Cek ISPU dan arahan BPBD atau pemerintah setempat. Ikuti instruksi evakuasi bila ada.'),
  _PlanStep('Cari udara yang lebih bersih',
      'Pindah ke ruang dalam yang lebih bersih. Tutup bukaan dan kurangi aktivitas berat di luar.'),
  _PlanStep('Siapkan & koordinasikan',
      'Bawa tas siaga dan obat rutin. Sepakati titik kumpul, lalu kabari anggota rumah tangga.'),
  _PlanStep('Kenali tanda bahaya',
      'Jika sesak berat atau nyeri dada, segera cari bantuan medis darurat. Jangan menunggu membaik.',
      danger: true),
];

class RencanaDaruratPage extends StatelessWidget {
  const RencanaDaruratPage({super.key});

  static final SectionKeys _sk = SectionKeys(6);

  List<CoachStep> get _tour => [
        CoachStep(
          target: _sk.keys[0],
          title: 'Panduan kesiapsiagaan',
          body: 'Ringkasan langkah tenang saat kabut asap terjadi di sekitarmu.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _sk.keys[1],
          title: 'Langkah utama',
          body: 'Urutan tindakan yang perlu dilakukan. Baca dari atas ke bawah.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _sk.keys[2],
          title: 'Kontak darurat keluarga',
          body: 'Ketuk untuk menyimpan nama dan nomor kontak yang bisa dihubungi. Tombol Atur Kontak Darurat di bawah layar juga membukanya.',
          scrollAlignment: 0.3,
        ),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'rencana_darurat',
        tour: _tour,
        guide: PageGuide(
          content: () => 'Ini halaman Rencana Darurat. Berisi ringkasan langkah tenang saat kabut asap terjadi, urutan langkah utama yang dibaca dari atas ke bawah, dan kontak darurat keluarga. Sekarang ada ${ReadinessState.instance.contacts.length} kontak tersimpan. Tombol Atur Kontak Darurat ada di bawah layar. Ucapkan kembali untuk ke halaman sebelumnya.',
        ),
        child: _scaffold(context),
      );

  Widget _scaffold(BuildContext context) {
    final s = ReadinessState.instance;
    return ReadyScaffold(
      title: 'Rencana Darurat',
      bottom: ReadyButton(
        label: 'Atur Kontak Darurat',
        icon: Icons.call_outlined,
        onTap: () => _openContacts(context),
      ),
      builder: (context, anim) {
_sk.reset();
        Widget r(double b, double e, Widget c) =>
            Reveal(animation: anim, begin: b, end: e, child: _sk.wrap(c));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            r(
              0.05,
              0.45,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PANDUAN KESIAPSIAGAAN',
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
                        TextSpan(text: 'Langkah tenang\nsaat '),
                        TextSpan(
                            text: 'kabut asap.',
                            style: TextStyle(color: RC.green)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Siapkan rencana ini sebelum dibutuhkan.',
                    style: GoogleFonts.poppins(fontSize: 12.5, color: RC.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            r(
              0.15,
              0.55,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Utamakan langkah berikut',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: RC.dark,
                      ),
                    ),
                  ),
                  Text(
                    '${_planSteps.length} LANGKAH',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: RC.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < _planSteps.length; i++)
              r(0.2 + i * 0.08, 0.62 + i * 0.08, _stepCard(i, _planSteps[i])),
            const SizedBox(height: 6),
            r(
              0.6,
              1.0,
              ListenableBuilder(
                listenable: s,
                builder: (context, _) => _contactCard(context, s),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stepCard(int i, _PlanStep s) {
    final danger = s.danger;
    final titleColor = danger ? const Color(0xFF7A4E0C) : RC.dark;
    final descColor = danger ? const Color(0xFF9A6A12) : RC.grey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: danger ? const Color(0xFFFBECD0) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: danger ? const Color(0xFFF1D9A6) : RC.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: danger ? const Color(0xFFF2D9A0) : RC.tile,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${i + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: danger ? const Color(0xFF9A6A12) : RC.green,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.desc,
                    style: GoogleFonts.poppins(
                        fontSize: 11.5, height: 1.55, color: descColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(BuildContext context, ReadinessState s) {
    final n = s.contacts.length;
    final subtitle = n == 0
        ? 'Belum ditambahkan'
        : (n == 1 ? s.contacts.first.name : '$n kontak tersimpan');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openContacts(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: RC.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: RC.tile,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.group_outlined,
                        size: 23, color: RC.green),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kontak keluarga',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: RC.dark,
                          ),
                        ),
                        Text(
                          subtitle,
                          style:
                              GoogleFonts.poppins(fontSize: 11, color: RC.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: RC.grey),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Simpan nomor keluarga & layanan darurat lokal. Catat siapa '
                'yang perlu bantuan saat berpindah.',
                style: GoogleFonts.poppins(
                    fontSize: 11, height: 1.55, color: RC.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openContacts(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => const _ContactsSheet(),
    );
  }
}

class _ContactsSheet extends StatefulWidget {
  const _ContactsSheet();

  @override
  State<_ContactsSheet> createState() => _ContactsSheetState();
}

class _ContactsSheetState extends State<_ContactsSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: RC.grey),
        prefixIcon: Icon(icon, size: 20, color: RC.green),
        filled: true,
        fillColor: const Color(0xFFF3F8F4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  void _save() {
    ReadinessState.instance.addContact(_name.text, _phone.text);
    _name.clear();
    _phone.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final s = ReadinessState.instance;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: ListenableBuilder(
        listenable: s,
        builder: (context, _) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RC.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kontak Darurat',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RC.dark,
                ),
              ),
              Text(
                'Simpan nomor keluarga & layanan darurat lokal.',
                style: GoogleFonts.poppins(fontSize: 11.5, color: RC.grey),
              ),
              const SizedBox(height: 14),
              for (final c in s.contacts)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
                  decoration: BoxDecoration(
                    color: RC.tile,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 20, color: RC.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name,
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: RC.dark)),
                            Text(c.phone,
                                style: GoogleFonts.poppins(
                                    fontSize: 11.5, color: RC.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => s.removeContact(c),
                        icon: const Icon(Icons.close_rounded,
                            size: 19, color: RC.grey),
                      ),
                    ],
                  ),
                ),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.poppins(fontSize: 13.5),
                decoration: _deco('Nama (mis. Ibu, Puskesmas)',
                    Icons.person_outline_rounded),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(fontSize: 13.5),
                decoration: _deco('Nomor telepon', Icons.call_outlined),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 14),
              ReadyButton(
                label: 'Simpan Kontak',
                icon: Icons.check_rounded,
                onTap: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
