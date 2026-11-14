import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/siren_service.dart';
import '../services/voice_service.dart';
import '../state/app_settings.dart';

class _AlertRecord {
  final DateTime lastAlertTime;
  final int lastIspu;
  const _AlertRecord({required this.lastAlertTime, required this.lastIspu});
}

class AlertCooldownManager {
  AlertCooldownManager._();
  static final AlertCooldownManager instance = AlertCooldownManager._();

  final Map<String, _AlertRecord> _history = {};
  DateTime? _snoozeUntil;

  DateTime? get snoozeUntil => _snoozeUntil;
  bool get isSnoozed =>
      _snoozeUntil != null && DateTime.now().isBefore(_snoozeUntil!);

  void snooze([Duration duration = const Duration(hours: 1)]) {
    _snoozeUntil = DateTime.now().add(duration);
  }

  void cancelSnooze() {
    _snoozeUntil = null;
  }

  bool shouldTriggerAlert(String region, int ispu, {int threshold = 300}) {
    if (ispu < threshold) return false;
    if (isSnoozed) return false;

    final key = region.trim().toLowerCase();
    final rec = _history[key];
    if (rec == null) return true;

    final elapsed = DateTime.now().difference(rec.lastAlertTime);
    if (elapsed < const Duration(minutes: 20)) {
      if (ispu - rec.lastIspu >= 50) {
        return true;
      }
      return false;
    }
    return true;
  }

  void recordAlert(String region, int ispu) {
    final key = region.trim().toLowerCase();
    _history[key] =
        _AlertRecord(lastAlertTime: DateTime.now(), lastIspu: ispu);
  }

  void clearHistory() {
    _history.clear();
    _snoozeUntil = null;
  }
}

class PeringatanGawatDialog extends StatefulWidget {
  final int ispu;
  final String wilayah;
  final VoidCallback? onAcknowledge;

  const PeringatanGawatDialog({
    super.key,
    required this.ispu,
    required this.wilayah,
    this.onAcknowledge,
  });

  static Future<void> show(
    BuildContext context, {
    required int ispu,
    required String wilayah,
  }) {
    if (ispu < 300) return Future.value();

    if (!AlertCooldownManager.instance.shouldTriggerAlert(wilayah, ispu)) {
      return Future.value();
    }
    AlertCooldownManager.instance.recordAlert(wilayah, ispu);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x8C1A2622),
      builder: (_) => PeringatanGawatDialog(ispu: ispu, wilayah: wilayah),
    );
  }

  @override
  State<PeringatanGawatDialog> createState() => _PeringatanGawatDialogState();
}

class _PeringatanGawatDialogState extends State<PeringatanGawatDialog> {
  bool _muted = false;
  bool _alive = true;
  bool _flash = false;
  Timer? _flashTimer;
  VoiceHold? _hold;

  static const List<String> _ackWords = [
    'paham', 'mengerti', 'siaga', 'oke', 'ok', 'ya', 'iya', 'siap', 'baik',
  ];

  @override
  void initState() {
    super.initState();
    final a = AppSettings.instance;
    if (a.visualAlerts) {
      SirenService.instance.startVibrate();
      _flashTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
        if (mounted) setState(() => _flash = !_flash);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _alert());
  }

  Future<void> _alert() async {
    final a = AppSettings.instance;
    final v = VoiceService.instance;
    if (a.visualAlerts) return; 
    _hold = v.hold();
    try {
      for (int round = 0; round < 3 && _alive; round++) {
        await v.stopSpeaking();
        await SirenService.instance.burst();
        if (!_alive) return;
        if (!a.effectiveAutoRead && !a.effectiveVoiceNav) return;
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!_alive) return;
        await v.speak(round == 0
            ? 'Itu tadi sirene peringatan udara berbahaya. Kualitas udara di '
                '${widget.wilayah} berbahaya, ISPU ${widget.ispu}. Artinya '
                'udara tidak sehat bagi semua orang. Pahami peringatan ini '
                'dan tetap siaga: tetap di dalam ruangan, tutup jendela dan '
                'pintu, dan pakai masker respirator bila harus keluar. '
                '${a.effectiveVoiceNav ? 'Katakan paham atau saya siaga bila sudah mengerti.' : 'Tekan tombol Saya Mengerti dan Siaga bila sudah paham.'}'
            : 'Peringatan udara berbahaya masih berlaku. Tetap di dalam '
                'ruangan dan siaga. '
                '${a.effectiveVoiceNav ? 'Katakan paham bila sudah mengerti.' : 'Tekan tombol Saya Mengerti dan Siaga.'}');
        if (!_alive) return;
        if (a.effectiveVoiceNav) {
          final heard =
              (await v.listenOnce(listenFor: const Duration(seconds: 12)))
                  .toLowerCase();
          if (!_alive) return;
          final words = heard.split(RegExp(r'[^a-z]+'));
          if (_ackWords.any(words.contains)) {
            await _voiceAck();
            return;
          }
        } else {
          return; 
        }
      }
    } finally {
      _hold?.release();
      _hold = null;
    }
  }

  Future<void> _voiceAck() async {
    SirenService.instance.stop();
    await VoiceService.instance.speak(
        'Terima kasih. Tetap siaga dan jaga kesehatanmu.');
    if (!mounted) return;
    widget.onAcknowledge?.call();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _alive = false;
    _flashTimer?.cancel();
    _hold?.release();
    SirenService.instance.stop();
    SirenService.instance.stopVibrate();
    super.dispose();
  }

  void _mute() {
    SirenService.instance.stop();
    setState(() => _muted = true);
  }

  @override
  Widget build(BuildContext context) {
    return _PeringatanGawatBody(
      ispu: widget.ispu,
      wilayah: widget.wilayah,
      muted: _muted,
      flash: _flash,
      onMute: _mute,
      onAcknowledge: () {
        _alive = false;
        SirenService.instance.stop();
        SirenService.instance.stopVibrate();
        VoiceService.instance.stopSpeaking();
        widget.onAcknowledge?.call();
      },
    );
  }
}

class _PeringatanGawatBody extends StatelessWidget {
  final int ispu;
  final String wilayah;
  final bool muted;
  final bool flash;
  final VoidCallback onMute;
  final VoidCallback? onAcknowledge;

  const _PeringatanGawatBody({
    required this.ispu,
    required this.wilayah,
    required this.muted,
    this.flash = false,
    required this.onMute,
    this.onAcknowledge,
  });

  static const Color _red = Color(0xFFC63A3A);
  static const Color _redText = Color(0xFFC0392B);
  static const Color _pink = Color(0xFFFCE9E9);
  static const Color _ink = Color(0xFF1F3D36);

  @override
  Widget build(BuildContext context) {
    final double s = MediaQuery.of(context).size.width / 420;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 28 * s, vertical: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(24 * s, 28 * s, 24 * s, 24 * s),
          decoration: BoxDecoration(
            color: flash ? _pink : Colors.white,
            borderRadius: BorderRadius.circular(28 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28 * s,
                offset: Offset(0, 10 * s),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104 * s,
                height: 104 * s,
                decoration: const BoxDecoration(
                  color: _pink,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_rounded, size: 62 * s, color: _red),
              ),
              SizedBox(height: 26 * s),
              Text(
                'PERINGATAN GAWAT!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w800,
                  color: _redText,
                ),
              ),
              SizedBox(height: 16 * s),
              Text(
                'Kualitas udara memburuk hingga level berbahaya (ISPU ≥ 300). '
                'Segera masuk ke ruangan tertutup dan gunakan masker respirator N95!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15 * s,
                  height: 1.55,
                  color: _ink,
                ),
              ),
              SizedBox(height: 22 * s),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 11 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEBEB),
                  borderRadius: BorderRadius.circular(12 * s),
                  border: Border.all(color: const Color(0xFFEF5350), width: 1),
                ),
                child: Text(
                  'ISPU saat ini: $ispu   •  $wilayah',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5 * s,
                    color: _redText,
                  ),
                ),
              ),
              SizedBox(height: 20 * s),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  SirenService.instance.stop();
                  SirenService.instance.stopVibrate();
                  VoiceService.instance.stopSpeaking();
                  onAcknowledge?.call();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  height: 54 * s,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(14 * s),
                  ),
                  child: Text(
                    'Saya Mengerti & Siaga',
                    style: GoogleFonts.inter(
                      fontSize: 15.5 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              TextButton.icon(
                onPressed: muted
                    ? null
                    : () {
                        SirenService.instance.stop();
                        SirenService.instance.stopVibrate();
                        onMute();
                      },
                icon: Icon(
                  muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  size: 18 * s,
                  color: muted ? const Color(0xFF8A9691) : _redText,
                ),
                label: Text(
                  muted ? 'Sirene dimatikan' : 'Matikan suara sirene',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                    color: muted ? const Color(0xFF8A9691) : _redText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  AlertCooldownManager.instance.snooze(const Duration(hours: 1));
                  SirenService.instance.stop();
                  SirenService.instance.stopVibrate();
                  VoiceService.instance.stopSpeaking();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Jangan ingatkan lagi selama 1 jam',
                  style: GoogleFonts.inter(
                    fontSize: 11.5 * s,
                    color: const Color(0xFF6B7A74),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotifikasiUdaraCard extends StatelessWidget {
  final int ispu;
  final String timeLabel;
  final VoidCallback? onTap;

  const NotifikasiUdaraCard({
    super.key,
    required this.ispu,
    this.timeLabel = 'sekarang',
    this.onTap,
  });

  static const Color _red = Color(0xFFE5383B);
  static const Color _ink = Color(0xFF1F2A27);

  @override
  Widget build(BuildContext context) {
    final double s = MediaQuery.of(context).size.width / 436;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 18 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24 * s,
              offset: Offset(0, 8 * s),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40 * s,
              height: 40 * s,
              decoration: BoxDecoration(
                color: const Color(0xFF1B6B55),
                borderRadius: BorderRadius.circular(11 * s),
              ),
              child: Icon(Icons.eco_outlined, size: 22 * s, color: Colors.white),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                            children: const [
                              TextSpan(text: 'TEDUH • '),
                              TextSpan(
                                text: 'Kualitas Udara',
                                style: TextStyle(color: _red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: const Color(0xFF8A9691),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14.8 * s,
                        height: 1.45,
                        color: _ink,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Kualitas udara di lokasi Anda mendadak '
                              'memburuk hingga ',
                        ),
                        TextSpan(
                          text: 'level berbahaya (ISPU $ispu).',
                          style: const TextStyle(
                            color: _red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(
                          text: ' Jangan memulai beraktivitas di luar ruangan '
                              'dan gunakan masker.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AirAlertLayer extends StatefulWidget {
  final int? alertIspu;
  final String alertRegion;
  final int threshold;
  final bool showDailyNotification;
  final int dailyIspu;
  final Duration bannerDuration;
  final VoidCallback? onDailyNotificationTap;

  const AirAlertLayer({
    super.key,
    this.alertIspu,
    this.alertRegion = '',
    this.threshold = 300,
    this.showDailyNotification = true,
    this.dailyIspu = 211,
    this.bannerDuration = const Duration(seconds: 7),
    this.onDailyNotificationTap,
  });

  @override
  State<AirAlertLayer> createState() => _AirAlertLayerState();
}

class _AirAlertLayerState extends State<AirAlertLayer> {
  bool _bannerVisible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final int? ispu = widget.alertIspu;
    if (ispu != null && ispu >= widget.threshold) {
      await PeringatanGawatDialog.show(
        context,
        ispu: ispu,
        wilayah: widget.alertRegion,
      );
      if (!mounted) return;
    }

    if (widget.showDailyNotification) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _bannerVisible = true);
      _hideTimer = Timer(widget.bannerDuration, _hideBanner);
    }
  }

  void _hideBanner() {
    _hideTimer?.cancel();
    if (mounted && _bannerVisible) setState(() => _bannerVisible = false);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final double s = media.size.width / 436;

    return Align(
      alignment: Alignment.topCenter,
      child: IgnorePointer(
        ignoring: !_bannerVisible,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              28 * s, media.padding.top + 8 * s, 28 * s, 0),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            offset: _bannerVisible ? Offset.zero : const Offset(0, -1.6),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _bannerVisible ? 1 : 0,
              child: GestureDetector(
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -150) _hideBanner();
                },
                child: NotifikasiUdaraCard(
                  ispu: widget.dailyIspu,
                  onTap: () {
                    _hideBanner();
                    widget.onDailyNotificationTap?.call();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
