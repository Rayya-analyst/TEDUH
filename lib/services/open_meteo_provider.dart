import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/air_quality_models.dart';

class OpenMeteoAirQualityProvider {
  static const _airBaseUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const _weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<OpenMeteoAirData?> fetchCurrentAirQuality({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(_airBaseUrl).replace(queryParameters: {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'hourly': 'pm2_5,pm10,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,aerosol_optical_depth,dust',
        'current': 'pm2_5,pm10,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,aerosol_optical_depth',
        'timezone': 'Asia/Jakarta',
        'past_days': '1',
        'forecast_days': '1',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'TEDUH-App/1.0 (contact@teduh.app)'},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        debugPrint('[OpenMeteo] Air quality HTTP ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return OpenMeteoAirData.fromJson(data, latitude: latitude, longitude: longitude);
    } catch (e) {
      debugPrint('[OpenMeteo] Air quality error: $e');
      return null;
    }
  }

  Future<OpenMeteoWeatherData?> fetchCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(_weatherBaseUrl).replace(queryParameters: {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,precipitation',
        'timezone': 'auto',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'TEDUH-App/1.0 (contact@teduh.app)'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return OpenMeteoWeatherData.fromJson(data);
    } catch (e) {
      debugPrint('[OpenMeteo] Weather error: $e');
      return null;
    }
  }

  Future<List<OpenMeteoHistoricalPoint>> fetchHistoricalHourly({
    required double latitude,
    required double longitude,
    int pastDays = 3,
  }) =>
      fetchHistoricalAirQuality(
        latitude: latitude,
        longitude: longitude,
        pastDays: pastDays,
      );

  Future<List<OpenMeteoHistoricalPoint>> fetchHistoricalAirQuality({
    required double latitude,
    required double longitude,
    int pastDays = 3,
  }) async {
    try {
      final uri = Uri.parse(_airBaseUrl).replace(queryParameters: {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'hourly': 'pm2_5,pm10,carbon_monoxide,nitrogen_dioxide',
        'past_days': pastDays.clamp(1, 14).toString(),
        'forecast_days': '0',
        'timezone': 'Asia/Jakarta',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'TEDUH-App/1.0 (contact@teduh.app)'},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final hourly = data['hourly'] as Map<String, dynamic>?;
      if (hourly == null) return [];

      final times = (hourly['time'] as List?)?.cast<String>() ?? [];
      final pm25List = (hourly['pm2_5'] as List?)?.cast<num?>() ?? [];
      final pm10List = (hourly['pm10'] as List?)?.cast<num?>() ?? [];

      final points = <OpenMeteoHistoricalPoint>[];
      for (int i = 0; i < times.length; i++) {
        final t = DateTime.tryParse(times[i]);
        if (t == null) continue;
        final p25 = i < pm25List.length ? pm25List[i]?.toDouble() : null;
        final p10 = i < pm10List.length ? pm10List[i]?.toDouble() : null;
        points.add(OpenMeteoHistoricalPoint(
          time: t,
          pm25: p25,
          pm10: p10,
          estimatedIspu: OpenMeteoAirData.calcIspuFromPm25(p25),
        ));
      }
      return points;
    } catch (e) {
      debugPrint('[OpenMeteo] Historical fetch error: $e');
      return [];
    }
  }
}

class OpenMeteoHistoricalPoint {
  final DateTime time;
  final double? pm25;
  final double? pm10;
  final int? estimatedIspu;

  const OpenMeteoHistoricalPoint({
    required this.time,
    this.pm25,
    this.pm10,
    this.estimatedIspu,
  });
}

class OpenMeteoAirData {
  final double latitude;
  final double longitude;
  final double? pm25;
  final double? pm10;
  final double? no2;  
  final double? o3;   
  final double? so2;  
  final double? co;   
  final double? aod;  
  final DateTime fetchedAt;

  final bool isOfficialIspu = false;

  int? get estimatedIspu => calcIspuFromPm25(pm25);

  IspuCategory get category => IspuCategory.fromIspu(estimatedIspu);

  static const String dataSourceLabel = 'Estimasi Model Atmosfer (CAMS)';
  static const String dataSourceNote =
      'Data ini merupakan hasil pemodelan atmosfer numerik Copernicus Atmosphere '
      'Monitoring Service (CAMS) melalui Open-Meteo. Bukan merupakan pengukuran langsung '
      'stasiun pemantau permukaan fisik resmi KLHK.';

  const OpenMeteoAirData({
    required this.latitude,
    required this.longitude,
    this.pm25,
    this.pm10,
    this.no2,
    this.o3,
    this.so2,
    this.co,
    this.aod,
    required this.fetchedAt,
  });

  factory OpenMeteoAirData.fromJson(
    Map<String, dynamic> json, {
    required double latitude,
    required double longitude,
  }) {
    final current = json['current'] as Map<String, dynamic>?;
    final hourly = json['hourly'] as Map<String, dynamic>?;

    double? pickVal(String key) {
      if (current != null && current.containsKey(key)) {
        return (current[key] as num?)?.toDouble();
      }
      final list = (hourly?[key] as List?)?.cast<num?>();
      if (list != null && list.isNotEmpty) {
        for (int i = list.length - 1; i >= 0; i--) {
          if (list[i] != null) return list[i]!.toDouble();
        }
      }
      return null;
    }

    return OpenMeteoAirData(
      latitude: latitude,
      longitude: longitude,
      pm25: pickVal('pm2_5'),
      pm10: pickVal('pm10'),
      no2: pickVal('nitrogen_dioxide'),
      o3: pickVal('ozone'),
      so2: pickVal('sulphur_dioxide'),
      co: pickVal('carbon_monoxide'),
      aod: pickVal('aerosol_optical_depth'),
      fetchedAt: DateTime.now(),
    );
  }

  static int? calcIspuFromPm25(double? pm25) {
    if (pm25 == null || pm25 < 0) return null;

    const breakpoints = [
      [0.0, 15.5, 0, 50],       
      [15.5, 55.4, 51, 100],    
      [55.4, 150.4, 101, 200],  
      [150.4, 250.4, 201, 300],
      [250.4, 500.0, 301, 500], 
    ];

    for (final bp in breakpoints) {
      final cMin = bp[0] as double;
      final cMax = bp[1] as double;
      final iMin = bp[2] as int;
      final iMax = bp[3] as int;

      if (pm25 >= cMin && pm25 <= cMax) {
        final ispu = ((iMax - iMin) / (cMax - cMin)) * (pm25 - cMin) + iMin;
        return ispu.round().clamp(0, 500);
      }
    }

    if (pm25 > 500.0) return 500;
    return 0;
  }
}

class OpenMeteoWeatherData {
  final double? temperature;
  final double? humidity;
  final double? windSpeed;
  final double? windDirection;
  final double? precipitation;
  final DateTime fetchedAt;

  const OpenMeteoWeatherData({
    this.temperature,
    this.humidity,
    this.windSpeed,
    this.windDirection,
    this.precipitation,
    required this.fetchedAt,
  });

  factory OpenMeteoWeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>?;
    return OpenMeteoWeatherData(
      temperature: (current?['temperature_2m'] as num?)?.toDouble(),
      humidity: (current?['relative_humidity_2m'] as num?)?.toDouble(),
      windSpeed: (current?['wind_speed_10m'] as num?)?.toDouble(),
      windDirection: (current?['wind_direction_10m'] as num?)?.toDouble(),
      precipitation: (current?['precipitation'] as num?)?.toDouble(),
      fetchedAt: DateTime.now(),
    );
  }

  String get temperatureText =>
      temperature != null ? '${temperature!.round()}°C' : '--';

  String get humidityText =>
      humidity != null ? '${humidity!.round()}%' : '--';

  String get windSpeedText =>
      windSpeed != null ? '${windSpeed!.round()} km/j' : '--';
}

