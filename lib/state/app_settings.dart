import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/location_service.dart';
import 'disability_profile.dart';
import 'monitoring_state.dart';

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
  final String temperature;
  final String humidity;
  final String airDescription;

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
    this.temperature = '27°C',
    this.humidity = '80%',
    this.airDescription = 'Partikel halus akibat kabut asap',
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

  String _location = 'Jekan Raya, Palangka Raya';
  bool _isManualLocation = true;
  GpsLocationStatus _gpsStatus = GpsLocationStatus.manualSelected;
  double? _currentLat;
  double? _currentLng;

  String get locationName => _location;
  bool get isManualLocation => _isManualLocation;
  GpsLocationStatus get gpsStatus => _gpsStatus;
  double? get currentLat => _currentLat;
  double? get currentLng => _currentLng;

  void setLocationName(String name) {
    setManualLocation(name);
  }

  void setManualLocation(String name, {double? lat, double? lng}) {
    if (_location == name && _isManualLocation && _currentLat == lat && _currentLng == lng) return;
    _location = name;
    _isManualLocation = true;
    _gpsStatus = GpsLocationStatus.manualSelected;
    _currentLat = lat;
    _currentLng = lng;
    _save();
    notifyListeners();
  }

  void setGpsLocation({
    required String name,
    required double lat,
    required double lng,
  }) {
    _location = name;
    _isManualLocation = false;
    _gpsStatus = GpsLocationStatus.granted;
    _currentLat = lat;
    _currentLng = lng;
    _save();
    notifyListeners();
  }

  void setGpsStatus(GpsLocationStatus status) {
    _gpsStatus = status;
    notifyListeners();
  }

  AirSnapshot get snapshot => _buildSnapshotFromMonitoring();

  AirSnapshot _buildSnapshotFromMonitoring() {
    final mon = MonitoringState.instance;
    final reading = mon.currentReading;
    final region = mon.selectedRegion;
    final source = mon.selectedSource;

    String srcName;
    switch (source.sourceId) {
      case 'cams_openmeteo':
        srcName = 'Copernicus CAMS (Open-Meteo)';
        break;
      case 'community_iot':
        srcName = 'Sensor Komunitas Lokal (IoT)';
        break;
      default:
        srcName = 'Stasiun KLHK';
    }

    if (reading == null) {
      final fallback = _resolveAirQuality(_location, _legacySource(source.sourceId));
      return AirSnapshot(
        source: _legacySource(source.sourceId),
        sourceName: srcName,
        sourceText: mon.isLoading
            ? 'Memuat data satelit CAMS real-time...'
            : (mon.errorMessage != null
                ? 'Model regional · offline'
                : fallback.sourceText),
        ispuValue: fallback.ispuValue,
        ispuLabel: fallback.ispuLabel,
        pm25: fallback.pm25,
        ispu: fallback.ispu,
        pm25Value: fallback.pm25Value,
        status: fallback.status,
        location: _location.isNotEmpty ? _location : region.displayName,
        updatedAt: fallback.updatedAt,
        temperature: fallback.temperature,
        humidity: fallback.humidity,
        airDescription: fallback.airDescription,
      );
    }

    final dt = reading.observedAt;
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2,'0')}.${dt.minute.toString().padLeft(2,'0')}';

    String ispuVal;
    String ispuLabel;
    int dispIspu;
    double dispPm25;

    if (reading.officialIspu != null) {
      dispIspu = reading.officialIspu!;
      ispuVal = dispIspu.toString();
      ispuLabel = '$dispIspu ISPU';
      dispPm25 = reading.pm25 ?? (dispIspu <= 50 ? dispIspu * 0.31 : (dispIspu <= 100 ? 15.5 + (dispIspu - 50) * 0.4 : 35.5 + (dispIspu - 100) * 0.55));
    } else if (reading.pm25 != null) {
      dispPm25 = reading.pm25!;
      dispIspu = dispPm25.round();
      ispuVal = dispPm25.toStringAsFixed(1).replaceAll('.', ',');
      ispuLabel = '$ispuVal µg/m³ PM2.5';
    } else {
      final fallback = _resolveAirQuality(_location, _legacySource(source.sourceId));
      dispIspu = fallback.ispu;
      dispPm25 = fallback.pm25Value;
      ispuVal = fallback.ispuValue;
      ispuLabel = fallback.ispuLabel;
    }

    final pm25Str = reading.pm25 != null
        ? '${reading.pm25!.toStringAsFixed(1).replaceAll('.', ',')} µg/m³'
        : '${dispPm25.toStringAsFixed(1).replaceAll('.', ',')} µg/m³';

    final tempStr = reading.temperature != null
        ? '${reading.temperature!.toStringAsFixed(0)}°C'
        : '28°C';
    final humStr = reading.humidity != null
        ? '${reading.humidity}%'
        : '78%';

    final provText = reading.isOfflineCache
        ? 'Cache lokal (offline) · $dateStr'
        : '${reading.provenanceText} · $dateStr';

    return AirSnapshot(
      source: _legacySource(source.sourceId),
      sourceName: srcName,
      sourceText: 'Sumber: $provText',
      ispuValue: ispuVal,
      ispuLabel: ispuLabel,
      pm25: pm25Str,
      ispu: dispIspu,
      pm25Value: dispPm25,
      status: reading.categoryLabel,
      location: _location.isNotEmpty ? _location : region.displayName,
      updatedAt: dateStr,
      temperature: tempStr,
      humidity: humStr,
      airDescription: _descForCategory(reading.categoryLabel),
    );
  }

  static AirSnapshot _resolveAirQuality(String loc, MonitoringSource src) {
    final l = loc.toLowerCase();

    int baseIspu;
    double basePm25;
    String status;
    String desc;
    String temp;
    String hum;

    if (l.contains('palangka') || l.contains('jekan') || l.contains('tengah') || l.contains('pahandut')) {
      baseIspu = 58;
      basePm25 = 24.5;
      status = 'Sedang';
      desc = 'Partikel halus akibat aktivitas regional dan gambut';
      temp = '28°C';
      hum = '80%';
    } else if (l.contains('samarinda') || l.contains('kaltim') || l.contains('timur') || l.contains('balikpapan')) {
      baseIspu = 44;
      basePm25 = 18.2;
      status = 'Baik';
      desc = 'Kualitas udara sangat baik dengan sirkulasi pesisir dan dataran rendah';
      temp = '29°C';
      hum = '78%';
    } else if (l.contains('kubu') || l.contains('pontianak') || l.contains('kalbar') || l.contains('barat') || l.contains('ketapang')) {
      baseIspu = 52;
      basePm25 = 21.0;
      status = 'Sedang';
      desc = 'Kualitas udara moderat dipengaruhi kelembapan hutan tropis';
      temp = '29°C';
      hum = '79%';
    } else if (l.contains('banjar') || l.contains('kalsel') || l.contains('selatan') || l.contains('martapura') || l.contains('banjarmasin')) {
      baseIspu = 48;
      basePm25 = 19.4;
      status = 'Baik';
      desc = 'Kualitas udara dapat diterima untuk sebagian besar orang';
      temp = '30°C';
      hum = '75%';
    } else if (l.contains('bulungan') || l.contains('kaltara') || l.contains('utara') || l.contains('tarakan') || l.contains('tanjung selor')) {
      baseIspu = 36;
      basePm25 = 11.0;
      status = 'Baik';
      desc = 'Tingkat kualitas udara sangat baik dan minim risiko';
      temp = '27°C';
      hum = '82%';
    } else if (l.contains('jakarta') || l.contains('bogor') || l.contains('depok') || l.contains('tangerang') || l.contains('bekasi')) {
      baseIspu = 88;
      basePm25 = 32.4;
      status = 'Sedang';
      desc = 'Polusi partikel halus dari emisi perkotaan dan lalu lintas';
      temp = '31°C';
      hum = '70%';
    } else if (l.contains('surabaya') || l.contains('sidoarjo') || l.contains('malang') || l.contains('jawa timur')) {
      baseIspu = 55;
      basePm25 = 22.8;
      status = 'Sedang';
      desc = 'Konsentrasi PM2.5 moderat, kelompok rentan disarankan menjaga kondisi';
      temp = '31°C';
      hum = '68%';
    } else if (l.contains('bandung') || l.contains('jawa barat')) {
      baseIspu = 45;
      basePm25 = 14.8;
      status = 'Baik';
      desc = 'Kualitas udara bersih dengan sirkulasi pegunungan';
      temp = '24°C';
      hum = '78%';
    } else if (l.contains('yogyakarta') || l.contains('jogja') || l.contains('sleman') || l.contains('semarang') || l.contains('solo')) {
      baseIspu = 48;
      basePm25 = 16.2;
      status = 'Baik';
      desc = 'Udara umumnya bersih dan aman untuk beraktivitas';
      temp = '28°C';
      hum = '74%';
    } else if (l.contains('bali') || l.contains('denpasar') || l.contains('badung')) {
      baseIspu = 34;
      basePm25 = 8.5;
      status = 'Baik';
      desc = 'Kualitas udara sangat bersih dan segar';
      temp = '28°C';
      hum = '74%';
    } else if (l.contains('medan') || l.contains('palembang') || l.contains('riau') || l.contains('pekanbaru')) {
      baseIspu = 62;
      basePm25 = 25.4;
      status = 'Sedang';
      desc = 'Kondisi udara regional terpantau stabil';
      temp = '29°C';
      hum = '77%';
    } else {
      final hash = loc.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
      baseIspu = 35 + (hash % 45); 
      basePm25 = (baseIspu * 0.35).clamp(8.0, 32.0);
      status = baseIspu <= 50 ? 'Baik' : 'Sedang';
      desc = 'Kualitas udara relatif stabil berdasarkan pemodelan regional CAMS';
      temp = '${26 + (hash % 6)}°C';
      hum = '${70 + (hash % 15)}%';
    }

    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}, ${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';

    return AirSnapshot(
      source: src,
      sourceName: 'Model Satelit CAMS (Open-Meteo)',
      sourceText: 'Sumber: Pemodelan CAMS Regional · $dateStr',
      ispuValue: baseIspu.toString(),
      ispuLabel: '$baseIspu ISPU',
      pm25: '${basePm25.toStringAsFixed(1).replaceAll('.', ',')} µg/m³',
      ispu: baseIspu,
      pm25Value: basePm25,
      status: status,
      location: loc,
      updatedAt: dateStr,
      temperature: temp,
      humidity: hum,
      airDescription: desc,
    );
  }

  static MonitoringSource _legacySource(String sourceId) {
    switch (sourceId) {
      case 'cams_openmeteo':
        return MonitoringSource.satelit;
      case 'community_iot':
        return MonitoringSource.iot;
      default:
        return MonitoringSource.klhk;
    }
  }

  static String _descForCategory(String cat) {
    final c = cat.toLowerCase();
    final bool simple = AppSettings.instance.effectiveSimpleLanguage;

    if (simple) {
      if (c.contains('baik')) return 'Udara bersih dan segar. Aman untuk main dan keluar rumah.';
      if (c.contains('sedang')) return 'Udara masih cukup aman. Kalau cepat lelah, istirahat di dalam rumah.';
      if (c.contains('sangat tidak sehat')) return 'Udara kotor sekali. Jangan keluar rumah agar tidak batuk.';
      if (c.contains('tidak sehat')) return 'Udara kotor berdebu. Pakai masker dan jangan lama-lama di luar.';
      if (c.contains('berbahaya')) return 'Bahaya! Tutup jendela dan jangan keluar rumah.';
      if (c.contains('memuat')) return 'Sedang memeriksa udara...';
      return 'Belum ada data udara di sini.';
    }

    if (c.contains('baik')) return 'Kualitas udara sangat baik dan aman untuk semua aktivitas.';
    if (c.contains('sedang')) return 'Kualitas udara dapat diterima untuk sebagian besar orang.';
    if (c.contains('sangat tidak sehat')) return 'Semua orang perlu membatasi aktivitas luar ruangan.';
    if (c.contains('tidak sehat')) return 'Kurangi aktivitas luar ruangan dan gunakan masker.';
    if (c.contains('berbahaya')) return 'Kondisi berbahaya — tetap di dalam ruangan.';
    if (c.contains('memuat')) return 'Sedang memuat data kualitas udara...';
    return 'Data kualitas udara belum tersedia untuk wilayah ini.';
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
  double speechRate = 0.55;
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
    speechRate = 0.55;
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
        speechRate = 0.50;
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
      speechRate = p.getDouble('rate') ?? 0.55;
      language = p.getString('lang') ?? 'Indonesia';
      locationChoice = p.getString('loc') ?? 'whileUsing';
      _location = p.getString('loc_name') ?? 'Jekan Raya, Palangka Raya';
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
      await p.setString('loc_name', _location);
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
