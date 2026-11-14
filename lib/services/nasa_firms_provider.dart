import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FirmsHotspot {
  final double latitude;
  final double longitude;
  final double brightness; 
  final String satellite;  
  final String instrument; 
  final DateTime acquisitionTime;
  final String confidence;
  final double? frp;       

  const FirmsHotspot({
    required this.latitude,
    required this.longitude,
    required this.brightness,
    required this.satellite,
    required this.instrument,
    required this.acquisitionTime,
    required this.confidence,
    this.frp,
  });

  bool get isHighConfidence =>
      confidence.toLowerCase() == 'high' ||
      confidence.toLowerCase() == 'h' ||
      (double.tryParse(confidence) != null && double.parse(confidence) >= 80);

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'brightness': brightness,
        'satellite': satellite,
        'instrument': instrument,
        'time': acquisitionTime.toIso8601String(),
        'confidence': confidence,
        'frp': frp,
      };

  factory FirmsHotspot.fromJson(Map<String, dynamic> json) => FirmsHotspot(
        latitude: (json['lat'] as num).toDouble(),
        longitude: (json['lng'] as num).toDouble(),
        brightness: (json['brightness'] as num?)?.toDouble() ?? 300.0,
        satellite: json['satellite'] as String? ?? 'VIIRS',
        instrument: json['instrument'] as String? ?? 'VIIRS',
        acquisitionTime: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
        confidence: json['confidence'] as String? ?? 'nominal',
        frp: (json['frp'] as num?)?.toDouble(),
      );
}

class NasaFirmsHotspotProvider {
  static const String attribution = 'NASA FIRMS (Fire Information for Resource Management System)';

  static const String scientificDisclaimer =
      'Hotspot adalah deteksi anomali radiasi termal permukaan oleh sensor inframerah satelit MODIS/VIIRS. '
      'Hotspot TIDAK merepresentasikan konsentrasi PM2.5, bukan konsentrasi polutan, dan bukan nilai ISPU. '
      'Sebaran asap aktual dipengaruhi oleh bahan bakar gambut, kelembapan, dan angin horizontal.';

  static const String defaultMapKey = '';

  DateTime? _lastFetchTime;
  String? _lastError;
  int _lastHotspotCount = 0;

  DateTime? get lastFetchTime => _lastFetchTime;
  String? get lastError => _lastError;
  int get lastHotspotCount => _lastHotspotCount;
  bool get isConfigured =>
      const String.fromEnvironment('NASA_FIRMS_MAP_KEY', defaultValue: defaultMapKey).isNotEmpty;

  static Future<void> saveMapKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nasa_firms_map_key', key.trim());
  }

  static Future<String> getEffectiveMapKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('nasa_firms_map_key') ?? '';
      if (saved.isNotEmpty) return saved.trim();
    } catch (_) {}
    return const String.fromEnvironment('NASA_FIRMS_MAP_KEY', defaultValue: defaultMapKey);
  }

  Future<List<FirmsHotspot>> fetchHotspotsForIndonesia({
    String? mapKey,
  }) async {
    String effectiveKey = mapKey ?? '';
    if (effectiveKey.isEmpty) {
      effectiveKey = await getEffectiveMapKey();
    }

    if (effectiveKey.isEmpty) {
      _lastError =
          'NASA FIRMS MAP_KEY belum dikonfigurasi. Hotspot satelit memerlukan MAP_KEY gratis yang didaftarkan melalui https://firms.modaps.eosdis.nasa.gov/api/map_key/';
      _lastHotspotCount = 0;
      debugPrint('[NasaFirmsHotspotProvider] $lastError');
      return [];
    }

    try {
      final url = Uri.parse(
        'https://firms.modaps.eosdis.nasa.gov/api/country/csv/$effectiveKey/VIIRS_SNPP_NRT/IDN/1',
      );
      final response =
          await http.get(url).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final hotspots = _parseCsvHotspots(response.body);
        _lastFetchTime = DateTime.now();
        _lastError = null;
        _lastHotspotCount = hotspots.length;
        return hotspots;
      } else {
        _lastError =
            'Server NASA FIRMS merespons status code HTTP ${response.statusCode}: ${response.reasonPhrase}';
        _lastHotspotCount = 0;
        debugPrint('[NasaFirmsHotspotProvider] Error HTTP: $_lastError');
        return [];
      }
    } catch (e) {
      _lastError = 'Koneksi ke NASA FIRMS gagal: $e';
      _lastHotspotCount = 0;
      debugPrint('[NasaFirmsHotspotProvider] Exception: $e');
      return [];
    }
  }

  List<FirmsHotspot> _parseCsvHotspots(String csv) {
    final lines = csv.split('\n');
    if (lines.length <= 1) return [];

    final results = <FirmsHotspot>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final parts = line.split(',');
      if (parts.length >= 8) {
        final lat = double.tryParse(parts[1]);
        final lon = double.tryParse(parts[2]);
        final bright = double.tryParse(parts[3]) ?? 300.0;
        final dateStr = parts[5];
        final timeStr = parts[6];
        final sat = parts[7];
        final conf = parts.length > 8 ? parts[8] : 'nominal';
        final frpVal = parts.length > 10 ? double.tryParse(parts[10]) : null;

        if (lat != null && lon != null) {
          DateTime acq = DateTime.now();
          try {
            acq = DateTime.parse(
                '${dateStr}T${timeStr.padLeft(4, '0').substring(0, 2)}:${timeStr.padLeft(4, '0').substring(2, 4)}:00Z');
          } catch (_) {}

          results.add(FirmsHotspot(
            latitude: lat,
            longitude: lon,
            brightness: bright,
            satellite: sat,
            instrument: 'VIIRS',
            acquisitionTime: acq,
            confidence: conf,
            frp: frpVal,
          ));
        }
      }
    }
    return results;
  }
}
