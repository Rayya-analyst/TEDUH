import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ai/teduh_ai_orchestrator.dart';
import '../services/ai_bridge.dart';
import '../services/voice_service.dart';
import '../state/app_settings.dart';
import '../state/monitoring_state.dart';
import '../widgets/coach_marks.dart';
import '../widgets/teduh_common.dart';
import '../widgets/voice_scope.dart';

class ChatMessage {
  final bool fromUser;
  final String text;
  final String time;
  final List<String> citations;

  const ChatMessage({
    required this.fromUser,
    required this.text,
    required this.time,
    this.citations = const [],
  });

  Map<String, dynamic> toJson() => {
        'fromUser': fromUser,
        'text': text,
        'time': time,
        'citations': citations,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        fromUser: json['fromUser'] as bool? ?? false,
        text: json['text'] as String? ?? '',
        time: json['time'] as String? ?? '',
        citations: (json['citations'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}

class ChatSession {
  final String id;
  String title;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Percakapan Baru',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        messages: (json['messages'] as List?)
                ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

const List<String> _quickSuggestions = [
  'Penyebab Karhutla & Gambut?',
  'Dampak PM2.5 bagi Balita?',
  'Kapan harus segera ke IGD?',
  'Standar Masker N95 vs Kain?',
  'Cara buat Ruang Bersih?',
  'Pertolongan Pertama Sesak?',
];

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

  static const _bg = Color(0xFFF3F6F2);
  static const _userBubble = Color(0xFF2F6B57);
  static const _send = Color(0xFF1F6B4F);
  static const _dangerDeep = Color(0xFF8E1B1B);
  static const _dangerTint = Color(0xFFFDECE8);

  static const String _sessionsPrefKey = 'teduh_ai_chat_sessions_v2';

  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isProcessing = false;
  bool _isLoadingSessions = true;
  Timer? _typewriterTimer;
  String? _ongoingFullText;

  final GlobalKey _kBanner = GlobalKey();
  final GlobalKey _kAnswer = GlobalKey();
  final GlobalKey _kSugg = GlobalKey();
  final GlobalKey _kInput = GlobalKey();

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

    _loadSessions().then((_) {
      final pending = AiAssistantBridge.pending;
      if (pending != null) {
        AiAssistantBridge.pending = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _sendMessage(pending);
        });
      }
    });
  }

  @override
  void dispose() {
    _finalizeCurrentTyping();
    AiAssistantBridge.send = null;
    _anim.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _finalizeCurrentTyping() {
    if (_typewriterTimer != null && _typewriterTimer!.isActive) {
      _typewriterTimer!.cancel();
      _typewriterTimer = null;
      if (_ongoingFullText != null &&
          _currentSession != null &&
          _currentSession!.messages.isNotEmpty) {
        final lastIdx = _currentSession!.messages.length - 1;
        final lastMsg = _currentSession!.messages[lastIdx];
        if (!lastMsg.fromUser && lastMsg.text != _ongoingFullText) {
          _currentSession!.messages[lastIdx] = ChatMessage(
            fromUser: false,
            text: _ongoingFullText!,
            time: lastMsg.time,
            citations: lastMsg.citations,
          );
        }
      }
      _ongoingFullText = null;
    }
  }

  String _hhmm() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}.'
        '${n.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionsPrefKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw) as List;
        _sessions = list
            .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[AiAssistant] Error loading sessions: $e');
    }

    if (_sessions.isEmpty) {
      final newSession = ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Percakapan Baru',
        createdAt: DateTime.now(),
        messages: [],
      );
      _sessions.add(newSession);
      _currentSession = newSession;
    } else {
      _currentSession = _sessions.first;
    }

    if (mounted) {
      setState(() => _isLoadingSessions = false);
    }
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _sessions.map((s) => s.toJson()).toList();
      await prefs.setString(_sessionsPrefKey, jsonEncode(list));
    } catch (e) {
      debugPrint('[AiAssistant] Error saving sessions: $e');
    }
  }

  void _createNewChat() {
    _finalizeCurrentTyping();
    FocusScope.of(context).unfocus();
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Percakapan Baru',
      createdAt: DateTime.now(),
      messages: [],
    );
    setState(() {
      _sessions.insert(0, newSession);
      _currentSession = newSession;
    });
    _saveSessions();
    _toBottom();
  }

  void _switchSession(ChatSession session) {
    _finalizeCurrentTyping();
    setState(() {
      _currentSession = session;
    });
    Navigator.of(context).maybePop();
    _toBottom();
  }

  void _deleteSession(ChatSession session) {
    _finalizeCurrentTyping();
    setState(() {
      _sessions.removeWhere((s) => s.id == session.id);
      if (_currentSession?.id == session.id) {
        if (_sessions.isNotEmpty) {
          _currentSession = _sessions.first;
        } else {
          final fresh = ChatSession(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Percakapan Baru',
            createdAt: DateTime.now(),
            messages: [],
          );
          _sessions.add(fresh);
          _currentSession = fresh;
        }
      }
    });
    _saveSessions();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _sendMessage([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _isProcessing) return;
    _finalizeCurrentTyping();
    _input.clear();
    final timeStr = _hhmm();

    if (_currentSession == null) {
      _createNewChat();
    }

    final session = _currentSession!;

    if (session.messages.isEmpty && session.title == 'Percakapan Baru') {
      session.title = text.length > 28 ? '${text.substring(0, 28)}...' : text;
    }

    final userMsg = ChatMessage(fromUser: true, text: text, time: timeStr);
    setState(() {
      session.messages.add(userMsg);
      _isProcessing = true;
    });
    _saveSessions();
    _toBottom();

    try {
      final history = session.messages.map((m) => {
            'role': m.fromUser ? 'user' : 'model',
            'text': m.text,
          }).toList();

      final res = await TeduhAiOrchestrator.instance.askAssistant(
        userQuestion: text,
        liveAir: AppSettings.instance.snapshot,
        conversationHistory: history,
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      final fullText = res.mainAction;
      final aiTime = _hhmm();
      _ongoingFullText = fullText;

      final aiMsg = ChatMessage(
        fromUser: false,
        text: '',
        time: aiTime,
        citations: res.citations,
      );
      setState(() {
        session.messages.add(aiMsg);
      });

      int charIndex = 0;
      final step = math.max(14, (fullText.length / 40).ceil());
      int scrollThrottle = 0;

      _typewriterTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
        try {
          if (!mounted) {
            timer.cancel();
            return;
          }
          charIndex = math.min(charIndex + step, fullText.length);
          final currentSub = fullText.substring(0, charIndex);

          final lastIdx = session.messages.length - 1;
          if (lastIdx >= 0) {
            session.messages[lastIdx] = ChatMessage(
              fromUser: false,
              text: currentSub,
              time: aiTime,
              citations: res.citations,
            );
          }
          setState(() {});

          scrollThrottle++;
          if (scrollThrottle % 3 == 0 && _scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }

          if (charIndex >= fullText.length) {
            timer.cancel();
            _typewriterTimer = null;
            _ongoingFullText = null;
            if (lastIdx >= 0) {
              session.messages[lastIdx] = ChatMessage(
                fromUser: false,
                text: fullText,
                time: aiTime,
                citations: res.citations,
              );
              setState(() {});
            }
            _saveSessions();
            _toBottom();
            VoiceService.instance.autoReadIfEnabled(res.speakableText);
          }
        } catch (err) {
          timer.cancel();
          _typewriterTimer = null;
          _ongoingFullText = null;
          final lastIdx = session.messages.length - 1;
          if (lastIdx >= 0) {
            session.messages[lastIdx] = ChatMessage(
              fromUser: false,
              text: fullText,
              time: aiTime,
              citations: res.citations,
            );
            setState(() {});
          }
          _saveSessions();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        session.messages.add(ChatMessage(
          fromUser: false,
          text: 'Maaf, terjadi kendala saat memproses jawaban. Silakan tanyakan kembali.',
          time: _hhmm(),
        ));
      });
      _saveSessions();
      _toBottom();
    }
  }

  Widget _r(double b, double e, Widget child) =>
      Reveal(animation: _anim, begin: b, end: e, child: child);

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'assistant',
        tour: [
          CoachStep(
            target: _kBanner,
            title: 'Kondisi udara untuk konteks',
            body:
                'Kartu ini merangkum data stasiun pemantauan aktif yang dipakai AI sebagai konteks agar rekomendasi akurat.',
            scrollAlignment: 0.1,
          ),
          CoachStep(
            target: _kAnswer,
            title: 'Jawaban Cerdas TEDUH AI',
            body:
                'Respon AI disesuaikan dengan pedoman WHO, ISPU KLHK, dan penanganan kabut asap lahan gambut.',
            scrollAlignment: 0.15,
          ),
          CoachStep(
            target: _kSugg,
            title: 'Pertanyaan cepat',
            body:
                'Ketuk saran pertanyaan seputar Karhutla, PM2.5, N95, atau IGD untuk bertanya instan.',
            scrollAlignment: 0.3,
          ),
          CoachStep(
            target: _kInput,
            title: 'Tanya apa saja',
            body:
                'Ketik pertanyaanmu tentang udara, kabut asap, dan perlindungan pernapasan di sini.',
          ),
        ],
        guide: PageGuide(
          content: () =>
              'Ini halaman Asisten AI TEDUH. Kamu bisa mengetik atau mengucapkan pertanyaan tentang dampak kabut asap, cara membuat ruang aman, rekomendasi masker, hingga kriteria kegawatdaruratan IGD. Di halaman ini semua ucapanmu dianggap pertanyaan. Ucapkan kembali untuk keluar.',
        ),
        child: _buildScaffold(context),
      );

  Widget _buildScaffold(BuildContext context) {
    final maxBubble = MediaQuery.of(context).size.width * 0.82;
    final messages = _currentSession?.messages ?? [];

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
              child: _isLoadingSessions
                  ? const Center(
                      child: CircularProgressIndicator(color: TC.greenDeep),
                    )
                  : SingleChildScrollView(
                      controller: _scroll,
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _r(0.10, 0.45,
                              KeyedSubtree(key: _kBanner, child: _contextBanner())),
                          const SizedBox(height: 18),

                          if (messages.isEmpty) ...[
                            _r(0.20, 0.60, _welcomeCard()),
                            const SizedBox(height: 18),
                            _r(0.40, 0.85,
                                KeyedSubtree(key: _kSugg, child: _suggestionCard())),
                          ] else ...[
                            for (final m in messages) ...[
                              _PopIn(
                                key: ObjectKey(m),
                                child: m.fromUser
                                    ? _userMessage(m.text, m.time, maxBubble)
                                    : _dynamicAnswer(m),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],

                          if (_isProcessing) ...[
                            _aiLabel(_hhmm()),
                            const SizedBox(height: 8),
                            _AiCard(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF1F6B4F),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'TEDUH AI sedang memproses jawaban...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: TC.hint,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
            ),
            _r(0.50, 0.95, KeyedSubtree(key: _kInput, child: _inputBar())),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFD3E8D8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.auto_awesome_rounded,
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
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: TC.dark,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3FA564),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _currentSession?.title ?? 'Aktif · siap membantu',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: TC.hint,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Chat Baru',
          onPressed: _createNewChat,
          icon: const Icon(Icons.add_comment_outlined),
          color: TC.greenDeep,
          iconSize: 23,
        ),
        IconButton(
          tooltip: 'Riwayat Percakapan',
          onPressed: _showHistorySheet,
          icon: const Icon(Icons.history_rounded),
          color: TC.dark,
          iconSize: 24,
        ),
      ],
    );
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8E2DB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Riwayat Percakapan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TC.dark,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _createNewChat();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Chat Baru'),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: _sessions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Belum ada riwayat percakapan.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: TC.hint,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _sessions.length,
                          separatorBuilder: (ctx, idx) =>
                              const Divider(height: 1, color: TC.divider),
                          itemBuilder: (context, i) {
                            final s = _sessions[i];
                            final isCurrent = s.id == _currentSession?.id;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                isCurrent
                                    ? Icons.chat_bubble_rounded
                                    : Icons.chat_bubble_outline_rounded,
                                color: isCurrent ? TC.greenDeep : TC.hint,
                                size: 20,
                              ),
                              title: Text(
                                s.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isCurrent ? TC.greenDeep : TC.dark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${s.messages.length} pesan · ${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}',
                                style: GoogleFonts.poppins(
                                    fontSize: 10.5, color: TC.hint),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 19, color: Color(0xFFC0392B)),
                                onPressed: () {
                                  _deleteSession(s);
                                  Navigator.pop(ctx);
                                },
                              ),
                              onTap: () => _switchSession(s),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _welcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F0E6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.health_and_safety_outlined,
                    size: 24, color: TC.greenDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo! Saya Asisten AI TEDUH',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: TC.dark,
                      ),
                    ),
                    Text(
                      'Pendamping perlindungan kesehatan & udara',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: TC.hint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Saya siap membantu menjawab pertanyaan seputar bahaya kabut asap Karhutla, '
            'perlindungan pernapasan ISPA, pemilihan masker N95, hingga langkah darurat. '
            'Semua respon berbasis data pemantauan langsung dan pedoman kesehatan resmi.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.6,
              color: const Color(0xFF425A4E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contextBanner() {
    final mon = MonitoringState.instance;
    final reading = mon.currentReading;
    final location = mon.locationName;
    final ispu = reading?.ispu ?? 0;
    final ispuText = reading != null ? '$ispu ISPU · ${reading.categoryLabel.toUpperCase()}' : 'DATA MENYINKRONKAN...';
    final pm25Text = reading?.formattedPm25 ?? '--';
    final sourceText = reading?.provenanceText ?? 'Stasiun Pemantauan Resmi';

    final isDanger = ispu > 200;
    final Color bannerBg = isDanger ? _dangerTint : const Color(0xFFE9F4EC);
    final Color bannerBorder = isDanger ? const Color(0xFFF7DDD7) : const Color(0xFFCCE4D4);
    final Color textColor = isDanger ? _dangerDeep : const Color(0xFF1E5B41);
    final IconData icon = isDanger ? Icons.warning_amber_rounded : Icons.location_on_outlined;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bannerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: textColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                ispuText,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'PM2.5 $pm25Text · $sourceText',
            style: GoogleFonts.poppins(fontSize: 11, color: textColor),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              decoration: const BoxDecoration(
                color: _userBubble,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
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
          const SizedBox(height: 4),
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
          const Icon(Icons.auto_awesome_rounded,
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

  Widget _dynamicAnswer(ChatMessage m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aiLabel(m.time),
        const SizedBox(height: 8),
        _AiCard(
          children: [
            Text(
              'Rekomendasi TEDUH AI',
              style: GoogleFonts.poppins(
                fontSize: 17,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: TC.dark,
              ),
            ),
            const SizedBox(height: 12),
            _MarkdownText(content: m.text),
            if (m.citations.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 1, color: TC.divider),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_outlined,
                      size: 14, color: Color(0xFF1F6B4F)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sumber: ${m.citations.join(" · ")}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: TC.hint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        _FeedbackRow(copyText: m.text),
      ],
    );
  }

  Widget _suggestionCard() {
    Widget chip(String text) {
      return Material(
        color: const Color(0xFFE6EFE6),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _sendMessage(text),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: TC.dark,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.north_east_rounded,
                    size: 13, color: TC.greenDeep),
              ],
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
            'PERTANYAAN CEPAT TENTANG KESEHATAN & UDARA',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: TC.greenDeep,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSuggestions.map((s) => chip(s)).toList(),
          ),
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
            padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
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
                Expanded(
                  child: TextField(
                    controller: _input,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    style: GoogleFonts.poppins(fontSize: 12.5, color: TC.dark),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      border: InputBorder.none,
                      hintText: 'Tanyakan perlindungan asap, ISPU, atau pernapasan...',
                      hintStyle: GoogleFonts.poppins(fontSize: 12, color: TC.hint),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _sendMessage(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: _send,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded,
                        size: 21, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI dapat keliru. Disusun berbasis panduan WHO & Kementerian Kesehatan.\n'
            'Untuk kondisi gawat darurat sesak napas berat, segera ke fasilitas medis terdekat.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              height: 1.45,
              color: TC.hint,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkdownText extends StatelessWidget {
  final String content;
  const _MarkdownText({required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trimRight();
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      if (line.startsWith('### ') || line.startsWith('## ') || line.startsWith('# ')) {
        final cleanHeader = line.replaceAll(RegExp(r'^#+\s*'), '');
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            cleanHeader,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: TC.dark,
            ),
          ),
        ));
        continue;
      }

      final isBullet = line.startsWith('* ') || line.startsWith('- ') || line.startsWith('• ');
      final numberMatch = RegExp(r'^(\d+)\.\s+(.*)').firstMatch(line);

      if (isBullet) {
        final textPart = line.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 5.5,
                height: 5.5,
                decoration: const BoxDecoration(
                  color: Color(0xFF1F6B4F),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: _buildRichInline(textPart),
              ),
            ],
          ),
        ));
      } else if (numberMatch != null) {
        final numStr = numberMatch.group(1)!;
        final textPart = numberMatch.group(2)!;
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2, right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EFE5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  numStr,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F6B4F),
                  ),
                ),
              ),
              Expanded(
                child: _buildRichInline(textPart),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildRichInline(line),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichInline(String raw) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(raw)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: raw.substring(lastEnd, match.start),
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            height: 1.6,
            color: const Color(0xFF2E3D35),
          ),
        ));
      }
      final boldText = match.group(1) ?? '';
      spans.add(TextSpan(
        text: boldText,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          height: 1.6,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF133F2E),
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < raw.length) {
      spans.add(TextSpan(
        text: raw.substring(lastEnd),
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          height: 1.6,
          color: const Color(0xFF2E3D35),
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
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
        content: Text('Jawaban disalin ke papan klip'),
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
              child: Icon(Icons.content_copy_rounded, size: 18, color: TC.dark),
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
            'Panduan umum · bukan pengganti dokter',
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
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 14),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
