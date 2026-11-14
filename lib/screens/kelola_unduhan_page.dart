import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/air_quality_models.dart';
import '../services/offline_data_service.dart';
import '../state/monitoring_state.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';

class KelolaUnduhanPage extends StatelessWidget {
  const KelolaUnduhanPage({super.key});

  static const Color _green = Color(0xFF176D59);
  static const Color _greenIcon = Color(0xFF2E7B67);
  static const Color _ink = Color(0xFF0F2A24);
  static const Color _body = Color(0xFF5B6763);
  static const Color _muted = Color(0xFF8A9691);
  static const Color _iconBox = Color(0xFFDDEEE3);
  static const Color _cardLine = Color(0xFFD3E4DA);
  static const double _limitMb = 100;

  static String _fmtBytes(int? bytes) {
    if (bytes == null || bytes == 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    final t = mb.toStringAsFixed(1);
    return '${t.endsWith('.0') ? t.substring(0, t.length - 2) : t.replaceAll('.', ',')} MB';
  }

  static String _fmtMb(double v) {
    final t = v.toStringAsFixed(1);
    return t.endsWith('.0') ? t.substring(0, t.length - 2) : t.replaceAll('.', ',');
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus semua unduhan?'),
        content: const Text(
            'Semua data offline yang tersimpan di perangkat akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      for (final region in MonitoringRegion.allSupported) {
        await OfflineDataService.instance.deletePackage(region.regionId);
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, String regionId, String regionName) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus unduhan $regionName?'),
        content: Text('Data offline untuk $regionName akan dihapus dari perangkat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await OfflineDataService.instance.deletePackage(regionId);
    }
  }

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'downloads',
        tour: const [
          CoachStep(
              title: 'Penyimpanan offline',
              body:
                  'Daftar paket data offline per wilayah Kalimantan: status unduhan, ukuran, dan waktu terakhir diperbarui.'),
          CoachStep(
              title: 'Unduh atau perbarui',
              body:
                  'Ketuk Unduh untuk mengunduh data wilayah. Jika sudah terunduh, kamu bisa memperbarui atau menghapusnya.'),
          CoachStep(
              title: 'Hapus semua unduhan',
              body:
                  'Ketuk untuk menghapus semua data offline dari perangkat. Kamu akan diminta konfirmasi lebih dulu.'),
        ],
        guide: PageGuide(
          content: () {
            final pkgs = OfflineDataService.instance.allPackages;
            final downloaded =
                pkgs.where((p) => p.effectiveStatus == OfflinePackageStatus.downloaded || p.effectiveStatus == OfflinePackageStatus.stale).length;
            return 'Ini halaman Kelola Unduhan. Tersedia $downloaded dari ${MonitoringRegion.allSupported.length} paket wilayah yang terunduh. Ketuk Unduh untuk mengunduh data offline suatu wilayah.';
          },
        ),
        child: AnimatedBuilder(
          animation: OfflineDataService.instance,
          builder: (ctx, child) => _buildPage(ctx),
        ),
      );

  Widget _buildPage(BuildContext context) {
    final double s = MediaQuery.of(context).size.width / 282;
    final svc = OfflineDataService.instance;
    final pkgs = MonitoringRegion.allSupported
        .map((r) => svc.getPackage(r.regionId) ??
            OfflinePackage(regionId: r.regionId, regionName: r.province))
        .toList();

    final int totalBytes = pkgs.fold(0, (sum, p) => sum + (p.sizeBytes ?? 0));
    final double usedMb = totalBytes / (1024 * 1024);
    final double progress = (usedMb / _limitMb).clamp(0.0, 1.0);

    final String selectedId =
        MonitoringState.instance.selectedRegion.regionId;

    final bool anyDownloaded = pkgs.any(
        (p) => p.status == OfflinePackageStatus.downloaded);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE9F4EC),
                      Color(0xFFF4F9F5),
                      Color(0xFFFAFCFA),
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -70 * s,
              top: -95 * s,
              child: Container(
                width: 190 * s,
                height: 190 * s,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCEEE2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18 * s, 10 * s, 18 * s, 22 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, s),
                    SizedBox(height: 22 * s),
                    _buildHeading(s),
                    SizedBox(height: 8 * s),
                    _buildSubtitle(s),
                    SizedBox(height: 14 * s),
                    _buildStorageCard(s, usedMb: usedMb, progress: progress),
                    SizedBox(height: 16 * s),
                    _buildSectionRow(s, 'PAKET WILAYAH',
                        '${pkgs.where((p) => p.status == OfflinePackageStatus.downloaded || p.status == OfflinePackageStatus.stale).length} terunduh'),
                    SizedBox(height: 8 * s),
                    for (final pkg in pkgs) ...[
                      _buildPackageCard(context, s, pkg,
                          isSelected: pkg.regionId == selectedId),
                      SizedBox(height: 8 * s),
                    ],
                    SizedBox(height: 6 * s),
                    _buildNote(s),
                    SizedBox(height: 14 * s),
                    _buildDeleteAll(context, s, enabled: anyDownloaded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double s) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 26 * s,
            height: 26 * s,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _cardLine, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4 * s,
                  offset: Offset(0, 1 * s),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_rounded, size: 11 * s, color: _ink),
          ),
        ),
        SizedBox(width: 14 * s),
        Text(
          'Kelola Unduhan',
          style: GoogleFonts.inter(
            fontSize: 8.6 * s,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
      ],
    );
  }

  Widget _buildHeading(double s) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 17.5 * s,
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: const Color(0xFF123F34),
        ),
        children: const [
          TextSpan(text: 'Siap, meski '),
          TextSpan(
              text: 'tanpa koneksi.',
              style: TextStyle(color: _green)),
        ],
      ),
    );
  }

  Widget _buildSubtitle(double s) {
    return Text(
      'Unduh data wilayah Kalimantan untuk diakses tanpa internet.',
      style: GoogleFonts.inter(fontSize: 7.7 * s, height: 1.5, color: _body),
    );
  }

  Widget _buildStorageCard(double s,
      {required double usedMb, required double progress}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(11 * s, 11 * s, 11 * s, 10 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F1E8),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: const Color(0xFFC3DDCD), width: 0.9),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.storage_rounded, size: 10 * s, color: _green),
              SizedBox(width: 6 * s),
              Text(
                'Penyimpanan offline',
                style: GoogleFonts.inter(
                  fontSize: 7.2 * s,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const Spacer(),
              Text(
                '${_fmtMb(usedMb)} MB',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF123F34),
                ),
              ),
            ],
          ),
          SizedBox(height: 9 * s),
          ClipRRect(
            borderRadius: BorderRadius.circular(4 * s),
            child: Stack(
              children: [
                Container(height: 4 * s, color: const Color(0xFFC9DED0)),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(height: 4 * s, color: _green),
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * s),
          Row(
            children: [
              Text(
                '${_fmtMb(usedMb)} MB dari batas ${_fmtMb(_limitMb)} MB',
                style: GoogleFonts.inter(fontSize: 5.8 * s, color: _body),
              ),
              const Spacer(),
              Text(
                '${_fmtMb(_limitMb - usedMb)} MB tersisa',
                style: GoogleFonts.inter(fontSize: 5.8 * s, color: _body),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionRow(double s, String left, String? right) {
    return Row(
      children: [
        Text(
          left,
          style: GoogleFonts.inter(
            fontSize: 6.2 * s,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
            color: _green,
          ),
        ),
        const Spacer(),
        if (right != null)
          Text(
            right,
            style: GoogleFonts.inter(fontSize: 6.2 * s, color: _muted),
          ),
      ],
    );
  }

  Widget _buildPackageCard(BuildContext context, double s, OfflinePackage pkg,
      {bool isSelected = false}) {
    final status = pkg.effectiveStatus;
    final bool isDownloading = status == OfflinePackageStatus.downloading;
    final bool isDownloaded = status == OfflinePackageStatus.downloaded;
    final bool isStale = status == OfflinePackageStatus.stale;
    final bool isFailed = status == OfflinePackageStatus.failed;
    final bool notDownloaded = status == OfflinePackageStatus.notDownloaded;

    Color badgeBg;
    Color badgeText;
    String badgeLabel;
    if (isDownloaded) {
      badgeBg = const Color(0xFFDDF0E4);
      badgeText = _green;
      badgeLabel = 'Tersedia offline';
    } else if (isStale) {
      badgeBg = const Color(0xFFFBF0DD);
      badgeText = const Color(0xFF9A6A12);
      badgeLabel = 'Kedaluwarsa';
    } else if (isDownloading) {
      badgeBg = const Color(0xFFE0EFFF);
      badgeText = const Color(0xFF1A56A0);
      badgeLabel = 'Mengunduh…';
    } else if (isFailed) {
      badgeBg = const Color(0xFFFFE9E9);
      badgeText = const Color(0xFFB00020);
      badgeLabel = 'Gagal';
    } else {
      badgeBg = const Color(0xFFF0F0F0);
      badgeText = _muted;
      badgeLabel = 'Belum diunduh';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 11 * s),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFEBF5EF)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
            color: isSelected ? _green : _cardLine,
            width: isSelected ? 1.1 : 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5 * s,
            offset: Offset(0, 1.5 * s),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26 * s,
                height: 26 * s,
                decoration: BoxDecoration(
                  color: _iconBox,
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                child: Icon(Icons.location_city_rounded,
                    size: 12.5 * s, color: _greenIcon),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pkg.regionName,
                            style: GoogleFonts.inter(
                              fontSize: 8 * s,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5 * s, vertical: 1.5 * s),
                            decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(10 * s),
                            ),
                            child: Text(
                              'Aktif',
                              style: GoogleFonts.inter(
                                fontSize: 5.5 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2 * s),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5 * s, vertical: 1.5 * s),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8 * s),
                          ),
                          child: Text(
                            badgeLabel,
                            style: GoogleFonts.inter(
                              fontSize: 5.8 * s,
                              fontWeight: FontWeight.w600,
                              color: badgeText,
                            ),
                          ),
                        ),
                        if (pkg.sizeBytes != null && pkg.sizeBytes! > 0) ...[
                          SizedBox(width: 6 * s),
                          Text(
                            _fmtBytes(pkg.sizeBytes),
                            style:
                                GoogleFonts.inter(fontSize: 5.8 * s, color: _muted),
                          ),
                        ],
                        if (pkg.downloadedAt != null) ...[
                          SizedBox(width: 4 * s),
                          Text(
                            '\u00b7 ${_relativeTime(pkg.downloadedAt!)}',
                            style: GoogleFonts.inter(
                                fontSize: 5.8 * s, color: _muted),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isDownloading) ...[
            SizedBox(height: 8 * s),
            ClipRRect(
              borderRadius: BorderRadius.circular(4 * s),
              child: Stack(
                children: [
                  Container(
                      height: 3.5 * s, color: const Color(0xFFCFE4F4)),
                  FractionallySizedBox(
                    widthFactor: pkg.progress.clamp(0.0, 1.0),
                    child: Container(
                        height: 3.5 * s,
                        color: const Color(0xFF1A56A0)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4 * s),
            Text(
              '${(pkg.progress * 100).toStringAsFixed(0)}% selesai…',
              style: GoogleFonts.inter(
                  fontSize: 6 * s, color: const Color(0xFF1A56A0)),
            ),
          ],
          SizedBox(height: 10 * s),
          Row(
            children: [
              if (notDownloaded || isFailed)
                _actionBtn(
                  s: s,
                  label: 'Unduh',
                  icon: Icons.download_rounded,
                  color: _green,
                  onTap: () => OfflineDataService.instance
                      .downloadPackage(pkg.regionId),
                ),
              if (isDownloaded || isStale) ...[
                _actionBtn(
                  s: s,
                  label: 'Perbarui',
                  icon: Icons.refresh_rounded,
                  color: _green,
                  onTap: () => OfflineDataService.instance
                      .downloadPackage(pkg.regionId),
                ),
                SizedBox(width: 8 * s),
                _actionBtn(
                  s: s,
                  label: 'Hapus',
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFF6B7773),
                  outline: true,
                  onTap: () =>
                      _confirmDelete(context, pkg.regionId, pkg.regionName),
                ),
              ],
              if (isDownloading)
                Text(
                  'Sedang mengunduh…',
                  style:
                      GoogleFonts.inter(fontSize: 6.5 * s, color: _muted),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required double s,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outline = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8 * s),
          border: Border.all(
              color: outline ? color.withValues(alpha: 0.4) : color.withValues(alpha: 0.3),
              width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 8 * s, color: color),
            SizedBox(width: 4 * s),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 6.8 * s,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNote(double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1 * s),
          child:
              Icon(Icons.info_outline_rounded, size: 7.5 * s, color: _body),
        ),
        SizedBox(width: 6 * s),
        Expanded(
          child: Text(
            'Unduhan baru dan pembaruan memerlukan koneksi internet. '
            'Data offline berlaku 24 jam sebelum dianggap kedaluwarsa.',
            style:
                GoogleFonts.inter(fontSize: 6.2 * s, height: 1.5, color: _body),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteAll(BuildContext context, double s,
      {required bool enabled}) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => _confirmDeleteAll(context) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded,
                  size: 9.5 * s,
                  color: enabled ? _green : _muted),
              SizedBox(width: 5 * s),
              Text(
                'Hapus semua unduhan',
                style: GoogleFonts.inter(
                  fontSize: 7.4 * s,
                  fontWeight: FontWeight.w700,
                  color: enabled ? _green : _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}
