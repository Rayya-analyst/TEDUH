import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../services/location_service.dart';
import '../state/app_settings.dart';
import '../state/monitoring_state.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';

class _MC {
  static const bg = Color(0xFFF5F8F4);
  static const dark = Color(0xFF1F4D3A);
  static const darkText = Color(0xFF1F3D2F);
  static const greenTitle = Color(0xFF17664C);
  static const green = Color(0xFF0F7B4F);
  static const button = Color(0xFF1B6B58);
  static const grey = Color(0xFF8A9A91);
  static const greyLight = Color(0xFF9AA59F);
  static const softLeaf = Color(0xFFE2EFDF);
  static const hint = Color(0xFF7C8B82);
}

List<String> _districtsFor(String loc) {
  final l = loc.toLowerCase();
  if (l.contains('malang')) {
    return ['Lowokwaru', 'Klojen', 'Blimbing', 'Sukun', 'Kedungkandang'];
  } else if (l.contains('palangka') || l.contains('jekan') || l.contains('tengah')) {
    return ['Jekan Raya', 'Pahandut', 'Bukit Batu', 'Sabangau', 'Rakumpit'];
  } else if (l.contains('jakarta')) {
    return ['Kebayoran Baru', 'Setiabudi', 'Menteng', 'Tebet', 'Cilandak'];
  } else if (l.contains('surabaya')) {
    return ['Tegalsari', 'Gubeng', 'Wonokromo', 'Rungkut', 'Sukolilo'];
  } else if (l.contains('bandung')) {
    return ['Coblong', 'Sumur Bandung', 'Cicendo', 'Lengkong', 'Sukajadi'];
  } else if (l.contains('banjar') || l.contains('selatan')) {
    return ['Banjarmasin Tengah', 'Banjarmasin Selatan', 'Martapura', 'Banjarbaru'];
  } else if (l.contains('kubu') || l.contains('pontianak') || l.contains('barat')) {
    return ['Pontianak Kota', 'Pontianak Selatan', 'Sungai Raya', 'Kubu'];
  } else if (l.contains('bulungan') || l.contains('tarakan') || l.contains('utara')) {
    return ['Tanjung Selor', 'Tarakan Barat', 'Tarakan Tengah', 'Bunyu'];
  } else if (l.contains('samarinda') || l.contains('timur') || l.contains('kaltim')) {
    return ['Samarinda Kota', 'Sungai Kunjang', 'Samarinda Ulu', 'Palaran'];
  }
  final mainArea = loc.split(',').first.trim();
  return [
    if (mainArea.isNotEmpty) mainArea else 'Pusat Kota',
    'Area Utara',
    'Area Selatan',
    'Area Timur',
    'Area Barat',
  ];
}

class _AqData {
  final int ispu;
  final List<double> tinggi;
  final List<Color> warna;
  const _AqData(this.ispu, this.tinggi, this.warna);
}

const List<Color> _palet = [
  Color(0xFFB9D8B7),
  Color(0xFFE8CC6C),
  Color(0xFFE8A57A),
  Color(0xFFC98B87),
  Color(0xFFE9454B),
];

Color _warnaSkala(double t) {
  final x = t.clamp(0.0, 1.0) * (_palet.length - 1);
  final i = x.floor().clamp(0, _palet.length - 2);
  return Color.lerp(_palet[i], _palet[i + 1], x - i)!;
}

_AqData _aqFromIspu(int ispu) {
  final barH = 13 + 16.4 * (ispu / 400).clamp(0.0, 1.0);
  final barColor = _warnaSkala(ispu / 400);
  return _AqData(
    ispu,
    List.filled(12, barH),
    List.filled(12, barColor),
  );
}

class _IndoLocationEntry {
  final String name;
  final String province;
  final String island;
  final double lat;
  final double lng;
  final bool isCapital;

  const _IndoLocationEntry({
    required this.name,
    required this.province,
    required this.island,
    required this.lat,
    required this.lng,
    this.isCapital = false,
  });
}

const List<_IndoLocationEntry> _kIndoLocations = [
  _IndoLocationEntry(name: 'Kota Palangka Raya', province: 'Kalimantan Tengah', island: 'Kalimantan', lat: -2.2161, lng: 113.9135, isCapital: true),
  _IndoLocationEntry(name: 'Sampit (Kotawaringin Timur)', province: 'Kalimantan Tengah', island: 'Kalimantan', lat: -2.5323, lng: 112.9547),
  _IndoLocationEntry(name: 'Pangkalan Bun (Kotawaringin Barat)', province: 'Kalimantan Tengah', island: 'Kalimantan', lat: -2.6833, lng: 111.6167),
  _IndoLocationEntry(name: 'Kuala Kapuas', province: 'Kalimantan Tengah', island: 'Kalimantan', lat: -3.0091, lng: 114.3876),
  _IndoLocationEntry(name: 'Kota Samarinda', province: 'Kalimantan Timur', island: 'Kalimantan', lat: -0.5022, lng: 117.1536, isCapital: true),
  _IndoLocationEntry(name: 'Kota Balikpapan', province: 'Kalimantan Timur', island: 'Kalimantan', lat: -1.2654, lng: 116.8312),
  _IndoLocationEntry(name: 'IKN Nusantara (Sepaku)', province: 'Kalimantan Timur', island: 'Kalimantan', lat: -0.9634, lng: 116.7093),
  _IndoLocationEntry(name: 'Kota Bontang', province: 'Kalimantan Timur', island: 'Kalimantan', lat: 0.1333, lng: 117.5000),
  _IndoLocationEntry(name: 'Tenggarong (Kutai Kartanegara)', province: 'Kalimantan Timur', island: 'Kalimantan', lat: -0.4144, lng: 116.9911),
  _IndoLocationEntry(name: 'Kota Pontianak', province: 'Kalimantan Barat', island: 'Kalimantan', lat: -0.0263, lng: 109.3425, isCapital: true),
  _IndoLocationEntry(name: 'Kota Singkawang', province: 'Kalimantan Barat', island: 'Kalimantan', lat: 0.9071, lng: 108.9859),
  _IndoLocationEntry(name: 'Sungai Raya (Kubu Raya)', province: 'Kalimantan Barat', island: 'Kalimantan', lat: -0.0931, lng: 109.3789),
  _IndoLocationEntry(name: 'Ketapang', province: 'Kalimantan Barat', island: 'Kalimantan', lat: -1.8344, lng: 109.9706),
  _IndoLocationEntry(name: 'Kota Banjarmasin', province: 'Kalimantan Selatan', island: 'Kalimantan', lat: -3.3194, lng: 114.5908, isCapital: true),
  _IndoLocationEntry(name: 'Kota Banjarbaru', province: 'Kalimantan Selatan', island: 'Kalimantan', lat: -3.4402, lng: 114.8306),
  _IndoLocationEntry(name: 'Martapura (Kabupaten Banjar)', province: 'Kalimantan Selatan', island: 'Kalimantan', lat: -3.4117, lng: 114.8572),
  _IndoLocationEntry(name: 'Tanjung Selor (Bulungan)', province: 'Kalimantan Utara', island: 'Kalimantan', lat: 2.8379, lng: 117.3653, isCapital: true),
  _IndoLocationEntry(name: 'Kota Tarakan', province: 'Kalimantan Utara', island: 'Kalimantan', lat: 3.3274, lng: 117.5925),
  _IndoLocationEntry(name: 'Nunukan', province: 'Kalimantan Utara', island: 'Kalimantan', lat: 4.1350, lng: 117.6483),

  _IndoLocationEntry(name: 'Kota Jakarta Pusat', province: 'DKI Jakarta', island: 'Jawa', lat: -6.1751, lng: 106.8650, isCapital: true),
  _IndoLocationEntry(name: 'Kota Jakarta Selatan', province: 'DKI Jakarta', island: 'Jawa', lat: -6.2615, lng: 106.8106),
  _IndoLocationEntry(name: 'Kota Jakarta Barat', province: 'DKI Jakarta', island: 'Jawa', lat: -6.1683, lng: 106.7588),
  _IndoLocationEntry(name: 'Kota Jakarta Timur', province: 'DKI Jakarta', island: 'Jawa', lat: -6.2250, lng: 106.9004),
  _IndoLocationEntry(name: 'Kota Jakarta Utara', province: 'DKI Jakarta', island: 'Jawa', lat: -6.1214, lng: 106.7741),
  _IndoLocationEntry(name: 'Kota Bandung', province: 'Jawa Barat', island: 'Jawa', lat: -6.9175, lng: 107.6191, isCapital: true),
  _IndoLocationEntry(name: 'Kota Bogor', province: 'Jawa Barat', island: 'Jawa', lat: -6.5971, lng: 106.8060),
  _IndoLocationEntry(name: 'Kota Bekasi', province: 'Jawa Barat', island: 'Jawa', lat: -6.2383, lng: 106.9756),
  _IndoLocationEntry(name: 'Kota Depok', province: 'Jawa Barat', island: 'Jawa', lat: -6.4025, lng: 106.7942),
  _IndoLocationEntry(name: 'Kota Tangerang', province: 'Banten', island: 'Jawa', lat: -6.1783, lng: 106.6319),
  _IndoLocationEntry(name: 'Kota Tangerang Selatan', province: 'Banten', island: 'Jawa', lat: -6.2889, lng: 106.7179),
  _IndoLocationEntry(name: 'Kota Serang', province: 'Banten', island: 'Jawa', lat: -6.1104, lng: 106.1640, isCapital: true),
  _IndoLocationEntry(name: 'Kota Cirebon', province: 'Jawa Barat', island: 'Jawa', lat: -6.7320, lng: 108.5523),
  _IndoLocationEntry(name: 'Kota Tasikmalaya', province: 'Jawa Barat', island: 'Jawa', lat: -7.3274, lng: 108.2207),
  _IndoLocationEntry(name: 'Kota Semarang', province: 'Jawa Tengah', island: 'Jawa', lat: -6.9667, lng: 110.4167, isCapital: true),
  _IndoLocationEntry(name: 'Kota Surakarta (Solo)', province: 'Jawa Tengah', island: 'Jawa', lat: -7.5755, lng: 110.8243),
  _IndoLocationEntry(name: 'Kota Yogyakarta', province: 'D.I. Yogyakarta', island: 'Jawa', lat: -7.7956, lng: 110.3695, isCapital: true),
  _IndoLocationEntry(name: 'Purwokerto (Banyumas)', province: 'Jawa Tengah', island: 'Jawa', lat: -7.4244, lng: 109.2303),
  _IndoLocationEntry(name: 'Kota Tegal', province: 'Jawa Tengah', island: 'Jawa', lat: -6.8694, lng: 109.1402),
  _IndoLocationEntry(name: 'Kota Magelang', province: 'Jawa Tengah', island: 'Jawa', lat: -7.4706, lng: 110.2178),
  _IndoLocationEntry(name: 'Kota Surabaya', province: 'Jawa Timur', island: 'Jawa', lat: -7.2575, lng: 112.7521, isCapital: true),
  _IndoLocationEntry(name: 'Kota Malang', province: 'Jawa Timur', island: 'Jawa', lat: -7.9839, lng: 112.6214),
  _IndoLocationEntry(name: 'Kota Batu', province: 'Jawa Timur', island: 'Jawa', lat: -7.8712, lng: 112.5270),
  _IndoLocationEntry(name: 'Kota Kediri', province: 'Jawa Timur', island: 'Jawa', lat: -7.8480, lng: 112.0178),
  _IndoLocationEntry(name: 'Kota Madiun', province: 'Jawa Timur', island: 'Jawa', lat: -7.6298, lng: 111.5239),
  _IndoLocationEntry(name: 'Jember', province: 'Jawa Timur', island: 'Jawa', lat: -8.1724, lng: 113.7007),
  _IndoLocationEntry(name: 'Banyuwangi', province: 'Jawa Timur', island: 'Jawa', lat: -8.2192, lng: 114.3691),

  _IndoLocationEntry(name: 'Kota Medan', province: 'Sumatera Utara', island: 'Sumatera', lat: 3.5952, lng: 98.6722, isCapital: true),
  _IndoLocationEntry(name: 'Kota Pekanbaru', province: 'Riau', island: 'Sumatera', lat: 0.5071, lng: 101.4478, isCapital: true),
  _IndoLocationEntry(name: 'Kota Dumai', province: 'Riau', island: 'Sumatera', lat: 1.6667, lng: 101.4500),
  _IndoLocationEntry(name: 'Kota Palembang', province: 'Sumatera Selatan', island: 'Sumatera', lat: -2.9761, lng: 104.7754, isCapital: true),
  _IndoLocationEntry(name: 'Kota Padang', province: 'Sumatera Barat', island: 'Sumatera', lat: -0.9471, lng: 100.4172, isCapital: true),
  _IndoLocationEntry(name: 'Kota Bukittinggi', province: 'Sumatera Barat', island: 'Sumatera', lat: -0.3056, lng: 100.3694),
  _IndoLocationEntry(name: 'Kota Bandar Lampung', province: 'Lampung', island: 'Sumatera', lat: -5.4500, lng: 105.2667, isCapital: true),
  _IndoLocationEntry(name: 'Kota Batam', province: 'Kepulauan Riau', island: 'Sumatera', lat: 1.1301, lng: 104.0529),
  _IndoLocationEntry(name: 'Kota Tanjungpinang', province: 'Kepulauan Riau', island: 'Sumatera', lat: 0.9167, lng: 104.4500, isCapital: true),
  _IndoLocationEntry(name: 'Kota Jambi', province: 'Jambi', island: 'Sumatera', lat: -1.6101, lng: 103.6131, isCapital: true),
  _IndoLocationEntry(name: 'Kota Bengkulu', province: 'Bengkulu', island: 'Sumatera', lat: -3.8004, lng: 102.2655, isCapital: true),
  _IndoLocationEntry(name: 'Kota Banda Aceh', province: 'Aceh', island: 'Sumatera', lat: 5.5483, lng: 95.3238, isCapital: true),
  _IndoLocationEntry(name: 'Kota Pangkalpinang', province: 'Kep. Bangka Belitung', island: 'Sumatera', lat: -2.1333, lng: 106.1167, isCapital: true),

  _IndoLocationEntry(name: 'Kota Makassar', province: 'Sulawesi Selatan', island: 'Sulawesi', lat: -5.1477, lng: 119.4327, isCapital: true),
  _IndoLocationEntry(name: 'Kota Manado', province: 'Sulawesi Utara', island: 'Sulawesi', lat: 1.4748, lng: 124.8421, isCapital: true),
  _IndoLocationEntry(name: 'Kota Palu', province: 'Sulawesi Tengah', island: 'Sulawesi', lat: -0.9003, lng: 119.8779, isCapital: true),
  _IndoLocationEntry(name: 'Kota Kendari', province: 'Sulawesi Tenggara', island: 'Sulawesi', lat: -3.9985, lng: 122.5126, isCapital: true),
  _IndoLocationEntry(name: 'Kota Gorontalo', province: 'Gorontalo', island: 'Sulawesi', lat: 0.5435, lng: 123.0568, isCapital: true),
  _IndoLocationEntry(name: 'Kota Mamuju', province: 'Sulawesi Barat', island: 'Sulawesi', lat: -2.6775, lng: 118.8875, isCapital: true),

  _IndoLocationEntry(name: 'Kota Denpasar', province: 'Bali', island: 'Bali & Nusa Tenggara', lat: -8.6705, lng: 115.2126, isCapital: true),
  _IndoLocationEntry(name: 'Badung (Kuta)', province: 'Bali', island: 'Bali & Nusa Tenggara', lat: -8.7233, lng: 115.1725),
  _IndoLocationEntry(name: 'Kota Mataram', province: 'Nusa Tenggara Barat', island: 'Bali & Nusa Tenggara', lat: -8.5833, lng: 116.1167, isCapital: true),
  _IndoLocationEntry(name: 'Kota Kupang', province: 'Nusa Tenggara Timur', island: 'Bali & Nusa Tenggara', lat: -10.1772, lng: 123.6070, isCapital: true),
  _IndoLocationEntry(name: 'Labuan Bajo', province: 'Nusa Tenggara Timur', island: 'Bali & Nusa Tenggara', lat: -8.4964, lng: 119.8877),

  _IndoLocationEntry(name: 'Kota Ambon', province: 'Maluku', island: 'Maluku & Papua', lat: -3.6547, lng: 128.1906, isCapital: true),
  _IndoLocationEntry(name: 'Kota Ternate', province: 'Maluku Utara', island: 'Maluku & Papua', lat: 0.7906, lng: 127.3842, isCapital: true),
  _IndoLocationEntry(name: 'Kota Jayapura', province: 'Papua', island: 'Maluku & Papua', lat: -2.5916, lng: 140.6690, isCapital: true),
  _IndoLocationEntry(name: 'Kota Sorong', province: 'Papua Barat Daya', island: 'Maluku & Papua', lat: -0.8762, lng: 131.2558, isCapital: true),
  _IndoLocationEntry(name: 'Manokwari', province: 'Papua Barat', island: 'Maluku & Papua', lat: -0.8615, lng: 134.0620, isCapital: true),
  _IndoLocationEntry(name: 'Merauke', province: 'Papua Selatan', island: 'Maluku & Papua', lat: -8.4991, lng: 140.4011, isCapital: true),
  _IndoLocationEntry(name: 'Timika (Mimika)', province: 'Papua Tengah', island: 'Maluku & Papua', lat: -4.5468, lng: 136.8837, isCapital: true),
  _IndoLocationEntry(name: 'Wamena (Jayawijaya)', province: 'Papua Pegunungan', island: 'Maluku & Papua', lat: -4.0981, lng: 138.9442, isCapital: true),
];

class _UnifiedSearchResult {
  final String name;
  final String subtitle;
  final double lat;
  final double lng;
  final bool isCapital;

  const _UnifiedSearchResult({
    required this.name,
    required this.subtitle,
    required this.lat,
    required this.lng,
    this.isCapital = false,
  });
}

class _LocationSearchModal extends StatefulWidget {
  final void Function(String name, double lat, double lng) onSelected;
  const _LocationSearchModal({required this.onSelected});

  @override
  State<_LocationSearchModal> createState() => _LocationSearchModalState();
}

class _LocationSearchModalState extends State<_LocationSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  List<_IndoLocationEntry> _filteredLocal = [];
  List<GeoSearchResult> _onlineResults = [];
  bool _isLoading = false;
  bool _isGpsLoading = false;
  String? _gpsError;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredLocal = [];
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    _activeQuery = q;

    if (q.isEmpty) {
      _debounceTimer?.cancel();
      setState(() {
        _filteredLocal = [];
        _onlineResults = [];
        _isLoading = false;
      });
      return;
    }

    final matched = _kIndoLocations.where((loc) {
      return loc.name.toLowerCase().contains(q) ||
          loc.province.toLowerCase().contains(q) ||
          loc.island.toLowerCase().contains(q);
    }).toList();

    setState(() {
      _filteredLocal = matched;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      _fetchOnline(query);
    });
  }

  void _executeSearch(String query) {
    _searchFocusNode.unfocus();
    _debounceTimer?.cancel();
    final q = query.trim().toLowerCase();
    _activeQuery = q;

    if (q.isEmpty) return;

    final matched = _kIndoLocations.where((loc) {
      return loc.name.toLowerCase().contains(q) ||
          loc.province.toLowerCase().contains(q) ||
          loc.island.toLowerCase().contains(q);
    }).toList();

    setState(() {
      _filteredLocal = matched;
      _isLoading = true;
    });

    _fetchOnline(query);
  }

  Future<void> _fetchOnline(String query) async {
    final q = query.trim();
    if (q.length < 2) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await LocationService.instance.searchLocations(q);
      if (mounted) {
        setState(() {
          _onlineResults = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _useGps() async {
    setState(() {
      _isGpsLoading = true;
      _gpsError = null;
    });

    final res = await LocationService.instance.getCurrentLocation();
    if (!mounted) return;

    if (res.lat != null && res.lng != null) {
      Navigator.pop(context);
      widget.onSelected(res.locationName, res.lat!, res.lng!);
    } else {
      setState(() {
        _isGpsLoading = false;
        _gpsError = res.errorMessage ?? 'Gagal mengambil koordinat GPS. Pastikan GPS aktif.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.84,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE3E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F2EC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_searching_rounded, color: Color(0xFF17664C), size: 19),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cari Lokasi di Indonesia',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F3D2F),
                            ),
                          ),
                          Text(
                            'Mendukung seluruh 38 provinsi, kota, dan koordinat GPS',
                            style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF7C8B82)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF7C8B82)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F7F5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDFE9E4)),
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.search_rounded, color: Color(0xFF1B6B58), size: 22),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                autofocus: true,
                                textInputAction: TextInputAction.search,
                                onSubmitted: _executeSearch,
                                onChanged: _onSearchChanged,
                                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1F3D2F)),
                                decoration: InputDecoration(
                                  hintText: 'Ketik kota, kabupaten, kecamatan...',
                                  hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF8A9A91)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF7A8C84)),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: const Color(0xFF1B6B58),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _executeSearch(_searchController.text),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: Text(
                            'Cari',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: const Color(0xFFE9F4EE),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isGpsLoading ? null : _useGps,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          _isGpsLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B6B58)),
                                )
                              : const Icon(Icons.my_location_rounded, size: 19, color: Color(0xFF1B6B58)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isGpsLoading ? 'Mendeteksi sinyal GPS aktual...' : 'Gunakan Lokasi GPS Saat Ini',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF17664C),
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF1B6B58)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_gpsError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                  child: Text(
                    _gpsError!,
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFE5384B)),
                  ),
                ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    color: Color(0xFF1B6B58),
                  ),
                ),
              const SizedBox(height: 6),
              Expanded(
                child: _buildResultsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final hasSearch = _activeQuery.isNotEmpty;

    if (hasSearch) {
      final List<_UnifiedSearchResult> unified = [];
      final Set<String> seen = {};

      for (final loc in _filteredLocal) {
        final key = loc.name.toLowerCase().trim();
        if (!seen.contains(key)) {
          seen.add(key);
          unified.add(_UnifiedSearchResult(
            name: loc.name,
            subtitle: '${loc.province} · Model CAMS & Hotspot',
            lat: loc.lat,
            lng: loc.lng,
            isCapital: loc.isCapital,
          ));
        }
      }

      for (final r in _onlineResults) {
        final key = r.name.toLowerCase().trim();
        final cleanKey = key.replaceAll('kota ', '').replaceAll('kabupaten ', '').replaceAll('provinsi ', '').trim();
        final isDuplicate = seen.any((s) => s.contains(cleanKey) || cleanKey.contains(s));
        if (!isDuplicate) {
          seen.add(key);
          unified.add(_UnifiedSearchResult(
            name: r.name,
            subtitle: r.displayName,
            lat: r.lat,
            lng: r.lng,
            isCapital: false,
          ));
        }
      }

      if (unified.isEmpty && !_isLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off_rounded, size: 40, color: Color(0xFFB5C2BC)),
                const SizedBox(height: 10),
                Text(
                  'Lokasi tidak ditemukan untuk "$_activeQuery"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1F3D2F)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coba ketik nama kota utama atau pilih dari daftar kota populer di bawah.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7C8B82)),
                ),
              ],
            ),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'HASIL PENCARIAN (${unified.length})',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: const Color(0xFF7C8B82),
              ),
            ),
          ),
          for (final item in unified)
            _buildLocationTile(
              name: item.name,
              subtitle: item.subtitle,
              lat: item.lat,
              lng: item.lng,
              isCapital: item.isCapital,
            ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'KOTA & WILAYAH POPULER',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: const Color(0xFF7C8B82),
            ),
          ),
        ),
        for (final loc in _kIndoLocations.take(15))
          _buildLocationTile(
            name: loc.name,
            subtitle: '${loc.province} · ${loc.island}',
            lat: loc.lat,
            lng: loc.lng,
            isCapital: loc.isCapital,
          ),
      ],
    );
  }

  Widget _buildLocationTile({
    required String name,
    required String subtitle,
    required double lat,
    required double lng,
    bool isCapital = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEFEA)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCapital ? const Color(0xFFE2F0E8) : const Color(0xFFF0F5F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isCapital ? Icons.location_city_rounded : Icons.location_on_rounded,
            color: const Color(0xFF1B6B58),
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F3D2F),
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7C8B82)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE9F4EE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih',
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF17664C),
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFF17664C)),
            ],
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          widget.onSelected(name, lat, lng);
        },
      ),
    );
  }
}


class MapPage extends StatefulWidget {
  final String wilayah;

  const MapPage({super.key, this.wilayah = ''});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late final AnimationController _anim; 
  late final AnimationController _chart;
  Timer? _chartDelayTimer;

  late String _currentWilayah;
  late List<String> _districts;
  late String _district;
  bool _picked = false; 

  @override
  void initState() {
    super.initState();
    final mon = MonitoringState.instance;
    _currentWilayah = widget.wilayah.isNotEmpty
        ? widget.wilayah
        : mon.locationName;
    _districts = _districtsFor(_currentWilayah);
    _district = _districts.first;

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AnimationBehavior.preserve,
    )..forward();
    _chart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      animationBehavior: AnimationBehavior.preserve,
    );
    _chartDelayTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) _chart.forward();
    });
  }

  @override
  void dispose() {
    _chartDelayTimer?.cancel();
    _anim.dispose();
    _chart.dispose();
    super.dispose();
  }

  void _openLocationSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LocationSearchModal(
        onSelected: (name, lat, lng) {
          AppSettings.instance.setManualLocation(name, lat: lat, lng: lng);
          if (mounted) {
            setState(() {
              _currentWilayah = name;
              _districts = _districtsFor(name);
              _district = _districts.first;
              _picked = true;
            });
            _chart.forward(from: 0);
          }
          MonitoringState.instance.setCustomLocation(
            name: name,
            lat: lat,
            lng: lng,
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'map',
        tour: const [
          CoachStep(title: 'Wilayah dan lokasi', body: 'Bagian atas menunjukkan wilayahmu. Ketuk Ubah Wilayah untuk memilih kecamatan atau area lain.'),
          CoachStep(title: 'Peta kualitas udara', body: 'Peta menampilkan titik-titik pemantauan dan jalan di sekitarmu. Ketuk bidang pencarian untuk mencari lokasi atau area.'),
          CoachStep(title: 'Kartu kualitas udara', body: 'Kartu ini menunjukkan status udara, nilai ISPU, sumber data, dan waktu pembaruan terakhir untuk lokasi yang dipilih.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Lokasi Saya. Ada wilayah yang aktif dengan tombol Ubah Wilayah, peta titik pemantauan dengan pencarian lokasi, dan kartu kualitas udara berisi status, ISPU, sumber, serta waktu pembaruan.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppSettings.instance, MonitoringState.instance]),
      builder: (context, _) {
        final snapshot = AppSettings.instance.snapshot;
        final mon = MonitoringState.instance;
        final curIspu = mon.currentReading?.officialIspu ??
            mon.currentReading?.pm25?.round() ??
            snapshot.ispu;
        final dynamicAq = _aqFromIspu(curIspu);

        final lat = mon.selectedSite.latitude != 0.0
            ? mon.selectedSite.latitude
            : (mon.selectedRegion.defaultLatitude != 0.0
                ? mon.selectedRegion.defaultLatitude
                : -2.2161);
        final lng = mon.selectedSite.longitude != 0.0
            ? mon.selectedSite.longitude
            : (mon.selectedRegion.defaultLongitude != 0.0
                ? mon.selectedRegion.defaultLongitude
                : 113.9135);
        final displayLoc = _picked
            ? '$_district, $_currentWilayah'
            : (AppSettings.instance.locationName.isNotEmpty
                ? AppSettings.instance.locationName
                : (mon.locationName.isNotEmpty ? mon.locationName : _currentWilayah));

        return Scaffold(
          backgroundColor: _MC.bg,
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _SoftLeavesPainter(_anim)),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _Reveal(
                      animation: _anim,
                      begin: 0.0,
                      end: 0.4,
                      child: _buildAppBar(context),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Reveal(
                              animation: _anim,
                              begin: 0.1,
                              end: 0.5,
                              child: _buildLokasiHeader(),
                            ),
                            const SizedBox(height: 16),
                            _Reveal(
                              animation: _anim,
                              begin: 0.2,
                              end: 0.65,
                              child: _MapCard(
                                lokasi: displayLoc,
                                latitude: lat,
                                longitude: lng,
                                onSearchTap: _openLocationSearch,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _Reveal(
                              animation: _anim,
                              begin: 0.35,
                              end: 0.8,
                              child: _AirQualityCard(
                                data: dynamicAq,
                                anim: _chart,
                                status: snapshot.status,
                                pm25: snapshot.pm25,
                                description: snapshot.airDescription,
                                observedAt: mon.currentReading?.observedAt,
                                sourceId: mon.currentReading?.sourceId,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _Reveal(
                              animation: _anim,
                              begin: 0.5,
                              end: 0.9,
                              child: _buildWarning(snapshot.status),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _Reveal(
                      animation: _anim,
                      begin: 0.6,
                      end: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 24, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _openLocationSearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _MC.button,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Ubah Wilayah / Cari Lokasi',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 48),
            icon: const Icon(Icons.arrow_back, color: _MC.dark, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Peta Kualitas Udara',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _MC.dark,
                  ),
                ),
                Text(
                  'Sebaran polutan CAMS & titik panas Karhutla se-Indonesia',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _MC.hint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLokasiHeader() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openLocationSearch,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCE6E0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on_rounded, color: _MC.button, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'LOKASI AKTIF',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: _MC.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: _MC.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _picked ? '$_district, $_currentWilayah' : _currentWilayah,
                      key: ValueKey(_picked ? '$_district, $_currentWilayah' : _currentWilayah),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _MC.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F4EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_rounded, size: 14, color: _MC.button),
                  const SizedBox(width: 4),
                  Text(
                    'Cari Kota',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _MC.button,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarning(String status) {
    final s = status.toLowerCase();
    String title;
    String desc;
    Color color;

    if (s.contains('baik')) {
      title = 'Kualitas udara bersih & segar!';
      desc = 'Sangat aman untuk beraktivitas dan berolahraga di luar ruangan.';
      color = const Color(0xFF1B8756);
    } else if (s.contains('sedang')) {
      title = 'Kualitas udara dalam batas aman';
      desc = 'Udara cukup baik untuk aktivitas sehari-hari di luar ruangan.';
      color = const Color(0xFFB5850A);
    } else if (s.contains('sensitif')) {
      title = 'Perhatian bagi kelompok rentan!';
      desc = 'Kelompok rentan (anak-anak, lansia, asma) dianjurkan mengurangi aktivitas luar.';
      color = const Color(0xFFE07D10);
    } else if (s.contains('tidak sehat')) {
      title = 'Kurangi aktivitas luar ruangan!';
      desc = 'Gunakan masker jika harus bepergian dan tutup ventilasi jika asap meningkat.';
      color = const Color(0xFFE5484D);
    } else {
      title = 'Waspada kabut asap pekat!';
      desc = 'Kondisi udara berbahaya. Tetap di dalam ruangan dan gunakan penyaring udara HEPA.';
      color = const Color(0xFFC71F24);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: GoogleFonts.poppins(
              color: const Color(0xFF3E4E46),
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatefulWidget {
  final String lokasi;
  final double latitude;
  final double longitude;
  final VoidCallback onSearchTap;

  const _MapCard({
    required this.lokasi,
    required this.latitude,
    required this.longitude,
    required this.onSearchTap,
  });

  @override
  State<_MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<_MapCard> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulse;
  bool _isSatellite = false;
  bool _showStations = true;
  bool _showHotspots = true;
  bool _showAerosol = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _MapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _mapController.move(
        LatLng(widget.latitude, widget.longitude),
        _mapController.camera.zoom,
      );
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final cur = _mapController.camera.zoom;
    if (cur < 18.0) {
      _mapController.move(_mapController.camera.center, (cur + 1.0).clamp(4.0, 18.0));
    }
  }

  void _zoomOut() {
    final cur = _mapController.camera.zoom;
    if (cur > 4.0) {
      _mapController.move(_mapController.camera.center, (cur - 1.0).clamp(4.0, 18.0));
    }
  }

  void _reset() {
    _mapController.move(LatLng(widget.latitude, widget.longitude), 13.0);
  }

  void _showLayerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE3E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.layers_rounded, color: Color(0xFF1B6B58), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Lapisan Peta & Data Udara',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C3A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TIPE DASAR PETA (BEBAS & PUBLIK)',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: const Color(0xFF7A8C84),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Standar (OSM)')),
                          selected: !_isSatellite,
                          selectedColor: const Color(0xFF1B6B58),
                          labelStyle: GoogleFonts.poppins(
                            color: !_isSatellite ? Colors.white : const Color(0xFF1C3A2E),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setSheetState(() => _isSatellite = false);
                              setState(() => _isSatellite = false);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Citra Satelit')),
                          selected: _isSatellite,
                          selectedColor: const Color(0xFF1B6B58),
                          labelStyle: GoogleFonts.poppins(
                            color: _isSatellite ? Colors.white : const Color(0xFF1C3A2E),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setSheetState(() => _isSatellite = true);
                              setState(() => _isSatellite = true);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LAPISAN PEMANTAUAN (LAYER)',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: const Color(0xFF7A8C84),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Stasiun & Model Permukaan',
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Konsentrasi PM2.5 / ISPU di permukaan tempat bernapas',
                      style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF7A8C84)),
                    ),
                    value: _showStations,
                    activeThumbColor: const Color(0xFF1B6B58),
                    onChanged: (v) {
                      setSheetState(() => _showStations = v);
                      setState(() => _showStations = v);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Titik Panas Karhutla (NASA FIRMS Hotspot)',
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Deteksi anomali suhu termal api satelit VIIRS/MODIS',
                      style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF7A8C84)),
                    ),
                    value: _showHotspots,
                    activeThumbColor: const Color(0xFFE5384B),
                    onChanged: (v) {
                      setSheetState(() => _showHotspots = v);
                      setState(() => _showHotspots = v);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Sebaran Asap Atmosfer (CAMS Aerosol AOD)',
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Ketebalan optik aerosol di kolom atmosfer (Open-Meteo)',
                      style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF7A8C84)),
                    ),
                    value: _showAerosol,
                    activeThumbColor: const Color(0xFFD97706),
                    onChanged: (v) {
                      setSheetState(() => _showAerosol = v);
                      setState(() => _showAerosol = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDFE9E4)),
                    ),
                    child: Text(
                      'Edukasi Ilmiah: Peta TEDUH menggunakan OpenStreetMap & NASA GIBS / ESRI publik '
                      'tanpa dependensi Google Cloud Billing. Angka polutan bersumber dari model atmosfer CAMS Open-Meteo.',
                      style: GoogleFonts.poppins(fontSize: 10, height: 1.45, color: const Color(0xFF4A5C54)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B6B58),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Terapkan Lapisan', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetLatLng = LatLng(widget.latitude, widget.longitude);

    return AspectRatio(
      aspectRatio: 1020 / 893,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: targetLatLng,
                  initialZoom: 13.0,
                  minZoom: 4.0,
                  maxZoom: 18.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: _isSatellite
                        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.teduh.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: targetLatLng,
                        width: 140,
                        height: 120,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulse,
                              builder: (context, _) {
                                final v = Curves.easeInOut.transform(_pulse.value);
                                return Container(
                                  width: 28 + 12 * v,
                                  height: 28 + 12 * v,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE8434F).withValues(alpha: 0.25 - 0.1 * v),
                                    border: Border.all(
                                      color: const Color(0xFFE8434F).withValues(alpha: 0.5 - 0.2 * v),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFE8434B),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x26000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1.5),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.lokasi.split(',').first.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF17664C),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                elevation: 3,
                shadowColor: const Color(0x22000000),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: widget.onSearchTap,
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, size: 21, color: Color(0xFF1B6B58)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cari kota, kabupaten, atau kecamatan...',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF7A8C84),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B6B58),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_searching_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                'Cari',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 68,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x15000000), blurRadius: 4, offset: Offset(0, 1.5)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B6B58),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isSatellite ? 'Citra Satelit ESRI/GIBS' : 'OpenStreetMap (OSM)',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF17664C),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 66,
              right: 12,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                shadowColor: const Color(0x22000000),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _showLayerBottomSheet,
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    child: Icon(
                      _isSatellite ? Icons.satellite_alt_rounded : Icons.layers_outlined,
                      size: 20,
                      color: const Color(0xFF1B6B58),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MapCtrl(
                    height: 74,
                    child: Column(
                      children: [
                        Expanded(
                          child: _MapIconTap(
                            icon: Icons.add,
                            color: _MC.dark,
                            onTap: _zoomIn,
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 1,
                          color: const Color(0xFFE6EBE7),
                        ),
                        Expanded(
                          child: _MapIconTap(
                            icon: Icons.remove,
                            color: _MC.dark,
                            onTap: _zoomOut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MapCtrl(
                    height: 36,
                    child: _MapIconTap(
                      icon: Icons.my_location,
                      color: const Color(0xFF1B7A55),
                      onTap: _reset,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isSatellite ? '© NASA GIBS / ESRI' : '© OpenStreetMap',
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    color: const Color(0xFF55635B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCtrl extends StatelessWidget {
  final double height;
  final Widget child;
  const _MapCtrl({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _MapIconTap extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MapIconTap({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(child: Icon(icon, size: 18, color: color)),
      ),
    );
  }
}

class _AirQualityCard extends StatelessWidget {
  final _AqData data;
  final Animation<double> anim;
  final String status;
  final String pm25;
  final String description;
  final DateTime? observedAt;
  final String? sourceId;

  const _AirQualityCard({
    required this.data,
    required this.anim,
    required this.status,
    required this.pm25,
    required this.description,
    this.observedAt,
    this.sourceId,
  });

  Color get _statusColor {
    final s = status.toLowerCase();
    if (s.contains('baik')) return const Color(0xFF1B8756);
    if (s.contains('sedang')) return const Color(0xFFB5850A);
    if (s.contains('sensitif')) return const Color(0xFFE07D10);
    if (s.contains('tidak sehat')) return const Color(0xFFE5484D);
    return const Color(0xFFC71F24);
  }

  List<Color> get _gradientColors {
    final s = status.toLowerCase();
    if (s.contains('baik')) {
      return const [Color(0xFF28A745), Color(0xFF74D88D)];
    }
    if (s.contains('sedang')) {
      return const [Color(0xFFE0A800), Color(0xFFFFD460)];
    }
    if (s.contains('sensitif')) {
      return const [Color(0xFFE07D10), Color(0xFFFFB366)];
    }
    if (s.contains('tidak sehat')) {
      return const [Color(0xFFE5484D), Color(0xFFF1949A)];
    }
    return const [Color(0xFFC71F24), Color(0xFF8B1216)];
  }

  String get _sourceName {
    if (sourceId == 'cams_openmeteo') {
      return 'Sumber: Open-Meteo CAMS (Model)';
    } else if (sourceId == 'firestore_stored') {
      return 'Sumber: Arsip Firestore';
    } else if (sourceId == 'google_air_quality') {
      return 'Sumber: Google Air Quality';
    }
    return 'Sumber: Open-Meteo CAMS';
  }

  String get _updatedText {
    if (observedAt != null) {
      final h = observedAt!.hour.toString().padLeft(2, '0');
      final m = observedAt!.minute.toString().padLeft(2, '0');
      return 'Diperbarui $h.$m WIB';
    }
    return 'Diperbarui baru saja';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor, width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Kualitas Udara: ',
                        style: TextStyle(color: _MC.greenTitle),
                      ),
                      TextSpan(
                        text: status,
                        style: TextStyle(color: _statusColor),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.info_outline,
                  size: 16, color: Color(0xFF7A8481)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _gradientColors,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ISPU',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: anim,
                      builder: (context, _) {
                        final p = Curves.easeOutCubic.transform(anim.value);
                        return Text(
                          '${(data.ispu * p).round()}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            description.isNotEmpty
                                ? description
                                : 'PM2.5: $pm25 µg/m³',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _MC.darkText,
                            ),
                          ),
                        ),
                        Text(
                          '6 jam terakhir',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _MC.greyLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 30,
                      child: AnimatedBuilder(
                        animation: anim,
                        builder: (context, _) {
                          final n = data.tinggi.length;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (int i = 0; i < n; i++) ...[
                                if (i != 0) const SizedBox(width: 4.8),
                                Expanded(
                                  child: Builder(builder: (context) {
                                    final start = (i / n) * 0.5;
                                    final t = Interval(start, start + 0.5,
                                            curve: Curves.easeOutCubic)
                                        .transform(anim.value);
                                    return Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: data.tinggi[i] * t,
                                        decoration: BoxDecoration(
                                          color: data.warna[i],
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(2),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '04.00',
                          style: GoogleFonts.poppins(
                            fontSize: 8.5,
                            color: const Color(0xFFA3ADA7),
                          ),
                        ),
                        Text(
                          'Sekarang',
                          style: GoogleFonts.poppins(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B7A55),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),

          Row(
            children: const [
              _SkalaSegmen(Color(0xFF1F7F52)),
              SizedBox(width: 3.85),
              _SkalaSegmen(Color(0xFFE8CB6C)),
              SizedBox(width: 3.85),
              _SkalaSegmen(Color(0xFFE8A57A)),
              SizedBox(width: 3.85),
              _SkalaSegmen(Color(0xFFC98884)),
              SizedBox(width: 3.85),
              _SkalaSegmen(Color(0xFFEE3A3F)),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Baik · 0–50',
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: _MC.greenTitle,
                ),
              ),
              Text(
                'Berbahaya',
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  color: _MC.greyLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9.5),

          Row(
            children: [
              const Icon(Icons.sync, size: 13, color: Color(0xFF7F8B85)),
              const SizedBox(width: 5),
              Text(
                _updatedText,
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  color: const Color(0xFF8A958F),
                ),
              ),
              const Spacer(),
              Text(
                _sourceName,
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1B6B58),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkalaSegmen extends StatelessWidget {
  final Color color;
  const _SkalaSegmen(this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  const _Reveal({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _SoftLeavesPainter extends CustomPainter {
  final Animation<double> anim;
  _SoftLeavesPainter(this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Curves.easeOut.transform(anim.value.clamp(0.0, 1.0));

    _leaf(canvas, Offset(w * 1.04, -h * 0.02), w * 0.62, w * 0.22,
        215 * math.pi / 180, _MC.softLeaf.withValues(alpha: 0.9 * p));
    _leaf(canvas, Offset(w * 0.98, -h * 0.01), w * 0.40, w * 0.14,
        195 * math.pi / 180, _MC.softLeaf.withValues(alpha: 0.6 * p));
  }

  void _leaf(Canvas canvas, Offset origin, double length, double width,
      double angle, Color color) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(width * 1.05, -length * 0.20, width * 0.95, -length * 0.72, 0,
          -length)
      ..cubicTo(-width * 0.95, -length * 0.72, -width * 1.05, -length * 0.20,
          0, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SoftLeavesPainter old) => false;
}
