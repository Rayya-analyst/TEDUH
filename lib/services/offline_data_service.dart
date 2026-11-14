import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/emergency_contacts.dart';
import '../models/air_quality_models.dart';
import '../services/ai/teduh_knowledge_base.dart';
import '../state/monitoring_state.dart';

enum OfflinePackageStatus { notDownloaded, downloading, downloaded, failed, stale }

class OfflinePackage {
  final String regionId;
  final String regionName;
  final OfflinePackageStatus status;
  final DateTime? downloadedAt;
  final int? sizeBytes;
  final double progress;
  final String? errorMessage;
  final Map<String, dynamic>? cachedData;

  const OfflinePackage({
    required this.regionId,
    required this.regionName,
    this.status = OfflinePackageStatus.notDownloaded,
    this.downloadedAt,
    this.sizeBytes,
    this.progress = 0.0,
    this.errorMessage,
    this.cachedData,
  });

  bool get isStale =>
      downloadedAt != null &&
      DateTime.now().difference(downloadedAt!) > const Duration(hours: 24);

  OfflinePackageStatus get effectiveStatus =>
      status == OfflinePackageStatus.downloaded && isStale
          ? OfflinePackageStatus.stale
          : status;

  String get statusLabel {
    switch (effectiveStatus) {
      case OfflinePackageStatus.notDownloaded:
        return 'Belum diunduh';
      case OfflinePackageStatus.downloading:
        return 'Mengunduh ${(progress * 100).toStringAsFixed(0)}%';
      case OfflinePackageStatus.downloaded:
        return 'Terunduh${downloadedAt != null ? ' · ${_relativeTime(downloadedAt!)}' : ''}';
      case OfflinePackageStatus.stale:
        return 'Kedaluwarsa · ${_relativeTime(downloadedAt!)}';
      case OfflinePackageStatus.failed:
        return 'Gagal: ${errorMessage ?? 'Coba lagi'}';
    }
  }

  String get sizeLabel {
    if (sizeBytes == null) return '';
    if (sizeBytes! < 1024) return '${sizeBytes}B';
    if (sizeBytes! < 1024 * 1024) return '${(sizeBytes! / 1024).toStringAsFixed(0)}KB';
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  AirReading? get cachedReading {
    if (cachedData == null) return null;
    try {
      final r = cachedData!['reading'];
      if (r == null) return null;
      return AirReading.fromJson(r as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  Map<String, dynamic> toJson() => {
        'regionId': regionId,
        'regionName': regionName,
        'status': status.name,
        'downloadedAt': downloadedAt?.toIso8601String(),
        'sizeBytes': sizeBytes,
        'cachedData': cachedData,
      };

  factory OfflinePackage.fromJson(Map<String, dynamic> j) => OfflinePackage(
        regionId: j['regionId'] as String,
        regionName: j['regionName'] as String,
        status: OfflinePackageStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => OfflinePackageStatus.notDownloaded,
        ),
        downloadedAt: j['downloadedAt'] != null
            ? DateTime.tryParse(j['downloadedAt'] as String)
            : null,
        sizeBytes: j['sizeBytes'] as int?,
        cachedData: j['cachedData'] as Map<String, dynamic>?,
      );

  OfflinePackage copyWith({
    OfflinePackageStatus? status,
    DateTime? downloadedAt,
    int? sizeBytes,
    double? progress,
    String? errorMessage,
    Map<String, dynamic>? cachedData,
  }) =>
      OfflinePackage(
        regionId: regionId,
        regionName: regionName,
        status: status ?? this.status,
        downloadedAt: downloadedAt ?? this.downloadedAt,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        progress: progress ?? this.progress,
        errorMessage: errorMessage ?? this.errorMessage,
        cachedData: cachedData ?? this.cachedData,
      );
}

class OfflineDataService extends ChangeNotifier {
  OfflineDataService._();
  static final OfflineDataService instance = OfflineDataService._();

  static const String _prefPrefix = 'offline_pkg_';

  final Map<String, OfflinePackage> _packages = {};

  List<OfflinePackage> get allPackages => _packages.values.toList();

  OfflinePackage? getPackage(String regionId) => _packages[regionId];

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final region in MonitoringRegion.allSupported) {
        final raw = prefs.getString('$_prefPrefix${region.regionId}');
        if (raw != null) {
          try {
            final pkg = OfflinePackage.fromJson(
                jsonDecode(raw) as Map<String, dynamic>);
            _packages[region.regionId] = pkg;
          } catch (_) {
            _packages[region.regionId] = OfflinePackage(
              regionId: region.regionId,
              regionName: region.province,
            );
          }
        } else {
          _packages[region.regionId] = OfflinePackage(
            regionId: region.regionId,
            regionName: region.province,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[OfflineDataService] Gagal inisialisasi: $e');
    }
  }

  Future<void> downloadPackage(String regionId) async {
    final existing = _packages[regionId];
    if (existing?.status == OfflinePackageStatus.downloading) return;

    final regionName = MonitoringRegion.allSupported
        .firstWhere((r) => r.regionId == regionId,
            orElse: () => MonitoringRegion.allSupported.first)
        .province;

    _packages[regionId] = OfflinePackage(
      regionId: regionId,
      regionName: regionName,
      status: OfflinePackageStatus.downloading,
      progress: 0.0,
    );
    notifyListeners();

    try {

      _updateProgress(regionId, 0.2);
      final reading = MonitoringState.instance.currentReading;

      _updateProgress(regionId, 0.4);
      final kb = TeduhKnowledgeBase.instance;
      final panduanMasker = kb.retrieve(query: 'masker N95').take(2).map((r) => {
            'title': r.document.title,
            'content': r.document.content,
            'source': r.document.source,
          }).toList();
      final panduanRuangAman = kb.retrieve(query: 'ruang aman').take(2).map((r) => {
            'title': r.document.title,
            'content': r.document.content,
            'source': r.document.source,
          }).toList();
      final panduanKarhutla = kb.retrieve(query: 'karhutla kebakaran').take(2).map((r) => {
            'title': r.document.title,
            'content': r.document.content,
            'source': r.document.source,
          }).toList();

      _updateProgress(regionId, 0.6);
      final contacts = EmergencyContacts.getForRegion(regionId)
          .map((c) => {
                'name': c.name,
                'function': c.function,
                'phone': c.phone,
                'address': c.address,
                'verified': c.verified,
                'verifiedNote': c.verifiedNote,
                'sourceUrl': c.sourceUrl,
              })
          .toList();

      _updateProgress(regionId, 0.8);
      final cat = reading?.category ?? IspuCategory.tidakTersedia;
      final rekomendasi = _rekomendasiFor(cat, reading);

      _updateProgress(regionId, 0.95);
      final data = {
        'downloadedAt': DateTime.now().toIso8601String(),
        'regionId': regionId,
        'regionName': regionName,
        'reading': reading?.toJson(),
        'panduan': {
          'masker': panduanMasker,
          'ruangAman': panduanRuangAman,
          'karhutla': panduanKarhutla,
        },
        'contacts': contacts,
        'rekomendasi': rekomendasi,
        'cachedAt': DateTime.now().toIso8601String(),
      };

      final encoded = jsonEncode(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefPrefix$regionId', jsonEncode({
        'regionId': regionId,
        'regionName': regionName,
        'status': OfflinePackageStatus.downloaded.name,
        'downloadedAt': DateTime.now().toIso8601String(),
        'sizeBytes': encoded.length,
        'cachedData': data,
      }));

      _packages[regionId] = OfflinePackage(
        regionId: regionId,
        regionName: regionName,
        status: OfflinePackageStatus.downloaded,
        downloadedAt: DateTime.now(),
        sizeBytes: encoded.length,
        progress: 1.0,
        cachedData: data,
      );
      notifyListeners();
      debugPrint('[OfflineDataService] Package $regionId berhasil diunduh (${encoded.length} bytes)');
    } catch (e) {
      final prev = _packages[regionId];
      _packages[regionId] = OfflinePackage(
        regionId: regionId,
        regionName: regionName,
        status: prev?.cachedData != null
            ? OfflinePackageStatus.downloaded
            : OfflinePackageStatus.failed,
        downloadedAt: prev?.downloadedAt,
        sizeBytes: prev?.sizeBytes,
        progress: 0.0,
        errorMessage: 'Gagal mengunduh: $e',
        cachedData: prev?.cachedData,
      );
      notifyListeners();
      debugPrint('[OfflineDataService] Gagal unduh $regionId: $e');
    }
  }

  void _updateProgress(String regionId, double progress) {
    final pkg = _packages[regionId];
    if (pkg == null) return;
    _packages[regionId] = pkg.copyWith(progress: progress);
    notifyListeners();
  }

  Future<void> cacheLatestReading(String regionId, AirReading reading) async {
    try {
      final pkg = _packages[regionId];
      if (pkg == null || pkg.status != OfflinePackageStatus.downloaded) return;

      final updatedData = Map<String, dynamic>.from(pkg.cachedData ?? {});
      updatedData['reading'] = reading.toJson();
      updatedData['cachedAt'] = DateTime.now().toIso8601String();

      final updated = pkg.copyWith(cachedData: updatedData);
      _packages[regionId] = updated;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefPrefix$regionId', jsonEncode(updated.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('[OfflineDataService] Gagal cache reading: $e');
    }
  }

  Future<void> deletePackage(String regionId) async {
    try {
      final pkg = _packages[regionId];
      final regionName = pkg?.regionName ?? regionId;

      _packages[regionId] = OfflinePackage(
        regionId: regionId,
        regionName: regionName,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefPrefix$regionId');
      notifyListeners();
    } catch (e) {
      debugPrint('[OfflineDataService] Gagal hapus package $regionId: $e');
    }
  }

  AirReading? getCachedReading(String regionId) =>
      _packages[regionId]?.cachedReading;

  bool hasData(String regionId) {
    final pkg = _packages[regionId];
    return pkg != null &&
        (pkg.status == OfflinePackageStatus.downloaded ||
            pkg.status == OfflinePackageStatus.stale ||
            pkg.effectiveStatus == OfflinePackageStatus.stale);
  }

  Map<String, String> _rekomendasiFor(IspuCategory cat, AirReading? reading) {
    switch (cat) {
      case IspuCategory.baik:
        return {
          'ringkasan': 'Kualitas udara baik. Aman beraktivitas di luar.',
          'tindakan': 'Lanjutkan aktivitas normal. Pantau kondisi secara berkala.',
        };
      case IspuCategory.sedang:
        return {
          'ringkasan': 'Kualitas udara sedang. Kelompok sensitif perlu berhati-hati.',
          'tindakan': 'Kurangi aktivitas berat di luar untuk anak-anak, lansia, dan penderita asma.',
        };
      case IspuCategory.tidakSehat:
        return {
          'ringkasan': 'Kualitas udara tidak sehat. Batasi aktivitas luar.',
          'tindakan': 'Gunakan masker N95 jika keluar. Kurangi waktu di luar. Tutup jendela dan pintu.',
        };
      case IspuCategory.sangatTidakSehat:
        return {
          'ringkasan': 'Kualitas udara sangat tidak sehat. Hindari aktivitas luar.',
          'tindakan': 'Tetap di dalam. Gunakan HEPA purifier. Hubungi BPBD jika gejala sesak.',
        };
      case IspuCategory.berbahaya:
        return {
          'ringkasan': 'Kualitas udara berbahaya. Darurat kesehatan.',
          'tindakan': 'Jangan keluar rumah. Cari ruang aman. Hubungi 119 jika ada gejala berat.',
        };
      case IspuCategory.tidakTersedia:
        return {
          'ringkasan': 'Data ISPU belum tersedia.',
          'tindakan': 'Pantau kondisi setelah data tersedia dari stasiun KLHK.',
        };
    }
  }
}

