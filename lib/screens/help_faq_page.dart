import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/coach_marks.dart';
import '../widgets/teduh_common.dart';
import '../widgets/voice_scope.dart';

class _Faq {
  final String question;
  final String answer;
  final String highlight;
  const _Faq(this.question, this.answer, this.highlight);
}

const List<_Faq> _faqs = [
  _Faq(
    'Apa itu ISPU dan cara membacanya?',
    'ISPU adalah Indeks Standar Pencemar Udara. Semakin rendah nilainya, '
        'semakin baik kualitas udara di sekitarmu.',
    '0–50: Baik untuk beraktivitas di luar.',
  ),
  _Faq(
    'Seberapa sering data udara diperbarui?',
    'Data diperbarui secara berkala dari stasiun pemantau BMKG dan KLH '
        'terdekat. Jika sumber sedang gangguan, data terakhir tetap '
        'ditampilkan.',
    'Tarik layar ke bawah untuk memuat ulang.',
  ),
  _Faq(
    'Kapan saya perlu memakai masker?',
    'Disarankan memakai masker saat ISPU di atas 100, terutama bagi anak, '
        'lansia, dan penderita gangguan pernapasan.',
    'Saat kabut asap, gunakan masker N95.',
  ),
  _Faq(
    'Bagaimana mengaktifkan Siaga Udara?',
    'Buka menu Notifikasi lalu aktifkan Peringatan Kualitas Udara. Kamu akan '
        'mendapat kabar saat udara mulai tidak sehat.',
    'Profil › Notifikasi › Peringatan Kualitas Udara.',
  ),
  _Faq(
    'Bagaimana cara menggunakan Konsultasi AI?',
    'Ketuk menu Konsultasi AI, tuliskan keluhan atau pertanyaan tentang '
        'udara, lalu ikuti saran yang diberikan.',
    'Saran AI bukan pengganti dokter.',
  ),
];

class HelpFaqPage extends StatefulWidget {
  const HelpFaqPage({super.key});

  @override
  State<HelpFaqPage> createState() => _HelpFaqPageState();
}

class _HelpFaqPageState extends State<HelpFaqPage> {
  final _searchC = TextEditingController();
  final _searchF = FocusNode();
  int? _open = 0; 
  String _query = '';
  final List<GlobalKey> _hk = List<GlobalKey>.generate(4, (_) => GlobalKey());

  List<CoachStep> get _tour => [
        CoachStep(
          target: _hk[0],
          title: 'Pusat bantuan',
          body: 'Halaman ini menjawab pertanyaan yang sering diajukan '
              'tentang TEDUH dan kualitas udara.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _hk[1],
          title: 'Cari jawaban',
          body: 'Ketik kata kunci seperti masker atau ISPU, dan daftar '
              'pertanyaan langsung menyaring sesuai kata itu.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _hk[2],
          title: 'Pertanyaan populer',
          body: 'Ketuk sebuah pertanyaan untuk membuka jawabannya, ketuk '
              'lagi untuk menutup.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _hk[3],
          title: 'Masih butuh bantuan?',
          body: 'Hubungi tim TEDUH lewat tombol dukungan, setiap hari pukul '
              'delapan pagi sampai delapan malam.',
          scrollAlignment: 0.6,
        ),
      ];

  String _narration() {
    final b = StringBuffer('Ini seluruh isi halaman Bantuan dan FAQ. Ada '
        'kolom pencarian, lalu ${_faqs.length} pertanyaan populer. ');
    for (int i = 0; i < _faqs.length; i++) {
      b.write('Pertanyaan ${i + 1}: ${_faqs[i].question} '
          '${_faqs[i].answer} ');
    }
    b.write('Di bagian bawah ada tombol Hubungi Dukungan, tim TEDUH siap '
        'membantu pukul delapan pagi sampai delapan malam. ');
    return b.toString();
  }

  @override
  void dispose() {
    _searchC.dispose();
    _searchF.dispose();
    super.dispose();
  }

  List<int> get _filtered {
    final q = _query.trim().toLowerCase();
    return [
      for (int i = 0; i < _faqs.length; i++)
        if (q.isEmpty ||
            _faqs[i].question.toLowerCase().contains(q) ||
            _faqs[i].answer.toLowerCase().contains(q))
          i,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return VoiceScope(
      screen: 'help',
      tour: _tour,
      guide: PageGuide(
        content: _narration,
        endText: 'Itu seluruh fitur utama TEDUH. Panduan selesai. Kamu tidak '
            'perlu menekan tombol: cukup ucapkan perintah kapan saja, '
            'misalnya buka TEDUH NOW, buka TEDUH ACTION, bacakan kondisi '
            'udara, atau tanyakan apa saja kepada Asisten AI. Ucapkan '
            'ulangi panduan bila ingin mendengar penjelasan ini lagi.',
      ),
      child: TeduhPage(
      title: 'Bantuan dan FAQ',
      builder: (context, anim) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            animation: anim,
            begin: 0.1,
            end: 0.45,
            child: KeyedSubtree(
              key: _hk[0],
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ada yang bisa kami bantu?',
                  style: GoogleFonts.poppins(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C3A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan jawaban untuk napas lebih tenang.',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: TC.hint),
                ),
              ],
            ),
            ),
          ),

          const SizedBox(height: 18),

          Reveal(
            animation: anim,
            begin: 0.2,
            end: 0.55,
            child: KeyedSubtree(
              key: _hk[1],
              child: AnimatedBuilder(
              animation: _searchF,
              builder: (context, _) {
                final focused = _searchF.hasFocus;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: focused ? TC.green : TC.border,
                      width: focused ? 1.2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          size: 22, color: TC.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchC,
                          focusNode: _searchF,
                          cursorColor: TC.green,
                          textInputAction: TextInputAction.search,
                          onChanged: (v) => setState(() => _query = v),
                          style: GoogleFonts.poppins(
                              fontSize: 12.5, color: TC.dark),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: 'Cari pertanyaan atau topik...',
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 12.5, color: TC.hint),
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchC.clear();
                            setState(() => _query = '');
                          },
                          child: const Icon(Icons.close_rounded,
                              size: 20, color: TC.hint),
                        ),
                    ],
                  ),
                );
              },
            ),
            ),
          ),

          const SizedBox(height: 22),

          Reveal(
            animation: anim,
            begin: 0.3,
            end: 0.65,
            child: Text(
              'Pertanyaan populer',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C3A2E),
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 34, color: TC.hint),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada hasil untuk "$_query"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12, color: TC.hint),
                    ),
                  ],
                ),
              ),
            )
          else
            for (int k = 0; k < items.length; k++) ...[
              Reveal(
                animation: anim,
                begin: 0.35 + k * 0.08,
                end: 0.75 + k * 0.06,
                child: KeyedSubtree(
                  key: k == 0 ? _hk[2] : null,
                  child: _FaqCard(
                    faq: _faqs[items[k]],
                    open: _open == items[k],
                    onTap: () => setState(
                      () => _open = _open == items[k] ? null : items[k],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

          const SizedBox(height: 14),

          Reveal(
            animation: anim,
            begin: 0.6,
            end: 1.0,
            child: KeyedSubtree(
              key: _hk[3],
              child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3EA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.headset_mic_outlined,
                          size: 24, color: TC.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Masih butuh bantuan?',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1C3A2E),
                              ),
                            ),
                            Text(
                              'Tim TEDUH siap membantu, 08.00–20.00.',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: TC.hint),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SupportButton(
                    onTap: () => showSoon(context, 'Hubungi Dukungan'),
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    ));
  }
}

class _FaqCard extends StatelessWidget {
  final _Faq faq;
  final bool open;
  final VoidCallback onTap;

  const _FaqCard({required this.faq, required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: open ? const Color(0xFFEAF5EE) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: open ? const Color(0xFFD3E8DA) : TC.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: open ? TC.green : const Color(0xFF1C3A2E),
                      ),
                      child: Text(faq.question),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 22, color: TC.green),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFD7E8DC),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          faq.answer,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            height: 1.55,
                            color: TC.hint,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded,
                                size: 16, color: TC.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                faq.highlight,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: TC.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _SupportButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SupportButton({required this.onTap});

  @override
  State<_SupportButton> createState() => _SupportButtonState();
}

class _SupportButtonState extends State<_SupportButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: TC.green,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: TC.green.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  size: 17, color: Colors.white),
              const SizedBox(width: 9),
              Text(
                'Hubungi Dukungan',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
