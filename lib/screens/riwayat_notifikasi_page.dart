import 'package:flutter/material.dart';
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
class RiwayatNotifikasiPage extends StatelessWidget {
  const RiwayatNotifikasiPage({super.key});

  static const Color _bg = Color(0xFFF8FBF9);
  static const Color _green = Color(0xFF2E8B57);
  static const Color _greenSoft = Color(0xFFE6F2EA);
  static const Color _greenBorder = Color(0xFFBFDDC9);
  static const Color _ink = Color(0xFF1F2A24);
  static const Color _muted = Color(0xFF8A938E);
  static const Color _line = Color(0xFFE3E8E5);

  static const List<_NotifItem> _items = [
    _NotifItem(
      icon: Icons.waves_rounded,
      iconColor: Color(0xFFE5484D),
      iconBg: Color(0xFFFDECEC),
      iconBorder: Color(0xFFF7CFD0),
      title: 'Udara mulai tidak sehat',
      subtitle: 'US AQI 158 · PM2.5 dominan',
      time: '08.45',
    ),
    _NotifItem(
      icon: Icons.trending_up_rounded,
      iconColor: Color(0xFFE5484D),
      iconBg: Color(0xFFFDECEC),
      iconBorder: Color(0xFFF7CFD0),
      title: 'Kondisi udara memburuk',
      subtitle: 'US AQI naik dari 112 ke 158',
      time: '08.30',
    ),
    _NotifItem(
      icon: Icons.cloud_outlined,
      iconColor: Color(0xFFE59A1F),
      iconBg: Color(0xFFFDF3DF),
      iconBorder: Color(0xFFF5E1B4),
      title: 'Peringatan kabut asap di sekitar lokasi',
      subtitle: 'Indikasi dari kenaikan PM2.5',
      time: '08.15',
    ),
    _NotifItem(
      icon: Icons.alarm_rounded,
      iconColor: Color(0xFF2E8B57),
      iconBg: Color(0xFFE6F2EA),
      iconBorder: Color(0xFFC6E0D0),
      title: 'Pengingat memeriksa kualitas udara sebelum beraktivitas',
      subtitle: 'Periksa data terbaru sebelum keluar',
      time: '07.00',
    ),
  ];

  static final GlobalKey _kBanner = GlobalKey();
  static final GlobalKey _kList = GlobalKey();

  List<CoachStep> get _tour => [
        CoachStep(
          target: _kBanner,
          title: 'Riwayat Notifikasi',
          body: 'Daftar pemberitahuan kualitas udara yang pernah dikirim TEDUH kepadamu. Bagian ini menjelaskan isi riwayatnya.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _kList,
          title: 'Baca tiap pemberitahuan',
          body: 'Tiap kartu memuat judul, keterangan singkat, dan waktunya. Data di halaman ini masih contoh, bukan pemberitahuan langsung.',
          scrollAlignment: 0.15,
        ),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'notif_riwayat',
        tour: _tour,
        guide: PageGuide(content: () => 'Ini halaman Riwayat Notifikasi. Berisi pemberitahuan seperti udara mulai tidak sehat, kondisi udara memburuk, peringatan kabut asap di sekitar lokasi, dan pengingat memeriksa kualitas udara sebelum beraktivitas. Data masih contoh. Ucapkan kembali untuk ke halaman sebelumnya.'),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    final double s = MediaQuery.of(context).size.width / 253;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, s),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(14 * s, 10 * s, 14 * s, 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KeyedSubtree(key: _kBanner, child: _buildInfoBanner(s)),
                    SizedBox(height: 14 * s),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Riwayat Notifikasi',
                            style: TextStyle(
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                        ),
                        Text(
                          'Hari ini',
                          style: TextStyle(fontSize: 7 * s, color: _muted),
                        ),
                      ],
                    ),
                    SizedBox(height: 3 * s),
                    Row(
                      children: [
                        Container(
                          width: 4 * s,
                          height: 4 * s,
                          decoration: const BoxDecoration(
                            color: _green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4 * s),
                        Text(
                          'Data contoh · bukan pemberitahuan langsung',
                          style: TextStyle(fontSize: 6.5 * s, color: _muted),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * s),
                    KeyedSubtree(
                      key: _kList,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in _items) _buildItem(item, s),
                        ],
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

  Widget _buildHeader(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * s, 8 * s, 14 * s, 8 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(2 * s),
              child: Icon(Icons.arrow_back_rounded, size: 12 * s, color: _green),
            ),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: Text(
              'Riwayat Notifikasi',
              style: TextStyle(
                fontSize: 9 * s,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: _greenSoft,
        borderRadius: BorderRadius.circular(7 * s),
        border: Border.all(color: _greenBorder, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1 * s),
            child: Icon(Icons.info_outline_rounded, size: 9 * s, color: _green),
          ),
          SizedBox(width: 6 * s),
          Expanded(
            child: Text(
              'Informasi kabut asap adalah indikasi dari data kualitas udara, '
              'bukan deteksi langsung kebakaran.',
              style: TextStyle(
                fontSize: 6.5 * s,
                height: 1.4,
                color: const Color(0xFF2F6B49),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(_NotifItem item, double s) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 11 * s),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line, width: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24 * s,
            height: 24 * s,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(7 * s),
              border: Border.all(color: item.iconBorder, width: 0.8),
            ),
            child: Icon(item.icon, size: 11 * s, color: item.iconColor),
          ),
          SizedBox(width: 9 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 7.5 * s,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 6 * s, color: _muted),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * s),
          Text(
            item.time,
            style: TextStyle(fontSize: 6 * s, color: _muted),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color iconBorder;
  final String title;
  final String subtitle;
  final String time;

  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.iconBorder,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
