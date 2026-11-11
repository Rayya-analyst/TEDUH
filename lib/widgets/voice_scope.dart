import 'dart:async';

import 'package:flutter/material.dart';

import '../services/voice_flow.dart';
import '../services/voice_service.dart';
import '../state/app_settings.dart';
import 'coach_marks.dart';

class PageGuide {
  final String Function() content;

  final String? nextScreen;
  final String? nextLabel;
  final String? nextHint;

  final String? endText;

  const PageGuide({
    required this.content,
    this.nextScreen,
    this.nextLabel,
    this.nextHint,
    this.endText,
  });
}

class VoiceScope extends StatefulWidget {
  final String screen;
  final Widget child;

  final List<CoachStep> tour;

  final PageGuide? guide;

  const VoiceScope({
    super.key,
    required this.screen,
    required this.child,
    this.tour = const [],
    this.guide,
  });

  @override
  State<VoiceScope> createState() => _VoiceScopeState();
}

String _none() => 'Halaman ini belum punya penjelasan suara.';

class _VoiceScopeState extends State<VoiceScope> {
  CoachHandle? _handle;
  bool _guiding = false;
  Future<void> Function()? _runner;

  bool get _seen => AppSettings.instance.tourSeen(widget.screen);

  @override
  void initState() {
    super.initState();
    final v = VoiceService.instance;
    _runner = () => _runGuide(forced: true);
    v.enterScreen(
      widget.screen,
      runner: _runner,
      content: () => (widget.guide ?? const PageGuide(content: _none)).content(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _onShown());
  }

  Future<void> _onShown() async {
    if (!mounted) return;
    final v = VoiceService.instance;
    final a = AppSettings.instance;
    final chain = VoiceSession.guideChain &&
        VoiceSession.guideTarget == widget.screen;
    if (chain) {
      VoiceSession.guideChain = false;
      VoiceSession.guideTarget = null;
    }

    if (a.dType.narratesPages) {
      if (widget.screen == 'now' && VoiceSession.welcomePending) {
        VoiceSession.welcomePending = false;
        if (_seen) {
          await v.speak('Berhasil masuk. Selamat datang kembali di TEDUH NOW. '
              '${v.airSummary()} Kamu bisa berkata: buka TEDUH ACTION, buka '
              'TEDUH READY, buka profil, jelajahi, ulangi panduan, atau '
              'tanyakan apa saja kepada Asisten AI.');
          return;
        }
        await v.speak('Berhasil masuk. Selamat datang di TEDUH NOW. Aku akan '
            'memandu kamu mengenal aplikasi ini. Kamu tidak perlu menyentuh '
            'layar, cukup berbicara.');
        await _blindGuide();
        return;
      }
      if (chain || !_seen) {
        await _blindGuide();
        return;
      }
      if (widget.guide == null &&
          widget.tour.isEmpty &&
          !v.hasSummary(widget.screen)) {
        return;
      }
      await v.speak('${_overview()} Katakan jelajahi untuk mendengar tiap '
          'bagian lebih dalam, atau ulangi panduan.');
      return;
    }

    if (widget.screen == 'now' && VoiceSession.welcomePending) {
      VoiceSession.welcomePending = false;
      if (a.effectiveAutoRead) {
        await v.speak('Berhasil masuk. Selamat datang di TEDUH NOW.');
      }
    }
    _maybeStartVisualTour(force: chain);
  }

  Future<void> _maybeStartVisualTour({bool force = false}) async {
    if (widget.tour.isEmpty) return;
    if (!force && _seen) return;
    if (_handle?.isActive ?? false) return;
    if (!await _waitReady()) return;
    if (!mounted) return;
    _handle = CoachMarks.show(
      context,
      steps: widget.tour,
      onEnd: (_) => AppSettings.instance.markTourSeen(widget.screen),
    );
  }

  Future<bool> _waitReady() async {
    for (int i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return false;
      final route = ModalRoute.of(context);
      final busy = VoiceService.instance.state != VoiceState.idle;
      if (route != null && route.isCurrent && !busy) return true;
    }
    return false;
  }

  Future<void> _runGuide({bool forced = false}) async {
    if (!mounted) return;
    if (AppSettings.instance.dType.narratesPages) {
      await _blindGuide();
    } else {
      await _maybeStartVisualTour(force: true);
    }
  }

  String _overview() {
    final v = VoiceService.instance;
    final g = widget.guide;
    if (g != null) return g.content();
    if (widget.tour.isNotEmpty) {
      final titles = widget.tour.map((s) => s.title).join(', ');
      return 'Halaman ini memiliki ${widget.tour.length} bagian: $titles.';
    }
    if (v.hasSummary(widget.screen)) return v.summaryFor(widget.screen);
    return 'Halaman ini belum punya penjelasan suara.';
  }

  Future<void> _blindGuide() async {
    if (_guiding || !mounted) return;
    _guiding = true;
    final v = VoiceService.instance;
    final hold = v.hold();
    try {
      if (!await _waitReady() || !mounted) return;
      await v.speak(_overview());
      if (!mounted) return;
      await _blindMenu();
    } finally {
      hold.release();
      _guiding = false;
    }
  }

  static bool _any(String heard, List<String> keys) {
    final w = heard
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((e) => e.isNotEmpty)
        .toSet();
    return keys.any(w.contains);
  }

  static const _kExplore = ['jelajahi', 'jelajah', 'explore', 'detail', 'rinci', 'dalam', 'lebih'];
  static const _kNext = ['lanjut', 'lanjutkan', 'berikutnya', 'selanjutnya', 'next', 'ya', 'iya', 'oke', 'ok', 'siap'];
  static const _kRepeat = ['ulang', 'ulangi', 'lagi', 'repeat'];
  static const _kDone = ['selesai', 'cukup', 'sudah', 'menu', 'keluar', 'stop', 'berhenti'];
  static const _kBack = ['kembali', 'sebelumnya', 'mundur'];

  Future<void> _blindMenu() async {
    final v = VoiceService.instance;
    final g = widget.guide;
    final hasNext = g?.nextScreen != null;
    final label = g?.nextLabel ?? g?.nextScreen ?? '';
    final canExplore = widget.tour.isNotEmpty;

    String options() {
      final b = StringBuffer('Apa yang ingin kamu lakukan? ');
      if (canExplore) {
        b.write('Katakan jelajahi untuk mendengar tiap bagian halaman ini '
            'lebih dalam. ');
      }
      if (hasNext) {
        b.write('Katakan lanjut untuk ke $label${g?.nextHint != null ? ', ${g!.nextHint}' : ''}. ');
      }
      b.write('Atau katakan ulangi, kembali, atau perintah lain seperti '
          'buka profil.');
      return b.toString();
    }

    bool first = true;
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      await v.speak(first
          ? options()
          : 'Katakan jelajahi, lanjut, ulangi, atau kembali.');
      first = false;
      if (!mounted) return;
      final heard = (await v.listenOnce(listenFor: const Duration(seconds: 10)))
          .toLowerCase()
          .trim();
      if (!mounted) return;
      if (heard.isEmpty) continue;

      if (canExplore && _any(heard, _kExplore)) {
        await _explore();
        i = -1;
        first = true;
        continue;
      }
      if (_any(heard, _kRepeat)) {
        await v.speak(_overview());
        i = -1;
        first = true;
        continue;
      }
      if (heard.contains('buka') || _any(heard, _kBack) || _any(heard, ['berhenti'])) {
        VoiceSession.guideChain = false;
        await v.handle(heard);
        return;
      }
      if (hasNext && _any(heard, _kNext)) {
        VoiceSession.guideChain = true;
        VoiceSession.guideTarget = g!.nextScreen;
        await v.speak('Baik, membuka $label.');
        if (!mounted) return;
        v.openMain(g.nextScreen!);
        return;
      }
      VoiceSession.guideChain = false;
      await v.handle(heard);
      return;
    }
    VoiceSession.guideChain = false;
    VoiceSession.guideTarget = null;
    if (mounted) {
      await v.speak('Aku tetap di halaman ini. Ucapkan perintah kapan saja'
          '${hasNext ? ', misalnya buka $label' : ''}.');
    }
  }

  Future<void> _explore() async {
    final v = VoiceService.instance;
    final steps = widget.tour;
    int i = 0;
    int silent = 0;
    bool announce = true;
    while (mounted && i < steps.length) {
      final s = steps[i];
      final last = i == steps.length - 1;
      if (announce) {
        await v.speak('Bagian ${i + 1} dari ${steps.length}: ${s.title}. ${s.body}');
        if (!mounted) return;
      }
      announce = true;
      await v.speak(last
          ? 'Itu bagian terakhir. Katakan ulangi, kembali, atau selesai.'
          : 'Katakan lanjut untuk bagian berikutnya, ulangi, kembali, atau selesai.');
      if (!mounted) return;
      final heard = (await v.listenOnce(listenFor: const Duration(seconds: 10)))
          .toLowerCase()
          .trim();
      if (!mounted) return;
      if (heard.isEmpty) {
        if (++silent >= 2) return;
        announce = false;
        continue;
      }
      silent = 0;
      if (_any(heard, _kDone)) {
        await v.speak('Baik, selesai menjelajah.');
        return;
      }
      if (_any(heard, _kBack)) {
        if (i > 0) i--;
        continue;
      }
      if (_any(heard, _kRepeat)) continue;

      final num = RegExp(r'\d+').firstMatch(heard);
      int? jump = num != null ? int.tryParse(num.group(0)!) : null;
      if (jump == null) {
        const words = ['satu', 'dua', 'tiga', 'empat', 'lima', 'enam', 'tujuh', 'delapan', 'sembilan'];
        for (int k = 0; k < words.length; k++) {
          if (_any(heard, [words[k]])) jump = k + 1;
        }
      }
      if (jump != null && jump >= 1 && jump <= steps.length) {
        i = jump - 1;
        continue;
      }
      int? byTitle;
      for (int k = 0; k < steps.length; k++) {
        final tw = steps[k]
            .title
            .toLowerCase()
            .split(RegExp(r'[^a-z0-9]+'))
            .where((e) => e.length > 3);
        if (tw.any((w) => heard.contains(w))) {
          byTitle = k;
          break;
        }
      }
      if (byTitle != null) {
        i = byTitle;
        continue;
      }
      if (_any(heard, _kNext)) {
        if (last) {
          await v.speak('Itu bagian terakhir. Selesai menjelajah.');
          return;
        }
        i++;
        continue;
      }
      announce = false;
    }
  }

  @override
  void dispose() {
    _handle?.dismiss(notify: false);
    VoiceService.instance.leaveScreen(widget.screen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SectionKeys {
  final List<GlobalKey> keys;
  int _i = 0;
  SectionKeys(int n) : keys = List<GlobalKey>.generate(n, (_) => GlobalKey());
  void reset() => _i = 0;
  Widget wrap(Widget child) {
    if (_i >= keys.length) return child;
    return KeyedSubtree(key: keys[_i++], child: child);
  }
}
