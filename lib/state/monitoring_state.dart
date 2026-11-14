import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/air_quality_models.dart';
import '../services/air_quality_repository.dart';

class MonitoringState extends ChangeNotifier {
  MonitoringState._();
  static final MonitoringState instance = MonitoringState._();

  MonitoringRegion _selectedRegion = MonitoringRegion.supportedKalimantan.first;
  MonitoringSite _selectedSite = MonitoringSite.defaultSites.first;
  final MonitoringSourceInfo _selectedSource = MonitoringSourceInfo.firestoreStored;

  AirReading? _currentReading;
  bool _isLoading = false;
  String? _errorMessage;

  MonitoringRegion get selectedRegion => _selectedRegion;
  MonitoringSite get selectedSite => _selectedSite;
  MonitoringSourceInfo get selectedSource => _selectedSource;
  AirReading? get currentReading => _currentReading;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get locationName => '${_selectedSite.stationName}, ${_selectedRegion.province}';

  int _activeRequestId = 0;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRegionId = prefs.getString('mon_region_id');
      final savedSiteId = prefs.getString('mon_site_id');

      if (savedRegionId != null) {
        _selectedRegion = MonitoringRegion.findById(savedRegionId);
      }
      if (savedSiteId != null) {
        final sites = MonitoringSite.getSitesForRegion(_selectedRegion.regionId);
        _selectedSite = sites.firstWhere(
          (s) => s.siteId == savedSiteId,
          orElse: () => MonitoringSite.getDefaultSiteForRegion(_selectedRegion.regionId),
        );
      } else {
        _selectedSite = MonitoringSite.getDefaultSiteForRegion(_selectedRegion.regionId);
      }
    } catch (e) {
      debugPrint('[MonitoringState] Gagal memuat preferensi monitoring: $e');
    }

    await refreshData();
  }

  Future<void> setRegion(MonitoringRegion region) async {
    if (_selectedRegion.regionId == region.regionId) return;

    _selectedRegion = region;
    _selectedSite = MonitoringSite.getDefaultSiteForRegion(region.regionId);
    _savePreferences();

    final cached = AirQualityRepository.instance.getCachedReading(
      site: _selectedSite,
      sourceId: _selectedSource.sourceId,
    );
    if (cached != null) {
      _currentReading = cached;
      _isLoading = false;
    } else {
      _currentReading = null;
      _isLoading = true;
    }
    notifyListeners();

    await refreshData();
  }

  Future<void> setSite(MonitoringSite site) async {
    if (_selectedSite.siteId == site.siteId) return;

    _selectedSite = site;
    _savePreferences();

    final cached = AirQualityRepository.instance.getCachedReading(
      site: _selectedSite,
      sourceId: _selectedSource.sourceId,
    );
    if (cached != null) {
      _currentReading = cached;
      _isLoading = false;
    } else {
      _currentReading = null;
      _isLoading = true;
    }
    notifyListeners();

    await refreshData();
  }

  Future<void> setCustomLocation({
    required String name,
    required double lat,
    required double lng,
  }) async {
    final matched = MonitoringRegion.matchFromText(name);
    if (matched != null) {
      _selectedRegion = matched;
    } else {
      _selectedRegion = MonitoringRegion(
        regionId: 'custom_${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}',
        province: name,
        regency: name,
        defaultLatitude: lat,
        defaultLongitude: lng,
      );
    }

    _selectedSite = MonitoringSite(
      siteId: 'site_${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}',
      sourceId: 'cams_openmeteo',
      regionId: _selectedRegion.regionId,
      stationName: name,
      district: name,
      latitude: lat,
      longitude: lng,
      observationType: ObservationType.model,
    );

    _savePreferences();

    final cached = AirQualityRepository.instance.getCachedReading(
      site: _selectedSite,
      sourceId: _selectedSource.sourceId,
    );
    if (cached != null) {
      _currentReading = cached;
      _isLoading = false;
    } else {
      _currentReading = null;
      _isLoading = true;
    }
    notifyListeners();

    await refreshData();
  }

  Future<void> setSource(MonitoringSourceInfo source) async {
    debugPrint('[MonitoringState] setSource dipanggil tetapi dinonaktifkan: sumber selalu KLHK.');
  }

  Future<void> refreshData() async {
    final int requestId = ++_activeRequestId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reading = await AirQualityRepository.instance.getCurrentReading(
        site: _selectedSite,
        sourceId: _selectedSource.sourceId,
      );

      if (requestId != _activeRequestId) return;

      _currentReading = reading;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (requestId != _activeRequestId) return;
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mon_region_id', _selectedRegion.regionId);
      await prefs.setString('mon_site_id', _selectedSite.siteId);
    } catch (_) {}
  }
}
