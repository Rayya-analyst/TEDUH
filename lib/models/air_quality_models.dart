enum ObservationType {
  station, 
  model, 
  sensor, 
}
enum IspuCategory {
  baik,
  sedang,
  tidakSehat, 
  sangatTidakSehat,
  berbahaya, 
  tidakTersedia; 

  String get label {
    switch (this) {
      case IspuCategory.baik:
        return 'Baik';
      case IspuCategory.sedang:
        return 'Sedang';
      case IspuCategory.tidakSehat:
        return 'Tidak Sehat';
      case IspuCategory.sangatTidakSehat:
        return 'Sangat Tidak Sehat';
      case IspuCategory.berbahaya:
        return 'Berbahaya';
      case IspuCategory.tidakTersedia:
        return 'Data Tidak Tersedia';
    }
  }

  static IspuCategory fromIspu(int? ispu) {
    if (ispu == null) return IspuCategory.tidakTersedia;
    if (ispu <= 50) return IspuCategory.baik;
    if (ispu <= 100) return IspuCategory.sedang;
    if (ispu <= 200) return IspuCategory.tidakSehat;
    if (ispu <= 300) return IspuCategory.sangatTidakSehat;
    return IspuCategory.berbahaya;
  }
}

class MonitoringSourceInfo {
  final String sourceId;
  final String providerName;
  final String sourceName;
  final ObservationType observationType;
  final String description;
  final String attribution;
  final String termsOfUse;
  final Duration refreshInterval;
  final bool isLiveAvailable;

  const MonitoringSourceInfo({
    required this.sourceId,
    required this.providerName,
    required this.sourceName,
    required this.observationType,
    required this.description,
    required this.attribution,
    required this.termsOfUse,
    required this.refreshInterval,
    this.isLiveAvailable = true,
  });

  static const firestoreStored = MonitoringSourceInfo(
    sourceId: 'firestore_stored',
    providerName: 'TEDUH Cloud Cache',
    sourceName: 'Basis Data Tersimpan (Firestore)',
    observationType: ObservationType.station,
    description: 'Data pembacaan yang tersimpan dalam basis data Cloud Firestore. Catatan: Data ini merupakan arsip tersimpan/cache dan belum terhubung secara streaming otomatis dengan API resmi stasiun fisik KLHK.',
    attribution: 'Arsip Data Tersimpan TEDUH (Cloud Firestore)',
    termsOfUse: 'Digunakan sebagai arsip lokal & cache tersimpan.',
    refreshInterval: Duration(hours: 1),
    isLiveAvailable: true,
  );

  static const openMeteoCams = MonitoringSourceInfo(
    sourceId: 'cams_openmeteo',
    providerName: 'Copernicus / Open-Meteo',
    sourceName: 'Satelit Sentinel & Copernicus (CAMS)',
    observationType: ObservationType.model,
    description: 'Estimasi pemodelan atmosfer berbasis satelit dan asimilasi data meteorologi.',
    attribution: 'Copernicus Atmosphere Monitoring Service (CAMS) & Open-Meteo (CC BY 4.0)',
    termsOfUse: 'Data pemodelan atmosfer tanpa jaminan akurasi titik stasiun.',
    refreshInterval: Duration(hours: 1),
    isLiveAvailable: true,
  );

  static const communitySensor = MonitoringSourceInfo(
    sourceId: 'community_iot',
    providerName: 'Jaringan Komunitas TEDUH',
    sourceName: 'Sensor Komunitas Lokal (IoT)',
    observationType: ObservationType.sensor,
    description: 'Jaringan sensor pemukiman warga untuk deteksi cepat asap lokal.',
    attribution: 'Komunitas Relawan TEDUH Karhutla',
    termsOfUse: 'Sensor berbiaya rendah (low-cost) untuk indikasi tren lokal.',
    refreshInterval: Duration(minutes: 15),
    isLiveAvailable: true,
  );

  static const List<MonitoringSourceInfo> allSources = [
    firestoreStored,
    openMeteoCams,
  ];

  static MonitoringSourceInfo findById(String id) {
    return allSources.firstWhere(
      (s) => s.sourceId == id,
      orElse: () => firestoreStored,
    );
  }
}

class MonitoringRegion {
  final String regionId; 
  final String province;
  final String regency;
  final double defaultLatitude;
  final double defaultLongitude;

  const MonitoringRegion({
    required this.regionId,
    required this.province,
    required this.regency,
    required this.defaultLatitude,
    required this.defaultLongitude,
  });

  String get displayName => '$regency, $province';

  static const List<MonitoringRegion> supportedKalimantan = [
    MonitoringRegion(
      regionId: 'kalteng',
      province: 'Kalimantan Tengah',
      regency: 'Kota Palangka Raya',
      defaultLatitude: -2.2161,
      defaultLongitude: 113.9135,
    ),
    MonitoringRegion(
      regionId: 'kaltim',
      province: 'Kalimantan Timur',
      regency: 'Kota Samarinda',
      defaultLatitude: -0.5022,
      defaultLongitude: 117.1536,
    ),
    MonitoringRegion(
      regionId: 'kalbar',
      province: 'Kalimantan Barat',
      regency: 'Kota Pontianak',
      defaultLatitude: -0.0263,
      defaultLongitude: 109.3425,
    ),
    MonitoringRegion(
      regionId: 'kalsel',
      province: 'Kalimantan Selatan',
      regency: 'Kota Banjarmasin',
      defaultLatitude: -3.3194,
      defaultLongitude: 114.5908,
    ),
    MonitoringRegion(
      regionId: 'kaltara',
      province: 'Kalimantan Utara',
      regency: 'Kabupaten Bulungan (Tanjung Selor)',
      defaultLatitude: 2.8379,
      defaultLongitude: 117.3653,
    ),
  ];

  static const List<MonitoringRegion> supportedIndonesia = [
    ...supportedKalimantan,
    MonitoringRegion(
      regionId: 'dki',
      province: 'DKI Jakarta',
      regency: 'Kota Jakarta Pusat',
      defaultLatitude: -6.1751,
      defaultLongitude: 106.8650,
    ),
    MonitoringRegion(
      regionId: 'jabar',
      province: 'Jawa Barat',
      regency: 'Kota Bandung',
      defaultLatitude: -6.9175,
      defaultLongitude: 107.6191,
    ),
    MonitoringRegion(
      regionId: 'jateng',
      province: 'Jawa Tengah',
      regency: 'Kota Semarang',
      defaultLatitude: -6.9667,
      defaultLongitude: 110.4167,
    ),
    MonitoringRegion(
      regionId: 'jatim',
      province: 'Jawa Timur',
      regency: 'Kota Surabaya',
      defaultLatitude: -7.2575,
      defaultLongitude: 112.7521,
    ),
    MonitoringRegion(
      regionId: 'diy',
      province: 'D.I. Yogyakarta',
      regency: 'Kota Yogyakarta',
      defaultLatitude: -7.7956,
      defaultLongitude: 110.3695,
    ),
    MonitoringRegion(
      regionId: 'banten',
      province: 'Banten',
      regency: 'Kota Serang',
      defaultLatitude: -6.1104,
      defaultLongitude: 106.1640,
    ),
    MonitoringRegion(
      regionId: 'bali',
      province: 'Bali',
      regency: 'Kota Denpasar',
      defaultLatitude: -8.6705,
      defaultLongitude: 115.2126,
    ),
    MonitoringRegion(
      regionId: 'sumut',
      province: 'Sumatera Utara',
      regency: 'Kota Medan',
      defaultLatitude: 3.5952,
      defaultLongitude: 98.6722,
    ),
    MonitoringRegion(
      regionId: 'riau',
      province: 'Riau',
      regency: 'Kota Pekanbaru',
      defaultLatitude: 0.5071,
      defaultLongitude: 101.4478,
    ),
    MonitoringRegion(
      regionId: 'sumbar',
      province: 'Sumatera Barat',
      regency: 'Kota Padang',
      defaultLatitude: -0.9471,
      defaultLongitude: 100.4172,
    ),
    MonitoringRegion(
      regionId: 'sumsel',
      province: 'Sumatera Selatan',
      regency: 'Kota Palembang',
      defaultLatitude: -2.9761,
      defaultLongitude: 104.7754,
    ),
    MonitoringRegion(
      regionId: 'jambi',
      province: 'Jambi',
      regency: 'Kota Jambi',
      defaultLatitude: -1.6101,
      defaultLongitude: 103.6131,
    ),
    MonitoringRegion(
      regionId: 'lampung',
      province: 'Lampung',
      regency: 'Kota Bandar Lampung',
      defaultLatitude: -5.4500,
      defaultLongitude: 105.2667,
    ),
    MonitoringRegion(
      regionId: 'aceh',
      province: 'Aceh',
      regency: 'Kota Banda Aceh',
      defaultLatitude: 5.5483,
      defaultLongitude: 95.3238,
    ),
    MonitoringRegion(
      regionId: 'kepri',
      province: 'Kepulauan Riau',
      regency: 'Kota Batam',
      defaultLatitude: 1.1301,
      defaultLongitude: 104.0529,
    ),
    MonitoringRegion(
      regionId: 'babel',
      province: 'Kepulauan Bangka Belitung',
      regency: 'Kota Pangkalpinang',
      defaultLatitude: -2.1333,
      defaultLongitude: 106.1167,
    ),
    MonitoringRegion(
      regionId: 'bengkulu',
      province: 'Bengkulu',
      regency: 'Kota Bengkulu',
      defaultLatitude: -3.8004,
      defaultLongitude: 102.2655,
    ),
    MonitoringRegion(
      regionId: 'sulsel',
      province: 'Sulawesi Selatan',
      regency: 'Kota Makassar',
      defaultLatitude: -5.1477,
      defaultLongitude: 119.4327,
    ),
    MonitoringRegion(
      regionId: 'sulut',
      province: 'Sulawesi Utara',
      regency: 'Kota Manado',
      defaultLatitude: 1.4748,
      defaultLongitude: 124.8421,
    ),
    MonitoringRegion(
      regionId: 'sulteng',
      province: 'Sulawesi Tengah',
      regency: 'Kota Palu',
      defaultLatitude: -0.9003,
      defaultLongitude: 119.8780,
    ),
    MonitoringRegion(
      regionId: 'sultra',
      province: 'Sulawesi Tenggara',
      regency: 'Kota Kendari',
      defaultLatitude: -3.9985,
      defaultLongitude: 122.5126,
    ),
    MonitoringRegion(
      regionId: 'gorontalo',
      province: 'Gorontalo',
      regency: 'Kota Gorontalo',
      defaultLatitude: 0.5435,
      defaultLongitude: 123.0568,
    ),
    MonitoringRegion(
      regionId: 'sulbar',
      province: 'Sulawesi Barat',
      regency: 'Kabupaten Mamuju',
      defaultLatitude: -2.6775,
      defaultLongitude: 118.8872,
    ),
    MonitoringRegion(
      regionId: 'ntb',
      province: 'Nusa Tenggara Barat',
      regency: 'Kota Mataram',
      defaultLatitude: -8.5769,
      defaultLongitude: 116.1009,
    ),
    MonitoringRegion(
      regionId: 'ntt',
      province: 'Nusa Tenggara Timur',
      regency: 'Kota Kupang',
      defaultLatitude: -10.1772,
      defaultLongitude: 123.6070,
    ),
    MonitoringRegion(
      regionId: 'maluku',
      province: 'Maluku',
      regency: 'Kota Ambon',
      defaultLatitude: -3.6554,
      defaultLongitude: 128.1908,
    ),
    MonitoringRegion(
      regionId: 'malut',
      province: 'Maluku Utara',
      regency: 'Kota Ternate',
      defaultLatitude: 0.7904,
      defaultLongitude: 127.3809,
    ),
    MonitoringRegion(
      regionId: 'papua',
      province: 'Papua',
      regency: 'Kota Jayapura',
      defaultLatitude: -2.5337,
      defaultLongitude: 140.7181,
    ),
    MonitoringRegion(
      regionId: 'papuabarat',
      province: 'Papua Barat',
      regency: 'Kabupaten Manokwari',
      defaultLatitude: -0.8615,
      defaultLongitude: 134.0620,
    ),
    MonitoringRegion(
      regionId: 'papuaselatan',
      province: 'Papua Selatan',
      regency: 'Kabupaten Merauke',
      defaultLatitude: -8.4991,
      defaultLongitude: 140.4011,
    ),
    MonitoringRegion(
      regionId: 'papuatengah',
      province: 'Papua Tengah',
      regency: 'Kabupaten Nabire',
      defaultLatitude: -3.3667,
      defaultLongitude: 135.4833,
    ),
    MonitoringRegion(
      regionId: 'papuapegunungan',
      province: 'Papua Pegunungan',
      regency: 'Kabupaten Jayawijaya (Wamena)',
      defaultLatitude: -4.0950,
      defaultLongitude: 138.9442,
    ),
    MonitoringRegion(
      regionId: 'papuabaratdaya',
      province: 'Papua Barat Daya',
      regency: 'Kota Sorong',
      defaultLatitude: -0.8762,
      defaultLongitude: 131.2558,
    ),
  ];

  static List<MonitoringRegion> get allSupported => supportedIndonesia;

  static MonitoringRegion findById(String id) {
    final cleanId = id.trim().toLowerCase();
    return supportedIndonesia.firstWhere(
      (r) => r.regionId == cleanId || cleanId.startsWith(r.regionId),
      orElse: () => supportedKalimantan.first,
    );
  }

  static MonitoringRegion? matchFromText(String text) {
    final lower = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (lower.isEmpty) return null;

    MonitoringRegion? best;
    int maxScore = 0;

    for (final r in supportedIndonesia) {
      final prov = r.province.toLowerCase();
      final regWord = r.regency
          .toLowerCase()
          .replaceAll('kota ', '')
          .replaceAll('kabupaten ', '')
          .trim();
      int score = 0;
      if (lower.contains(prov)) score += 150;

      if (lower.contains(regWord)) score += 120;

      if (lower.contains(r.regionId)) score += 100;

      final provWords = prov.split(' ').where((w) => w.length > 2).toList();
      if (provWords.length > 1 && provWords.every((w) => lower.contains(w))) {
        score += 130;
      }

      if (lower.contains('kalimantan') && !prov.contains('kalimantan')) score -= 2000;
      if (lower.contains('jawa') && !prov.contains('jawa')) score -= 2000;
      if (lower.contains('sumatera') && !prov.contains('sumatera')) score -= 2000;
      if (lower.contains('sulawesi') && !prov.contains('sulawesi')) score -= 2000;

      final direction = prov.split(' ').last;
      if (direction.length > 3 && lower.contains(direction)) score += 20;

      if (prov.contains('kalimantan')) score += 5;

      if (score > maxScore) {
        maxScore = score;
        best = r;
      }
    }
    return maxScore >= 50 ? best : null;
  }
}

class MonitoringSite {
  final String siteId; 
  final String sourceId;
  final String regionId;
  final String stationName;
  final String district;
  final double latitude;
  final double longitude;
  final ObservationType observationType;
  final bool isActive;

  const MonitoringSite({
    required this.siteId,
    required this.sourceId,
    required this.regionId,
    required this.stationName,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.observationType,
    this.isActive = true,
  });

  factory MonitoringSite.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
    String defaultSourceId = 'firestore_stored',
  }) {
    final region = (data['regionId'] as String?)?.trim() ?? 'kalteng';
    final name = (data['name'] as String?)?.trim() ?? 'Stasiun Pemantau';
    final lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (data['lng'] as num?)?.toDouble() ?? 0.0;

    return MonitoringSite(
      siteId: id,
      sourceId: defaultSourceId,
      regionId: region,
      stationName: name,
      district: name.replaceAll('Stasiun ', ''),
      latitude: lat,
      longitude: lng,
      observationType: ObservationType.station,
      isActive: true,
    );
  }

  static const List<MonitoringSite> defaultSites = [
    MonitoringSite(
      siteId: 'stn-kalteng-1',
      sourceId: 'firestore_stored',
      regionId: 'kalteng',
      stationName: 'Stasiun Palangka Raya',
      district: 'Palangka Raya',
      latitude: -2.2161,
      longitude: 113.9135,
      observationType: ObservationType.station,
    ),
    MonitoringSite(
      siteId: 'stn-kaltim-1',
      sourceId: 'firestore_stored',
      regionId: 'kaltim',
      stationName: 'Stasiun Samarinda',
      district: 'Samarinda',
      latitude: -0.5022,
      longitude: 117.1536,
      observationType: ObservationType.station,
    ),
    MonitoringSite(
      siteId: 'stn-kalbar-1',
      sourceId: 'firestore_stored',
      regionId: 'kalbar',
      stationName: 'Stasiun Pontianak',
      district: 'Pontianak',
      latitude: -0.0263,
      longitude: 109.3425,
      observationType: ObservationType.station,
    ),
    MonitoringSite(
      siteId: 'stn-kalsel-1',
      sourceId: 'firestore_stored',
      regionId: 'kalsel',
      stationName: 'Stasiun Banjarmasin',
      district: 'Banjarmasin',
      latitude: -3.3194,
      longitude: 114.5908,
      observationType: ObservationType.station,
    ),
    MonitoringSite(
      siteId: 'stn-kaltara-1',
      sourceId: 'firestore_stored',
      regionId: 'kaltara',
      stationName: 'Stasiun Tanjung Selor',
      district: 'Tanjung Selor',
      latitude: 2.8379,
      longitude: 117.3653,
      observationType: ObservationType.station,
    ),
  ];

  static List<MonitoringSite> getSitesForRegion(String regionId) {
    final clean = regionId.trim().toLowerCase();
    final sites = defaultSites.where((s) => s.regionId == clean).toList();
    if (sites.isNotEmpty) return sites;

    final isKnown = MonitoringRegion.supportedIndonesia.any((r) => r.regionId == clean);
    if (!isKnown) {
      return [defaultSites.first];
    }

    final reg = MonitoringRegion.findById(clean);
    return [
      MonitoringSite(
        siteId: 'stn-${reg.regionId}-1',
        sourceId: 'firestore_stored',
        regionId: reg.regionId,
        stationName: 'Stasiun ${reg.regency.replaceAll('Kota ', '').replaceAll('Kabupaten ', '')}',
        district: reg.regency,
        latitude: reg.defaultLatitude,
        longitude: reg.defaultLongitude,
        observationType: ObservationType.station,
      ),
    ];
  }

  static MonitoringSite getDefaultSiteForRegion(String regionId) {
    return getSitesForRegion(regionId).first;
  }
}

class AirReading {
  final String readingId;
  final String sourceId;
  final String siteId;
  final String regionId;
  final DateTime observedAt;
  final DateTime fetchedAt;
  final DateTime? createdAt;
  final ObservationType observationType;
  final bool isOfflineCache;

  final double? pm25;
  final double? pm10; 
  final double? co;
  final double? no2;
  final double? o3;

  final int? officialIspu;
  final String? categoryId; 
  final String? criticalPollutant;

  final double? temperature;
  final int? humidity;

  const AirReading({
    required this.readingId,
    required this.sourceId,
    required this.siteId,
    required this.regionId,
    required this.observedAt,
    required this.fetchedAt,
    this.createdAt,
    required this.observationType,
    this.isOfflineCache = false,
    this.pm25,
    this.pm10,
    this.co,
    this.no2,
    this.o3,
    this.officialIspu,
    this.categoryId,
    this.criticalPollutant,
    this.temperature,
    this.humidity,
  });

  factory AirReading.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
    String defaultSourceId = 'firestore_stored',
  }) {
    final region = (data['regionId'] as String?)?.trim() ?? '';
    final station = (data['stationId'] as String?)?.trim() ?? '';
    final ispuVal = (data['ispu'] as num?)?.toInt();
    final catId = (data['categoryId'] as String?)?.trim();

    DateTime measuredTime = DateTime.now();
    if (data['measuredAt'] != null) {
      final m = data['measuredAt'];
      if (m is DateTime) {
        measuredTime = m;
      } else if (m is int) {
        measuredTime = DateTime.fromMillisecondsSinceEpoch(m);
      } else {
        measuredTime = DateTime.tryParse(m.toString()) ?? DateTime.now();
      }
    }

    DateTime? createdTime;
    if (data['createdAt'] != null) {
      final c = data['createdAt'];
      if (c is DateTime) {
        createdTime = c;
      } else if (c is int) {
        createdTime = DateTime.fromMillisecondsSinceEpoch(c);
      } else {
        createdTime = DateTime.tryParse(c.toString());
      }
    }

    final double? pm25Val = (data['pm25'] as num?)?.toDouble();
    final double? pm10Val = (data['pm10'] as num?)?.toDouble();
    final double? coVal = (data['co'] as num?)?.toDouble();
    final double? no2Val = (data['no2'] as num?)?.toDouble();
    final double? o3Val = (data['o3'] as num?)?.toDouble();

    return AirReading(
      readingId: id,
      sourceId: defaultSourceId,
      siteId: station,
      regionId: region,
      observedAt: measuredTime,
      fetchedAt: DateTime.now(),
      createdAt: createdTime,
      observationType: ObservationType.station,
      officialIspu: ispuVal,
      categoryId: catId,
      pm25: pm25Val,
      pm10: pm10Val,
      co: coVal,
      no2: no2Val,
      o3: o3Val,
    );
  }

  IspuCategory get category {
    if (categoryId != null) {
      final c = categoryId!.toLowerCase();
      if (c.contains('baik')) return IspuCategory.baik;
      if (c.contains('sedang')) return IspuCategory.sedang;
      if (c.contains('sangat')) return IspuCategory.sangatTidakSehat;
      if (c.contains('tidak-sehat') || c.contains('tidak_sehat') || c.contains('tidak sehat')) {
        return IspuCategory.tidakSehat;
      }
      if (c.contains('bahaya')) return IspuCategory.berbahaya;
    }

    if (officialIspu != null) {
      final v = officialIspu!;
      if (v <= 50) return IspuCategory.baik;
      if (v <= 100) return IspuCategory.sedang;
      if (v <= 200) return IspuCategory.tidakSehat;
      if (v <= 300) return IspuCategory.sangatTidakSehat;
      return IspuCategory.berbahaya;
    }

    if (pm25 != null) {
      final v = pm25!;
      if (v <= 15.5) return IspuCategory.baik;
      if (v <= 55.4) return IspuCategory.sedang;
      if (v <= 150.4) return IspuCategory.tidakSehat;
      if (v <= 250.4) return IspuCategory.sangatTidakSehat;
      return IspuCategory.berbahaya;
    }

    return IspuCategory.tidakTersedia;
  }

  String get categoryLabel {
    switch (category) {
      case IspuCategory.baik:
        return 'Baik';
      case IspuCategory.sedang:
        return 'Sedang';
      case IspuCategory.tidakSehat:
        return 'Tidak Sehat';
      case IspuCategory.sangatTidakSehat:
        return 'Sangat Tidak Sehat';
      case IspuCategory.berbahaya:
        return 'Berbahaya';
      case IspuCategory.tidakTersedia:
        return 'Data Tidak Tersedia';
    }
  }

  String get provenanceText {
    switch (observationType) {
      case ObservationType.station:
        return 'Stasiun KLHK';
      case ObservationType.model:
        return 'Estimasi Pemodelan Satelit (Copernicus CAMS)';
      case ObservationType.sensor:
        return 'Sensor Komunitas (IoT)';
    }
  }

  String get formattedPm25 =>
      pm25 != null ? '${pm25!.toStringAsFixed(1).replaceAll('.', ',')} µg/m³' : 'Tidak tersedia';

  int get ispu => officialIspu ?? (pm25 != null ? pm25!.round() : 0);

  String get formattedIspuOrAqi {
    if (officialIspu != null) {
      return '$officialIspu ISPU';
    }
    if (pm25 != null) {
      return '${pm25!.toStringAsFixed(1).replaceAll('.', ',')} µg/m³';
    }
    return '--';
  }

  Map<String, dynamic> toJson() => {
        'readingId': readingId,
        'sourceId': sourceId,
        'siteId': siteId,
        'regionId': regionId,
        'observedAt': observedAt.toIso8601String(),
        'fetchedAt': fetchedAt.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'observationType': observationType.name,
        'isOfflineCache': isOfflineCache,
        'pm25': pm25,
        'pm10': pm10,
        'co': co,
        'no2': no2,
        'o3': o3,
        'officialIspu': officialIspu,
        'categoryId': categoryId,
        'criticalPollutant': criticalPollutant,
        'temperature': temperature,
        'humidity': humidity,
      };
  factory AirReading.fromJson(Map<String, dynamic> j) => AirReading(
        readingId: j['readingId'] as String? ?? '',
        sourceId: j['sourceId'] as String? ?? 'firestore_stored',
        siteId: j['siteId'] as String? ?? '',
        regionId: j['regionId'] as String? ?? '',
        observedAt: DateTime.tryParse(j['observedAt'] as String? ?? '') ?? DateTime.now(),
        fetchedAt: DateTime.tryParse(j['fetchedAt'] as String? ?? '') ?? DateTime.now(),
        createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt'] as String) : null,
        observationType: ObservationType.values.firstWhere(
          (e) => e.name == j['observationType'],
          orElse: () => ObservationType.station,
        ),
        isOfflineCache: j['isOfflineCache'] as bool? ?? true,
        pm25: (j['pm25'] as num?)?.toDouble(),
        pm10: (j['pm10'] as num?)?.toDouble(),
        co: (j['co'] as num?)?.toDouble(),
        no2: (j['no2'] as num?)?.toDouble(),
        o3: (j['o3'] as num?)?.toDouble(),
        officialIspu: (j['officialIspu'] as num?)?.toInt(),
        categoryId: j['categoryId'] as String?,
        criticalPollutant: j['criticalPollutant'] as String?,
        temperature: (j['temperature'] as num?)?.toDouble(),
        humidity: (j['humidity'] as num?)?.toInt(),
      );
}
