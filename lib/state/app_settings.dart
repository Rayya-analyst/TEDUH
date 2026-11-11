import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'disability_profile.dart';

enum MonitoringSource { klhk, satelit, iot }

class AirSnapshot {
  final MonitoringSource source;
  final String sourceName;
  final String sourceText;
  final String ispuValue;
  final String ispuLabel;
  final String pm25;
  final int ispu;
  final double pm25Value;
  final String status;
  final String location;
  final String updatedAt;

  const AirSnapshot({
    required this.source,
    required this.sourceName,
    required this.sourceText,
    required this.ispuValue,
    required this.ispuLabel,
    required this.pm25,
    required this.ispu,
    required this.pm25Value,
    required this.status,
    required this.location,
    required this.updatedAt,
  });
}

class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  MonitoringSource _source = MonitoringSource.klhk;
  MonitoringSource get source => _source;

  void setSource(MonitoringSource s) {
    if (_source == s) return;
    _source = s;
    _save();
    notifyListeners();
  }

  static const String _location = 'Jekan Raya, Palangka Raya';
  static const String _updated = '3 Nov 2026, 12.00';

  AirSnapshot get snapshot {
    switch (_source) {
      case MonitoringSource.klhk:
        return const AirSnapshot(
          source: MonitoringSource.klhk,
          sourceName: 'Stasiun Resmi Pemerintah (KLHK)',
          sourceText: 'Sumber: BMKG dan KLH • 3 November 2026',
          ispuValue: '275,2',
          ispuLabel: '462 ISPU',
          pm25: '275,2 µg/m³',
          ispu: 462,
          pm25Value: 275.2,
          status: 'Berbahaya',
          location: _location,
          updatedAt: _updated,
        );
      case MonitoringSource.satelit:
        return const AirSnapshot(
          source: MonitoringSource.satelit,
          sourceName: 'Satelit Sentinel & Copernicus',
          sourceText: 'Sumber: Satelit Sentinel & Copernicus • 3 November 2026',
          ispuValue: '268,9',
          ispuLabel: '451 ISPU',
          pm25: '268,9 µg/m³',
          ispu: 451,
          pm25Value: 268.9,
          status: 'Berbahaya',
          location: _location,
          updatedAt: _updated,
        );
      case MonitoringSource.iot:
        return const AirSnapshot(
          source: MonitoringSource.iot,
          sourceName: 'Sensor Komunitas Lokal (IoT)',
          sourceText: 'Sumber: Sensor Komunitas Lokal (IoT) • 3 November 2026',
          ispuValue: '281,4',
          ispuLabel: '470 ISPU',
          pm25: '281,4 µg/m³',
          ispu: 470,
          pm25Value: 281.4,
          status: 'Berbahaya',
          location: _location,
          updatedAt: _updated,
        );
    }
  }

  static const List<String> sizeLabels = [
    'Kecil',
    'Agak kecil',
    'Sedang',
    'Besar',
    'Sangat besar',
  ];
  static const List<int> sizePercents = [80, 90, 100, 115, 130];

  int textSizeIdx = 2;
  bool highContrast = false;
  bool darkMode = false;
  bool reduceMotion = false;
  bool screenReader = false;
  bool disabilityMode = false;
  DisabilityType disabilityType = DisabilityType.none;
  bool simpleLanguage = false;
  bool voiceNavigation = false;
  bool autoRead = false;
  bool sirenEnabled = true;
  double speechRate = 0.5;
  String language = 'Indonesia';
  String locationChoice = 'whileUsing';
  final Set<String> seenTours = <String>{};

  bool tourSeen(String id) => seenTours.contains(id);
  void markTourSeen(String id) {
    if (seenTours.add(id)) _save();
  }

  DisabilityType get dType {
    if (!disabilityMode) return DisabilityType.none;
    return disabilityType == DisabilityType.none
        ? DisabilityType.multiple
        : disabilityType;
  }

  double get textScale {
    final base = sizePercents[textSizeIdx] / 100.0;
    final minScale = switch (dType) {
      DisabilityType.lowVision => 1.30,
      DisabilityType.motor ||
      DisabilityType.cognitive ||
      DisabilityType.multiple =>
        1.15,
      _ => 0.0,
    };
    return base < minScale ? minScale : base;
  }

  bool get boldText =>
      highContrast ||
      dType == DisabilityType.lowVision ||
      dType == DisabilityType.multiple;
  bool get effectiveSimpleLanguage => simpleLanguage || dType.simpleLanguage;

  bool get effectiveAutoRead => autoRead || screenReader || dType.usesSpeech;

  bool get effectiveVoiceNav => voiceNavigation || dType.usesMic;

  bool get voiceFlows => disabilityMode && dType.usesMic;

  bool get visualAlerts => disabilityMode && dType.needsVisualAlerts;

  void applyDisabilityType(DisabilityType type) {
    disabilityMode = type != DisabilityType.none;
    disabilityType = type;
    voiceNavigation = false;
    autoRead = false;
    screenReader = false;
    simpleLanguage = false;
    highContrast = false;
    reduceMotion = false;
    speechRate = 0.5;
    textSizeIdx = 2;
    switch (type) {
      case DisabilityType.none:
        break;
      case DisabilityType.blind:
        voiceNavigation = true;
        autoRead = true;
        screenReader = true;
        simpleLanguage = true;
      case DisabilityType.lowVision:
        voiceNavigation = true;
        autoRead = true;
        highContrast = true;
        textSizeIdx = 4;
      case DisabilityType.deaf:
        sirenEnabled = true;
      case DisabilityType.speech:
        break;
      case DisabilityType.motor:
        voiceNavigation = true;
        textSizeIdx = 3;
      case DisabilityType.cognitive:
        autoRead = true;
        simpleLanguage = true;
        reduceMotion = true;
        speechRate = 0.4;
        textSizeIdx = 3;
      case DisabilityType.multiple:
        voiceNavigation = true;
        autoRead = true;
        simpleLanguage = true;
        highContrast = true;
        textSizeIdx = 3;
    }
    _save();
    notifyListeners();
  }

  AnimationBehavior get animBehavior =>
      reduceMotion ? AnimationBehavior.normal : AnimationBehavior.preserve;

  void update(VoidCallback change) {
    change();
    _save();
    notifyListeners();
  }

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _source = MonitoringSource
          .values[(p.getInt('src') ?? 0).clamp(0, MonitoringSource.values.length - 1).toInt()];
      textSizeIdx = (p.getInt('textIdx') ?? 2).clamp(0, sizeLabels.length - 1).toInt();
      highContrast = p.getBool('contrast') ?? false;
      darkMode = p.getBool('dark') ?? false;
      reduceMotion = p.getBool('reduce') ?? false;
      screenReader = p.getBool('reader') ?? false;
      disabilityMode = p.getBool('disability') ?? false;
      disabilityType = DisabilityType.fromKey(p.getString('dtype'));
      simpleLanguage = p.getBool('simple') ?? false;
      voiceNavigation = p.getBool('voiceNav') ?? false;
      autoRead = p.getBool('autoRead') ?? false;
      sirenEnabled = p.getBool('siren') ?? true;
      speechRate = p.getDouble('rate') ?? 0.5;
      language = p.getString('lang') ?? 'Indonesia';
      locationChoice = p.getString('loc') ?? 'whileUsing';
      seenTours
        ..clear()
        ..addAll(p.getStringList('tours') ?? const <String>[]);
    } catch (_) {
    }
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt('src', _source.index);
      await p.setInt('textIdx', textSizeIdx);
      await p.setBool('contrast', highContrast);
      await p.setBool('dark', darkMode);
      await p.setBool('reduce', reduceMotion);
      await p.setBool('reader', screenReader);
      await p.setBool('disability', disabilityMode);
      await p.setString('dtype', disabilityType.key);
      await p.setBool('simple', simpleLanguage);
      await p.setBool('voiceNav', voiceNavigation);
      await p.setBool('autoRead', autoRead);
      await p.setBool('siren', sirenEnabled);
      await p.setDouble('rate', speechRate);
      await p.setString('lang', language);
      await p.setString('loc', locationChoice);
      await p.setStringList('tours', seenTours.toList());
    } catch (_) {}
  }
}

extension TeduhMotion on AnimationController {
  void repeatUnlessReduced({bool reverse = false}) {
    if (AppSettings.instance.reduceMotion) return;
    repeat(reverse: reverse);
  }
}
