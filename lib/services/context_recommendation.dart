import '../state/app_settings.dart';

enum TeduhActivity { sekolah, bekerja, olahraga, perjalanan, rumah }

extension TeduhActivityX on TeduhActivity {
  String get label {
    switch (this) {
      case TeduhActivity.sekolah:
        return 'Sekolah/kuliah';
      case TeduhActivity.bekerja:
        return 'Bekerja';
      case TeduhActivity.olahraga:
        return 'Olahraga';
      case TeduhActivity.perjalanan:
        return 'Perjalanan';
      case TeduhActivity.rumah:
        return 'Aktivitas rumah';
    }
  }
}

enum RiskLevel { aman, waspada, tinggi, sangatTinggi }

class ContextRecommendation {
  final RiskLevel level;
  final String levelLabel;
  final String headline;
  final String headlineSimple;
  final String reason;
  final String reasonSimple;
  final List<String> steps;
  final List<String> alternatives;

  const ContextRecommendation({
    required this.level,
    required this.levelLabel,
    required this.headline,
    required this.headlineSimple,
    required this.reason,
    required this.reasonSimple,
    required this.steps,
    required this.alternatives,
  });

  String spoken({required bool simple}) {
    final b = StringBuffer()
      ..write(simple ? headlineSimple : headline)
      ..write('. ')
      ..write(simple ? reasonSimple : reason)
      ..write(' Yang perlu dilakukan: ')
      ..write(steps.join('. '))
      ..write('. Alternatif: ')
      ..write(alternatives.join('. '))
      ..write('.');
    return b.toString();
  }
}

class ContextRecommender {
  ContextRecommender._();

  static String timeOfDay(DateTime t) {
    if (t.hour < 11) return 'pagi';
    if (t.hour < 15) return 'siang';
    if (t.hour < 18) return 'sore';
    return 'malam';
  }

  static ContextRecommendation build({
    required AirSnapshot air,
    required TeduhActivity activity,
    bool sensitive = false,
  }) {
    final RiskLevel level = air.ispu <= 100
        ? RiskLevel.aman
        : air.ispu <= 200
            ? RiskLevel.waspada
            : air.ispu <= 300
                ? RiskLevel.tinggi
                : RiskLevel.sangatTinggi;
    final label = const {
      RiskLevel.aman: 'Aman',
      RiskLevel.waspada: 'Perlu kewaspadaan',
      RiskLevel.tinggi: 'Risiko tinggi',
      RiskLevel.sangatTinggi: 'Risiko sangat tinggi',
    }[level]!;

    final pm = air.pm25;
    final bad = level != RiskLevel.aman;
    final extra = sensitive && bad
        ? ' Karena kamu sensitif terhadap polusi, ambil langkah ini lebih '
            'awal dan lebih ketat.'
        : '';

    String headline;
    String headlineSimple;
    String reason;
    String reasonSimple;
    List<String> steps;
    List<String> alts;

    if (!bad) {
      headline = 'Kondisi udara mendukung aktivitas ${activity.label.toLowerCase()}';
      headlineSimple = 'Udara cukup bersih. Kamu boleh beraktivitas.';
      reason = 'ISPU ${air.ispu} (PM2.5 $pm) masih dalam batas aman.';
      reasonSimple = 'Jumlah partikel polusi di udara masih sedikit.';
      steps = [
        'Lanjutkan aktivitas seperti biasa',
        'Periksa kembali kualitas udara bila langit mulai berkabut',
      ];
      alts = ['Tidak perlu mengubah rencana'];
    } else {
      switch (activity) {
        case TeduhActivity.olahraga:
          headline = 'Sebaiknya tunda olahraga di luar ruangan';
          headlineSimple = 'Jangan berolahraga di luar dulu.';
          reason = 'ISPU ${air.ispu} (PM2.5 $pm). Aktivitas fisik berat '
              'meningkatkan jumlah udara yang dihirup sehingga paparan '
              'partikulat juga meningkat.$extra';
          reasonSimple = 'Saat berolahraga, kamu menghirup lebih banyak udara '
              'kotor. Jumlah partikel polusi kecil sedang sangat banyak.';
          steps = [
            'Tunda olahraga di luar ruangan',
            'Hindari area yang terpapar asap',
            'Periksa kembali kualitas udara sebelum beraktivitas',
          ];
          alts = [
            'Pilih olahraga ringan di dalam ruangan dengan udara yang lebih bersih',
            'Lakukan peregangan atau latihan pernapasan santai di rumah',
          ];
          break;
        case TeduhActivity.sekolah:
          headline = 'Periksa kondisi udara sebelum berangkat';
          headlineSimple = 'Cek udara dulu sebelum berangkat.';
          reason = 'ISPU ${air.ispu} (PM2.5 $pm). Perjalanan dan kegiatan di '
              'luar kelas meningkatkan paparan asap.$extra';
          reasonSimple = 'Udara di luar sedang kotor, jadi perjalanan ke '
              'sekolah perlu dijaga.';
          steps = [
            'Periksa kondisi udara sebelum berangkat',
            'Jika harus keluar, gunakan respirator yang sesuai dan terpasang dengan baik',
            'Pilih perjalanan yang mengurangi paparan asap',
            'Ikuti informasi sekolah dan otoritas setempat jika ada pembatasan aktivitas',
          ];
          alts = [
            'Tanyakan apakah pembelajaran bisa dilakukan dari rumah',
            'Hindari kegiatan olahraga dan upacara di luar ruangan',
          ];
          break;
        case TeduhActivity.bekerja:
          headline = 'Kurangi aktivitas kerja di luar ruangan';
          headlineSimple = 'Kurangi kerja di luar ruangan.';
          reason = 'ISPU ${air.ispu} (PM2.5 $pm). Pekerjaan di luar ruangan '
              'membuat paparan partikulat berlangsung lama.$extra';
          reasonSimple = 'Bekerja lama di luar membuat kamu menghirup banyak '
              'partikel polusi.';
          steps = [
            'Prioritaskan pekerjaan di dalam ruangan',
            'Jika harus di luar, gunakan respirator yang sesuai dan terpasang dengan baik',
            'Batasi waktu di luar dan sering istirahat di ruang bersih',
          ];
          alts = [
            'Bicarakan opsi kerja dari rumah dengan atasan',
            'Geser tugas lapangan ke waktu ketika udara lebih baik',
          ];
          break;
        case TeduhActivity.perjalanan:
          headline = 'Tunda perjalanan yang tidak mendesak';
          headlineSimple = 'Tunda perjalanan yang tidak penting.';
          reason = 'ISPU ${air.ispu} (PM2.5 $pm). Asap juga dapat mengurangi '
              'jarak pandang dan memperbesar paparan di perjalanan.$extra';
          reasonSimple = 'Asap membuat jalan sulit dilihat dan udara di '
              'jalan kotor.';
          steps = [
            'Tunda perjalanan yang tidak mendesak',
            'Jika harus pergi, gunakan respirator yang sesuai dan tutup jendela kendaraan',
            'Hindari rute yang dekat sumber asap',
            'Periksa kembali kualitas udara sebelum berangkat',
          ];
          alts = [
            'Gunakan layanan antar atau kerja jarak jauh bila memungkinkan',
          ];
          break;
        case TeduhActivity.rumah:
          headline = 'Lindungi udara di dalam rumah';
          headlineSimple = 'Jaga udara di dalam rumah tetap bersih.';
          reason = 'ISPU ${air.ispu} (PM2.5 $pm). Asap dapat masuk lewat '
              'celah pintu dan jendela.$extra';
          reasonSimple = 'Asap bisa masuk ke rumah lewat pintu dan jendela.';
          steps = [
            'Tutup pintu dan jendela',
            'Gunakan penyaring udara (HEPA) bila tersedia',
            'Hindari membakar sampah, dupa, atau menyalakan lilin',
            'Pantau anggota keluarga yang rentan seperti anak, lansia, atau penderita asma',
          ];
          alts = [
            'Siapkan satu ruangan paling tertutup sebagai ruang bersih',
            'Tunda menjemur pakaian di luar',
          ];
          break;
      }
      if (level == RiskLevel.sangatTinggi) {
        steps = [
          ...steps,
          'Segera cari bantuan medis bila sesak napas, nyeri dada, atau sangat lemas',
        ];
      }
    }

    return ContextRecommendation(
      level: level,
      levelLabel: label,
      headline: headline,
      headlineSimple: headlineSimple,
      reason: reason,
      reasonSimple: reasonSimple,
      steps: steps,
      alternatives: alts,
    );
  }
}

class ActivityChoice {
  ActivityChoice._();
  static TeduhActivity current = TeduhActivity.olahraga;
  static bool sensitive = false;
}
