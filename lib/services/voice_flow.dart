import '../state/app_settings.dart';
import 'voice_service.dart';

class VoiceSession {
  VoiceSession._();
  static String? pendingEmail;
  static String? pendingPassword;
  static bool welcomePending = false;

  static bool guideChain = false;
  static String? guideTarget;
}

class VoiceFlow {
  final bool Function() alive;
  VoiceFlow(this.alive);

  VoiceService get _v => VoiceService.instance;

  Future<void> say(String text) async {
    if (!alive()) return;
    _v.flowActivity(alive);
    await _v.speak(text);
    _v.flowActivity(alive);
  }

  Future<String> ask(String prompt, {int tries = 3, String? retry}) async {
    for (int i = 0; i < tries; i++) {
      if (!alive()) return '';
      _v.flowActivity(alive);
      await _v.speak(i == 0 ? prompt : (retry ?? 'Maaf, tidak terdengar. $prompt'));
      if (!alive()) return '';
      final heard = await _v.listenOnce();
      _v.flowActivity(alive);
      if (heard.trim().isNotEmpty) return heard.trim();
    }
    return '';
  }

  Future<bool?> askYesNo(
    String prompt, {
    List<String> yes = const [],
    List<String> no = const [],
  }) async {
    for (int i = 0; i < 3; i++) {
      final a = await ask(i == 0 ? prompt : 'Mohon jawab dengan jelas. $prompt', tries: 1);
      if (!alive()) return null;
      final r = parseYesNo(a, yes: yes, no: no);
      if (r != null) return r;
    }
    return null;
  }

  static final List<String> _yes = [
    'ya', 'iya', 'yap', 'yoi', 'betul', 'benar', 'boleh', 'oke', 'ok',
    'setuju', 'aktifkan', 'aktif', 'lanjut', 'sudah', 'punya', 'mau', 'siap',
  ];
  static final List<String> _no = [
    'tidak', 'nggak', 'enggak', 'gak', 'ngga', 'bukan', 'belum', 'jangan',
    'lewati', 'skip', 'normal', 'batal',
  ];

  static bool? parseYesNo(String s,
      {List<String> yes = const [], List<String> no = const []}) {
    final words = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .split(RegExp(r'\s+'));
    bool hit(List<String> base, List<String> extra) {
      for (final w in [...base, ...extra]) {
        if (words.contains(w)) return true;
      }
      return false;
    }

    if (hit(_no, no)) return false;
    if (hit(_yes, yes)) return true;
    return null;
  }

  static const Map<String, String> _digits = {
    'nol': '0', 'kosong': '0', 'satu': '1', 'dua': '2', 'tiga': '3',
    'empat': '4', 'lima': '5', 'enam': '6', 'tujuh': '7', 'delapan': '8',
    'sembilan': '9',
  };

  static String _wordsToSymbols(String s) {
    var t = ' ${s.toLowerCase()} ';
    const rep = {
      ' titik ': '.', ' dot ': '.', ' garis bawah ': '_', ' underscore ': '_',
      ' strip ': '-', ' minus ': '-', ' tanda hubung ': '-',
      ' at ': '@', ' et ': '@', ' monyet ': '@', ' keong ': '@',
    };
    rep.forEach((k, v) => t = t.replaceAll(k, v));
    final parts = t.trim().split(RegExp(r'\s+'));
    return parts.map((w) => _digits[w] ?? w).join();
  }

  static String emailFromSpeech(String s) {
    var e = _wordsToSymbols(s).replaceAll(' ', '');
    e = e.replaceAll('gmailcom', 'gmail.com');
    if (!e.contains('@')) e = '$e@gmail.com';
    if (e.endsWith('@')) e = '${e}gmail.com';
    return e;
  }

  static String passwordFromSpeech(String s) {
    var t = s.trim();
    final parts = t.split(RegExp(r'\s+'));
    return parts.map((w) => _digits[w.toLowerCase()] ?? w).join();
  }

  static const Map<String, int> _months = {
    'januari': 1, 'februari': 2, 'maret': 3, 'april': 4, 'mei': 5,
    'juni': 6, 'juli': 7, 'agustus': 8, 'september': 9, 'oktober': 10,
    'november': 11, 'desember': 12,
  };

  static DateTime? dateFromSpeech(String s) {
    final t = s.toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ');
    final nums = RegExp(r'\d+').allMatches(t).map((m) => int.parse(m.group(0)!)).toList();
    int? month;
    _months.forEach((k, v) {
      if (t.contains(k)) month = v;
    });
    int? d, m, y;
    if (month != null && nums.length >= 2) {
      d = nums[0];
      m = month;
      y = nums[1];
    } else if (nums.length >= 3) {
      d = nums[0];
      m = nums[1];
      y = nums[2];
    }
    if (d == null || m == null || y == null) return null;
    if (y < 100) y += y > 30 ? 1900 : 2000;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    final dt = DateTime(y, m, d);
    if (dt.isAfter(DateTime.now())) return null;
    return dt;
  }

  bool get enabled => AppSettings.instance.voiceFlows;

  static Future<void> onboardingStep({
    required bool Function() alive,
    required String text,
    required void Function() onNext,
    required void Function() onSkip,
    String nextWord = 'lanjut',
  }) async {
    if (!AppSettings.instance.voiceFlows) return;
    final f = VoiceFlow(alive);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    for (int i = 0; i < 3; i++) {
      if (!alive()) return;
      VoiceService.instance.flowActivity(alive);
      await f.say(i == 0
          ? '$text Katakan $nextWord, atau lewati.'
          : 'Katakan $nextWord untuk melanjutkan, atau lewati.');
      if (!alive()) return;
      final heard = (await VoiceService.instance.listenOnce()).toLowerCase();
      if (!alive()) return;
      if (heard.contains('lewati') || heard.contains('skip')) {
        onSkip();
        return;
      }
      for (final w in ['lanjut', 'mulai', 'berikut', 'next', 'ya', 'oke', 'siap']) {
        if (heard.contains(w)) {
          onNext();
          return;
        }
      }
    }
  }
}
