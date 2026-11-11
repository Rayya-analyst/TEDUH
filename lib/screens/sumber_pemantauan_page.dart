import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_settings.dart';

class SumberPemantauanPage extends StatefulWidget {
  final ValueChanged<String>? onApply;

  const SumberPemantauanPage({super.key, this.onApply});

  @override
  State<SumberPemantauanPage> createState() => _SumberPemantauanPageState();
}

class _SourceOption {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SourceOption(this.icon, this.title, this.subtitle);
}

class _SumberPemantauanPageState extends State<SumberPemantauanPage> {
  static const Color _green = Color(0xFF176D59);
  static const Color _greenIcon = Color(0xFF2E7B67);
  static const Color _ink = Color(0xFF0F2A24);
  static const Color _body = Color(0xFF5B6763);
  static const Color _muted = Color(0xFF8A9691);
  static const Color _iconBox = Color(0xFFDDEEE3);

  static const List<_SourceOption> _options = [
    _SourceOption(
      Icons.account_balance_outlined,
      'Stasiun Resmi Pemerintah (KLHK)',
      'Data resmi, diperbarui setiap 1 jam',
    ),
    _SourceOption(
      Icons.satellite_alt_outlined,
      'Satelit Sentinel & Copernicus',
      'Cakupan wilayah lebih luas, estimasi real-time',
    ),
    _SourceOption(
      Icons.sensors_rounded,
      'Sensor Komunitas Lokal (IoT)',
      'Sensor terdekat di sekitar pemukiman warga',
    ),
  ];

  int _selected = AppSettings.instance.source.index;

  void _apply() {
    final String name = _options[_selected].title;
    AppSettings.instance.setSource(MonitoringSource.values[_selected]);
    if (widget.onApply != null) {
      widget.onApply!(name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sumber diterapkan: $name')),
      );
    }
    Navigator.of(context).maybePop(_selected);
  }

  List<CoachStep> get _tour => const [
        CoachStep(title: 'Preferensi data', body: 'Pilih sumber data kualitas udara yang paling kamu percaya. Angka di seluruh aplikasi akan ikut berubah.'),
        CoachStep(title: 'Tiga pilihan sumber', body: 'Ada Stasiun Resmi Pemerintah, Satelit Sentinel dan Copernicus, dan Sensor Komunitas Lokal. Ketuk salah satu untuk memilihnya.'),
        CoachStep(title: 'Terapkan Sumber', body: 'Setelah memilih, ketuk Terapkan Sumber. Pilihan bisa diubah kapan saja.'),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'sumber',
        tour: _tour,
        guide: PageGuide(content: () => 'Ini halaman Sumber Pemantauan. Ada tiga pilihan: Stasiun Resmi Pemerintah yang diperbarui setiap satu jam, Satelit Sentinel dan Copernicus dengan cakupan lebih luas, dan Sensor Komunitas Lokal di sekitar pemukiman warga. Nilai bisa berbeda antar sumber. Kamu bisa berkata ganti sumber ke satelit, ganti sumber ke sensor, atau ganti sumber ke resmi.'),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    final double s = MediaQuery.of(context).size.width / 285;

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
            Positioned(
              right: -14 * s,
              top: 120 * s,
              child: Container(
                width: 22 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F0E7),
                  borderRadius: BorderRadius.circular(22 * s),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(19 * s, 12 * s, 19 * s, 12 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, s),
                          SizedBox(height: 22 * s),
                          _buildHeading(s),
                          SizedBox(height: 8 * s),
                          Text(
                            'Tentukan sumber data kualitas udara yang paling '
                            'sesuai untuk Anda.',
                            style: GoogleFonts.inter(
                              fontSize: 7.5 * s,
                              height: 1.5,
                              color: _body,
                            ),
                          ),
                          SizedBox(height: 14 * s),
                          for (int i = 0; i < _options.length; i++) ...[
                            _buildOptionCard(s, i),
                            SizedBox(height: 11 * s),
                          ],
                          SizedBox(height: 4 * s),
                          _buildNote(s),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(19 * s, 4 * s, 19 * s, 12 * s),
                    child: Column(
                      children: [
                        _buildApplyButton(s),
                        SizedBox(height: 9 * s),
                        Text(
                          'Pilihan dapat diubah kapan saja.',
                          style: GoogleFonts.inter(
                              fontSize: 5.9 * s, color: _muted),
                        ),
                      ],
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

  Widget _buildHeader(BuildContext context, double s) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Padding(
            padding: EdgeInsets.all(2 * s),
            child: Icon(Icons.arrow_back_rounded, size: 12 * s, color: _ink),
          ),
        ),
        SizedBox(width: 12 * s),
        Text(
          'Sumber Pemantauan',
          style: GoogleFonts.inter(
            fontSize: 8 * s,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
      ],
    );
  }

  Widget _buildHeading(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREFERENSI DATA',
          style: GoogleFonts.inter(
            fontSize: 5.6 * s,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: _green,
          ),
        ),
        SizedBox(height: 5 * s),
        Text.rich(
          TextSpan(
            style: GoogleFonts.inter(
              fontSize: 16.5 * s,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: const Color(0xFF123F34),
            ),
            children: const [
              TextSpan(text: 'Informasi, '),
              TextSpan(text: 'pantau udara.', style: TextStyle(color: _green)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(double s, int index) {
    final _SourceOption o = _options[index];
    final bool selected = index == _selected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected = index),
      child: Container(
        width: double.infinity,
        height: 86 * s,
        padding: EdgeInsets.fromLTRB(11 * s, 11 * s, 11 * s, 0),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE3F1E8) : Colors.white,
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(
            color: selected ? _green : const Color(0xFFDDE6E0),
            width: selected ? 1.4 : 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.0 : 0.03),
              blurRadius: 5 * s,
              offset: Offset(0, 1.5 * s),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 27 * s,
              height: 27 * s,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFCFE6D8) : _iconBox,
                borderRadius: BorderRadius.circular(8 * s),
              ),
              child: Icon(o.icon, size: 13 * s, color: _greenIcon),
            ),
            SizedBox(width: 9 * s),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.title,
                      style: GoogleFonts.inter(
                        fontSize: 7.7 * s,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      o.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 6 * s,
                        color: selected ? _body : _muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNote(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1 * s),
            child: Icon(Icons.info_outline_rounded, size: 7.5 * s, color: _body),
          ),
          SizedBox(width: 6 * s),
          Expanded(
            child: Text(
              'Nilai dapat berbeda antar sumber karena lokasi dan metode '
              'pengukuran.',
              style: GoogleFonts.inter(
                fontSize: 6 * s,
                height: 1.55,
                color: _body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(double s) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _apply,
      child: Container(
        width: double.infinity,
        height: 37 * s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(12 * s),
          boxShadow: [
            BoxShadow(
              color: _green.withValues(alpha: 0.22),
              blurRadius: 8 * s,
              offset: Offset(0, 3 * s),
            ),
          ],
        ),
        child: Text(
          'Terapkan Sumber',
          style: GoogleFonts.inter(
            fontSize: 8 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
