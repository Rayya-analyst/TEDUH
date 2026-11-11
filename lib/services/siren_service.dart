import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../state/app_settings.dart';

class SirenService {
  SirenService._();
  static final SirenService instance = SirenService._();

  AudioPlayer? _player;
  Timer? _haptic;
  bool _playing = false;
  bool get isPlaying => _playing;

  static Uint8List? _wav;

  static Uint8List _buildWav() {
    const int rate = 22050;
    const double seconds = 3.0;
    final int n = (rate * seconds).round();
    final data = ByteData(44 + n * 2);

    void str(int off, String s) {
      for (int i = 0; i < s.length; i++) {
        data.setUint8(off + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    data.setUint32(4, 36 + n * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little); 
    data.setUint16(22, 1, Endian.little); 
    data.setUint32(24, rate, Endian.little);
    data.setUint32(28, rate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    str(36, 'data');
    data.setUint32(40, n * 2, Endian.little);

    double phase = 0;
    for (int i = 0; i < n; i++) {
      final double t = i / rate;
      final double tri = 1 - (2 * (t / seconds) - 1).abs();
      final double freq = 600 + 600 * tri;
      phase += 2 * math.pi * freq / rate;
      final double v = 0.8 * math.sin(phase) + 0.2 * math.sin(2 * phase);
      data.setInt16(44 + i * 2, (v * 0.85 * 32767).round(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  Future<void> start() async {
    if (_playing) return;
    if (!AppSettings.instance.sirenEnabled) {
      _startHaptic();
      _playing = true;
      return;
    }
    _playing = true;
    _startHaptic();
    try {
      _wav ??= _buildWav();
      final p = _player ??= AudioPlayer();
      await p.setReleaseMode(ReleaseMode.release);
      await p.setVolume(1.0);
      await p.play(BytesSource(_wav!));
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void _startHaptic() {
    _haptic?.cancel();
    HapticFeedback.heavyImpact();
    _haptic = Timer.periodic(const Duration(milliseconds: 900), (_) {
      HapticFeedback.heavyImpact();
    });
  }

  Future<void> stop() async {
    _playing = false;
    _haptic?.cancel();
    _haptic = null;
    try {
      await _player?.stop();
    } catch (_) {}
  }

  Future<void> burst() async {
    await start();
    await Future<void>.delayed(const Duration(milliseconds: 3000));
    await stop();
  }

  void startVibrate() {
    _startHaptic();
  }

  void stopVibrate() {
    _haptic?.cancel();
    _haptic = null;
  }

  Future<void> test() async {
    await start();
    await Future<void>.delayed(const Duration(seconds: 3));
    await stop();
  }
}
