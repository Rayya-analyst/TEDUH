import 'package:flutter_test/flutter_test.dart';
import 'package:teduh/models/air_quality_models.dart';
import 'package:teduh/models/air_quality_snapshot.dart';
import 'package:teduh/services/air_quality_decision_engine.dart';
import 'package:teduh/services/nasa_firms_provider.dart';

AirQualitySnapshot _makeSnapshot({
  int? officialIspu,
  double? pm25,
  bool isOffline = false,
  String locationId = 'region-kalteng',
}) {
  final pollutants = <String, PollutantValue>{};
  if (pm25 != null) {
    pollutants['pm2_5'] = PollutantValue(
      value: pm25,
      unit: 'µg/m³',
      providerId: 'cams_openmeteo',
      timestamp: DateTime.now(),
      dataType: ObservationType.model,
      confidence: DataConfidence.modelEstimate,
    );
  }

  IspuResult? ispuResult;
  if (officialIspu != null) {
    ispuResult = IspuResult(
      ispuValue: officialIspu,
      category: IspuCategory.fromIspu(officialIspu),
      dominantPollutant: 'PM2.5',
      calculationSource: 'firestore_stored',
      isOfficialStation: true,
    );
  }

  return AirQualitySnapshot(
    locationId: locationId,
    latitude: -2.2161,
    longitude: 113.9135,
    locationName: 'Palangka Raya, Kalimantan Tengah',
    province: 'Kalimantan Tengah',
    city: 'Palangka Raya',
    timestamp: DateTime.now(),
    pollutants: pollutants,
    ispu: ispuResult,
    sourceMetadata: SourceMetadata(
      totalProvidersTried: 1,
      totalProvidersSucceeded: pollutants.isNotEmpty || ispuResult != null ? 1 : 0,
      hasOfficialStationData: ispuResult?.isOfficialStation ?? false,
      hasModelData: pm25 != null,
      hasSatelliteData: pm25 != null,
      snapshotCreatedAt: DateTime.now(),
      providerStatus: {'cams_openmeteo': 'ok'},
    ),
    isOfflineCache: isOffline,
  );
}

FirmsHotspot _makeHotspot({
  double lat = -2.0,
  double lng = 113.5,
  String confidence = 'high',
}) {
  return FirmsHotspot(
    latitude: lat,
    longitude: lng,
    brightness: 330.0,
    satellite: 'SNPP',
    instrument: 'VIIRS',
    acquisitionTime: DateTime.now().subtract(const Duration(hours: 2)),
    confidence: confidence,
    frp: 15.0,
  );
}

void main() {
  group('AirQualityDecisionEngine — Kategori ISPU resmi', () {
    test('ISPU 25 → Baik', () {
      final snap = _makeSnapshot(officialIspu: 25);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.baik);
      expect(d.status, 'baik');
      expect(d.confidence, DataConfidence.stationMeasured);
    });

    test('ISPU 50 → Baik (batas atas)', () {
      final snap = _makeSnapshot(officialIspu: 50);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.baik);
    });

    test('ISPU 51 → Sedang (batas bawah)', () {
      final snap = _makeSnapshot(officialIspu: 51);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.sedang);
      expect(d.status, 'sedang');
    });

    test('ISPU 100 → Sedang', () {
      final snap = _makeSnapshot(officialIspu: 100);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.sedang);
    });

    test('ISPU 101 → Tidak Sehat', () {
      final snap = _makeSnapshot(officialIspu: 101);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.tidakSehat);
      expect(d.status, 'tidak_sehat');
    });

    test('ISPU 200 → Tidak Sehat', () {
      final snap = _makeSnapshot(officialIspu: 200);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.tidakSehat);
    });

    test('ISPU 201 → Sangat Tidak Sehat', () {
      final snap = _makeSnapshot(officialIspu: 201);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.sangatTidakSehat);
      expect(d.status, 'sangat_tidak_sehat');
    });

    test('ISPU 300 → Sangat Tidak Sehat (batas atas)', () {
      final snap = _makeSnapshot(officialIspu: 300);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.sangatTidakSehat);
    });

    test('ISPU 301 → Berbahaya', () {
      final snap = _makeSnapshot(officialIspu: 301);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.berbahaya);
      expect(d.status, 'berbahaya');
    });

    test('ISPU 462 → Berbahaya', () {
      final snap = _makeSnapshot(officialIspu: 462);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.berbahaya);
      expect(d.isActionRequired, isTrue);
    });
  });

  group('AirQualityDecisionEngine — Estimasi dari PM2.5', () {
    test('PM2.5 10.0 → Baik (estimasi)', () {
      final snap = _makeSnapshot(pm25: 10.0);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.baik);
      expect(d.confidence, DataConfidence.modelEstimate);
    });

    test('PM2.5 15.5 → Baik (batas)', () {
      final snap = _makeSnapshot(pm25: 15.5);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.baik);
    });

    test('PM2.5 55.4 → Sedang', () {
      final snap = _makeSnapshot(pm25: 55.4);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.sedang);
    });

    test('PM2.5 150.4 → Tidak Sehat', () {
      final snap = _makeSnapshot(pm25: 150.4);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.tidakSehat);
    });

    test('PM2.5 250.4 → Sangat Tidak Sehat', () {
      final snap = _makeSnapshot(pm25: 250.4);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.sangatTidakSehat);
    });

    test('PM2.5 300.0 → Berbahaya', () {
      final snap = _makeSnapshot(pm25: 300.0);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.category, IspuCategory.berbahaya);
    });
  });

  group('AirQualityDecisionEngine — Hotspot Alert', () {
    test('Hotspot high-confidence dalam 100km → hotspotAlert true', () {
      final snap = _makeSnapshot(pm25: 45.0);
      final hotspot = _makeHotspot(lat: -2.26, lng: 113.95, confidence: 'high');
      final d = AirQualityDecisionEngine.decide(
        snapshot: snap,
        nearbyHotspots: [hotspot],
        hotspotRadiusKm: 100.0, 
      );
      expect(d.hotspotAlert, isTrue);
      expect(d.hotspotCount, greaterThan(0));
    });

    test('Hotspot low-confidence diabaikan', () {
      final snap = _makeSnapshot(pm25: 45.0);
      final hotspot = _makeHotspot(lat: -2.0, lng: 113.5, confidence: 'low');
      final d = AirQualityDecisionEngine.decide(
        snapshot: snap,
        nearbyHotspots: [hotspot],
      );
      expect(d.hotspotAlert, isFalse);
    });

    test('Hotspot jauh (>50km) tidak memicu alert', () {
      final snap = _makeSnapshot(pm25: 45.0);
      final hotspot = _makeHotspot(lat: -4.0, lng: 140.0, confidence: 'high');
      final d = AirQualityDecisionEngine.decide(
        snapshot: snap,
        nearbyHotspots: [hotspot],
        hotspotRadiusKm: 50.0,
      );
      expect(d.hotspotAlert, isFalse);
    });
  });

  group('AirQualityDecisionEngine — Tidak ada data', () {
    test('Snapshot kosong → tidak_cukup_data', () {
      final snap = AirQualitySnapshot.empty(
        locationId: 'region-papua',
        latitude: -2.5337,
        longitude: 140.7181,
        locationName: 'Jayapura',
        province: 'Papua',
        city: 'Jayapura',
      );
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.status, 'tidak_cukup_data');
      expect(d.category, IspuCategory.tidakTersedia);
      expect(d.confidence, DataConfidence.unavailable);
    });
  });

  group('AirQualityDecisionEngine — Rekomendasi', () {
    test('Berbahaya menghasilkan minimal 4 rekomendasi', () {
      final snap = _makeSnapshot(officialIspu: 400);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.recommendations.length, greaterThanOrEqualTo(4));
      final combined = d.recommendations.join(' ').toLowerCase();
      expect(combined.contains('ruangan') || combined.contains('masker'), isTrue);
    });

    test('Baik menghasilkan rekomendasi positif', () {
      final snap = _makeSnapshot(officialIspu: 30);
      final d = AirQualityDecisionEngine.decide(snapshot: snap);
      expect(d.recommendations, isNotEmpty);
      final combined = d.recommendations.join(' ').toLowerCase();
      expect(combined.contains('bersih') || combined.contains('biasa') || combined.contains('pantau'), isTrue);
    });
  });

  group('Haversine distance', () {
    test('Palangka Raya ke Pontianak ≈ 560km', () {
      final dist = AirQualityDecisionEngine.haversineKmTest(
        -2.2161, 113.9135, -0.0263, 109.3425,
      );
      expect(dist, greaterThan(530));
      expect(dist, lessThan(600));
    });

    test('Titik sama → jarak 0', () {
      final dist = AirQualityDecisionEngine.haversineKmTest(
        -2.2161, 113.9135, -2.2161, 113.9135,
      );
      expect(dist, closeTo(0.0, 0.01));
    });
  });
}
