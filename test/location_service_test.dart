import 'package:flutter_test/flutter_test.dart';
import 'package:teduh/models/air_quality_models.dart';
import 'package:teduh/services/location_service.dart';
import 'package:teduh/services/open_meteo_provider.dart';
import 'package:teduh/services/nasa_firms_provider.dart';
import 'package:teduh/state/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocationService & AppSettings Tests', () {
    test('LocationResult fallback mengembalikan default aman', () {
      const fallback = LocationResult.fallback;
      expect(fallback.locationName, equals('Palangka Raya'));
      expect(fallback.isFromGps, isFalse);
      expect(fallback.status, equals(GpsLocationStatus.manualSelected));
      expect(fallback.lat, isNull);
      expect(fallback.lng, isNull);
    });

    test('LocationResult custom instansiasi menyimpan data dengan benar', () {
      const result = LocationResult(
        locationName: 'Pahandut, Kota Palangka Raya',
        lat: -2.215,
        lng: 113.918,
        isFromGps: true,
        status: GpsLocationStatus.granted,
      );
      expect(result.locationName, equals('Pahandut, Kota Palangka Raya'));
      expect(result.lat, equals(-2.215));
      expect(result.lng, equals(113.918));
      expect(result.isFromGps, isTrue);
      expect(result.status, equals(GpsLocationStatus.granted));
    });

    test('LocationResult membedakan status izin GPS (denied, permanentlyDenied, serviceDisabled)', () {
      const denied = LocationResult(
        locationName: '',
        isFromGps: false,
        status: GpsLocationStatus.denied,
        errorMessage: 'Izin ditolak',
      );
      expect(denied.isFromGps, isFalse);
      expect(denied.status, equals(GpsLocationStatus.denied));

      const permDenied = LocationResult(
        locationName: '',
        isFromGps: false,
        status: GpsLocationStatus.permanentlyDenied,
      );
      expect(permDenied.status, equals(GpsLocationStatus.permanentlyDenied));

      const disabled = LocationResult(
        locationName: '',
        isFromGps: false,
        status: GpsLocationStatus.serviceDisabled,
      );
      expect(disabled.status, equals(GpsLocationStatus.serviceDisabled));
    });

    test('AppSettings setLocationName memperbarui snapshot location', () {
      final settings = AppSettings.instance;
      settings.setLocationName('Banjarmasin Tengah, Banjarmasin');
      expect(settings.locationName, equals('Banjarmasin Tengah, Banjarmasin'));
      expect(settings.snapshot.location, equals('Banjarmasin Tengah, Banjarmasin'));
    });

    test('AppSettings membedakan lokasi manual vs lokasi GPS perangkat', () {
      final settings = AppSettings.instance;

      settings.setManualLocation('Kota Bandung, Jawa Barat', lat: -6.9175, lng: 107.6191);
      expect(settings.locationName, equals('Kota Bandung, Jawa Barat'));
      expect(settings.isManualLocation, isTrue);
      expect(settings.gpsStatus, equals(GpsLocationStatus.manualSelected));
      expect(settings.currentLat, equals(-6.9175));
      settings.setGpsLocation(name: 'Jekan Raya, Palangka Raya', lat: -2.216, lng: 113.913);
      expect(settings.locationName, equals('Jekan Raya, Palangka Raya'));
      expect(settings.isManualLocation, isFalse);
      expect(settings.gpsStatus, equals(GpsLocationStatus.granted));
      settings.setGpsStatus(GpsLocationStatus.denied);
      expect(settings.gpsStatus, equals(GpsLocationStatus.denied));
      expect(settings.locationName, isNotEmpty);
    });

    test('MonitoringRegion mencakup seluruh Indonesia (38 provinsi)', () {
      final regions = MonitoringRegion.allSupported;
      expect(regions.length, greaterThanOrEqualTo(38));

      final dki = MonitoringRegion.matchFromText('DKI Jakarta');
      expect(dki, isNotNull);
      expect(dki!.province, equals('DKI Jakarta'));

      final jabar = MonitoringRegion.matchFromText('Kota Bandung');
      expect(jabar, isNotNull);
      expect(jabar!.province, equals('Jawa Barat'));

      final jatim = MonitoringRegion.matchFromText('Surabaya');
      expect(jatim, isNotNull);
      expect(jatim!.province, equals('Jawa Timur'));

      final sulsel = MonitoringRegion.matchFromText('Makassar');
      expect(sulsel, isNotNull);
      expect(sulsel!.province, equals('Sulawesi Selatan'));

      final papua = MonitoringRegion.matchFromText('Jayapura');
      expect(papua, isNotNull);
      expect(papua!.province, equals('Papua'));
    });

    test('OpenMeteoAirData menghitung breakpoint ISPU Permen LHK 14/2020 dengan benar', () {
      expect(OpenMeteoAirData.calcIspuFromPm25(10.0), inInclusiveRange(0, 50));
      expect(OpenMeteoAirData.calcIspuFromPm25(35.0), inInclusiveRange(51, 100));
      expect(OpenMeteoAirData.calcIspuFromPm25(80.0), inInclusiveRange(101, 200));
      expect(OpenMeteoAirData.calcIspuFromPm25(200.0), inInclusiveRange(201, 300));
      expect(OpenMeteoAirData.calcIspuFromPm25(350.0), inInclusiveRange(301, 500));
      final data = OpenMeteoAirData(
        latitude: -6.2,
        longitude: 106.8,
        pm25: 45.0,
        fetchedAt: DateTime.now(),
      );
      expect(data.isOfficialIspu, isFalse);
    });

    test('NasaFirmsHotspotProvider secara transparan menegaskan hotspot bukan PM2.5 atau ISPU', () {
      expect(
        NasaFirmsHotspotProvider.scientificDisclaimer,
        contains('Hotspot TIDAK merepresentasikan konsentrasi PM2.5'),
      );
    });
  });
}
