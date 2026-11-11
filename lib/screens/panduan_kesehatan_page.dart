import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _PgColors {
  static const green = Color(0xFF1A6B55);
  static const ink = Color(0xFF0F2A24);
  static const body = Color(0xFF4A5A55);
  static const muted = Color(0xFF6B7B75);
  static const faint = Color(0xFF8A9A94);
  static const orange = Color(0xFFD9731A);
  static const mint = Color(0xFFE6F3EA);
  static const pillBg = Color(0xFFE3F2E7);
  static const cardBorder = Color(0xFFE6ECE8);
  static const divider = Color(0xFFE9EEEB);
  static const noticeBg = Color(0xFFF2F6F3);
}

enum _TipIcon { lungs, eye, throat, head, flu }

class _Tip {
  final _TipIcon icon;
  final String title;
  final String body;
  const _Tip(this.icon, this.title, this.body);
}

const Map<String, _Tip> _tips = {
  'Batuk': _Tip(
    _TipIcon.lungs,
    'Solusi Batuk',
    'Jauhi asap dan pindah ke dalam ruangan dengan udara lebih bersih. '
        'Minum air untuk membantu kenyamanan tenggorokan.',
  ),
  'Sesak Napas': _Tip(
    _TipIcon.lungs,
    'Solusi Sesak Napas',
    'Segera menjauh dari asap, duduk dengan tenang di ruangan berudara '
        'bersih, dan atur napas perlahan. Bila tidak membaik, segera cari '
        'bantuan tenaga kesehatan.',
  ),
  'Mata Perih': _Tip(
    _TipIcon.eye,
    'Solusi Mata Perih',
    'Hindari mengucek mata. Bilas perlahan dengan air bersih dan kurangi '
        'paparan asap agar iritasi tidak bertambah.',
  ),
  'Tenggorokan Kering': _Tip(
    _TipIcon.throat,
    'Solusi Tenggorokan Kering',
    'Minum air putih secara teratur dan kurangi paparan asap. Gunakan '
        'masker saat harus keluar ruangan.',
  ),
  'Pusing': _Tip(
    _TipIcon.head,
    'Solusi Pusing',
    'Beristirahat di ruangan dengan sirkulasi udara bersih, minum cukup air, '
        'dan hindari aktivitas berat sampai keluhan mereda.',
  ),
  'Flu/Pilek': _Tip(
    _TipIcon.flu,
    'Solusi Flu/Pilek',
    'Perbanyak istirahat dan minum air hangat. Gunakan masker agar paparan '
        'asap tidak memperberat keluhan.',
  ),
};

class PanduanKesehatanPage extends StatelessWidget {

  final List<String> symptoms;

  final int ispu;

  final String statusLabel;

  final VoidCallback? onKembaliTap;

  const PanduanKesehatanPage({
    super.key,
    this.symptoms = const ['Batuk', 'Mata Perih'],
    this.ispu = 142,
    this.statusLabel = 'Perlu Waspada',
    this.onKembaliTap,
  });

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'healthguide',
        tour: const [
          CoachStep(title: 'Kondisi udara saat ini', body: 'Bagian atas menunjukkan peringatan dan nilai ISPU saat ini, supaya kamu tahu seberapa waspada harus bersikap.'),
          CoachStep(title: 'Pilih keluhanmu', body: 'Ketuk keluhan yang kamu rasakan, seperti batuk, sesak napas, mata perih, tenggorokan kering, pusing, atau flu dan pilek, untuk melihat solusinya.'),
          CoachStep(title: 'Jangan abaikan gejala', body: 'Bila keluhan menetap atau sulit bernapas, segera cari bantuan tenaga kesehatan.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Panduan Kesehatan. Berisi keluhan yang sering muncul saat udara buruk: batuk, sesak napas, mata perih, tenggorokan kering, pusing, dan flu atau pilek, masing-masing dengan solusinya. Bila sulit bernapas, segera cari bantuan medis.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final media = MediaQuery.of(context);
    final s = media.size.width / 318;
    final tips = [
      for (final name in symptoms)
        if (_tips[name] != null) _tips[name]!,
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, s),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(24 * s, 14 * s, 24 * s, 16 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopRow(s),
                      SizedBox(height: 10 * s),
                      Text.rich(
                        TextSpan(
                          text: 'Udara kurang baik,\n',
                          style: GoogleFonts.inter(
                            fontSize: 21 * s,
                            height: 1.2,
                            letterSpacing: -0.4,
                            fontWeight: FontWeight.w800,
                            color: _PgColors.ink,
                          ),
                          children: const [
                            TextSpan(
                              text: 'jaga tubuh Anda.',
                              style: TextStyle(color: _PgColors.green),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 9 * s),
                      Text(
                        'Kurangi paparan polusi dan kenali keluhan yang '
                        'mungkin Anda rasakan.',
                        style: GoogleFonts.inter(
                          fontSize: 10 * s,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: _PgColors.muted,
                        ),
                      ),
                      SizedBox(height: 17 * s),
                      _buildTipsCard(s, tips),
                      SizedBox(height: 17 * s),
                      _buildNotice(s),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 18 * s),
                child: _buildButton(context, s),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double s) {
    return SizedBox(
      height: 42 * s,
      child: Padding(
        padding: EdgeInsets.only(left: 18 * s, right: 24 * s),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: EdgeInsets.all(6 * s),
                child: Icon(Icons.arrow_back_rounded,
                    size: 18 * s, color: _PgColors.ink),
              ),
            ),
            SizedBox(width: 8 * s),
            Text(
              'Panduan Kesehatan',
              style: GoogleFonts.inter(
                fontSize: 11 * s,
                fontWeight: FontWeight.w700,
                color: _PgColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 4 * s),
          child: Text(
            'TEDUH / KESEHATAN',
            style: GoogleFonts.inter(
              fontSize: 6.5 * s,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w500,
              color: _PgColors.faint,
            ),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
              decoration: BoxDecoration(
                color: _PgColors.pillBg,
                borderRadius: BorderRadius.circular(10 * s),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 9 * s, color: _PgColors.green),
                  SizedBox(width: 2 * s),
                  Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 7 * s,
                      fontWeight: FontWeight.w600,
                      color: _PgColors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5 * s),
            Text(
              'ISPU $ispu',
              style: GoogleFonts.inter(
                fontSize: 7.5 * s,
                fontWeight: FontWeight.w800,
                color: _PgColors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipsCard(double s, List<_Tip> tips) {
    return Container(
      padding: EdgeInsets.fromLTRB(14 * s, 16 * s, 14 * s, 16 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: _PgColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2A24).withValues(alpha: 0.06),
            blurRadius: 16 * s,
            offset: Offset(0, 5 * s),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < tips.length; i++) ...[
            if (i > 0) ...[
              SizedBox(height: 14 * s),
              Container(height: 1, color: _PgColors.divider),
              SizedBox(height: 14 * s),
            ],
            _tipRow(s, tips[i]),
          ],
        ],
      ),
    );
  }

  Widget _tipRow(double s, _Tip tip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34 * s,
          height: 34 * s,
          decoration: BoxDecoration(
            color: _PgColors.mint,
            borderRadius: BorderRadius.circular(11 * s),
          ),
          child: Center(child: _iconFor(tip.icon, s)),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2 * s),
              Text(
                tip.title,
                style: GoogleFonts.inter(
                  fontSize: 11.5 * s,
                  fontWeight: FontWeight.w800,
                  color: _PgColors.ink,
                ),
              ),
              SizedBox(height: 5 * s),
              Text(
                tip.body,
                style: GoogleFonts.inter(
                  fontSize: 9 * s,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: _PgColors.body,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconFor(_TipIcon icon, double s) {
    switch (icon) {
      case _TipIcon.lungs:
        return SizedBox(
          width: 18 * s,
          height: 18 * s,
          child: CustomPaint(painter: _LungsPainter()),
        );
      case _TipIcon.eye:
        return Icon(Icons.visibility_outlined,
            size: 18 * s, color: _PgColors.green);
      case _TipIcon.throat:
        return Icon(Icons.water_drop_outlined,
            size: 17 * s, color: _PgColors.green);
      case _TipIcon.head:
        return Icon(Icons.blur_on_rounded,
            size: 18 * s, color: _PgColors.green);
      case _TipIcon.flu:
        return Icon(Icons.thermostat_rounded,
            size: 18 * s, color: _PgColors.green);
    }
  }

  Widget _buildNotice(double s) {
    return Container(
      padding: EdgeInsets.fromLTRB(12 * s, 12 * s, 12 * s, 12 * s),
      decoration: BoxDecoration(
        color: _PgColors.noticeBg,
        borderRadius: BorderRadius.circular(14 * s),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1 * s),
            child: Icon(Icons.health_and_safety_outlined,
                size: 13 * s, color: _PgColors.green),
          ),
          SizedBox(width: 9 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jangan abaikan gejala',
                  style: GoogleFonts.inter(
                    fontSize: 8.5 * s,
                    fontWeight: FontWeight.w800,
                    color: _PgColors.ink,
                  ),
                ),
                SizedBox(height: 3 * s),
                Text(
                  'Jika keluhan menetap atau sulit bernapas, segera cari '
                  'bantuan tenaga kesehatan.',
                  style: GoogleFonts.inter(
                    fontSize: 7.5 * s,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: _PgColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, double s) {
    return Material(
      color: _PgColors.green,
      borderRadius: BorderRadius.circular(14 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(14 * s),
        onTap: () {
          if (onKembaliTap != null) {
            onKembaliTap!();
          } else {
            Navigator.of(context).pop(true);
          }
        },
        child: SizedBox(
          height: 42 * s,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kembali ke Beranda',
                style: GoogleFonts.inter(
                  fontSize: 10.5 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8 * s),
              Icon(Icons.arrow_forward_rounded,
                  size: 13 * s, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _LungsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k, k);

    final line = Paint()
      ..color = _PgColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(const Offset(12, 3), const Offset(12, 11), line);
    canvas.drawLine(const Offset(12, 11), const Offset(8.5, 14), line);
    canvas.drawLine(const Offset(12, 11), const Offset(15.5, 14), line);

    final left = Path()
      ..moveTo(9.5, 7)
      ..cubicTo(6, 7, 3, 13, 3, 18)
      ..cubicTo(3, 20.5, 4.5, 21, 6, 21)
      ..cubicTo(8, 21, 9.5, 19.5, 9.5, 17)
      ..close();
    canvas.drawPath(left, line);

    final right = Path()
      ..moveTo(14.5, 7)
      ..cubicTo(18, 7, 21, 13, 21, 18)
      ..cubicTo(21, 20.5, 19.5, 21, 18, 21)
      ..cubicTo(16, 21, 14.5, 19.5, 14.5, 17)
      ..close();
    canvas.drawPath(right, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
