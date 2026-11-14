import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../screens/accessibility_page.dart';
import '../screens/ai_analysis_page.dart';
import '../screens/ai_assistant_page.dart';
import '../screens/air_quality_history_page.dart';
import '../screens/context_recommendation_page.dart';
import '../screens/data_profile_page.dart';
import '../screens/map_page.dart';
import '../screens/notification_page.dart';
import '../screens/privacy_security_page.dart';
import '../screens/recommendation_history_page.dart';
import '../screens/mode_offline_page.dart';
import '../screens/readiness_state.dart';
import '../screens/rencana_darurat_page.dart';
import '../screens/riwayat_notifikasi_page.dart';
import '../screens/sumber_pemantauan_page.dart';
import '../screens/tas_siaga_page.dart';
import '../screens/voice_settings_page.dart';
import '../screens/region_page.dart';
import '../models/air_quality_models.dart';
import '../state/app_nav.dart';
import '../state/app_settings.dart';
import '../state/monitoring_state.dart';
import '../widgets/teduh_drawer.dart';
import 'ai_bridge.dart';
import 'context_recommendation.dart';

enum VoiceState { idle, listening, speaking }

class _ScopeInfo {
  _ScopeInfo(this.id, this.runner, this.content);
  final String id;
  final Future<void> Function()? runner;
  final String Function()? content;
}

class VoiceHold {
  VoiceHold._(this._svc);
  final VoiceService _svc;
  bool _released = false;
  void release() {
    if (_released) return;
    _released = true;
    _svc._holds.remove(this);
  }
}

class VoiceService extends ChangeNotifier {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _ttsReady = false;
  bool _sttReady = false;
  String? _localeId;

  VoiceState state = VoiceState.idle;
  String transcript = '';
  String response = '';
  String? error;

  final List<String> _screens = [];
  final List<_ScopeInfo> _scopes = [];
  String get currentScreen => _screens.isEmpty ? '' : _screens.last;

  void enterScreen(String id,
      {Future<void> Function()? runner, String Function()? content}) {
    _screens.add(id);
    _scopes.add(_ScopeInfo(id, runner, content));
    syncAmbient();
  }

  void leaveScreen(String id) {
    _screens.remove(id);
    final i = _scopes.lastIndexWhere((s) => s.id == id);
    if (i >= 0) _scopes.removeAt(i);
  }

  Future<void> Function()? get guideRunner =>
      _scopes.isEmpty ? null : _scopes.last.runner;
  String Function()? get pageContent =>
      _scopes.isEmpty ? null : _scopes.last.content;

  void _set(VoiceState s) {
    state = s;
    if (s == VoiceState.idle) _lastBusy = DateTime.now();
    notifyListeners();
  }

  final Set<VoiceHold> _holds = <VoiceHold>{};
  final Map<bool Function(), DateTime> _flowAlive = <bool Function(), DateTime>{};
  bool _foreground = true;
  bool _ambientWanted = false;
  bool _ambientRunning = false;
  bool _ambientListening = false;
  Future<String>? _ambientFut;
  DateTime _lastBusy = DateTime.fromMillisecondsSinceEpoch(0);
  AppLifecycleListener? _life;

  VoiceHold hold() {
    final h = VoiceHold._(this);
    _holds.add(h);
    return h;
  }

  void flowActivity(bool Function() alive) {
    _flowAlive[alive] = DateTime.now();
  }

  void attach() {
    if (_life != null) return;
    _life = AppLifecycleListener(onStateChange: (s) {
      _foreground = s == AppLifecycleState.resumed;
      if (!_foreground) cancelAll();
      syncAmbient();
    });
    AppSettings.instance.addListener(syncAmbient);
    syncAmbient();
  }

  void syncAmbient() {
    _ambientWanted = AppSettings.instance.effectiveVoiceNav && _foreground;
    if (_ambientWanted && !_ambientRunning) {
      _ambientLoop();
    } else if (!_ambientWanted && _ambientListening) {
      _abortAmbient();
    }
  }

  bool get _ambientBlocked {
    if (_screens.isEmpty) return true;
    if (_holds.isNotEmpty) return true;
    if (state != VoiceState.idle || _oneShot != null) return true;
    final now = DateTime.now();
    _flowAlive.removeWhere((alive, _) => !alive());
    for (final t in _flowAlive.values) {
      if (now.difference(t) < const Duration(seconds: 12)) return true;
    }
    return now.difference(_lastBusy) < const Duration(milliseconds: 1400);
  }

  Future<void> _abortAmbient() async {
    final c = _oneShot;
    if (c != null && !c.isCompleted) c.complete('');
    try {
      await _stt.cancel();
    } catch (_) {}
    final f = _ambientFut;
    if (f != null) {
      try {
        await f;
      } catch (_) {}
    }
    _ambientListening = false;
  }

  Future<void> _ambientLoop() async {
    if (_ambientRunning) return;
    _ambientRunning = true;
    int quiet = 0;
    try {
      while (_ambientWanted) {
        if (_ambientBlocked) {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          continue;
        }
        _ambientListening = true;
        String heard = '';
        try {
          _ambientFut = listenOnce(
            listenFor: const Duration(seconds: 25),
            pauseFor: const Duration(seconds: 3),
            ambient: true,
          );
          heard = await _ambientFut!;
        } catch (_) {}
        _ambientFut = null;
        _ambientListening = false;
        if (!_ambientWanted) break;
        if (_holds.isNotEmpty || _screens.isEmpty) continue;
        if (heard.isEmpty) {
          quiet++;
          final maxMs = _sttReady ? 3000 : 12000;
          await Future<void>.delayed(
              Duration(milliseconds: (400 * quiet).clamp(400, maxMs).toInt()));
        } else {
          quiet = 0;
          await handle(heard, ambient: true);
        }
      }
    } finally {
      _ambientRunning = false;
      _ambientListening = false;
    }
  }

  bool _ttsLocaleSet = false;

  Future<void> _initTts() async {
    if (_ttsReady) return;
    try {
      await _tts.setLanguage('id-ID');

      final langs = await _tts.getLanguages as List?;
      final bool hasId = langs == null ||
          langs.any((l) =>
              l.toString().toLowerCase().startsWith('id') ||
              l.toString().toLowerCase().contains('indonesian'));

      if (!hasId) {
        debugPrint('[VoiceService] PERINGATAN: Voice bahasa Indonesia (id-ID) '
            'tidak tersedia di perangkat ini. TTS mungkin menggunakan bahasa lain.');
      }

      try {
        final voices = await _tts.getVoices as List?;
        if (voices != null) {
          final idVoices = voices.where((v) {
            final str = v.toString().toLowerCase();
            return str.contains('id') || str.contains('indonesian');
          }).toList();
          if (idVoices.isNotEmpty) {
            final Map<String, String>? voiceMap = idVoices.first is Map<String, String>
                ? idVoices.first as Map<String, String>
                : null;
            if (voiceMap != null && voiceMap['name'] != null) {
              await _tts.setVoice({'name': voiceMap['name']!, 'locale': 'id-ID'});
            }
          }
        }
      } catch (_) {
      }

      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.9); 
      _ttsLocaleSet = true;

      _tts.setCompletionHandler(() {
        if (state == VoiceState.speaking) _set(VoiceState.idle);
      });
      _tts.setCancelHandler(() {
        if (state == VoiceState.speaking) _set(VoiceState.idle);
      });
      _tts.setErrorHandler((_) {
        if (state == VoiceState.speaking) _set(VoiceState.idle);
      });
      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
      _ttsLocaleSet = false;
    }
  }

  String _prepareTtsText(String raw) {
    if (raw.trim().isEmpty) return '';
    var text = raw.trim();

    text = text.replaceAll(RegExp(r'\*\*|__|[#*`_~]'), '');

    text = text.replaceAll(RegExp(r'\.{2,}'), ',');
    text = text.replaceAll(RegExp(r'\.\s+'), ', ');

    text = text.replaceAll(RegExp(r'[,;]\s*,'), ',');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (!text.endsWith('.') && !text.endsWith('?') && !text.endsWith('!')) {
      text = '$text.';
    }
    return text;
  }

  Future<void> speak(String text) async {
    response = text;
    if (_ambientListening) await _abortAmbient();
    await _initTts();
    try {
      await _tts.stop();
      if (!_ttsLocaleSet) {
        await _tts.setLanguage('id-ID');
        _ttsLocaleSet = true;
      }
      final rate = AppSettings.instance.speechRate.clamp(0.52, 0.85);
      await _tts.setSpeechRate(rate);
      _set(VoiceState.speaking);
      final prepared = _prepareTtsText(text);
      await _tts.speak(prepared);
      if (state == VoiceState.speaking) _set(VoiceState.idle);
    } catch (_) {
      _set(VoiceState.idle);
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
    if (state == VoiceState.speaking) _set(VoiceState.idle);
  }

  Future<void> autoReadIfEnabled(String text) async {
    if (AppSettings.instance.effectiveAutoRead) await speak(text);
  }

  Future<bool> _initStt() async {
    if (_sttReady) return true;
    try {
      _sttReady = await _stt.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      if (_sttReady) {
        final locales = await _stt.locales();
        for (final l in locales) {
          if (l.localeId.toLowerCase().startsWith('id')) {
            _localeId = l.localeId;
            break;
          }
        }
        _localeId ??= 'id_ID';
      }
    } catch (_) {
      _sttReady = false;
    }
    return _sttReady;
  }

  Completer<String>? _oneShot;

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      final c = _oneShot;
      if (c != null) {
        if (!c.isCompleted) c.complete(transcript);
        return;
      }
      if (state == VoiceState.listening) _finishListening();
    }
  }

  void _onError(SpeechRecognitionError e) {
    final c = _oneShot;
    if (c != null) {
      if (!c.isCompleted) c.complete(transcript);
      return;
    }
    if (state != VoiceState.listening) return;
    error = e.errorMsg == 'error_no_match' || e.errorMsg == 'error_speech_timeout'
        ? 'Suara tidak terdengar. Coba ucapkan lagi.'
        : 'Pengenalan suara bermasalah (${e.errorMsg}).';
    _set(VoiceState.idle);
  }

  Future<void> startListening() async {
    error = null;
    transcript = '';
    await stopSpeaking();
    final ok = await _initStt();
    if (!ok) {
      error = 'Pengenalan suara tidak tersedia. Pastikan izin mikrofon '
          'diberikan dan layanan suara Google aktif.';
      _set(VoiceState.idle);
      return;
    }
    _set(VoiceState.listening);
    try {
      await _stt.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          localeId: _localeId ?? 'id_ID',
          listenMode: ListenMode.confirmation,
          listenFor: const Duration(seconds: 20),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      error = 'Tidak bisa memulai mendengarkan.';
      _set(VoiceState.idle);
    }
  }

  Future<String> listenOnce({
    Duration listenFor = const Duration(seconds: 12),
    Duration pauseFor = const Duration(seconds: 3),
    bool ambient = false,
  }) async {
    if (!ambient && _ambientListening) {
      await _abortAmbient();
    } else if (_oneShot != null) {
      final old = _oneShot!;
      if (!old.isCompleted) old.complete('');
      try {
        await _stt.cancel();
      } catch (_) {}
    }
    error = null;
    transcript = '';
    await stopSpeaking();
    final ok = await _initStt();
    if (!ok) {
      error = 'Pengenalan suara tidak tersedia.';
      _set(VoiceState.idle);
      return '';
    }
    final c = Completer<String>();
    _oneShot = c;
    _set(VoiceState.listening);
    try {
      await _stt.listen(
        onResult: (r) {
          transcript = r.recognizedWords;
          notifyListeners();
          if (r.finalResult && !c.isCompleted) c.complete(r.recognizedWords);
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          localeId: _localeId ?? 'id_ID',
          listenMode: ListenMode.confirmation,
          listenFor: listenFor,
          pauseFor: pauseFor,
        ),
      );
    } catch (_) {
      if (!c.isCompleted) c.complete('');
    }
    final res = await c.future
        .timeout(listenFor + const Duration(seconds: 4), onTimeout: () => transcript);
    if (identical(_oneShot, c)) {
      _oneShot = null;
      try {
        await _stt.stop();
      } catch (_) {}
      _set(VoiceState.idle);
    }
    return res.trim();
  }

  Future<void> cancelAll() async {
    await stopSpeaking();
    try {
      await _stt.cancel();
    } catch (_) {}
    final c = _oneShot;
    if (c != null && !c.isCompleted) c.complete('');
    if (state != VoiceState.idle) _set(VoiceState.idle);
  }

  void _onResult(SpeechRecognitionResult r) {
    transcript = r.recognizedWords;
    notifyListeners();
    if (r.finalResult) _finishListening();
  }

  bool _finishing = false;
  Future<void> _finishListening() async {
    if (_finishing) return;
    _finishing = true;
    try {
      await _stt.stop();
    } catch (_) {}
    final text = transcript.trim();
    if (text.isEmpty) {
      error ??= 'Suara tidak terdengar. Coba ucapkan lagi.';
      _set(VoiceState.idle);
    } else {
      _set(VoiceState.idle);
      await handle(text);
    }
    _finishing = false;
  }

  Future<void> stopListening() async {
    if (state != VoiceState.listening) return;
    await _finishListening();
  }
  
  static const List<String> exampleCommands = [
    'Buka TEDUH NOW',
    'Buka TEDUH ACTION',
    'Buka TEDUH READY',
    'Bacakan kondisi udara',
    'Apa rekomendasi untuk saya?',
    'Buka checklist saya',
    'Bacakan informasi ini',
    'Kembali',
    'Apa itu PM2.5?',
    'Apa yang harus saya lakukan saat kabut asap?',
  ];

  String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool _has(String t, List<String> words) {
    for (final w in words) {
      if (t.contains(w)) return true;
    }
    return false;
  }

  String? _lastA11yReply;

  NavigatorState? get _nav => teduhNavKey.currentState;

  VoidCallback? closeSheet;
  bool closedByNavigation = false;

  void _dismissSheet() {
    final c = closeSheet;
    if (c != null) {
      closedByNavigation = true;
      c();
    }
  }

  void _push(Widget page) {
    _dismissSheet();
    _nav?.push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _goMain(HomeMenuItem item) {
    _dismissSheet();
    final nav = _nav;
    if (nav == null) return;
    if (item == HomeMenuItem.now) {
      nav.popUntil((r) => r.isFirst);
      return;
    }
    nav.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => TeduhNav.pageFor(item)),
      (r) => r.isFirst,
    );
  }

  void askAssistant(String question) {
    final send = AiAssistantBridge.send;
    if (send != null) {
      send(question);
    } else {
      AiAssistantBridge.pending = question;
      _push(const AiAssistantPage());
    }
  }

  bool _isControl(String t) =>
      _has(t, ['berhenti', 'diam', 'stop', 'kembali', 'balik', 'tutup']) ||
      t.startsWith('buka ') ||
      t.startsWith('pergi ');

  bool _looksLikeQuestion(String t) {
    const starters = [
      'apa', 'apakah', 'bagaimana', 'gimana', 'kenapa', 'mengapa', 'siapa',
      'kapan', 'dimana', 'di mana', 'berapa', 'bolehkah', 'tanya', 'tolong',
      'asisten', 'teduh',
    ];
    for (final s in starters) {
      if (t == s || t.startsWith('$s ')) return true;
    }
    return false;
  }

  void openMain(String screen) {
    switch (screen) {
      case 'now':
        _goMain(HomeMenuItem.now);
      case 'action':
        _goMain(HomeMenuItem.action);
      case 'ready':
        _goMain(HomeMenuItem.ready);
      case 'profile':
        _goMain(HomeMenuItem.profile);
      case 'help':
        _goMain(HomeMenuItem.help);
    }
  }

  String _scaleReply() {
    final s = AppSettings.instance;
    return 'Ukuran teks sekarang ${AppSettings.sizeLabels[s.textSizeIdx]}, '
        '${AppSettings.sizePercents[s.textSizeIdx]} persen.';
  }

  String? _accessibilityCommand(String t) {
    final s = AppSettings.instance;
    final off = _has(t, ['matikan', 'nonaktifkan', 'sembunyikan', 'hapus']);
    if (_has(t, ['teks', 'tulisan', 'huruf']) &&
        _has(t, ['besar', 'perbesar', 'naikkan', 'kecil', 'perkecil', 'turunkan', 'normal', 'standar'])) {
      if (_has(t, ['normal', 'standar'])) {
        s.update(() => s.textSizeIdx = 2);
      } else if (_has(t, ['kecil', 'perkecil', 'turunkan'])) {
        s.update(() => s.textSizeIdx = (s.textSizeIdx - 1).clamp(0, 4).toInt());
      } else {
        s.update(() => s.textSizeIdx = (s.textSizeIdx + 1).clamp(0, 4).toInt());
      }
      return _scaleReply();
    }
    if (_has(t, ['mode gelap', 'tema gelap', 'gelap'])) {
      s.update(() => s.darkMode = !off);
      return off ? 'Mode gelap dimatikan.' : 'Mode gelap diaktifkan.';
    }
    if (_has(t, ['mode terang', 'tema terang', 'terang'])) {
      s.update(() => s.darkMode = false);
      return 'Mode terang diaktifkan.';
    }
    if (t.contains('kontras')) {
      s.update(() => s.highContrast = !off);
      return off ? 'Kontras tinggi dimatikan.' : 'Kontras tinggi diaktifkan.';
    }
    if (t.contains('animasi')) {
      final on = !off && !_has(t, ['nyalakan', 'aktifkan animasi']);
      final reduce = _has(t, ['kurangi', 'matikan', 'hentikan']) || on;
      s.update(() => s.reduceMotion = reduce && !_has(t, ['nyalakan']));
      return s.reduceMotion ? 'Animasi dikurangi.' : 'Animasi dinyalakan.';
    }
    if (t.contains('sirene')) {
      s.update(() => s.sirenEnabled = !off);
      return off ? 'Sirene dimatikan.' : 'Sirene dinyalakan.';
    }
    if (t.contains('bahasa sederhana')) {
      s.update(() => s.simpleLanguage = !off);
      return off ? 'Bahasa sederhana dimatikan.' : 'Bahasa sederhana diaktifkan.';
    }
    if (t.contains('suara') && _has(t, ['cepat', 'lambat', 'pelan'])) {
      final faster = t.contains('cepat');
      s.update(() => s.speechRate = (s.speechRate + (faster ? 0.1 : -0.1)).clamp(0.25, 0.8).toDouble());
      return faster ? 'Suara dipercepat.' : 'Suara diperlambat.';
    }
    if (t.contains('sumber') || t.contains('satelit') || t.contains('copernicus') ||
        t.contains('sensor') || t.contains('iot')) {
      if (_has(t, ['ganti', 'ubah', 'pakai', 'gunakan', 'pilih', 'ke '])) {
        return 'Sumber ISPU TEDUH telah ditetapkan sebagai stasiun resmi KLHK '
            'dan tidak dapat diubah secara manual. '
            'Data selalu berasal dari stasiun pemantau udara resmi pemerintah.';
      }
    }
    return null;
  }

  String airSummary() {
    final a = AppSettings.instance.snapshot;
    final String advice = a.ispu > 300
        ? 'Hindari aktivitas di luar ruangan dan gunakan respirator bila terpaksa keluar.'
        : a.ispu > 200
            ? 'Kurangi aktivitas di luar ruangan.'
            : a.ispu > 100
                ? 'Kelompok sensitif sebaiknya mengurangi aktivitas di luar ruangan.'
                : 'Udara cukup baik untuk beraktivitas.';
    return 'Kondisi udara di ${a.location} saat ini ${a.status}. '
        'ISPU ${a.ispu}, PM2.5 ${a.pm25}. '
        'Data dari ${a.sourceName}, diperbarui ${a.updatedAt}. $advice';
  }

  String recommendationSummary() {
    final rec = ContextRecommender.build(
      air: AppSettings.instance.snapshot,
      activity: ActivityChoice.current,
      sensitive: ActivityChoice.sensitive,
    );
    return 'Untuk aktivitas ${ActivityChoice.current.label.toLowerCase()}: '
        '${rec.spoken(simple: AppSettings.instance.effectiveSimpleLanguage)}';
  }

  String pageSummary() {
    final c = pageContent;
    if (c != null && !hasSummary(currentScreen)) return c();
    return summaryFor(currentScreen);
  }

  bool hasSummary(String screen) =>
      const ['now', 'action', 'ready', 'profile', 'help'].contains(screen);

  String summaryFor(String screen) {
    switch (screen) {
      case 'now':
        return airSummary();
      case 'action':
        return recommendationSummary();
      case 'ready':
        return 'Kesiapsiagaanmu saat ini '
            '${ReadinessState.instance.overallPercent} persen. '
            'Ada dua menu: Tas Siaga Haze, yang juga berisi checklist langkah '
            'harian, dan Rencana Darurat.';
      case 'profile':
        return 'Halaman Profil berisi tiga kelompok menu: Akun Saya, '
            'Aktivitas Teduh, dan Pengaturan.';
      case 'help':
        return 'Halaman Bantuan dan FAQ berisi pertanyaan yang sering '
            'diajukan seputar ISPU, pembaruan data, masker, Siaga Udara, '
            'dan Konsultasi AI.';
      default:
        return 'Halaman ini belum punya ringkasan suara. Ucapkan buka '
            'TEDUH NOW untuk mendengar kondisi udara.';
    }
  }

  Future<String> handle(String raw, {bool ambient = false}) async {
    final t = _norm(raw);
    final compact = t.replaceAll(' ', '');
    String reply;

    if (currentScreen == 'assistant' && !_isControl(t)) {
      askAssistant(raw);
      response = 'Pertanyaan terkirim ke Asisten AI.';
      notifyListeners();
      return response;
    }

    if (_has(t, ['berhenti', 'diam', 'stop'])) {
      await stopSpeaking();
      response = 'Baik, berhenti.';
      notifyListeners();
      return response;
    } else if (t == 'kembali' || t.startsWith('kembali ') || t == 'balik') {
      _dismissSheet();
      _nav?.maybePop();
      reply = 'Kembali ke halaman sebelumnya.';
    } else if (_has(t, [
      'ulangi panduan', 'mulai panduan', 'putar panduan', 'buka panduan',
      'panduan halaman', 'panduan ini', 'jelaskan halaman', 'jelaskan fitur',
      'jelaskan halaman ini', 'jelaskan isi',
    ])) {
      final run = guideRunner;
      if (run == null) {
        reply = 'Halaman ini belum punya panduan suara. Ucapkan bacakan '
            'informasi ini untuk mendengar isinya.';
      } else {
        reply = 'Baik, aku mulai panduan halaman ini.';
        run();
      }
    } else if (_has(t, ['daftar perintah', 'perintah apa', 'bantuan suara', 'apa yang bisa'])) {
      reply = 'Kamu bisa mengucapkan: buka TEDUH NOW, buka TEDUH ACTION, '
          'buka TEDUH READY, buka analisis kualitas udara, buka rekomendasi aktivitas, '
          'tampilkan riwayat kualitas udara, mulai percakapan baru, buka profil, '
          'buka bantuan, bacakan kondisi udara atau ISPU, '
          'apa rekomendasi untuk saya, buka checklist saya, bacakan informasi '
          'ini, ulangi panduan, atau kembali. Ketuk layar kapan saja untuk '
          'menghentikan suaraku. '
          'Kamu juga bisa bilang: perbesar teks, mode gelap, kontras tinggi, '
          'kurangi animasi, atau tanya apa saja '
          'untuk dijawab Asisten AI.';
    } else if (_has(t, ['bacakan halaman', 'bacakan informasi', 'baca halaman', 'baca informasi', 'bacakan ini'])) {
      reply = pageSummary();
    } else if (t.contains('rekomendasi') &&
        !_has(t, ['buka', 'masuk', 'tampilkan'])) {
      reply = recommendationSummary();
    } else if (t.contains('udara') &&
        !_has(t, ['buka', 'masuk', 'riwayat', 'peta', 'mengapa', 'kenapa', 'kabut']) &&
        _has(t, ['bacakan', 'baca', 'bagaimana', 'gimana', 'kondisi', 'kualitas', 'hari ini'])) {
      reply = airSummary();
    } else if ((_lastA11yReply = _accessibilityCommand(t)) != null) {
      reply = _lastA11yReply!;
    } else if (t.startsWith('tambah item') || t.startsWith('tambahkan item')) {
      final item = raw.replaceFirst(RegExp(r'^\s*tambah(kan)?\s+item\s*', caseSensitive: false), '').trim();
      if (item.isEmpty) {
        reply = 'Sebutkan nama itemnya, misalnya tambah item senter.';
      } else {
        ReadinessState.instance.addCustomItem(item);
        reply = 'Item $item ditambahkan ke Tas Siaga.';
      }
    } else if (_has(t, ['tas siaga'])) {
      _push(const TasSiagaPage());
      reply = 'Membuka Tas Siaga Haze.';
    } else if (_has(t, ['rencana darurat'])) {
      _push(const RencanaDaruratPage());
      reply = 'Membuka Rencana Darurat.';
    } else if (_has(t, ['progres', 'progress'])) {
      _push(const TasSiagaPage());
      reply = 'Membuka Tas Siaga Haze, tempat progres kesiapsiagaan.';
    } else if (_has(t, ['data profil'])) {
      _push(const DataProfilePage());
      reply = 'Membuka Data Profil.';
    } else if (_has(t, ['privasi', 'keamanan'])) {
      _push(const PrivacySecurityPage());
      reply = 'Membuka Privasi dan Keamanan.';
    } else if (_has(t, ['lokasi saya'])) {
      _push(const MapPage());
      reply = 'Membuka Lokasi Saya.';
    } else if (_has(t, ['riwayat rekomendasi'])) {
      _push(const RecommendationHistoryPage());
      reply = 'Membuka Riwayat Rekomendasi.';
    } else if (_has(t, ['pengaturan notifikasi', 'kelola notifikasi'])) {
      _push(const NotificationPage());
      reply = 'Membuka pengaturan Notifikasi.';
    } else if (_has(t, ['riwayat notifikasi', 'notifikasi'])) {
      _push(const RiwayatNotifikasiPage());
      reply = 'Membuka Riwayat Notifikasi.';
    } else if (_has(t, ['riwayat kualitas udara', 'tampilkan riwayat', 'buka riwayat udara'])) {
      _push(const AirQualityHistoryPage());
      reply = 'Membuka Riwayat Kualitas Udara.';
    } else if (_has(t, ['riwayat'])) {
      _push(const AirQualityHistoryPage());
      reply = 'Membuka Riwayat Kualitas Udara.';
    } else if (_has(t, ['sumber'])) {
      _push(const SumberPemantauanPage());
      reply = 'Membuka Sumber Pemantauan.';
    } else if (_has(t, ['peta'])) {
      _push(const MapPage());
      reply = 'Membuka Peta Udara.';
    } else if (_has(t, ['offline'])) {
      _push(const ModeOfflinePage());
      reply = 'Membuka Mode Offline.';
    } else if (_has(t, ['pengaturan suara'])) {
      _push(const VoiceSettingsPage());
      reply = 'Membuka Pengaturan Suara.';
    } else if (_has(t, ['aksesibilitas'])) {
      _push(const AccessibilityPage());
      reply = 'Membuka Aksesibilitas.';
    } else if (_has(t, ['analisis kualitas udara', 'buka analisis'])) {
      _push(const AiAnalysisPage());
      reply = 'Membuka Analisis Kualitas Udara.';
    } else if (_has(t, ['analisis'])) {
      _push(const AiAnalysisPage());
      reply = 'Membuka Analisis AI.';
    } else if (_has(t, ['percakapan baru', 'mulai percakapan', 'chat baru', 'mulai chat'])) {
      AiAssistantBridge.pending = null; 
      _push(const AiAssistantPage());
      reply = 'Membuka percakapan baru di Asisten AI TEDUH.';
    } else if (_has(t, ['asisten', 'tanya ai'])) {
      _push(const AiAssistantPage());
      reply = 'Membuka Asisten AI TEDUH.';
    } else if (_has(t, ['ganti wilayah', 'ubah wilayah', 'pilih wilayah', 'buka wilayah', 'wilayah pemantauan', 'wilayah'])) {
      final match = MonitoringRegion.matchFromText(raw);
      if (match != null) {
        MonitoringState.instance.setRegion(match);
        reply = 'Wilayah berhasil diubah ke ${match.province}, ${match.regency}.';
      } else {
        _push(const RegionPage());
        reply = 'Membuka halaman pilih wilayah. Sebutkan wilayah yang ingin kamu pantau.';
      }
    } else if (_has(t, ['ispu', 'kualitas udara saya', 'udara wilayah saya', 'ispu wilayah'])) {
      reply = airSummary();
    } else if (_has(t, ['rekomendasi aktivitas', 'buka rekomendasi'])) {
      _push(const ContextRecommendationPage());
      reply = 'Membuka rekomendasi aktivitas. ${recommendationSummary()}';
    } else if (t.contains('rekomendasi')) {
      _push(const ContextRecommendationPage());
      reply = 'Membuka rekomendasi untuk aktivitasmu.';
    } else if (_has(t, ['profil'])) {
      _goMain(HomeMenuItem.profile);
      reply = 'Membuka Profil.';
    } else if (_has(t, ['bantuan', 'faq'])) {
      _goMain(HomeMenuItem.help);
      reply = 'Membuka Pusat Bantuan dan FAQ.';
    } else if (_has(t, ['ready', 'checklist', 'kesiapsiagaan', 'siaga'])) {
      _goMain(HomeMenuItem.ready);
      reply = 'Membuka TEDUH READY. ${pageSummaryFor('ready')}';
    } else if (_has(t, ['action', 'aksi'])) {
      _goMain(HomeMenuItem.action);
      reply = 'Membuka TEDUH ACTION.';
    } else if (_has(t, ['teduh now', 'beranda', 'home', 'pemantauan', 'buka now'])) {
      _goMain(HomeMenuItem.now);
      reply = 'Membuka TEDUH NOW. ${airSummary()}';
    } else if (compact.contains('pm25') || compact.contains('pm2')) {
      reply = 'PM2.5 adalah partikel polusi yang sangat kecil, berukuran '
          'kurang dari 2,5 mikrometer. Partikel ini bisa masuk jauh ke paru-paru. '
          'Saat kabut asap, jumlahnya naik dan dapat memicu batuk, sesak, '
          'serta memperberat asma.';
    } else if (_has(t, ['kabut asap', 'asap']) &&
        _has(t, ['harus', 'lakukan', 'bagaimana', 'gimana', 'tindakan'])) {
      reply = 'Saat kabut asap: tetap di dalam ruangan dengan pintu dan '
          'jendela tertutup, kurangi aktivitas berat, gunakan respirator N95 '
          'yang rapat bila harus keluar, dan segera cari bantuan medis bila '
          'sesak napas berat atau nyeri dada.';
    } else if (_has(t, ['mengapa', 'kenapa']) && t.contains('udara')) {
      final a = AppSettings.instance.snapshot;
      reply = 'Menurut ${a.sourceName}, ISPU saat ini ${a.ispu} dan PM2.5 '
          '${a.pm25}, yaitu level ${a.status}. Di musim kemarau, asap '
          'kebakaran hutan dan lahan sering menjadi penyebab utama partikel '
          'halus. Untuk penyebab pasti, ikuti informasi otoritas setempat.';
    } else if (t.contains('masker')) {
      reply = 'Masker kain tidak cukup untuk asap halus. Gunakan respirator '
          'N95 atau KN95 yang rapat di wajah, dan ingat masker tidak '
          'menghilangkan seluruh risiko.';
    } else {
      if (ambient && !_looksLikeQuestion(t)) {
        return '';
      }
      askAssistant(raw);
      reply = 'Pertanyaanmu aku teruskan ke Asisten AI: $raw';
    }

    await speak(reply);
    return reply;
  }

  String pageSummaryFor(String screen) {
    if (screen == 'ready') {
      return 'Kesiapsiagaanmu ${ReadinessState.instance.overallPercent} persen.';
    }
    return '';
  }
}
