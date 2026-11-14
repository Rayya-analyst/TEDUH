import 'package:flutter_test/flutter_test.dart';
import 'package:teduh/models/air_quality_models.dart';
import 'package:teduh/screens/region_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Voice Region Matching Precision Tests', () {
    const popularRegions = [
      RegionOption('Kalimantan Tengah', 'Kota Palangka Raya'),
      RegionOption('Kalimantan Timur', 'Kota Samarinda'),
      RegionOption('Kalimantan Barat', 'Kota Pontianak'),
      RegionOption('Kalimantan Selatan', 'Kota Banjarmasin'),
      RegionOption('Kalimantan Utara', 'Kabupaten Bulungan (Tanjung Selor)'),
      RegionOption('DKI Jakarta', 'Kota Jakarta Pusat'),
      RegionOption('Jawa Barat', 'Kota Bandung'),
      RegionOption('Jawa Timur', 'Kota Surabaya'),
      RegionOption('Jawa Tengah', 'Kota Semarang'),
      RegionOption('D.I. Yogyakarta', 'Kota Yogyakarta'),
      RegionOption('Banten', 'Kota Serang'),
      RegionOption('Bali', 'Kota Denpasar'),
      RegionOption('Sumatera Utara', 'Kota Medan'),
      RegionOption('Riau', 'Kota Pekanbaru'),
      RegionOption('Sumatera Selatan', 'Kota Palembang'),
      RegionOption('Sulawesi Selatan', 'Kota Makassar'),
    ];

    test('Ucapkan "kalimantan barat" HARUS memilih Kalimantan Barat, BUKAN Jawa Barat', () {
      final match = RegionOption.matchFromSpeech('kalimantan barat', popularRegions);
      expect(match, isNotNull);
      expect(match!.province, equals('Kalimantan Barat'));
      expect(match.area, equals('Kota Pontianak'));
    });

    test('Ucapkan "pontianak" memilih Kalimantan Barat', () {
      final match = RegionOption.matchFromSpeech('pontianak', popularRegions);
      expect(match, isNotNull);
      expect(match!.province, equals('Kalimantan Barat'));
    });

    test('Ucapkan "jawa barat" memilih Jawa Barat', () {
      final match = RegionOption.matchFromSpeech('jawa barat', popularRegions);
      expect(match, isNotNull);
      expect(match!.province, equals('Jawa Barat'));
    });

    test('Ucapkan "palangka raya" memilih Kalimantan Tengah', () {
      final match = RegionOption.matchFromSpeech('palangka raya', popularRegions);
      expect(match, isNotNull);
      expect(match!.province, equals('Kalimantan Tengah'));
    });

    test('MonitoringRegion.matchFromText("kalimantan barat") memilih Kalimantan Barat', () {
      final r = MonitoringRegion.matchFromText('kalimantan barat');
      expect(r, isNotNull);
      expect(r!.province, equals('Kalimantan Barat'));
    });

    test('MonitoringRegion.matchFromText("jawa barat") memilih Jawa Barat', () {
      final r = MonitoringRegion.matchFromText('jawa barat');
      expect(r, isNotNull);
      expect(r!.province, equals('Jawa Barat'));
    });
  });
}

