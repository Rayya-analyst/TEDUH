import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/user_points_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/teduh_common.dart';

Future<bool?> showActivityReward(
  BuildContext context, {
  required bool indoor,
  String? userName,
  int? points,
  int? target,
  int earnedPoints = 20,
}) {
  final resolvedName = (userName != null &&
          userName.trim().isNotEmpty &&
          userName != 'Arsinka')
      ? userName.trim()
      : UserProfileService.instance.shortName;
  final effectiveName = resolvedName.isNotEmpty ? resolvedName : 'Sobat TEDUH';
  final effectivePoints = points ?? UserPointsService.instance.points;
  final effectiveTarget = target ?? UserPointsService.instance.currentTarget;

  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Reward',
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, _, _) => _RewardView(
      indoor: indoor,
      userName: effectiveName,
      points: effectivePoints,
      target: effectiveTarget,
      earnedPoints: earnedPoints,
    ),
    transitionBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _RewardTheme {
  final List<Color> bg;
  final Color leaf;
  final Color title;
  final Color accent;
  final Color heroBg;
  final Color chipBg;
  final Color chipText;
  final Color innerBg;
  final Color innerBorder;
  final Color valueColor;
  final Color trackColor;
  final List<Color> bar;
  final Color iconCircle;
  final Color iconColor;
  final Color readyBg;
  final Color readyText;
  final Color earnedBg;
  final Color earnedText;
  final List<Color> button;

  const _RewardTheme({
    required this.bg,
    required this.leaf,
    required this.title,
    required this.accent,
    required this.heroBg,
    required this.chipBg,
    required this.chipText,
    required this.innerBg,
    required this.innerBorder,
    required this.valueColor,
    required this.trackColor,
    required this.bar,
    required this.iconCircle,
    required this.iconColor,
    required this.readyBg,
    required this.readyText,
    required this.earnedBg,
    required this.earnedText,
    required this.button,
  });
}

const _RewardTheme _greenTheme = _RewardTheme(
  bg: [Color(0xFFE6F3E9), Color(0xFFF7FBF8)],
  leaf: Color(0xFFD3E8D5),
  title: Color(0xFF1B6F57),
  accent: Color(0xFF1B6F57),
  heroBg: Color(0xFFE9F2EC),
  chipBg: Color(0xFFE0F3E7),
  chipText: Color(0xFF0F7B4F),
  innerBg: Color(0xFFF2F6F2),
  innerBorder: Color(0xFFE1EAE2),
  valueColor: Color(0xFF1B6F57),
  trackColor: Color(0xFFDDEBE0),
  bar: [Color(0xFFE2A32E), Color(0xFFF59E0B)],
  iconCircle: Color(0xFFF8E6B8),
  iconColor: Color(0xFF9A6A12),
  readyBg: Color(0xFFD9F2E3),
  readyText: Color(0xFF0F7B4F),
  earnedBg: Color(0xFFD9F2E3),
  earnedText: Color(0xFF0B5D43),
  button: [Color(0xFF1B6F57), Color(0xFF1B6F57)],
);

const _RewardTheme _redTheme = _RewardTheme(
  bg: [Color(0xFFFFE9E2), Color(0xFFFFFAF6)],
  leaf: Color(0xFFF8D9CC),
  title: Color(0xFF8E1B1B),
  accent: Color(0xFFEA580C),
  heroBg: Color(0xFFFFEFE6),
  chipBg: Color(0xFFFDE8D8),
  chipText: Color(0xFF7A2E0E),
  innerBg: Color(0xFFFFF3EA),
  innerBorder: Color(0xFFF6DDCC),
  valueColor: Color(0xFF8E1B1B),
  trackColor: Color(0xFFF9E1D3),
  bar: [Color(0xFFFB7A1E), Color(0xFFEA580C)],
  iconCircle: Color(0xFFFBC8C8),
  iconColor: Color(0xFF8E1B1B),
  readyBg: Color(0xFFFDE8D8),
  readyText: Color(0xFFC2410C),
  earnedBg: Color(0xFFFBC8C8),
  earnedText: Color(0xFF8E1B1B),
  button: [Color(0xFFFB7A1E), Color(0xFFEA580C)],
);

class _RewardView extends StatefulWidget {
  final bool indoor;
  final String userName;
  final int points;
  final int target;
  final int earnedPoints;

  const _RewardView({
    required this.indoor,
    required this.userName,
    required this.points,
    required this.target,
    this.earnedPoints = 20,
  });

  @override
  State<_RewardView> createState() => _RewardViewState();
}

class _RewardViewState extends State<_RewardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  _RewardTheme get t => widget.indoor ? _redTheme : _greenTheme;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      animationBehavior: AnimationBehavior.preserve,
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _r(double b, double e, Widget child) =>
      Reveal(animation: _anim, begin: b, end: e, child: child);

  @override
  Widget build(BuildContext context) {
    final progress =
        (widget.points / widget.target).clamp(0.0, 1.0).toDouble();
    final percent = (progress * 100).round();
    final remaining =
        widget.target > widget.points ? widget.target - widget.points : 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: t.bg,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: SoftLeavesPainter(_anim, t.leaf)),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                      child: Column(
                        children: [
                          _r(
                            0.0,
                            0.3,
                            Text(
                              'Reward',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: t.title,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _r(0.05, 0.45, _trophy()),
                          const SizedBox(height: 22),
                          _r(
                            0.15,
                            0.55,
                            Text(
                              'Hebat, ${widget.userName}!',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: t.title,
                              ),
                            ),
                          ),
                          if (widget.earnedPoints > 0) ...[
                            const SizedBox(height: 8),
                            _r(
                              0.18,
                              0.58,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: t.chipBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: t.chipText.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  '+${widget.earnedPoints} Poin Sehat Didapatkan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: t.chipText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          _r(
                            0.2,
                            0.6,
                            Text(
                              widget.earnedPoints > 0
                                  ? 'Aktivitasmu berhasil diselesaikan! Terus kumpulkan '
                                    'poin dan jaga kebugaran tubuh setiap hari.'
                                  : 'Sesi diakhiri lebih awal. Selesaikan '
                                    'seluruh langkah untuk mendapatkan poin.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.6,
                                color: const Color(0xFF7C8A82),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _r(0.3, 0.7,
                              _pointsCard(progress, percent, remaining)),
                          const SizedBox(height: 18),
                          _r(0.45, 0.88, _medalsCard()),
                        ],
                      ),
                    ),
                  ),
                  _r(0.7, 1.0, _bottomButton()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trophy() {
    return Container(
      width: 220,
      height: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.heroBg,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: t.accent.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.asset(
          'assets/images/reward/trophy.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            alignment: Alignment.center,
            color: t.heroBg,
            child: Icon(Icons.emoji_events_rounded,
                size: 110, color: t.accent.withValues(alpha: 0.85)),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      );

  Widget _pointsCard(double progress, int percent, int remaining) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Poin & Pencapaian',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: TC.dark,
                      ),
                    ),
                    Text(
                      'Akumulasi poin aktivitas fisikmu',
                      style: GoogleFonts.poppins(
                          fontSize: 11.5, color: const Color(0xFF7C8A82)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: t.chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percent% ke target',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: t.chipText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.innerBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: t.innerBorder),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stat('Poin terkumpul', '${widget.points}',
                        CrossAxisAlignment.start),
                    const Spacer(),
                    _stat('Target berikutnya', '${widget.target}',
                        CrossAxisAlignment.end),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 12,
                    color: t.trackColor,
                    alignment: Alignment.centerLeft,
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, _) {
                        final v = Curves.easeOutCubic
                            .transform(
                            ((_anim.value - 0.4) / 0.6).clamp(0.0, 1.0).toDouble());
                        return FractionallySizedBox(
                          widthFactor: progress * v,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: t.bar),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${widget.points} poin terkumpul',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: const Color(0xFF7C8A82)),
                    ),
                    const Spacer(),
                    Text(
                      '$remaining poin lagi',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: t.valueColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11.5, color: const Color(0xFF7C8A82))),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 32,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: t.valueColor,
          ),
        ),
      ],
    );
  }

  Widget _medalsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medali & Reward',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: TC.dark,
            ),
          ),
          Text(
            'Setiap langkah sehatmu berarti',
            style: GoogleFonts.poppins(
                fontSize: 11.5, color: const Color(0xFF7C8A82)),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, c) {
              final w = (c.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: w,
                    child: _badge(
                      Icons.workspace_premium_outlined,
                      'Langkah Pertama',
                      'Menyelesaikan aktivitas pertama di TEDUH ACTION',
                      'Siap diklaim',
                      t.readyBg,
                      t.readyText,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _badge(
                      Icons.shield_outlined,
                      'Aktif di Dalam',
                      'Menyelesaikan latihan di dalam ruangan dengan aman',
                      'Diperoleh',
                      t.earnedBg,
                      t.earnedText,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _badge(
                      Icons.calendar_month_outlined,
                      'Konsisten 7 Hari',
                      '7 hari aktivitas berturut-turut',
                      'Terkunci',
                      const Color(0xFFFFF1CC),
                      const Color(0xFFB7791F),
                      minHeight: 150,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String title, String desc, String status,
      Color chipBg, Color chipText,
      {double minHeight = 0}) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: t.iconCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: t.iconColor),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: chipText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: TC.dark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: GoogleFonts.poppins(
                fontSize: 10.5, height: 1.5, color: const Color(0xFF7C8A82)),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: t.button),
          boxShadow: [
            BoxShadow(
              color: t.button.last.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).pop(true),
            child: Center(
              child: Text(
                'Kembali ke Beranda',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
