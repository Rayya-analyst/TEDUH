import 'package:flutter_test/flutter_test.dart';
import 'package:teduh/models/air_quality_models.dart';
import 'package:teduh/services/air_quality_providers.dart';
import 'package:teduh/services/open_meteo_provider.dart';
import 'package:teduh/services/nasa_firms_provider.dart';

final _testSites = <MonitoringSite>[
  const MonitoringSite(
    siteId: 'stn-dki-1',
    sourceId: 'cams_openmeteo',
    regionId: 'dki',
    stationName: 'Jakarta Pusat',
    district: 'Jakarta Pusat',
    latitude: -6.2088,
    longitude: 106.8456,
    observationType: ObservationType.model,
  ),
  const MonitoringSite(
    siteId: 'stn-kalteng-1',
    sourceId: 'cams_openmeteo',
    regionId: 'kalteng',
    stationName: 'Palangka Raya',
    district: 'Jekan Raya',
    latitude: -2.2161,
    longitude: 113.9135,
    observationType: ObservationType.model,
  ),
  const MonitoringSite(
    siteId: 'stn-riau-1',
    sourceId: 'cams_openmeteo',
    regionId: 'riau',
    stationName: 'Pekanbaru',
    district: 'Pekanbaru',
    latitude: 0.5071,
    longitude: 101.4478,
    observationType: ObservationType.model,
  ),
];

void main() {
  group('OpenMeteoCamsProvider — Live API', () {
    final provider = OpenMeteoCamsProvider();

    for (final site in _testSites) {
      test('Fetch data kini untuk ${site.stationName}', () async {
        final reading = await provider.fetchCurrentReading(site: site);

        expect(
          reading,
          isNotNull,
          reason: 'Open-Meteo CAMS harus tersedia untuk ${site.stationName} '
              '(lat=${site.latitude}, lng=${site.longitude})',
        );

        if (reading != null) {
          expect(reading.sourceId, 'cams_openmeteo');
          expect(reading.regionId, site.regionId);
          expect(reading.observationType, ObservationType.model);
          expect(reading.officialIspu, isNull,
              reason: 'Open-Meteo BUKAN stasiun KLHK — officialIspu harus null');

          expect(
            reading.pm25 != null || reading.pm10 != null,
            isTrue,
            reason: 'Minimal satu parameter polutan harus tersedia',
          );

          if (reading.pm25 != null) {
            expect(reading.pm25!, greaterThanOrEqualTo(0));
            expect(reading.pm25!, lessThan(1000),
                reason: 'PM2.5 >1000 µg/m³ tidak masuk akal secara fisik');
          }
          if (reading.pm10 != null) {
            expect(reading.pm10!, greaterThanOrEqualTo(0));
            expect(reading.pm10!, lessThan(2000),
                reason: 'PM10 >2000 µg/m³ tidak masuk akal secara fisik');
          }

          final ageDiff = DateTime.now().difference(reading.observedAt).abs();
          expect(ageDiff.inHours, lessThan(48),
              reason: 'Data harus terkini (< 48 jam lalu)');
        }
      });
    }

    test('Fetch historis 24 jam untuk Jakarta', () async {
      final site = _testSites.first;
      final readings = await provider.fetchHistoricalReadings(
        site: site,
        duration: const Duration(hours: 24),
      );

      expect(readings.length, greaterThan(10),
          reason: 'Histori 24 jam harus menghasilkan setidaknya 10 data point hourly');

      for (final r in readings) {
        expect(r.observationType, ObservationType.model);
        expect(r.sourceId, 'cams_openmeteo');
      }
    });
  });

  group('OpenMeteoAirQualityProvider — Live API', () {
    final provider = OpenMeteoAirQualityProvider();

    test('Fetch kualitas udara terkini Palangka Raya', () async {
      final data = await provider.fetchCurrentAirQuality(
        latitude: -2.2161,
        longitude: 113.9135,
      );

      expect(data, isNotNull,
          reason: 'Open-Meteo Air Quality harus tersedia untuk Palangka Raya');

      if (data != null) {
        expect(data.pm25 != null || data.pm10 != null, isTrue);
        expect(data.isOfficialIspu, isFalse,
            reason: 'Open-Meteo BUKAN data ISPU resmi KLHK');

        if (data.pm25 != null) {
          expect(data.estimatedIspu, isNotNull);
          expect(data.estimatedIspu!, greaterThanOrEqualTo(0));
          expect(data.estimatedIspu!, lessThanOrEqualTo(500));
        }
      }
    });

    test('Fetch historis 3 hari', () async {
      final points = await provider.fetchHistoricalAirQuality(
        latitude: -2.2161,
        longitude: 113.9135,
        pastDays: 3,
      );

      expect(points.length, greaterThan(20),
          reason: 'Histori 3 hari harus ada setidaknya 20 data point hourly');
    });
  });

  group('NasaFirmsHotspotProvider', () {
    final provider = NasaFirmsHotspotProvider();

    test('Tanpa MAP_KEY tidak boleh menampilkan data tiruan / dummy', () async {
      final hotspots = await provider.fetchHotspotsForIndonesia(mapKey: '');

      expect(hotspots, isEmpty,
          reason: 'Tanpa MAP_KEY NASA, provider harus mengembalikan list kosong dan tidak memalsukan hotspot');
      expect(provider.lastError, isNotNull,
          reason: 'Harus ada pesan kesalahan / instruksi pendaftaran MAP_KEY');
      expect(provider.lastError, contains('MAP_KEY'));
    });

    test('FirmsHotspot.isHighConfidence — kategori high', () {
      final h = FirmsHotspot(
        latitude: -2.0,
        longitude: 113.5,
        brightness: 335.0,
        satellite: 'SNPP',
        instrument: 'VIIRS',
        acquisitionTime: DateTime.now(),
        confidence: 'high',
        frp: 18.0,
      );
      expect(h.isHighConfidence, isTrue);
    });

    test('FirmsHotspot.isHighConfidence — kategori nominal → false', () {
      final h = FirmsHotspot(
        latitude: -2.0,
        longitude: 113.5,
        brightness: 310.0,
        satellite: 'SNPP',
        instrument: 'VIIRS',
        acquisitionTime: DateTime.now(),
        confidence: 'nominal',
      );
      expect(h.isHighConfidence, isFalse);
    });

    test('FirmsHotspot.isHighConfidence — confidence >= 80% → true', () {
      final h = FirmsHotspot(
        latitude: -2.0,
        longitude: 113.5,
        brightness: 340.0,
        satellite: 'NOAA-20',
        instrument: 'VIIRS',
        acquisitionTime: DateTime.now(),
        confidence: '85',
      );
      expect(h.isHighConfidence, isTrue);
    });
  });

  group('ISPU Breakpoints — Permen LHK 14/2020', () {
    test('PM2.5 breakpoints kalkulasi konsisten', () {
      final cases = [
        (0.0, 0),    
        (15.5, 50),  
        (15.6, 51),  
        (55.4, 100), 
        (55.5, 101), 
        (150.4, 200),
        (150.5, 201),
        (250.4, 300),
        (250.5, 301),
      ];

      for (final (pm25, expectedIspu) in cases) {
        final ispu = OpenMeteoAirData.calcIspuFromPm25(pm25);
        expect(
          ispu,
          closeTo(expectedIspu, 2), 
          reason: 'PM2.5=$pm25 seharusnya menghasilkan ISPU≈$expectedIspu',
        );
      }
    });
  });
}

