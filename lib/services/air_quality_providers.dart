import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/air_quality_models.dart';

abstract class AirQualityProvider {
  String get sourceId;
  Future<AirReading?> fetchCurrentReading({
    required MonitoringSite site,
  });

  Future<List<AirReading>> fetchHistoricalReadings({
    required MonitoringSite site,
    required Duration duration,
  });
}

class FirestoreAirQualityProvider implements AirQualityProvider {
  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore? get _firestore {
    if (_firestoreOverride != null) return _firestoreOverride;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirestoreAirQualityProvider({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  @override
  String get sourceId => 'firestore_stored';

  @override
  Future<AirReading?> fetchCurrentReading({
    required MonitoringSite site,
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('[FirestoreAirQualityProvider] Firebase belum diinisialisasi.');
      return null;
    }

    try {
      final docId = 'ar-${site.regionId}-1';
      final docSnap = await firestore
          .collection('air_readings')
          .doc(docId)
          .get()
          .timeout(const Duration(milliseconds: 1000));

      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        final rawMeasured = data['measuredAt'];
        DateTime measuredDate = DateTime.now();
        if (rawMeasured is Timestamp) {
          measuredDate = rawMeasured.toDate();
        } else if (rawMeasured is String) {
          measuredDate = DateTime.tryParse(rawMeasured) ?? DateTime.now();
        }

        final rawCreated = data['createdAt'];
        DateTime? createdDate;
        if (rawCreated is Timestamp) {
          createdDate = rawCreated.toDate();
        } else if (rawCreated is String) {
          createdDate = DateTime.tryParse(rawCreated);
        }

        return AirReading(
          readingId: docSnap.id,
          sourceId: sourceId,
          siteId: (data['stationId'] as String?) ?? site.siteId,
          regionId: (data['regionId'] as String?) ?? site.regionId,
          observedAt: measuredDate,
          fetchedAt: DateTime.now(),
          createdAt: createdDate,
          observationType: ObservationType.station,
          officialIspu: (data['ispu'] as num?)?.toInt(),
          categoryId: data['categoryId'] as String?,
          pm25: null, 
          pm10: null,
          co: null,
          no2: null,
          o3: null,
        );
      }

      final query = await firestore
          .collection('air_readings')
          .where('regionId', isEqualTo: site.regionId)
          .limit(1)
          .get()
          .timeout(const Duration(milliseconds: 1000));

      if (query.docs.isNotEmpty) {
        final d = query.docs.first;
        final data = d.data();
        final rawMeasured = data['measuredAt'];
        DateTime measuredDate = DateTime.now();
        if (rawMeasured is Timestamp) {
          measuredDate = rawMeasured.toDate();
        } else if (rawMeasured is String) {
          measuredDate = DateTime.tryParse(rawMeasured) ?? DateTime.now();
        }

        return AirReading(
          readingId: d.id,
          sourceId: sourceId,
          siteId: (data['stationId'] as String?) ?? site.siteId,
          regionId: site.regionId,
          observedAt: measuredDate,
          fetchedAt: DateTime.now(),
          observationType: ObservationType.station,
          officialIspu: (data['ispu'] as num?)?.toInt(),
          categoryId: data['categoryId'] as String?,
          pm25: null,
          pm10: null,
        );
      }
    } catch (e) {
      debugPrint('[FirestoreAirQualityProvider] Error reading Firestore: $e');
    }
    return null;
  }

  @override
  Future<List<AirReading>> fetchHistoricalReadings({
    required MonitoringSite site,
    required Duration duration,
  }) async {
    return [];
  }
}

class OpenMeteoCamsProvider implements AirQualityProvider {
  @override
  String get sourceId => 'cams_openmeteo';

  static const String _baseUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality';

  @override
  Future<AirReading?> fetchCurrentReading({
    required MonitoringSite site,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?latitude=${site.latitude}&longitude=${site.longitude}'
        '&current=pm2_5,pm10,carbon_monoxide,nitrogen_dioxide,ozone'
        '&timezone=Asia%2FJakarta',
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current'] as Map<String, dynamic>?;
        if (current == null) return null;

        final timeStr = current['time'] as String?;
        final obsTime = timeStr != null ? DateTime.tryParse(timeStr) ?? DateTime.now() : DateTime.now();

        final pm25Val = (current['pm2_5'] as num?)?.toDouble();
        final pm10Val = (current['pm10'] as num?)?.toDouble();
        final coVal = (current['carbon_monoxide'] as num?)?.toDouble();
        final no2Val = (current['nitrogen_dioxide'] as num?)?.toDouble();
        final o3Val = (current['ozone'] as num?)?.toDouble();

        double? tempVal;
        int? humVal;
        try {
          final weatherUri = Uri.parse(
            'https://api.open-meteo.com/v1/forecast?latitude=${site.latitude}&longitude=${site.longitude}'
            '&current=temperature_2m,relative_humidity_2m'
            '&timezone=Asia%2FJakarta',
          );
          final wRes = await http.get(weatherUri).timeout(const Duration(seconds: 4));
          if (wRes.statusCode == 200) {
            final wData = jsonDecode(wRes.body);
            final wCurr = wData['current'] as Map<String, dynamic>?;
            if (wCurr != null) {
              tempVal = (wCurr['temperature_2m'] as num?)?.toDouble();
              humVal = (wCurr['relative_humidity_2m'] as num?)?.toInt();
            }
          }
        } catch (_) {}

        return AirReading(
          readingId: 'cams_${site.siteId}_${obsTime.millisecondsSinceEpoch}',
          sourceId: sourceId,
          siteId: site.siteId,
          regionId: site.regionId,
          observedAt: obsTime,
          fetchedAt: DateTime.now(),
          observationType: ObservationType.model,
          pm25: pm25Val,
          pm10: pm10Val,
          co: coVal,
          no2: no2Val,
          o3: o3Val,
          officialIspu: null, 
          temperature: tempVal,
          humidity: humVal,
        );
      }
    } catch (e) {
      debugPrint('[OpenMeteoCamsProvider] Gagal mengambil data live: $e');
    }
    return null;
  }

  @override
  Future<List<AirReading>> fetchHistoricalReadings({
    required MonitoringSite site,
    required Duration duration,
  }) async {
    final List<AirReading> results = [];
    try {
      int pastDays = 1;
      if (duration.inDays > 1) {
        pastDays = duration.inDays.clamp(1, 30);
      }

      final uri = Uri.parse(
        '$_baseUrl?latitude=${site.latitude}&longitude=${site.longitude}'
        '&hourly=pm2_5,pm10'
        '&past_days=$pastDays&forecast_days=1'
        '&timezone=Asia%2FJakarta',
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final hourly = data['hourly'] as Map<String, dynamic>?;
        if (hourly != null) {
          final times = List<String>.from(hourly['time'] ?? []);
          final pm25List = List<dynamic>.from(hourly['pm2_5'] ?? []);
          final pm10List = List<dynamic>.from(hourly['pm10'] ?? []);

          final cutoff = DateTime.now().subtract(duration);

          for (int i = 0; i < times.length; i++) {
            final t = DateTime.tryParse(times[i]);
            if (t == null) continue;
            if (t.isAfter(cutoff) && t.isBefore(DateTime.now().add(const Duration(hours: 1)))) {
              final p25 = (pm25List.length > i && pm25List[i] != null)
                  ? (pm25List[i] as num).toDouble()
                  : null;
              final p10 = (pm10List.length > i && pm10List[i] != null)
                  ? (pm10List[i] as num).toDouble()
                  : null;

              results.add(AirReading(
                readingId: 'hist_${site.siteId}_${t.millisecondsSinceEpoch}',
                sourceId: sourceId,
                siteId: site.siteId,
                regionId: site.regionId,
                observedAt: t,
                fetchedAt: DateTime.now(),
                observationType: ObservationType.model,
                pm25: p25,
                pm10: p10,
              ));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[OpenMeteoCamsProvider] Gagal mengambil data histori: $e');
    }
    return results;
  }
}

class CommunitySensorProvider implements AirQualityProvider {
  @override
  String get sourceId => 'community_iot';

  @override
  Future<AirReading?> fetchCurrentReading({required MonitoringSite site}) async {

    return null;
  }

  @override
  Future<List<AirReading>> fetchHistoricalReadings({
    required MonitoringSite site,
    required Duration duration,
  }) async {
    return [];
  }
}
