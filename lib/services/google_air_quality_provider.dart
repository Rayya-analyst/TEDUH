import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/air_quality_models.dart';
import 'air_quality_providers.dart';

class GoogleAirQualityProvider implements AirQualityProvider {
  static const String _apiEndpoint =
      'https://airquality.googleapis.com/v1/currentConditions:lookup';

  static const String _apiKey = String.fromEnvironment(
    'GOOGLE_AIR_QUALITY_KEY',
    defaultValue: '',
  );

  static const String disclaimer =
      'Data kualitas udara ini bersumber dari model atmosfer Google Air Quality API, '
      'bukan dari stasiun pemantau resmi KLHK. Gunakan sebagai informasi tambahan saja.';

  @override
  String get sourceId => 'google_air_quality';

  @override
  Future<AirReading?> fetchCurrentReading({
    required MonitoringSite site,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('[GoogleAirQuality] API key tidak dikonfigurasi (not_configured).');
      return null;
    }

    try {
      final uri = Uri.parse('$_apiEndpoint?key=$_apiKey');

      final requestBody = jsonEncode({
        'location': {
          'latitude': site.latitude,
          'longitude': site.longitude,
        },
        'extraComputations': [
          'HEALTH_RECOMMENDATIONS',
          'DOMINANT_POLLUTANT_CONCENTRATION',
          'POLLUTANT_CONCENTRATION',
          'LOCAL_AQI',
          'POLLUTANT_ADDITIONAL_INFO',
        ],
        'languageCode': 'id',
      });

      final stopwatch = Stopwatch()..start();
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 12));
      stopwatch.stop();

      if (response.statusCode == 200) {
        return _parseResponse(
          body: response.body,
          site: site,
        );
      } else {
        debugPrint(
          '[GoogleAirQuality] API error HTTP ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('[GoogleAirQuality] Exception: $e');
      return null;
    }
  }

  @override
  Future<List<AirReading>> fetchHistoricalReadings({
    required MonitoringSite site,
    required Duration duration,
  }) async {
    return [];
  }

  AirReading? _parseResponse({
    required String body,
    required MonitoringSite site,
  }) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final pollutants = data['pollutants'] as List<dynamic>?;
      if (pollutants == null || pollutants.isEmpty) {
        debugPrint('[GoogleAirQuality] Tidak ada data polutan dalam respons.');
        return null;
      }

      double? pm25;
      double? pm10;
      double? co;
      double? no2;
      double? o3;

      for (final p in pollutants) {
        final pollutant = p as Map<String, dynamic>;
        final code = (pollutant['code'] as String?)?.toUpperCase() ?? '';
        final concentration = pollutant['concentration'] as Map<String, dynamic>?;
        final value = (concentration?['value'] as num?)?.toDouble();
        if (value == null) continue;

        switch (code) {
          case 'PM25':
            pm25 = value;
            break;
          case 'PM10':
            pm10 = value;
            break;
          case 'CO':
            co = value * 1.145;
            break;
          case 'NO2':
            no2 = value;
            break;
          case 'O3':
            o3 = value;
            break;
        }
      }

      final now = DateTime.now();
      final timeString = data['dateTime'] as String?;
      final observedAt =
          timeString != null ? DateTime.tryParse(timeString) ?? now : now;

      return AirReading(
        readingId:
            'google_${site.siteId}_${observedAt.millisecondsSinceEpoch}',
        sourceId: sourceId,
        siteId: site.siteId,
        regionId: site.regionId,
        observedAt: observedAt,
        fetchedAt: now,
        observationType: ObservationType.model,
        pm25: pm25,
        pm10: pm10,
        co: co,
        no2: no2,
        o3: o3,
        officialIspu: null,
        criticalPollutant: _parseDominantPollutant(data),
      );
    } catch (e) {
      debugPrint('[GoogleAirQuality] Error parsing respons: $e');
      return null;
    }
  }

  String? _parseDominantPollutant(Map<String, dynamic> data) {
    try {
      final indexes = data['indexes'] as List<dynamic>?;
      if (indexes != null) {
        for (final idx in indexes) {
          final indexMap = idx as Map<String, dynamic>;
          final dominant = indexMap['dominantPollutant'] as String?;
          if (dominant != null && dominant.isNotEmpty) {
            return dominant.toUpperCase();
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
