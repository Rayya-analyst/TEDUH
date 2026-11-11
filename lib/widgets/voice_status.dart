import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/voice_service.dart';
class VoiceStatusBar extends StatelessWidget {
  const VoiceStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final v = VoiceService.instance;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 12 + bottom,
      child: IgnorePointer(
        child: ListenableBuilder(
          listenable: v,
          builder: (context, _) {
            final listening = v.state == VoiceState.listening;
            final speaking = v.state == VoiceState.speaking;
            final bool quietListen = listening && v.transcript.isEmpty;
            final String? text = listening
                ? (v.transcript.isEmpty ? null : '“${v.transcript}”')
                : speaking
                    ? v.response
                    : null;
            if (quietListen) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xCC1F3D2F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_rounded,
                      size: 16, color: Color(0xFF7FD6A8)),
                ),
              );
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: text == null
                  ? const SizedBox.shrink(key: ValueKey('idle'))
                  : Center(
                      key: ValueKey(listening ? 'listen' : 'speak'),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xEB1F3D2F),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              listening
                                  ? Icons.mic_rounded
                                  : Icons.volume_up_rounded,
                              size: 18,
                              color: const Color(0xFF7FD6A8),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                text,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
