import 'package:flutter/material.dart';

import '../state/app_settings.dart';
import '../services/voice_service.dart';
import 'voice_status.dart';
class AccessibilityShell extends StatelessWidget {
  final Widget? child;
  const AccessibilityShell({super.key, this.child});

  static const ColorFilter _contrast = ColorFilter.matrix(<double>[
    1.4, 0, 0, 0, -51.2,
    0, 1.4, 0, 0, -51.2,
    0, 0, 1.4, 0, -51.2,
    0, 0, 0, 1, 0,
  ]);

  static const ColorFilter _dark = ColorFilter.matrix(<double>[
    0.574, -1.430, -0.144, 0, 255,
    -0.426, -0.430, -0.144, 0, 255,
    -0.426, -1.430, 0.856, 0, 255,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final s = AppSettings.instance;
        final mq = MediaQuery.of(context);
        final double z = s.textScale;

        Widget w = Stack(
          children: [
            Positioned.fill(
              child: (s.effectiveVoiceNav || s.effectiveAutoRead)
                  ? Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: (_) {
                        final v = VoiceService.instance;
                        if (v.state == VoiceState.speaking) v.stopSpeaking();
                      },
                      child: child ?? const SizedBox.shrink(),
                    )
                  : (child ?? const SizedBox.shrink()),
            ),
            if (s.effectiveVoiceNav) const VoiceStatusBar(),
          ],
        );

        final MediaQueryData base = mq.copyWith(
          boldText: s.boldText || mq.boldText,
          disableAnimations: s.reduceMotion || mq.disableAnimations,
          highContrast: s.highContrast || mq.highContrast,
        );

        if ((z - 1.0).abs() > 0.001) {
          final inner = w;
          w = LayoutBuilder(
            builder: (context, c) {
              final double lw = c.maxWidth / z;
              final double lh = c.maxHeight / z;
              return ClipRect(
                child: Transform.scale(
                  scale: z,
                  alignment: Alignment.topLeft,
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: lw,
                    maxWidth: lw,
                    minHeight: lh,
                    maxHeight: lh,
                    child: MediaQuery(
                      data: base.copyWith(
                        size: Size(lw, lh),
                        padding: base.padding / z,
                        viewPadding: base.viewPadding / z,
                        viewInsets: base.viewInsets / z,
                        systemGestureInsets: base.systemGestureInsets / z,
                      ),
                      child: inner,
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          w = MediaQuery(data: base, child: w);
        }

        if (s.highContrast) {
          w = ColorFiltered(colorFilter: _contrast, child: w);
        }
        if (s.darkMode) {
          w = ColorFiltered(colorFilter: _dark, child: w);
        }
        return w;
      },
    );
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}
