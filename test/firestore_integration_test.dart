import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teduh/models/air_quality_models.dart';
import 'package:teduh/state/monitoring_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 5: Non-Destructive Firestore Integration & Model Mapping Tests', () {
    test('1. Harmonisasi 5 Region ID Firestore (kalbar, kalsel, kalteng, kaltim, kaltara)', () {
      final regions = MonitoringRegion.supportedKalimantan;
      final ids = regions.map((r) => r.regionId).toList();

      expect(ids, contains('kalbar'));
      expect(ids, contains('kalsel'));
      expect(ids, contains('kalteng'));
      expect(ids, contains('kaltim'));
      expect(ids, contains('kaltara'));

      expect(MonitoringRegion.findById('kalbar').province, equals('Kalimantan Barat'));
      expect(MonitoringRegion.findById('kaltim').province, equals('Kalimantan Timur'));
      expect(MonitoringRegion.findById('kalteng').province, equals('Kalimantan Tengah'));
      expect(MonitoringRegion.findById('kalsel').province, equals('Kalimantan Selatan'));
      expect(MonitoringRegion.findById('kaltara').province, equals('Kalimantan Utara'));
    });

    test('2. Parsing dokumen air_readings aktual dari Firestore', () {
      final rawFirestoreDoc = {
        'stationId': 'stn-kalbar-1',
        'regionId': 'kalbar',
        'ispu': 158,
        'categoryId': 'tidak-sehat',
        'measuredAt': '2026-11-09T06:59:11.867Z',
        'createdAt': '2026-11-09T06:59:14.328Z',
      };

      final reading = AirReading.fromFirestore(
        id: 'ar-kalbar-1',
        data: rawFirestoreDoc,
      );

      expect(reading.readingId, equals('ar-kalbar-1'));
      expect(reading.siteId, equals('stn-kalbar-1'));
      expect(reading.regionId, equals('kalbar'));
      expect(reading.officialIspu, equals(158));
      expect(reading.category, equals(IspuCategory.tidakSehat));
      expect(reading.categoryLabel, equals('Tidak Sehat'));
      expect(reading.observedAt.year, equals(2026));
      expect(reading.createdAt, isNotNull);
      expect(reading.createdAt!.month, equals(11));
    });

    test('3. Parsing dokumen stations aktual dan koordinat GPS', () {
      final rawStationDoc = {
        'name': 'Stasiun Samarinda',
        'regionId': 'kaltim',
        'lat': -0.5022,
        'lng': 117.1536,
      };

      final site = MonitoringSite.fromFirestore(
        id: 'stn-kaltim-1',
        data: rawStationDoc,
      );

      expect(site.siteId, equals('stn-kaltim-1'));
      expect(site.stationName, equals('Stasiun Samarinda'));
      expect(site.regionId, equals('kaltim'));
      expect(site.latitude, equals(-0.5022));
      expect(site.longitude, equals(117.1536));
      expect(site.observationType, equals(ObservationType.station));
    });

    test('4. Field parameter polutan yang tidak tersedia di Firestore harus null (tanpa rekaan)', () {
      final rawFirestoreDoc = {
        'stationId': 'stn-kaltara-1',
        'regionId': 'kaltara',
        'ispu': 42,
        'categoryId': 'baik',
        'measuredAt': '2026-11-09T06:59:11.867Z',
      };

      final reading = AirReading.fromFirestore(
        id: 'ar-kaltara-1',
        data: rawFirestoreDoc,
      );

      expect(reading.officialIspu, equals(42));
      expect(reading.category, equals(IspuCategory.baik));
      expect(reading.pm25, isNull);
      expect(reading.pm10, isNull);
      expect(reading.co, isNull);
      expect(reading.no2, isNull);
      expect(reading.o3, isNull);
      expect(reading.formattedPm25, equals('Tidak tersedia'));
    });

    test('5. Perbedaan timestamp measuredAt dan createdAt', () {
      final rawDoc = {
        'stationId': 'stn-kalsel-1',
        'regionId': 'kalsel',
        'ispu': 85,
        'measuredAt': '2026-11-09T06:59:11.867Z',
        'createdAt': '2026-11-09T07:15:00.000Z',
      };

      final reading = AirReading.fromFirestore(id: 'ar-kalsel-1', data: rawDoc);
      expect(reading.observedAt.isBefore(reading.createdAt!), isTrue);
    });

    test('6. Ketidaksesuaian stationId dan regionId fallback aman', () {
      final sitesForKaltim = MonitoringSite.getSitesForRegion('kaltim');
      expect(sitesForKaltim.first.regionId, equals('kaltim'));
      expect(sitesForKaltim.first.siteId, equals('stn-kaltim-1'));

      final defaultSite = MonitoringSite.getDefaultSiteForRegion('wilayah_tidak_dikenal');
      expect(defaultSite, isNotNull);
      expect(defaultSite.siteId, equals('stn-kalteng-1'));
    });

    test('7. Pemisahan identitas data Firestore tersimpan vs Satelit Open-Meteo', () {
      final readingFirestore = AirReading(
        readingId: 'ar-1',
        sourceId: 'firestore_stored',
        siteId: 'stn-1',
        regionId: 'kalbar',
        observedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
        observationType: ObservationType.station,
        officialIspu: 158,
      );

      final readingModel = AirReading(
        readingId: 'cams-1',
        sourceId: 'cams_openmeteo',
        siteId: 'stn-1',
        regionId: 'kalbar',
        observedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
        observationType: ObservationType.model,
        pm25: 45.2,
      );

      expect(readingFirestore.provenanceText, equals('Stasiun KLHK'));
      expect(readingFirestore.officialIspu, equals(158));
      expect(readingFirestore.pm25, isNull);

      expect(readingModel.provenanceText, contains('Estimasi Pemodelan Satelit'));
      expect(readingModel.officialIspu, isNull);
      expect(readingModel.pm25, equals(45.2));
    });

    test('8. MonitoringState pemilihan wilayah menyelaraskan stasiun dan sumber', () async {
      final state = MonitoringState.instance;
      await state.initialize();

      final kaltim = MonitoringRegion.findById('kaltim');
      await state.setRegion(kaltim);

      expect(state.selectedRegion.regionId, equals('kaltim'));
      expect(state.selectedRegion.province, equals('Kalimantan Timur'));
      expect(state.selectedSite.siteId, equals('stn-kaltim-1'));
      expect(state.selectedSite.latitude, equals(-0.5022));
      expect(state.selectedSite.longitude, equals(117.1536));
    });
  });
}
