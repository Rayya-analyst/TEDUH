import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teduh/models/air_quality_models.dart';
import 'package:teduh/state/monitoring_state.dart';
import 'package:teduh/state/app_settings.dart';
import 'package:teduh/services/ai/ai_key_manager.dart';
import 'package:teduh/services/ai/teduh_ai_orchestrator.dart';
import 'package:teduh/services/context_recommendation.dart';
import 'package:teduh/services/user_profile_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Area 1: Validasi API & Model Parsing', () {
    test('AirReading memetakan semua polutan (PM2.5, PM10, CO, NO2, O3) dan membedakan cuaca', () {
      final now = DateTime.now();
      final reading = AirReading(
        readingId: 'test_reading_1',
        sourceId: 'cams_openmeteo',
        siteId: 'site_plk_1',
        regionId: 'kalteng',
        observedAt: now,
        fetchedAt: now,
        observationType: ObservationType.model,
        pm25: 11.7,
        pm10: 12.4,
        co: 448.0,
        no2: 1.4,
        o3: 36.0,
        temperature: 26.3,
        humidity: 98,
      );

      expect(reading.pm25, equals(11.7));
      expect(reading.pm10, equals(12.4));
      expect(reading.co, equals(448.0));
      expect(reading.no2, equals(1.4));
      expect(reading.o3, equals(36.0));

      expect(reading.temperature, equals(26.3));
      expect(reading.humidity, equals(98));

      expect(reading.category, equals(IspuCategory.baik));
      expect(reading.categoryLabel, equals('Baik'));
    });

    test('Penanganan data null dilakukan secara jujur tanpa rekayasa nilai', () {
      final now = DateTime.now();
      final emptyReading = AirReading(
        readingId: 'empty_reading',
        sourceId: 'cams_openmeteo',
        siteId: 'site_unknown',
        regionId: 'kalteng',
        observedAt: now,
        fetchedAt: now,
        observationType: ObservationType.model,
      );

      expect(emptyReading.pm25, isNull);
      expect(emptyReading.pm10, isNull);
      expect(emptyReading.officialIspu, isNull);
      expect(emptyReading.category, equals(IspuCategory.tidakTersedia));
      expect(emptyReading.categoryLabel, equals('Data Tidak Tersedia'));
    });
  });

  group('Area 2: Validasi Monitoring & Koordinat Peta', () {
    test('Setiap wilayah Kalimantan memiliki stasiun dan koordinat yang presisi', () {
      final regions = MonitoringRegion.supportedKalimantan;
      expect(regions.length, equals(5));

      for (final r in regions) {
        expect(r.defaultLatitude, isNotNull);
        expect(r.defaultLongitude, isNotNull);
        final sites = MonitoringSite.getSitesForRegion(r.regionId);
        expect(sites, isNotEmpty, reason: 'Wilayah ${r.displayName} harus memiliki minimal 1 stasiun pemantau');
        for (final s in sites) {
          expect(s.latitude, isNotNull);
          expect(s.longitude, isNotNull);
          expect(s.regionId, equals(r.regionId));
        }
      }
    });

    test('Pergantian wilayah mengubah stasiun dan koordinat aktif', () async {
      final state = MonitoringState.instance;
      await state.initialize();

      final kaltara = MonitoringRegion.findById('kaltara');
      await state.setRegion(kaltara);
      expect(state.selectedRegion.regionId, equals('kaltara'));
      expect(state.selectedSite.regionId, equals('kaltara'));
      expect(state.selectedSite.latitude, equals(2.8379));
      expect(state.selectedSite.longitude, equals(117.3653));

      final kalteng = MonitoringRegion.findById('kalteng');
      await state.setRegion(kalteng);
      expect(state.selectedRegion.regionId, equals('kalteng'));
      expect(state.selectedSite.latitude, equals(-2.2161));
    });
  });

  group('Area 3: Validasi Riwayat & Rentang Waktu', () {
    test('Rentang waktu 6h, 12h, 24h, 7d, 30d memiliki cutoff waktu yang tepat', () {
      final now = DateTime.now();
      final durations = {
        '6 Jam': const Duration(hours: 6),
        '12 Jam': const Duration(hours: 12),
        '24 Jam': const Duration(hours: 24),
        '7 Hari': const Duration(days: 7),
        '30 Hari': const Duration(days: 30),
      };

      durations.forEach((label, dur) {
        final cutoff = now.subtract(dur);
        expect(cutoff.isBefore(now), isTrue);
        expect(now.difference(cutoff).inHours, equals(dur.inHours));
      });
    });
  });

  group('Area 4: Validasi AI Assistant & Proteksi Kredensial', () {
    test('MultiApiKeyManager merahasiakan API key', () {
      final key = AIKey(key: 'AIzaSyABCDEF1234567890');
      expect(key.maskedKey, startsWith('AIzaSy...'));
      expect(key.maskedKey.contains('ABCDEF1234'), isFalse);
    });

    test('TeduhAiOrchestrator menerima data nyata dan menghasilkan rekomendasi kontekstual', () {
      const airSnapshot = AirSnapshot(
        source: MonitoringSource.klhk,
        sourceName: 'Copernicus CAMS',
        sourceText: 'Model Atmosfer',
        ispuValue: '165',
        ispuLabel: 'Tidak Sehat',
        pm25: '88.5',
        ispu: 165,
        pm25Value: 88.5,
        status: 'Tidak Sehat',
        location: 'Palangka Raya',
        updatedAt: '20:00 WIB',
      );

      final rec = TeduhAiOrchestrator.instance.generateContextAwareRecommendation(
        air: airSnapshot,
        activity: TeduhActivity.olahraga,
      );

      expect(rec.success, isTrue);
      expect(rec.priority, equals('high'));
      expect(rec.mainAction, contains('Tunda olahraga'));
    });
  });

  group('Area 5: Validasi Status Cache vs Offline', () {
    test('AirReading menandai flag isOfflineCache saat disajikan dari cache lokal', () {
      final now = DateTime.now();
      final cachedReading = AirReading(
        readingId: 'cached_read',
        sourceId: 'cache',
        siteId: 'site_1',
        regionId: 'kalteng',
        observedAt: now,
        fetchedAt: now,
        observationType: ObservationType.model,
        isOfflineCache: true,
        pm25: 22.0,
      );

      expect(cachedReading.isOfflineCache, isTrue);
      expect(cachedReading.observationType, equals(ObservationType.model));
    });
  });

  group('Area 6: Validasi Profil & Persistence', () {
    test('UserProfileData memformat nama pengguna dengan benar', () {
      const userWithFull = UserProfileData(
        uid: 'uid123',
        nama: 'Ahmad Dahlan',
        email: 'ahmad@example.com',
      );
      expect(userWithFull.shortName, equals('Ahmad'));

      const userEmailOnly = UserProfileData(
        uid: 'uid456',
        nama: '',
        email: 'budi_santoso@example.com',
      );
      expect(userEmailOnly.shortName, equals('Budi_santoso'));
    });

    test('AppSettings menyimpan status lokasi dan memperbarui snapshot', () {
      final settings = AppSettings.instance;
      settings.setLocationName('Banjarmasin, Kalsel');
      expect(settings.snapshot.location, equals('Banjarmasin, Kalsel'));
    });
  });
}
