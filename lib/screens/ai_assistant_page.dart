import 'package:flutter/material.dart';
import '../services/ai_bridge.dart';
import '../services/voice_service.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import '../state/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';

const String _a1Title = 'Kita utamakan napas si kecil dulu.';
const String _a1Intro = 'Saya paham ini mengkhawatirkan. Pada contoh kondisi '
    'berbahaya ini, anak lebih rentan terhadap asap. Lakukan langkah berikut '
    'bersama keluarga.';
const List<List<String>> _a1Steps = [
  [
    '1. Masuk ke ruang paling bersih',
    'Tutup pintu dan jendela. Gunakan penyaring HEPA bila tersedia, dan atur '
        'AC ke sirkulasi dalam. Hindari rokok, dupa, atau membakar apa pun.'
  ],
  [
    '2. Tunda semua aktivitas luar',
    'Jangan bermain di teras atau berolahraga. Pilih aktivitas tenang di '
        'dalam. Jika asap tetap masuk, cari ruang berfilter yang lebih aman '
        'sesuai arahan setempat.'
  ],
  [
    '3. Perhatikan napasnya',
    'Pantau batuk, mengi, atau napas lebih cepat. Bila punya asma, ikuti '
        'rencana dan obat dari dokter; jangan menambah dosis sendiri.'
  ],
];
const String _a1AlertTitle = 'Segera ke IGD jika gejala berat';
const String _a1AlertBody = 'Sulit bernapas, bibir kebiruan, sangat lemas, atau '
    'nyeri dada. Jangan menunggu balasan saya.';
const String _a1Question =
    'Apakah anak Anda sedang batuk atau memiliki riwayat asma?';

const String _a2Title = 'Masker kain tidak cukup untuk asap halus.';
const String _a2P1 = 'Jika benar-benar harus keluar, gunakan respirator N95 '
    'yang rapat untuk orang dewasa. Untuk anak, ukuran dan kerapatan sangat '
    'penting; jangan mengandalkan masker yang longgar.';
const String _a2P2 = 'Pilihan paling aman adalah anak tetap di ruang berudara '
    'bersih bersama pendamping. Persingkat perjalanan dan hindari aktivitas '
    'fisik berat. Masker tidak menghilangkan seluruh risiko.';

const List<String> _suggestions = [
  'Tanpa penyaring udara?',
  'Cara cek masker rapat?',
  'Kapan harus ke IGD?',
  'Ruang aman untuk anak?',
];

class _Msg {
  final bool fromUser;
  final String text;
  final String time;
  const _Msg(this.fromUser, this.text, this.time);
}

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Msg> _extra = [];

  static const _bg = Color(0xFFF3F6F2);
  static const _userBubble = Color(0xFF2F6B57);
  static const _send = Color(0xFF1F6B4F);
  static const _danger = Color(0xFFB3261E);
  static const _dangerDeep = Color(0xFF8E1B1B);
  static const _dangerTint = Color(0xFFFDECE8);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AppSettings.instance.animBehavior,
    )..forward();
    AiAssistantBridge.send = (q) {
      if (mounted) _sendMessage(q);
    };
    final pending = AiAssistantBridge.pending;
    if (pending != null) {
      AiAssistantBridge.pending = null;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => mounted ? _sendMessage(pending) : null);
    }
  }

  @override
  void dispose() {
    AiAssistantBridge.send = null;
    _anim.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _hhmm() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}.'
        '${n.minute.toString().padLeft(2, '0')}';
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _sendMessage([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    _input.clear();
    setState(() => _extra.add(_Msg(true, text, _hhmm())));
    _toBottom();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _extra.add(_Msg(
            false,
            'Ini balasan simulasi untuk keperluan desain. Setelah terhubung '
            'ke layanan AI, jawaban akan menyesuaikan kondisi udara dan '
            'kebutuhanmu.',
            _hhmm(),
          )));
      _toBottom();
      VoiceService.instance.autoReadIfEnabled(_extra.last.text);
    });
  }

  final GlobalKey _kBanner = GlobalKey();
  final GlobalKey _kAnswer = GlobalKey();
  final GlobalKey _kSugg = GlobalKey();
  final GlobalKey _kInput = GlobalKey();

  Widget _r(double b, double e, Widget child) =>
      Reveal(animation: _anim, begin: b, end: e, child: child);

  @override
  Widget build(BuildContext context) =>
      VoiceScope(
        screen: 'assistant',
        tour: [
          CoachStep(
            target: _kBanner,
            title: 'Kondisi udara untuk konteks',
            body: 'Kartu ini merangkum kondisi udara yang dipakai Asisten sebagai dasar jawaban, supaya saran sesuai keadaanmu.',
            scrollAlignment: 0.1,
          ),
          CoachStep(
            target: _kAnswer,
            title: 'Balasan Asisten',
            body: 'Jawaban Asisten tampil di sini. Saat ini balasan masih contoh dari desain, belum jawaban AI sungguhan, dan bukan pengganti dokter.',
            scrollAlignment: 0.15,
          ),
          CoachStep(
            target: _kSugg,
            title: 'Pertanyaan cepat',
            body: 'Ketuk saran pertanyaan seperti kapan harus ke IGD atau ruang aman untuk anak, untuk bertanya tanpa mengetik.',
            scrollAlignment: 0.3,
          ),
          CoachStep(
            target: _kInput,
            title: 'Tanya apa saja',
            body: 'Ketik pertanyaanmu tentang udara dan kesehatan di kolom ini lalu ketuk kirim, atau cukup ucapkan bila suara aktif.',
          ),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Asisten AI TEDUH. Kamu bisa mengetik atau mengucapkan pertanyaan tentang udara dan kesehatan, misalnya tanpa penyaring udara, cara cek masker rapat, kapan harus ke IGD, atau ruang aman untuk anak. Balasan saat ini masih simulasi. Di halaman ini semua ucapanmu dianggap pertanyaan. Ucapkan kembali untuk keluar.',
        ),
        child: _buildScaffold(context),
      );

  Widget _buildScaffold(BuildContext context) {
    final maxBubble = MediaQuery.of(context).size.width * 0.82;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 16, 0),
              child: Reveal(
                animation: _anim,
                begin: 0.0,
                end: 0.35,
                child: _header(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _r(0.10, 0.50,
                        KeyedSubtree(key: _kBanner, child: _contextBanner())),
                    const SizedBox(height: 20),
                    _r(
                      0.18,
                      0.55,
                      Center(
                        child: Text(
                          'Hari ini · 07 November 2026',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: TC.hint),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _r(
                      0.25,
                      0.62,
                      _userMessage(
                        'Asap di Jekan Raya makin tebal. Anak saya 7 tahun, '
                        'apa yang harus kami lakukan sekarang?',
                        '14.31',
                        maxBubble,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _r(0.35, 0.72, _aiLabel('14.31')),
                    const SizedBox(height: 8),
                    _r(0.38, 0.78,
                        KeyedSubtree(key: _kAnswer, child: _firstAnswer())),
                    const SizedBox(height: 8),
                    _r(
                      0.45,
                      0.82,
                      const _FeedbackRow(
                        copyText: '$_a1Title $_a1Intro',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _r(
                      0.52,
                      0.88,
                      _userMessage(
                        'Belum ada gejala. Kalau harus keluar sebentar, '
                        'apakah masker kain cukup?',
                        '14.32',
                        maxBubble,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _r(0.58, 0.92, _aiLabel('14.32')),
                    const SizedBox(height: 8),
                    _r(0.62, 0.96, _secondAnswer()),
                    const SizedBox(height: 16),

                    for (final m in _extra) ...[
                      _PopIn(
                        key: ObjectKey(m),
                        child: m.fromUser
                            ? _userMessage(m.text, m.time, maxBubble)
                            : _dynamicAnswer(m),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _r(0.70, 1.0,
                        KeyedSubtree(key: _kSugg, child: _suggestionCard())),
                  ],
                ),
              ),
            ),
            _r(0.75, 1.0, KeyedSubtree(key: _kInput, child: _inputBar())),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: TC.dark,
          iconSize: 26,
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFD3E8D8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.auto_awesome_outlined,
              size: 22, color: Color(0xFF1F6B4F)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asisten AI TEDUH',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TC.dark,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3FA564),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Aktif · siap membantu',
                    style: GoogleFonts.poppins(fontSize: 10.5, color: TC.hint),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => showSoon(context, 'Menu'),
          icon: const Icon(Icons.more_horiz_rounded),
          color: TC.dark,
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _contextBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _dangerTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7DDD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 17, color: _dangerDeep),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Jekan Raya',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _dangerDeep,
                  ),
                ),
              ),
              Text(
                '462 ISPU · BERBAHAYA',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _dangerDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'PM2.5 883.2 µg/m³ · Palangka Raya',
            style: GoogleFonts.poppins(fontSize: 11, color: _danger),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: TC.hint,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Data simulasi · 07 Nov 2026 · 14.30 WIB',
                style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userMessage(String text, String time, double maxWidth) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                color: _userBubble,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.55,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$time · Terkirim',
            style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
          ),
        ],
      ),
    );
  }

  Widget _aiLabel(String time) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_outlined,
              size: 16, color: TC.greenDeep),
          const SizedBox(width: 6),
          Text(
            'TEDUH AI',
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: TC.greenDeep,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: GoogleFonts.poppins(fontSize: 10, color: TC.hint),
          ),
        ],
      ),
    );
  }

  Widget _dynamicAnswer(_Msg m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aiLabel(m.time),
        const SizedBox(height: 8),
        _AiCard(
          children: [
            _answerTitle('Pertanyaanmu sudah kuterima.'),
            const SizedBox(height: 12),
            _bodyText(m.text),
          ],
        ),
        const SizedBox(height: 8),
        _FeedbackRow(copyText: m.text),
      ],
    );
  }

  Widget _answerTitle(String t) => Text(
        t,
        style: GoogleFonts.poppins(
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w800,
          color: TC.dark,
        ),
      );

  Widget _bodyText(String t) => Text(
        t,
        style: GoogleFonts.poppins(fontSize: 12.5, height: 1.65, color: TC.hint),
      );

  Widget _firstAnswer() {
    return _AiCard(
      children: [
        _answerTitle(_a1Title),
        const SizedBox(height: 14),
        _bodyText(_a1Intro),
        const SizedBox(height: 16),
        for (int i = 0; i < _a1Steps.length; i++) ...[
          Text(
            _a1Steps[i][0],
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TC.dark,
            ),
          ),
          const SizedBox(height: 3),
          _bodyText(_a1Steps[i][1]),
          const SizedBox(height: 14),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: _dangerTint,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9908A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Icons.monitor_heart_outlined,
                    size: 20, color: _danger),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _a1AlertTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _dangerDeep,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _a1AlertBody,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        height: 1.5,
                        color: _dangerDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, thickness: 1, color: TC.divider),
        const SizedBox(height: 14),
        Text(
          _a1Question,
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: TC.dark,
          ),
        ),
      ],
    );
  }

  Widget _secondAnswer() {
    return _AiCard(
      children: [
        _answerTitle(_a2Title),
        const SizedBox(height: 14),
        _bodyText(_a2P1),
        const SizedBox(height: 14),
        _bodyText(_a2P2),
      ],
    );
  }

  Widget _suggestionCard() {
    Widget chip(String text) {
      return Expanded(
        child: Material(
          color: const Color(0xFFE6EFE6),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _sendMessage(text),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 10, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: TC.dark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.north_east_rounded,
                      size: 14, color: TC.greenDeep),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LANJUTKAN DENGAN PERTANYAAN',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: TC.greenDeep,
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            chip(_suggestions[0]),
            const SizedBox(width: 10),
            chip(_suggestions[1]),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            chip(_suggestions[2]),
            const SizedBox(width: 10),
            chip(_suggestions[3]),
          ]),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: TC.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => showSoon(context, 'Lampiran'),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.add_rounded,
                        size: 24, color: TC.greenDeep),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _input,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    style: GoogleFonts.poppins(fontSize: 12, color: TC.dark),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Tanyakan cara melindungi diri...',
                      hintStyle:
                          GoogleFonts.poppins(fontSize: 12, color: TC.hint),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _sendMessage(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: _send,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded,
                        size: 22, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI dapat keliru. Data udara simulasi, belum terverifikasi.\n'
            'Untuk kondisi gawat, cari bantuan medis segera.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              height: 1.5,
              color: TC.hint,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  final List<Widget> children;
  const _AiCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FeedbackRow extends StatefulWidget {
  final String copyText;
  const _FeedbackRow({required this.copyText});

  @override
  State<_FeedbackRow> createState() => _FeedbackRowState();
}

class _FeedbackRowState extends State<_FeedbackRow> {
  bool _liked = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.copyText));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Jawaban disalin'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: _copy,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child:
                  Icon(Icons.content_copy_rounded, size: 18, color: TC.dark),
            ),
          ),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => setState(() => _liked = !_liked),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                _liked
                    ? Icons.thumb_up_alt_rounded
                    : Icons.thumb_up_alt_outlined,
                size: 18,
                color: _liked ? TC.green : TC.dark,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Panduan umum · bukan diagnosis',
            style: GoogleFonts.poppins(fontSize: 9.5, color: TC.hint),
          ),
        ],
      ),
    );
  }
}

class _PopIn extends StatelessWidget {
  final Widget child;
  const _PopIn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 18),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
