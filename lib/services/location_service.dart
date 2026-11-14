import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

enum GpsLocationStatus {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
  loading,
  unavailable,
  manualSelected,
}

class LocationResult {
  final String locationName;
  final double? lat;
  final double? lng;
  final bool isFromGps;
  final GpsLocationStatus status;
  final String? errorMessage;

  const LocationResult({
    required this.locationName,
    this.lat,
    this.lng,
    this.isFromGps = false,
    this.status = GpsLocationStatus.unavailable,
    this.errorMessage,
  });

  static const LocationResult fallback = LocationResult(
    locationName: 'Palangka Raya',
    isFromGps: false,
    status: GpsLocationStatus.manualSelected,
  );
}

class GeoSearchResult {
  final String displayName;
  final String name;
  final String? subdistrict;
  final String? cityOrRegency;
  final String? province;
  final double lat;
  final double lng;

  const GeoSearchResult({
    required this.displayName,
    required this.name,
    this.subdistrict,
    this.cityOrRegency,
    this.province,
    required this.lat,
    required this.lng,
  });
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  LocationResult? _lastResult;
  bool _isFetching = false;

  LocationResult? get lastResult => _lastResult;

  Future<LocationResult> getCurrentLocation() async {
    if (_isFetching) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _lastResult ?? LocationResult.fallback;
    }
    _isFetching = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] GPS tidak aktif');
        return const LocationResult(
          locationName: '',
          isFromGps: false,
          status: GpsLocationStatus.serviceDisabled,
          errorMessage: 'Layanan lokasi (GPS) pada perangkat sedang dinonaktifkan.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Izin ditolak');
          return const LocationResult(
            locationName: '',
            isFromGps: false,
            status: GpsLocationStatus.denied,
            errorMessage: 'Izin akses lokasi ditolak oleh pengguna.',
          );
        }
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Izin ditolak permanen');
        return const LocationResult(
          locationName: '',
          isFromGps: false,
          status: GpsLocationStatus.permanentlyDenied,
          errorMessage: 'Izin akses lokasi ditolak secara permanen. Buka pengaturan aplikasi untuk mengizinkan.',
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      debugPrint(
        '[LocationService] GPS: lat=${pos.latitude}, lng=${pos.longitude}',
      );

      final name = await _reverseGeocode(pos.latitude, pos.longitude);

      _lastResult = LocationResult(
        locationName: name,
        lat: pos.latitude,
        lng: pos.longitude,
        isFromGps: true,
        status: GpsLocationStatus.granted,
      );
      return _lastResult!;
    } catch (e) {
      debugPrint('[LocationService] Error: $e');
      return LocationResult(
        locationName: '',
        isFromGps: false,
        status: GpsLocationStatus.unavailable,
        errorMessage: 'Gagal memperoleh koordinat GPS: $e',
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<List<GeoSearchResult>> searchLocations(String query) async {
    final clean = query.trim();
    if (clean.length < 2) return [];

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(clean)}'
        '&countrycodes=id'
        '&format=json'
        '&addressdetails=1'
        '&limit=10'
        '&accept-language=id',
      );

      final resp = await http.get(url, headers: {
        'User-Agent': 'TeduhApp/1.0 (contact@teduh.app)',
      }).timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) return [];

      final list = jsonDecode(resp.body) as List<dynamic>;
      final results = <GeoSearchResult>[];

      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final address = map['address'] as Map<String, dynamic>? ?? {};
        final lat = double.tryParse(map['lat']?.toString() ?? '') ?? 0.0;
        final lon = double.tryParse(map['lon']?.toString() ?? '') ?? 0.0;

        final subdistrict = _pick(address, ['suburb', 'village', 'town', 'municipality']);
        final city = _pick(address, ['city', 'regency', 'county']);
        final province = _pick(address, ['state']);

        final displayName = (map['display_name'] as String?) ?? '';
        final name = (map['name'] as String?) ?? (subdistrict ?? city ?? clean);

        results.add(GeoSearchResult(
          displayName: displayName,
          name: name,
          subdistrict: subdistrict,
          cityOrRegency: city,
          province: province,
          lat: lat,
          lng: lon,
        ));
      }
      return results;
    } catch (e) {
      debugPrint('[LocationService] Search error: $e');
      return [];
    }
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat&lon=$lng&format=json&addressdetails=1&accept-language=id',
      );

      final resp = await http
          .get(url, headers: {'User-Agent': 'TeduhApp/1.0 (contact@teduh.app)'})
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) {
        debugPrint('[LocationService] Nominatim HTTP ${resp.statusCode}');
        return _fallbackCoordName(lat, lng);
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>? ?? {};

      final sub = _pick(address, [
        'village',        
        'suburb',          
        'town',            
        'municipality',
        'county',
      ]);

      final city = _pick(address, [
        'city',
        'regency',
        'county',
        'state_district',
        'state',
      ]);

      if (sub != null && city != null) {
        return '$sub, $city';
      } else if (city != null) {
        return city;
      } else {
        final display = data['display_name'] as String? ?? '';
        return _shortenDisplayName(display);
      }
    } catch (e) {
      debugPrint('[LocationService] Reverse geocode error: $e');
      return _fallbackCoordName(lat, lng);
    }
  }

  String? _pick(Map<String, dynamic> address, List<String> keys) {
    for (final k in keys) {
      final v = address[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  String _fallbackCoordName(double lat, double lng) {
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  String _shortenDisplayName(String displayName) {
    final parts = displayName.split(',');
    if (parts.length >= 2) {
      return '${parts[0].trim()}, ${parts[1].trim()}';
    }
    return displayName;
  }
}
