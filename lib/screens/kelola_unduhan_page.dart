import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class KelolaUnduhanPage extends StatefulWidget {
  const KelolaUnduhanPage({super.key});

  @override
  State<KelolaUnduhanPage> createState() => _KelolaUnduhanPageState();
}

class _DownloadItem {
  final String id;
  final IconData icon;
  final String title;
  final String meta;
  final double sizeMb;

  const _DownloadItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.meta,
    required this.sizeMb,
  });
}

class _KelolaUnduhanPageState extends State<KelolaUnduhanPage> {
  static const Color _green = Color(0xFF176D59);
  static const Color _greenIcon = Color(0xFF2E7B67);
  static const Color _ink = Color(0xFF0F2A24);
  static const Color _body = Color(0xFF5B6763);
  static const Color _muted = Color(0xFF8A9691);
  static const Color _iconBox = Color(0xFFDDEEE3);
  static const Color _cardLine = Color(0xFFD3E4DA);

  static const double _limitMb = 100;

  final List<_DownloadItem> _items = [
    const _DownloadItem(
      id: 'udara',
      icon: Icons.air_rounded,
      title: 'Data kualitas udara',
      meta: 'Jakarta · 2 jam lalu',
      sizeMb: 8.4,
    ),
    const _DownloadItem(
      id: 'panduan',
      icon: Icons.menu_book_outlined,
      title: 'Panduan kesehatan',
      meta: '3 panduan',
      sizeMb: 15.2,
    ),
    const _DownloadItem(
      id: 'kontak',
      icon: Icons.contact_phone_outlined,
      title: 'Kontak darurat',
      meta: '2 kontak pribadi',
      sizeMb: 0.4,
    ),
  ];

  bool _hasPending = true;

  double get _usedMb => _items.fold(0.0, (sum, e) => sum + e.sizeMb);

  String _fmt(double v) {
    final String t = v.toStringAsFixed(1);
    return t.endsWith('.0') ? t.substring(0, t.length - 2) : t.replaceAll('.', ',');
  }

  Future<void> _confirmDeleteAll() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus semua unduhan?'),
        content: const Text(
            'Semua data yang tersimpan di perangkat akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        _items.clear();
        _hasPending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'downloads',
        tour: const [
          CoachStep(title: 'Penyimpanan offline', body: 'Daftar data yang tersimpan di perangkat: data kualitas udara, panduan kesehatan, dan kontak darurat, masing-masing dengan keterangan terunduh atau menunggu koneksi.'),
          CoachStep(title: 'Pembaruan data udara', body: 'Menunjukkan apakah ada pembaruan yang tertunda. Unduhan baru perlu koneksi internet.'),
          CoachStep(title: 'Hapus semua unduhan', body: 'Ketuk untuk menghapus semua data yang tersimpan di perangkat. Kamu akan diminta konfirmasi lebih dulu.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Kelola Unduhan. Berisi penyimpanan offline: data kualitas udara, panduan kesehatan, dan kontak darurat. Ada juga status pembaruan data udara dan tombol Hapus semua unduhan.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final double s = MediaQuery.of(context).size.width / 282;

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
                    _buildStorageCard(s),
                    SizedBox(height: 16 * s),
                    _buildSectionRow(s, 'TERUNDUH', '${_items.length} kategori'),
                    SizedBox(height: 8 * s),
                    if (_items.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16 * s),
                        child: Center(
                          child: Text(
                            'Belum ada unduhan tersimpan',
                            style: GoogleFonts.inter(
                                fontSize: 7 * s, color: _muted),
                          ),
                        ),
                      ),
                    for (final item in _items) ...[
                      _buildDownloadCard(s, item),
                      SizedBox(height: 8 * s),
                    ],
                    if (_hasPending) ...[
                      SizedBox(height: 6 * s),
                      _buildSectionRow(s, 'MENUNGGU KONEKSI', null),
                      SizedBox(height: 8 * s),
                      _buildPendingCard(s),
                    ],
                    SizedBox(height: 14 * s),
                    _buildNote(s),
                    SizedBox(height: 14 * s),
                    _buildDeleteAll(s),
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
          TextSpan(text: 'tanpa koneksi.', style: TextStyle(color: _green)),
        ],
      ),
    );
  }

  Widget _buildSubtitle(double s) {
    return Text(
      'Atur data dan panduan yang tersimpan di perangkat Anda.',
      style: GoogleFonts.inter(fontSize: 7.7 * s, height: 1.5, color: _body),
    );
  }

  Widget _buildStorageCard(double s) {
    final double used = _usedMb;
    final double progress = (used / _limitMb).clamp(0.0, 1.0);
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
                '${_fmt(used)} MB',
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
                '${_fmt(used)} MB dari batas ${_fmt(_limitMb)} MB',
                style: GoogleFonts.inter(fontSize: 5.8 * s, color: _body),
              ),
              const Spacer(),
              Text(
                '${_fmt(_limitMb - used)} MB tersisa',
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

  Widget _buildDownloadCard(double s, _DownloadItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 11 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: _cardLine, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5 * s,
            offset: Offset(0, 1.5 * s),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 26 * s,
            height: 26 * s,
            decoration: BoxDecoration(
              color: _iconBox,
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Icon(item.icon, size: 12.5 * s, color: _greenIcon),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 8 * s,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 3 * s),
                Text(
                  '${item.meta} · ${_fmt(item.sizeMb)} MB',
                  style: GoogleFonts.inter(fontSize: 6.2 * s, color: _muted),
                ),
                SizedBox(height: 4 * s),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 7 * s, color: _green),
                    SizedBox(width: 3 * s),
                    Text(
                      'Tersedia offline',
                      style: GoogleFonts.inter(
                        fontSize: 6.2 * s,
                        fontWeight: FontWeight.w600,
                        color: _green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _items.removeWhere((e) => e.id == item.id)),
            child: Padding(
              padding: EdgeInsets.all(4 * s),
              child: Icon(Icons.delete_outline_rounded,
                  size: 11 * s, color: const Color(0xFF6B7773)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF0DD),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: const Color(0xFFEFDDB9), width: 0.9),
      ),
      child: Row(
        children: [
          Container(
            width: 24 * s,
            height: 24 * s,
            decoration: BoxDecoration(
              color: const Color(0xFFF6E3BE),
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Icon(Icons.schedule_rounded,
                size: 12 * s, color: const Color(0xFF9A6A12)),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembaruan data udara',
                  style: GoogleFonts.inter(
                    fontSize: 7.6 * s,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 3 * s),
                Text(
                  'Tertunda · Perlu koneksi internet',
                  style: GoogleFonts.inter(fontSize: 6.2 * s, color: _muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _hasPending = false),
            child: Padding(
              padding: EdgeInsets.all(3 * s),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontSize: 6.8 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8A5A0A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote(double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1 * s),
          child: Icon(Icons.info_outline_rounded, size: 7.5 * s, color: _body),
        ),
        SizedBox(width: 6 * s),
        Expanded(
          child: Text(
            'Data terakhir: 2 jam lalu. Unduhan baru dan pembaruan '
            'memerlukan koneksi internet.',
            style: GoogleFonts.inter(fontSize: 6.2 * s, height: 1.5, color: _body),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteAll(double s) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _items.isEmpty && !_hasPending ? null : _confirmDeleteAll,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, size: 9.5 * s, color: _green),
              SizedBox(width: 5 * s),
              Text(
                'Hapus semua unduhan',
                style: GoogleFonts.inter(
                  fontSize: 7.4 * s,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
