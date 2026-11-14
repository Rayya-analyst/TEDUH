import 'package:flutter_test/flutter_test.dart';
import 'package:teduh/state/monitoring_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapPage & Free-First Peta Udara Tests', () {
    test('setCustomLocation — Kota Malang: stationName, lat, lng, sourceId benar', () async {
      final mon = MonitoringState.instance;
      await mon.setCustomLocation(
        name: 'Kota Malang',
        lat: -7.9839,
        lng: 112.6214,
      );

      expect(mon.selectedSite.stationName, 'Kota Malang');
      expect(mon.selectedSite.latitude, -7.9839);
      expect(mon.selectedSite.longitude, 112.6214);
      expect(mon.selectedSite.sourceId, 'cams_openmeteo');
      expect(mon.selectedSite.observationType.name, 'model');
    });

    test('setCustomLocation — Kota Surabaya: koordinat ter-update benar', () async {
      final mon = MonitoringState.instance;
      await mon.setCustomLocation(
        name: 'Kota Surabaya',
        lat: -7.2575,
        lng: 112.7521,
      );
      expect(mon.selectedSite.stationName, 'Kota Surabaya');
      expect(mon.selectedSite.latitude, -7.2575);
      expect(mon.selectedSite.longitude, 112.7521);
      expect(mon.selectedSite.sourceId, 'cams_openmeteo');
    });

    test('setCustomLocation — Pekanbaru: sourceId selalu cams_openmeteo', () async {
      final mon = MonitoringState.instance;
      await mon.setCustomLocation(
        name: 'Kota Pekanbaru',
        lat: 0.5071,
        lng: 101.4478,
      );
      expect(mon.selectedSite.sourceId, 'cams_openmeteo');
      expect(mon.selectedSite.latitude, 0.5071);
    });

    test('setCustomLocation — koordinat GPS custom: siteId berisi koordinat', () async {
      final mon = MonitoringState.instance;
      const lat = -1.1234;
      const lng = 116.5678;
      await mon.setCustomLocation(
        name: 'Lokasi GPS',
        lat: lat,
        lng: lng,
      );
      expect(mon.selectedSite.latitude, lat);
      expect(mon.selectedSite.longitude, lng);
      expect(mon.selectedSite.siteId, contains(lat.toStringAsFixed(2)));
    });
  });
}
