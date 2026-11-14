import 'dart:async';
import 'dart:math' as math;
import '../services/voice_service.dart';
import '../state/app_settings.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _CC {
  static const green = Color(0xFF0F7B4F);
  static const dark = Color(0xFF1F3D2F);
  static const hint = Color(0xFF6F8277);
  static const chip = Color(0xFFE8F3EB);
  static const dotIdle = Color(0xFFD5E3D9);
  static const scrim = Color(0xFF0B1F16);
}

class CoachStep {
  final GlobalKey? target;
  final String title;
  final String body;
  final double padding;
  final double radius;
  final double scrollAlignment;

  const CoachStep({
    this.target,
    required this.title,
    required this.body,
    this.padding = 8,
    this.radius = 20,
    this.scrollAlignment = 0.25,
  });
}

class CoachHandle {
  CoachHandle._(this._entry, this._onEnd);

  final OverlayEntry _entry;
  final void Function(bool completed)? _onEnd;
  bool _active = true;
  final Completer<bool> _done = Completer<bool>();

  bool get isActive => _active;

  Future<bool> get finished => _done.future;

  void _finish(bool completed, {bool notify = true}) {
    if (!_active) return;
    _active = false;
    _entry.remove();
    if (notify) _onEnd?.call(completed);
    if (!_done.isCompleted) _done.complete(completed);
  }

  void dismiss({bool notify = true}) => _finish(false, notify: notify);
}

class CoachMarks {
  static CoachHandle show(
    BuildContext context, {
    required List<CoachStep> steps,
    void Function(bool completed)? onEnd,
  }) {
    assert(steps.isNotEmpty);
    final overlay = Overlay.of(context, rootOverlay: true);
    late final CoachHandle handle;
    final entry = OverlayEntry(
      builder: (_) => _CoachOverlay(
        steps: steps,
        root: context,
        onClose: (completed) => handle._finish(completed),
      ),
    );
    handle = CoachHandle._(entry, onEnd);
    overlay.insert(entry);
    return handle;
  }
}

class _CoachOverlay extends StatefulWidget {
  final List<CoachStep> steps;
  final BuildContext root;
  final void Function(bool completed) onClose;

  const _CoachOverlay(
      {required this.steps, required this.root, required this.onClose});

  @override
  State<_CoachOverlay> createState() => _CoachOverlayState();
}

class _CoachOverlayState extends State<_CoachOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _move; 
  late final AnimationController _pulse; 
  late final AnimationController _fade; 

  VoiceHold? _micHold;
  List<BuildContext?> _auto = const [];
  bool _autoDone = false;
  bool _noSpot = false;
  int _i = 0;
  Rect _from = Rect.zero;
  Rect _to = Rect.zero;
  bool _tipVisible = false;
  bool _busy = false;
  bool _closing = false;

  int get _n => widget.steps.length;
  bool get _last => _i == _n - 1;

  @override
  void initState() {
    super.initState();
    _micHold = VoiceService.instance.hold();
    _move = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      animationBehavior: AppSettings.instance.animBehavior,
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
      animationBehavior: AppSettings.instance.animBehavior,
    )..repeatUnlessReduced();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      animationBehavior: AppSettings.instance.animBehavior,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _goTo(0, first: true));
  }

  @override
  void dispose() {
    _micHold?.release();
    _move.dispose();
    _pulse.dispose();
    _fade.dispose();
    super.dispose();
  }

  BuildContext? _ctxOf(int i) {
    final c = widget.steps[i].target?.currentContext;
    if (c != null) return c;
    if (i < _auto.length) {
      final a = _auto[i];
      if (a != null && a.mounted) return a;
    }
    return null;
  }

  Rect? _rectOf(BuildContext? ctx) {
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    final me = context.findRenderObject();
    if (me is! RenderBox || !me.attached) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final tl = me.globalToLocal(box.localToGlobal(Offset.zero));
    final br = me.globalToLocal(
        box.localToGlobal(box.size.bottomRight(Offset.zero)));
    return Rect.fromPoints(tl, br);
  }

  Future<void> _goTo(int index, {bool first = false}) async {
    if (_busy || _closing) return;
    _busy = true;

    setState(() {
      _i = index;
      _tipVisible = false;
    });

    final step = widget.steps[index];

    if (!_autoDone) {
      _autoDone = true;
      if (widget.root.mounted) {
        _auto = AutoTour.resolve(widget.root, widget.steps);
      }
    }
    final ctx = _ctxOf(index);
    if (ctx != null && ctx.mounted) {
      await Scrollable.ensureVisible(
        ctx,
        alignment: step.scrollAlignment,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    if (ctx == null && step.target == null) {
      final size = (context.findRenderObject() as RenderBox?)?.size ??
          MediaQuery.of(context).size;
      setState(() {
        _noSpot = true;
        _from = Rect.fromCenter(center: size.center(Offset.zero), width: 0, height: 0);
        _to = _from;
      });
      await _move.forward(from: 0);
      if (!mounted) return;
      setState(() => _tipVisible = true);
      _busy = false;
      _voiceStep(index, 0);
      return;
    }

    final r = _rectOf(_ctxOf(index));
    if (r == null) {
      _busy = false;
      if (index < _n - 1) {
        _goTo(index + 1, first: first);
      } else {
        _close(true);
      }
      return;
    }

    final target = r.inflate(step.padding);
    setState(() {
      _noSpot = false;
      _from = first || _to == Rect.zero
          ? Rect.fromCenter(center: target.center, width: 0, height: 0)
          : _to;
      _to = target;
    });

    await _move.forward(from: 0);
    if (!mounted) return;
    setState(() => _tipVisible = true);
    _busy = false;
    _voiceStep(index, 0);
  }

  Future<void> _voiceStep(int index, int silent) async {
    final a = AppSettings.instance;
    final speaks = a.effectiveAutoRead;
    final listens = a.effectiveVoiceNav;
    if (!speaks && !listens) return;
    final step = widget.steps[index];
    final v = VoiceService.instance;
    final last = index == _n - 1;
    bool stale() => !mounted || _closing || _i != index;

    if (speaks && silent == 0) {
      final cmd = listens
          ? ' Katakan ${last ? 'selesai' : 'lanjut'}, kembali, atau lewati.'
          : '';
      await v.speak('${step.title}. ${step.body} '
          'Langkah ${index + 1} dari $_n.$cmd');
      if (stale()) return;
    }
    if (!listens) return;

    final heard = (await v.listenOnce(listenFor: const Duration(seconds: 10)))
        .toLowerCase();
    if (stale()) return;

    final words = heard.split(RegExp(r'[^a-z]+'));
    bool has(List<String> w) => w.any(words.contains);
    if (has(['lewati', 'skip', 'tutup', 'berhenti'])) {
      _close(false);
    } else if (has(['kembali', 'sebelum', 'sebelumnya', 'mundur'])) {
      _back();
    } else if (has(['ulang', 'ulangi', 'lagi'])) {
      _voiceStep(index, 0);
    } else if (has([
      'lanjut', 'lanjutkan', 'selesai', 'berikut', 'berikutnya',
      'selanjutnya', 'next', 'oke', 'ok', 'ya', 'iya', 'siap',
    ])) {
      _next();
    } else if (silent < 4) {
      _voiceStep(index, silent + 1);
    }
  }

  void _next() {
    if (_busy) return;
    if (_last) {
      _close(true);
    } else {
      _goTo(_i + 1);
    }
  }

  void _back() {
    if (_busy || _i == 0) return;
    _goTo(_i - 1);
  }

  Future<void> _close(bool completed) async {
    if (_closing) return;
    _closing = true;
    VoiceService.instance.stopSpeaking();
    setState(() => _tipVisible = false);
    await _fade.reverse();
    if (!mounted) return;
    widget.onClose(completed);
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.of(context).padding;

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, c) {
          return AnimatedBuilder(
            animation: Listenable.merge([_move, _pulse, _fade]),
            builder: (context, _) {
              final t = Curves.easeInOutCubic.transform(_move.value);
              final rect = Rect.lerp(_from, _to, t) ?? _to;
              final radius = widget.steps[_i].radius;

              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: CustomPaint(
                        painter: _SpotPainter(
                          rect: rect,
                          radius: radius,
                          fade: _fade.value,
                          pulse: _tipVisible ? _pulse.value : 0,
                        ),
                      ),
                    ),
                  ),
                  if (_to != Rect.zero) _tooltip(c, safe),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _tooltip(BoxConstraints c, EdgeInsets safe) {
    final step = widget.steps[_i];
    final target = _to;

    if (_noSpot) {
      return Positioned.fill(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, safe.top + 12, 20, safe.bottom + 12),
          child: Center(
            child: SingleChildScrollView(
              child: IgnorePointer(
                ignoring: !_tipVisible,
                child: AnimatedOpacity(
                  opacity: _tipVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 260),
                  child: _cardBody(step, false, 0),
                ),
              ),
            ),
          ),
        ),
      );
    }

    const side = 20.0;
    const gap = 16.0;
    const edge = 10.0;
    const minCard = 200.0;
    final cardW = c.maxWidth - side * 2;

    final topLimit = safe.top + edge;
    final bottomLimit = c.maxHeight - safe.bottom - edge;
    final spaceBelow = bottomLimit - (target.bottom + gap);
    final spaceAbove = (target.top - gap) - topLimit;

    Widget animated(Widget card, bool below) => IgnorePointer(
          ignoring: !_tipVisible,
          child: AnimatedOpacity(
            opacity: _tipVisible ? 1 : 0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset:
                  _tipVisible ? Offset.zero : Offset(0, below ? 0.06 : -0.06),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: card,
            ),
          ),
        );

    if (math.max(spaceBelow, spaceAbove) < minCard) {
      final atTop = target.center.dy > c.maxHeight / 2;
      final double maxH = math.max(120.0, bottomLimit - topLimit);
      return Positioned(
        left: side,
        right: side,
        top: atTop ? topLimit : null,
        bottom: atTop ? null : c.maxHeight - bottomLimit,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH * 0.62),
          child: animated(_cardBody(step, false, 0, arrow: false), false),
        ),
      );
    }

    final below = spaceBelow >= spaceAbove;
    final avail = below ? spaceBelow : spaceAbove;
    final arrowX = (target.center.dx - side).clamp(28.0, cardW - 28.0);

    return Positioned(
      left: side,
      right: side,
      top: below ? target.bottom + gap : null,
      bottom: below ? null : c.maxHeight - target.top + gap,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: avail),
        child: animated(_cardBody(step, below, arrowX), below),
      ),
    );
  }

  Widget _cardBody(CoachStep step, bool below, double arrowX,
      {bool arrow = true}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _CC.chip,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Langkah ${_i + 1} dari $_n',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _CC.green,
                      ),
                    ),
                  ),
                  const Spacer(),
                  for (int k = 0; k < _n; k++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 5),
                      width: k == _i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: k == _i ? _CC.green : _CC.dotIdle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                step.title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _CC.dark,
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    step.body,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      height: 1.55,
                      color: _CC.hint,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (!_last)
                    TextButton(
                      onPressed: () => _close(false),
                      style: TextButton.styleFrom(
                        foregroundColor: _CC.hint,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Lewati',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (_i > 0) ...[
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      style: IconButton.styleFrom(
                        foregroundColor: _CC.green,
                        side: const BorderSide(color: Color(0xFFCFE3D6)),
                        minimumSize: const Size(38, 38),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: _CC.green,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 11),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _last ? 'Selesai' : 'Lanjut',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _last
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!_noSpot && arrow)
        Positioned(
          top: below ? -6 : null,
          bottom: below ? null : -6,
          left: arrowX - 7,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotPainter extends CustomPainter {
  final Rect rect;
  final double radius;
  final double fade;
  final double pulse;

  _SpotPainter({
    required this.rect,
    required this.radius,
    required this.fade,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;

    canvas.saveLayer(full, Paint());
    canvas.drawRect(
      full,
      Paint()..color = _CC.scrim.withValues(alpha: 0.78 * fade),
    );
    if (rect.width > 0 && rect.height > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()..blendMode = BlendMode.clear,
      );
    }
    canvas.restore();

    if (rect.width > 0 && rect.height > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withValues(alpha: 0.85 * fade),
      );
      
      if (pulse > 0) {
        final grow = pulse * 12;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.inflate(2 + grow),
            Radius.circular(radius + grow),
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFF7FD6A8)
                .withValues(alpha: (1 - pulse) * 0.5 * fade),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpotPainter old) => true;
}

class AutoTour {
  AutoTour._();

  static const Set<String> _stop = {
    'yang', 'dengan', 'untuk', 'kamu', 'pada', 'akan', 'atau', 'dari', 'agar',
    'bisa', 'lihat', 'ketuk', 'halaman', 'bagian', 'setiap', 'semua', 'dalam',
    'sini', 'saat', 'juga', 'lebih', 'tentang', 'sesuai', 'langsung',
  };

  static Set<String> _words(String s) => RegExp(r'[a-z0-9]+')
      .allMatches(s.toLowerCase())
      .map((m) => m.group(0)!)
      .where((w) => w.length > 3 && !_stop.contains(w))
      .toSet();

  static bool _substantial(Element e) {
    final ro = e.renderObject;
    return ro is RenderBox && ro.attached && ro.hasSize && ro.size.height >= 28;
  }

  static double _height(Element e) {
    final ro = e.renderObject;
    return ro is RenderBox && ro.hasSize ? ro.size.height : 0;
  }

  static List<Element> _sections(BuildContext root) {
    Element? scroll;
    void findScroll(Element e) {
      if (scroll != null) return;
      final w = e.widget;
      final vertical = (w is SingleChildScrollView &&
              w.scrollDirection == Axis.vertical) ||
          (w is ListView && w.scrollDirection == Axis.vertical) ||
          (w is CustomScrollView && w.scrollDirection == Axis.vertical);
      if (vertical) {
        scroll = e;
        return;
      }
      e.visitChildren(findScroll);
    }

    (root as Element).visitChildren(findScroll);
    final start = scroll;
    if (start == null) return const [];

    final cands = <List<Element>>[];
    final heights = <double>[];
    final queue = <Element>[start];
    int guard = 0;
    while (queue.isNotEmpty && guard++ < 1500) {
      final e = queue.removeAt(0);
      final w = e.widget;
      if (w is Flex && w.direction == Axis.vertical) {
        final kids = <Element>[];
        e.visitChildren(kids.add);
        final good = kids.where(_substantial).toList();
        if (good.length >= 3) {
          cands.add(good);
          heights.add(_height(e));
        }
      }
      e.visitChildren(queue.add);
    }
    if (cands.isEmpty) return const [];
    final maxH = heights.reduce(math.max);
    List<Element>? best;
    for (int i = 0; i < cands.length; i++) {
      if (heights[i] < maxH * 0.7) continue;
      if (best == null || cands[i].length > best.length) best = cands[i];
    }
    return best ?? const [];
  }

  static String _textOf(Element root) {
    final b = StringBuffer();
    void visit(Element e) {
      final w = e.widget;
      if (w is Text) {
        b.write(' ${w.data ?? w.textSpan?.toPlainText() ?? ''}');
      } else if (w is RichText) {
        b.write(' ${w.text.toPlainText()}');
      }
      e.visitChildren(visit);
    }

    visit(root);
    return b.toString();
  }

  static List<BuildContext?> resolve(BuildContext root, List<CoachStep> steps) {
    final out = List<BuildContext?>.filled(steps.length, null);
    if (steps.every((s) => s.target != null)) return out;
    final secs = _sections(root);
    if (secs.isEmpty) return out;
    final texts = secs.map((e) => _words(_textOf(e))).toList();
    int prev = -1;
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].target != null) continue;
      final sw = _words('${steps[i].title} ${steps[i].body}');
      int best = -1;
      int bestScore = 0;
      for (int k = math.max(prev, 0); k < secs.length; k++) {
        final score = texts[k].intersection(sw).length;
        if (score > bestScore) {
          bestScore = score;
          best = k;
        }
      }
      if (best < 0) best = math.min(prev + 1, secs.length - 1);
      out[i] = secs[best];
      prev = best;
    }
    return out;
  }
}
