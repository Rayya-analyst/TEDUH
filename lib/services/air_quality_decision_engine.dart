import 'dart:math' as math;
import '../models/air_quality_models.dart';
import '../models/air_quality_snapshot.dart';
import 'nasa_firms_provider.dart';

class AirQualityDecisionEngine {
  static const List<_IspuBreakpoint> _pm25Breakpoints = [
    _IspuBreakpoint(cLow: 0,     cHigh: 15.5,  ispuLow: 0,   ispuHigh: 50),
    _IspuBreakpoint(cLow: 15.6,  cHigh: 55.4,  ispuLow: 51,  ispuHigh: 100),
    _IspuBreakpoint(cLow: 55.5,  cHigh: 150.4, ispuLow: 101, ispuHigh: 200),
    _IspuBreakpoint(cLow: 150.5, cHigh: 250.4, ispuLow: 201, ispuHigh: 300),
    _IspuBreakpoint(cLow: 250.5, cHigh: 500.0, ispuLow: 301, ispuHigh: 500),
  ];

  static AirQualityDecision decide({
    required AirQualitySnapshot snapshot,
    List<FirmsHotspot> nearbyHotspots = const [],
    double hotspotRadiusKm = 50.0,
  }) {
    final now = DateTime.now();

    final hotspotsNearby = nearbyHotspots.where((h) {
      final dist = _haversineKm(
        snapshot.latitude, snapshot.longitude,
        h.latitude, h.longitude,
      );
      return dist <= hotspotRadiusKm && h.isHighConfidence;
    }).toList();
    final hotspotAlert = hotspotsNearby.isNotEmpty;
    final hotspotCount = hotspotsNearby.length;

    if (!snapshot.hasAnyData) {
      return AirQualityDecision(
        status: 'tidak_cukup_data',
        category: IspuCategory.tidakTersedia,
        confidence: DataConfidence.unavailable,
        reasonId: 'no_data',
        reasonText: 'Data kualitas udara belum tersedia dari sumber manapun untuk lokasi ini. '
            'Coba refresh atau periksa koneksi internet.',
        recommendations: [
          'Pantau informasi dari BMKG dan KLHK secara manual.',
          'Jika ada asap terlihat secara langsung, gunakan masker.',
          'Hubungi posko terdekat untuk informasi kondisi udara setempat.',
        ],
        sourcesUsed: [],
        hotspotAlert: hotspotAlert,
        hotspotCount: hotspotAlert ? hotspotCount : null,
        decidedAt: now,
      );
    }

    int? ispuValue = snapshot.ispuValue;
    bool isOfficialIspu = snapshot.ispu?.isOfficialStation ?? false;
    String dominantPollutant = snapshot.dominantPollutant ?? 'PM2.5';

    DataConfidence confidence;
    String reasonSuffix;

    if (ispuValue == null && snapshot.pm25 != null) {
      ispuValue = _pm25ToIspu(snapshot.pm25!);
      isOfficialIspu = false;
      confidence = DataConfidence.modelEstimate;
      reasonSuffix = ' (Estimasi berbasis PM2.5 model satelit CAMS — bukan pengukuran stasiun KLHK)';
    } else if (isOfficialIspu) {
      confidence = DataConfidence.stationMeasured;
      reasonSuffix = ' (Data pengukuran stasiun / arsip)';
    } else if (snapshot.isOfflineCache) {
      confidence = DataConfidence.cachedOffline;
      reasonSuffix = ' (Data cache offline — mungkin sudah tidak terkini)';
    } else {
      confidence = DataConfidence.modelEstimate;
      reasonSuffix = ' (Estimasi model atmosfer)';
    }

    final category = IspuCategory.fromIspu(ispuValue);
    final status = _categoryToStatus(category);

    final reasonText = _buildReasonText(
      category: category,
      ispuValue: ispuValue,
      dominantPollutant: dominantPollutant,
      hotspotAlert: hotspotAlert,
      hotspotCount: hotspotCount,
      isOfficialIspu: isOfficialIspu,
      suffix: reasonSuffix,
    );

    final sourcesUsed = snapshot.providerResults.entries
        .where((e) => e.value.success)
        .map((e) => e.value.providerName)
        .toList();

    return AirQualityDecision(
      status: status,
      category: category,
      confidence: confidence,
      reasonId: status,
      reasonText: reasonText,
      recommendations: _getRecommendations(category, hotspotAlert),
      sourcesUsed: sourcesUsed,
      hotspotAlert: hotspotAlert,
      hotspotCount: hotspotAlert ? hotspotCount : null,
      decidedAt: now,
    );
  }

  static String _categoryToStatus(IspuCategory cat) {
    switch (cat) {
      case IspuCategory.baik:          return 'baik';
      case IspuCategory.sedang:        return 'sedang';
      case IspuCategory.tidakSehat:    return 'tidak_sehat';
      case IspuCategory.sangatTidakSehat: return 'sangat_tidak_sehat';
      case IspuCategory.berbahaya:     return 'berbahaya';
      case IspuCategory.tidakTersedia: return 'tidak_cukup_data';
    }
  }

  static String _buildReasonText({
    required IspuCategory category,
    required int? ispuValue,
    required String dominantPollutant,
    required bool hotspotAlert,
    required int hotspotCount,
    required bool isOfficialIspu,
    required String suffix,
  }) {
    final ispuStr = ispuValue != null ? 'ISPU $ispuValue' : 'ISPU tidak diketahui';
    final catLabel = category.label;

    String base = 'Kualitas udara saat ini: $catLabel ($ispuStr). '
        'Parameter pencemar dominan: $dominantPollutant.$suffix';

    if (hotspotAlert) {
      base += '\n\n⚠️ Terdeteksi $hotspotCount titik panas (hotspot) aktif kepercayaan-tinggi '
          'dalam radius 50 km dari lokasi Anda berdasarkan data satelit NASA FIRMS. '
          'Hotspot mengindikasikan potensi kebakaran lahan/hutan yang dapat memperburuk kualitas udara.';
    }

    return base;
  }

  static List<String> _getRecommendations(IspuCategory cat, bool hasHotspot) {
    final List<String> base;

    switch (cat) {
      case IspuCategory.baik:
        base = [
          'Udara bersih — aktivitas luar ruangan dapat dilakukan seperti biasa.',
          'Tetap pantau perkembangan kualitas udara secara berkala.',
        ];
        break;
      case IspuCategory.sedang:
        base = [
          'Kelompok sensitif (penderita asma, lansia, anak-anak) sebaiknya mengurangi aktivitas fisik berat di luar ruangan.',
          'Pertimbangkan membuka jendela untuk sirkulasi udara dalam ruangan.',
          'Pantau gejala seperti batuk atau iritasi mata.',
        ];
        break;
      case IspuCategory.tidakSehat:
        base = [
          'Kurangi aktivitas fisik berat di luar ruangan.',
          'Gunakan masker KN95/N95 jika harus berada di luar ruangan.',
          'Kelompok sensitif sebaiknya tetap di dalam ruangan.',
          'Pastikan ventilasi rumah tertutup rapat jika ada asap di luar.',
          'Siapkan obat-obatan yang diresepkan bagi penderita gangguan pernapasan.',
        ];
        break;
      case IspuCategory.sangatTidakSehat:
        base = [
          'Hindari semua aktivitas di luar ruangan yang tidak mendesak.',
          'Wajib menggunakan masker N95 jika harus keluar.',
          'Tutup semua ventilasi dan jendela — gunakan pendingin udara jika ada.',
          'Konsultasikan dengan dokter jika mengalami sesak napas, batuk parah, atau nyeri dada.',
          'Siapkan rencana evakuasi jika kondisi terus memburuk.',
          'Pantau informasi resmi BPBD dan KLHK setempat.',
        ];
        break;
      case IspuCategory.berbahaya:
        base = [
          '⛔ KONDISI BERBAHAYA — Hindari semua paparan udara luar.',
          'Tetap di dalam ruangan yang tertutup rapat.',
          'Hubungi layanan darurat (119) jika mengalami gejala parah.',
          'Ikuti instruksi evakuasi dari pihak berwenang setempat.',
          'Gunakan masker N95 atau respirator P100 jika terpaksa keluar.',
          'Jangan membakar apapun di dalam atau luar ruangan.',
        ];
        break;
      case IspuCategory.tidakTersedia:
        base = [
          'Data kualitas udara belum tersedia.',
          'Gunakan penilaian visual: jika jarak pandang buruk atau ada bau asap, hindari luar ruangan.',
          'Pantau informasi dari BMKG dan KLHK.',
        ];
        break;
    }

    if (hasHotspot && cat.index >= IspuCategory.sedang.index) {
      base.add(
        '🔥 Ada titik panas aktif di sekitar lokasi Anda. '
        'Kondisi bisa memburuk dengan cepat jika arah angin berubah.',
      );
    }

    return base;
  }

  static int _pm25ToIspu(double pm25) {
    for (final bp in _pm25Breakpoints) {
      if (pm25 <= bp.cHigh) {
        final ispu = ((bp.ispuHigh - bp.ispuLow) / (bp.cHigh - bp.cLow)) *
                (pm25 - bp.cLow) +
            bp.ispuLow;
        return ispu.round().clamp(0, 500);
      }
    }
    return 500;
  }

  static double haversineKmTest(
    double lat1, double lng1,
    double lat2, double lng2,
  ) => _haversineKm(lat1, lng1, lat2, lng2);

  static double _haversineKm(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    const r = 6371.0; 
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}

class _IspuBreakpoint {
  final double cLow;
  final double cHigh;
  final int ispuLow;
  final int ispuHigh;

  const _IspuBreakpoint({
    required this.cLow,
    required this.cHigh,
    required this.ispuLow,
    required this.ispuHigh,
  });
}

