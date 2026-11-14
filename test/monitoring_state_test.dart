import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teduh/models/air_quality_models.dart';
import 'package:teduh/state/monitoring_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MonitoringState & Models Tests (Single Source of Truth)', () {
    test('MonitoringRegion mencakup 5 provinsi Kalimantan', () {
      final regions = MonitoringRegion.supportedKalimantan;
      expect(regions.length, equals(5));

      final provinces = regions.map((r) => r.province).toList();
      expect(provinces, contains('Kalimantan Tengah'));
      expect(provinces, contains('Kalimantan Timur'));
      expect(provinces, contains('Kalimantan Barat'));
      expect(provinces, contains('Kalimantan Selatan'));
      expect(provinces, contains('Kalimantan Utara'));
    });

    test('AirReading mengevaluasi kategori ISPU dan PM2.5 dengan jujur', () {
      final readingGood = AirReading(
        readingId: 'test_1',
        sourceId: 'cams_openmeteo',
        siteId: 'site_1',
        regionId: 'reg_1',
        observedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
        observationType: ObservationType.model,
        pm25: 12.0,
      );
      expect(readingGood.category, equals(IspuCategory.baik));
      expect(readingGood.categoryLabel, equals('Baik'));

      final readingDanger = AirReading(
        readingId: 'test_2',
        sourceId: 'cams_openmeteo',
        siteId: 'site_1',
        regionId: 'reg_1',
        observedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
        observationType: ObservationType.model,
        pm25: 280.0,
      );
      expect(readingDanger.category, equals(IspuCategory.berbahaya));
      expect(readingDanger.categoryLabel, equals('Berbahaya'));
    });

    test('MonitoringState setRegion otomatis mengubah stasiun dan koordinat default', () async {
      final state = MonitoringState.instance;
      await state.initialize();

      final kaltim = MonitoringRegion.findById('kaltim');
      await state.setRegion(kaltim);

      expect(state.selectedRegion.province, equals('Kalimantan Timur'));
      expect(state.selectedSite.regionId, equals('kaltim'));
      expect(state.selectedSite.stationName, contains('Samarinda'));
    });

    test('MonitoringState setSource tetap terkunci di KLHK (tidak dapat diubah)', () async {
      final state = MonitoringState.instance;
      await state.initialize();

      await state.setSource(MonitoringSourceInfo.communitySensor);
      expect(state.selectedSource.sourceId, equals('firestore_stored'));
      expect(state.selectedSource.observationType, equals(ObservationType.station));

      await state.setSource(MonitoringSourceInfo.openMeteoCams);
      expect(state.selectedSource.sourceId, equals('firestore_stored'));
      expect(state.selectedSource.observationType, equals(ObservationType.station));
    });

    test('Pergantian wilayah Kaltim ke Kalteng langsung mengubah data dan stasiun instan (cache-first)', () async {
      final state = MonitoringState.instance;
      await state.initialize();

      final kaltim = MonitoringRegion.findById('kaltim');
      await state.setRegion(kaltim);
      expect(state.selectedRegion.province, equals('Kalimantan Timur'));
      expect(state.selectedSite.regionId, equals('kaltim'));
      final kalteng = MonitoringRegion.findById('kalteng');
      await state.setRegion(kalteng);
      expect(state.selectedRegion.province, equals('Kalimantan Tengah'));
      expect(state.selectedSite.regionId, equals('kalteng'));
      expect(state.selectedSite.stationName, contains('Palangka Raya'));
      expect(state.currentReading, isNotNull);
      expect(state.currentReading!.regionId, equals('kalteng'));
    });
  });
}

