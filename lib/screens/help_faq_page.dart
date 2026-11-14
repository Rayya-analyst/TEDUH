import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_settings.dart';
import '../widgets/coach_marks.dart';
import '../widgets/teduh_common.dart';
import '../widgets/teduh_drawer.dart';
import '../widgets/teduh_header.dart';
import '../widgets/voice_scope.dart';

class _Faq {
  final String question;
  final String answer;
  final String highlight;
  final String category;

  const _Faq(
    this.question,
    this.answer,
    this.highlight, {
    required this.category,
  });
}

const List<_Faq> _faqs = [
  _Faq(
    'Apa itu ISPU dan bagaimana cara membacanya?',
    'ISPU (Indeks Standar Pencemar Udara) adalah angka tanpa satuan yang digunakan untuk menggambarkan kondisi mutu udara ambien di lokasi tertentu berdasarkan dampak terhadap kesehatan manusia dan lingkungan. Rentang nilainya: 0–50 (Baik), 51–100 (Sedang), 101–200 (Tidak Sehat), 201–300 (Sangat Tidak Sehat), dan >300 (Berbahaya).',
    '0–50: Aman untuk semua aktivitas luar ruangan.',
    category: 'ISPU & Udara',
  ),
  _Faq(
    'Apa perbedaan ISPU Baik, Sedang, Tidak Sehat, dan Berbahaya?',
    'Baik (0-50): Tingkat mutu udara tidak berdampak pada kesehatan manusia/hewan. Sedang (51-100): Tidak berpengaruh pada kesehatan umum, kelompok sangat sensitif mungkin perlu waspada. Tidak Sehat (101-200): Mulai merugikan kelompok rentan seperti penderita asma, anak-anak, lansia. Sangat Tidak Sehat (201-300): Meningkatkan risiko kesehatan pada seluruh populasi. Berbahaya (>300): Tingkat darurat beracun yang memerlukan evakuasi atau isolasi ruang bersih.',
    'Warna indeks berubah dari hijau, kuning, oranye, merah, hingga merah tua pekat.',
    category: 'ISPU & Udara',
  ),
  _Faq(
    'Apa itu partikel PM2.5 dan mengapa paling berbahaya saat kebakaran lahan?',
    'PM2.5 adalah partikulat udara berukuran 2,5 mikrometer atau lebih kecil (sekitar 1/30 diameter rambut manusia). Saat kebakaran hutan dan lahan (karhutla), pembakaran biomassa gambut menghasilkan asap pekat yang kaya PM2.5. Partikel ini dapat menembus alveoli paru-paru dan masuk ke peredaran darah perifer.',
    'PM2.5 dapat menyebabkan ISPA, memicu serangan asma, dan meningkatkan risiko kardiovaskular.',
    category: 'ISPU & Udara',
  ),
  _Faq(
    'Kapan saya wajib memakai masker?',
    'Anda disarankan memakai masker ketika ISPU melebihi 100 (Kategori Tidak Sehat), terutama jika berada di luar ruangan. Untuk kelompok rentan (anak-anak, ibu hamil, lansia, penderita asma/PPOK), masker disarankan sejak ISPU mendekati 80.',
    'Gunakan masker respirator N95/KN95 saat kabut asap pekat.',
    category: 'ISPU & Udara',
  ),
  _Faq(
    'Apakah masker kain atau bedah efektif untuk kabut asap karhutla?',
    'Masker kain biasa dan masker bedah 3-ply hanya menyaring partikel kasar (debu jalanan, droplet liur). Partikel halus PM2.5 dari kabut asap karhutla dapat menembus pori-pori masker kain. Disarankan memakai respirator berstandar N95, KN95, atau KF94 dengan kerapatan tepi yang pas di wajah.',
    'Masker bedah hanya pilihan darurat jika N95 tidak tersedia.',
    category: 'ISPU & Udara',
  ),
  _Faq(
    'Apa yang dimaksud dengan polutan kritis (Critical Pollutant)?',
    'Polutan kritis adalah parameter pencemar udara yang memiliki nilai sub-indeks tertinggi pada periode pengukuran tertentu. Parameter penentu ISPU di Indonesia mencakup PM2.5, PM10, Karbon Monoksida (CO), Nitrogen Dioksida (NO2), Sulfur Dioksida (SO2), dan Ozon (O3). Angka ISPU akhir ditentukan oleh polutan dengan skor tertinggi ini.',
    'Saat musim kemarau dan karhutla, PM2.5 hampir selalu menjadi polutan kritis.',
    category: 'ISPU & Udara',
  ),
  _Faq(
    'Mengapa angka ISPU di TEDUH berbeda dengan aplikasi lain seperti AQI US?',
    'Standar ISPU Indonesia mengacu pada Peraturan Menteri LHK No. 14 Tahun 2020 dengan batas breakpoint konsentrasi yang telah disesuaikan dengan kondisi geografis dan regulasi nasional Indonesia. Banyak aplikasi luar negeri menggunakan standar US AQI (EPA) atau CAQI Eropa yang memiliki skala dan rumus konversi breakpoint berbeda.',
    'TEDUH menampilkan ISPU resmi nasional KLHK agar konsisten dengan peringatan otoritas Indonesia.',
    category: 'ISPU & Udara',
  ),
  _Faq(
    'Bagaimana kualitas udara mempengaruhi anak-anak dibanding orang dewasa?',
    'Anak-anak bernapas lebih cepat dan menghirup lebih banyak volume udara per kilogram berat badan dibanding orang dewasa. Saluran napas mereka masih dalam masa pertumbuhan dan sistem imunitasnya belum matang, sehingga lebih rentan mengalami bronkitis, serangan asma akut, dan infeksi pernapasan akibat kabut asap.',
    'Batasi jam bermain luar ruangan saat ISPU berada di atas 100.',
    category: 'ISPU & Udara',
  ),
  _Faq(
    'Apa itu Ruang Bersih (Clean Air Room) di rumah?',
    'Ruang bersih adalah satu ruangan di rumah (biasanya kamar tidur) yang jendelanya ditutup rapat, ventilasi disaring dengan kain basah atau filter HEPA, dan tidak ada sumber pembakaran internal (rokok, obat nyamuk bakar, lilin). Ruangan ini berfungsi sebagai tempat perlindungan dari kabut asap.',
    'Gunakan pembersih udara berfilter HEPA dan lap permukaan dengan kain lembap.',
    category: 'ISPU & Udara',
  ),
  _Faq(
    'Kapan sekolah atau perkantoran disarankan diliburkan/WFR?',
    'Sesuai protokol penanggulangan karhutla, saat ISPU menyentuh kategori Sangat Tidak Sehat (201-300), aktivitas fisik luar ruangan harus dihentikan total. Jika ISPU menembus kategori Berbahaya (>300), otoritas daerah merekomendasikan pembelajaran jarak jauh (PJJ) dan pembatasan kerja fisik.',
    'Pantau surat edaran dinas pendidikan dan BPBD setempat melalui TEDUH.',
    category: 'ISPU & Udara',
  ),

  _Faq(
    'Mengapa TEDUH meminta izin akses lokasi?',
    'TEDUH memerlukan akses lokasi perangkat (GPS) untuk mendeteksi stasiun pemantau KLHK terdekat dan menyajikan data kualitas udara, prakiraan cuaca, serta peringatan kabut asap yang paling relevan dengan posisi Anda saat ini.',
    'Akses lokasi hanya digunakan untuk menentukan koordinat wilayah Anda.',
    category: 'GPS & Lokasi',
  ),
  _Faq(
    'Apa perbedaan "Saat aplikasi digunakan", "Hanya kali ini", dan "Jangan izinkan"?',
    '"Saat aplikasi digunakan": TEDUH akan otomatis memperbarui data udara ketika Anda membuka aplikasi. "Hanya kali ini": Izin diberikan satu kali pada sesi ini dan akan diminta lagi nanti. "Jangan izinkan": Akses GPS ditolak, dan TEDUH tetap berfungsi menggunakan wilayah manual yang Anda pilih.',
    'Anda dapat mengubah preferensi perizinan kapan saja di Pengaturan perangkat.',
    category: 'GPS & Lokasi',
  ),
  _Faq(
    'Apa yang terjadi jika saya memilih "Jangan izinkan"?',
    'Aplikasi tidak akan memaksa atau mengubah lokasi Anda secara sepihak. Lokasi aktif Anda akan tetap menggunakan wilayah manual terakhir yang Anda tentukan atau wilayah default. Anda dapat mencari dan memilih kota/kabupaten di seluruh Indonesia melalui menu Pilih Wilayah.',
    'Lokasi manual tetap 100% valid tanpa memerlukan GPS.',
    category: 'GPS & Lokasi',
  ),
  _Faq(
    'Bagaimana jika izin lokasi ditolak secara permanen ("Never Allow")?',
    'Jika izin ditolak permanen pada tingkat sistem Android, sistem operasi tidak akan menampilkan dialog izin lagi. Anda dapat mengaktifkannya kembali dengan mengetuk opsi "Buka Pengaturan" yang disediakan di TEDUH untuk membuka menu Izin Aplikasi di setelan Android.',
    'Pilih "Buka Pengaturan" › Izin › Lokasi › Izinkan saat aplikasi digunakan.',
    category: 'GPS & Lokasi',
  ),
  _Faq(
    'Mengapa GPS mendeteksi lokasi saya kurang presisi?',
    'Akurasi GPS bergantung pada sinyal satelit, kondisi cuaca, gedung tinggi, dan mode hemat baterai perangkat. Jika Anda berada di dalam ruangan beratap tebal, aktifkan mode Akurasi Tinggi (Wi-Fi & Bluetooth scanning) di pengaturan perangkat Anda.',
    'Anda juga dapat memilih nama kecamatan secara manual melalui bilah pencarian.',
    category: 'GPS & Lokasi',
  ),
  _Faq(
    'Apakah TEDUH melacak lokasi saya di latar belakang (background tracking)?',
    'Tidak. TEDUH tidak melacak pergerakan koordinat Anda secara terus menerus di latar belakang. Lokasi hanya dibaca saat Anda membuka aplikasi atau saat Anda menekan tombol "Gunakan Lokasi Saat Ini".',
    'Privasi dan efisiensi baterai perangkat Anda adalah prioritas kami.',
    category: 'GPS & Lokasi',
  ),
  _Faq(
    'Bagaimana cara berpindah ke kota atau provinsi lain di luar lokasi saya?',
    'Buka menu samping atau ketuk nama lokasi di bagian atas layar, lalu gunakan bilah pencarian untuk mengetik nama kota, kabupaten, atau kecamatan di seluruh Indonesia. Pilih dari hasil pencarian dan konfirmasi pilihan Anda.',
    'TEDUH kini mendukung seluruh 38 provinsi di Indonesia.',
    category: 'GPS & Lokasi',
  ),
  _Faq(
    'Apakah saya bisa menggunakan TEDUH jika layanan GPS perangkat dimatikan?',
    'Ya, tentu saja. TEDUH dirancang untuk tetap dapat digunakan sepenuhnya tanpa layanan GPS. Cukup pilih provinsi dan kota tujuan Anda dari daftar wilayah populer atau cari melalui bilah pencarian.',
    'Semua data kualitas udara, riwayat, dan panduan tetap dapat diakses.',
    category: 'GPS & Lokasi',
  ),

  _Faq(
    'Dari mana sumber resmi angka ISPU di aplikasi TEDUH?',
    'Angka ISPU resmi pada aplikasi TEDUH berasal dari stasiun pemantau kualitas udara otomatis (SPKU) milik Kementerian Lingkungan Hidup dan Kehutanan (KLHK) Republik Indonesia yang disinkronkan secara berkala.',
    'KLHK adalah otoritas resmi tunggal pembacaan ISPU di Indonesia.',
    category: 'Data & Sumber',
  ),
  _Faq(
    'Seberapa sering data ISPU diperbarui?',
    'Stasiun pemantau KLHK melakukan pembaruan data setiap 1 jam sekali. Di TEDUH, Anda dapat menarik layar ke bawah (pull-to-refresh) untuk menyinkronkan data pembacaan terbaru.',
    'Waktu pembaruan terakhir selalu tertera di kartu utama TEDUH NOW.',
    category: 'Data & Sumber',
  ),
  _Faq(
    'Apa perbedaan antara pengukuran stasiun fisik dengan data model satelit CAMS?',
    'Stasiun fisik KLHK mengukur konsentrasi polutan langsung di permukaan tanah pada titik koordinat stasiun. Sedangkan Copernicus CAMS adalah model numerik atmosfer berbasis asimilasi data satelit Eropa yang mengestimasi konsentrasi udara dalam grid area yang luas.',
    'TEDUH membedakan secara jujur antara stasiun resmi fisik dengan data estimasi model.',
    category: 'Data & Sumber',
  ),
  _Faq(
    'Mengapa ada stasiun yang menampilkan status "Data Tidak Tersedia"?',
    'Hal ini dapat terjadi jika stasiun pemantau fisik sedang dalam masa kalibrasi sensor berkala, gangguan listrik akibat cuaca ekstrem, atau transmisi jaringan internet stasiun terputus. TEDUH tidak pernah mengarang angka dummy jika stasiun sedang offline.',
    'Kami menampilkan status jujur beserta waktu pembacaan terakhir yang valid.',
    category: 'Data & Sumber',
  ),
  _Faq(
    'Apakah data Open-Meteo merupakan data resmi KLHK?',
    'Bukan. Open-Meteo menyediakan pemodelan atmosfer CAMS (Copernicus Atmosphere Monitoring Service) global. Nilai dari Open-Meteo di TEDUH diberi label jelas sebagai "Estimasi Model Atmosfer" dan bukan pengukuran stasiun fisik resmi.',
    'Label transparansi sumber selalu ditampilkan di setiap halaman data.',
    category: 'Data & Sumber',
  ),
  _Faq(
    'Mengapa opsi sensor komunitas IoT tidak lagi memiliki angka ISPU buatan?',
    'Sesuai regulasi Permen LHK 14/2020, indeks ISPU resmi hanya dapat dihitung dari instrumen referensi berstandar baku mutu. Sensor komunitas berbiaya rendah (low-cost IoT) bermanfaat untuk indikasi tren lokal tetapi tidak memiliki sertifikasi penghitungan ISPU resmi.',
    'Kami menjaga integritas ilmiah data dengan tidak menyimulasikan angka ISPU palsu.',
    category: 'Data & Sumber',
  ),
  _Faq(
    'Bagaimana cara memastikan data yang saya lihat adalah data terbaru?',
    'Perhatikan timestamp pada bagian bawah kartu kondisi udara (contoh: "13 Nov 2026, 08.00 WIB"). Anda juga dapat menyapu layar ke bawah (pull to refresh) untuk memicu pengambilan data terbaru.',
    'Jika aplikasi sedang offline, badge "Cache lokal (offline)" akan muncul.',
    category: 'Data & Sumber',
  ),
  _Faq(
    'Apakah data kualitas udara TEDUH dapat digunakan untuk rujukan medis?',
    'Data kualitas udara TEDUH menyajikan indikasi lingkungan berdasarkan standar resmi lingkungan hidup untuk langkah pencegahan mandiri. Untuk diagnosis, gejala sesak napas berat, atau penanganan klinis, selalu konsultasikan dengan dokter atau fasilitas kesehatan.',
    'TEDUH adalah alat bantu kesiapsiagaan dan perlindungan lingkungan.',
    category: 'Data & Sumber',
  ),

  _Faq(
    'Bagaimana cara membaca peta sebaran udara di TEDUH?',
    'Peta kualitas udara TEDUH menampilkan visualisasi sebaran polusi dengan kode warna ISPU standar. Anda dapat memperbesar (zoom in), menggeser wilayah, dan mengetuk titik stasiun untuk melihat rincian angka ISPU di lokasi tersebut.',
    'Hijau: Baik, Kuning: Sedang, Oranye: Tidak Sehat, Merah: Sangat Tidak Sehat.',
    category: 'Peta & Satelit',
  ),
  _Faq(
    'Apa itu titik panas (Hotspot) NASA FIRMS pada peta?',
    'NASA FIRMS (Fire Information for Resource Management System) mendeteksi radiasi termal permukaan bumi dari sensor satelit MODIS dan VIIRS. Titik panas mengindikasikan adanya kebakaran vegetasi aktif atau anomali termal di permukaan bumi.',
    'Hotspot adalah indikator titik api, BUKAN konsentrasi PM2.5 atau ISPU.',
    category: 'Peta & Satelit',
  ),
  _Faq(
    'Apa perbedaan antara Titik Panas (Hotspot) dengan Ketebalan Aerosol (AOD)?',
    'Titik panas (hotspot) menunjukkan lokasi api yang sedang menyala di tanah. Aerosol Optical Depth (AOD) dari satelit Copernicus mengukur seberapa banyak sinar matahari terhalang oleh partikel kabut asap di kolom udara vertikal atmosfer.',
    'Hotspot = sumber api; AOD = sebaran kolom asap di langit.',
    category: 'Peta & Satelit',
  ),
  _Faq(
    'Mengapa ada kabut asap pekat padahal di dekat saya tidak ada hotspot?',
    'Asap kebakaran hutan dapat terbawa oleh arah angin melintasi jarak ratusan kilometer (transboundary haze). Partikel PM2.5 yang sangat ringan dapat melayang berhari-hari di atmosfer mengikuti pola monsun sebelum turun ke permukaan.',
    'Periksa arah dan kecepatan angin pada kartu cuaca TEDUH NOW.',
    category: 'Peta & Satelit',
  ),
  _Faq(
    'Bagaimana cara beralih antara tampilan peta Standar dan Satelit?',
    'Ketuk ikon Lapisan (Layers) di pojok kanan bilah kontrol peta. Anda dapat memilih tipe dasar peta (Peta Jalan Vektor atau Citra Satelit Bumi) serta mengaktifkan/menonaktifkan layer stasiun dan titik panas.',
    'Mode satelit sangat berguna untuk melihat tutupan lahan gambut dan bekas bakar.',
    category: 'Peta & Satelit',
  ),
  _Faq(
    'Apakah peta dapat digunakan saat perangkat sedang tidak terhubung internet?',
    'Peta dasar memerlukan koneksi internet untuk memuat ubin peta online. Namun jika Anda telah mengunduh paket wilayah di menu Mode Offline, data koordinat stasiun, ringkasan kualitas udara, dan rekomendasi tetap dapat dibuka.',
    'Unduh paket wilayah offline sebelum bepergian ke area minim sinyal.',
    category: 'Peta & Satelit',
  ),

  _Faq(
    'Apa itu fitur Analisis AI di aplikasi TEDUH?',
    'Analisis AI adalah modul komputasi cerdas yang menggabungkan pembacaan stasiun pemantau, pemodelan atmosfer CAMS, profil kerentanan pengguna, serta basis pengetahuan kesehatan lingkungan untuk menghasilkan rekomendasi tindakan perlindungan yang terukur.',
    'Menyediakan analisis multi-sumber, tren 24 jam, dan panduan mitigasi.',
    category: 'Analisis AI',
  ),
  _Faq(
    'Apa perbedaan antara Analisis AI dan Asisten AI TEDUH?',
    'Analisis AI adalah dasbor visual berbasis data analitik yang menyajikan ringkasan kondisi, grafik tren, dan tingkat risiko aktivitas. Sedangkan Asisten AI adalah antarmuka percakapan tanya-jawab di mana Anda dapat berkonsultasi mengenai gejala kesehatan, masker, dan kesiapsiagaan.',
    'Gunakan Analisis AI untuk gambaran besar data, gunakan Asisten AI untuk bertanya langsung.',
    category: 'Analisis AI',
  ),
  _Faq(
    'Dari mana Asisten AI memperoleh pengetahuannya?',
    'Asisten AI TEDUH ditenagai basis pengetahuan (Knowledge Base) terverifikasi yang bersumber dari pedoman Kementerian Kesehatan RI, KLHK, WHO, CDC, serta penelitian ilmiah respirasi dan gambut tropis. Asisten menerapkan grounding ketat agar tidak memberikan halusinasi.',
    'Jawaban disertai rujukan dokumen resmi yang transparan.',
    category: 'Analisis AI',
  ),
  _Faq(
    'Apakah Asisten AI dapat digunakan tanpa koneksi internet (offline)?',
    'Ya. TEDUH dilengkapi mesin fallback pengetahuan luring (offline knowledge engine) yang menyimpan puluhan dokumen inti mitigasi kabut asap di dalam memori lokal aplikasi, sehingga tetap dapat menjawab pertanyaan penting saat listrik/sinyal padam.',
    'Pertanyaan seputar masker, ruang aman, dan penanganan asap tetap terjawab saat offline.',
    category: 'Analisis AI',
  ),
  _Faq(
    'Bagaimana Asisten AI menyesuaikan saran dengan kondisi kesehatan saya?',
    'Jika Anda mengisi Profil Kesiapsiagaan (misalnya menandai riwayat asma, lansia, atau ibu hamil), Asisten AI secara otomatis meningkatkan tingkat kehati-hatian dalam rekomendasi aktivitas luar ruangan dan ambang batas pemakaian masker.',
    'Perbarui data Anda di menu Profil untuk rekomendasi yang lebih personal.',
    category: 'Analisis AI',
  ),
  _Faq(
    'Apakah Asisten AI dapat meresepkan obat-obatan?',
    'Tidak. Asisten AI dilarang keras meresepkan obat keras atau mengubah dosis obat dokter. Asisten hanya memberikan panduan pencegahan lingkungan, pertolongan pertama non-invasif, dan menyarankan kapan harus segera pergi ke IGD/Puskesmas.',
    'Segera hubungi faskes terdekat jika mengalami sesak napas berat.',
    category: 'Analisis AI',
  ),

  _Faq(
    'Apa itu Mode Offline dan bagaimana cara kerjanya?',
    'Mode Offline adalah fitur andalan TEDUH yang memungkinkan Anda menyimpan data kualitas udara terakhir, panduan darurat karhutla, SOP ruang bersih, serta nomor telepon darurat faskes ke penyimpanan lokal perangkat sebelum terjadi pemadaman listrik/sinyal.',
    'Dapat diakses kapan saja tanpa kuota internet atau jaringan seluler.',
    category: 'Mode Offline',
  ),
  _Faq(
    'Bagaimana cara mengunduh paket data wilayah offline?',
    'Buka menu Profil atau menu samping, pilih "Kelola Unduhan" atau "Mode Offline". Pilih provinsi yang ingin Anda simpan (misalnya Kalimantan Tengah atau DKI Jakarta), lalu ketuk tombol "Unduh Paket". Ukuran paket sangat ringan (kurang dari 1 MB).',
    'Aplikasi akan mengunduh data pembacaan, dokumen RAG, dan kontak resmi.',
    category: 'Mode Offline',
  ),
  _Faq(
    'Apakah paket data offline perlu diperbarui berkala?',
    'Ya. Data kualitas udara memiliki masa kedaluwarsa. TEDUH menandai data yang lebih lama dari 24 jam dengan label "Kedaluwarsa" agar pengguna tahu bahwa data tersebut bukan kondisi menit ini melainkan acuan darurat terakhir.',
    'Perbarui paket offline seminggu sekali atau saat musim asap mulai tiba.',
    category: 'Mode Offline',
  ),
  _Faq(
    'Apa saja yang tersimpan di dalam paket offline?',
    'Paket mencakup: (1) Snapshot pembacaan ISPU dan polutan terakhir, (2) Dokumen panduan respirator N95 & pembuatan filter DIY, (3) Panduan ruang aman rumah tangga, (4) Daftar kontak darurat BPBD, Damkar, Rumah Sakit terverifikasi, dan (5) Rencana darurat pribadi.',
    'Semua data disimpan dalam basis data aman di memori perangkat.',
    category: 'Mode Offline',
  ),
  _Faq(
    'Bagaimana cara menghapus paket data offline untuk menghemat memori?',
    'Masuk ke halaman "Kelola Unduhan", temukan wilayah yang paketnya sudah terunduh, lalu ketuk ikon tempat sampah atau tombol "Hapus Data". Memori lokal perangkat Anda akan langsung dibebaskan.',
    'Ukuran paket rata-rata hanya berkisar antara 20 KB hingga 150 KB.',
    category: 'Mode Offline',
  ),
  _Faq(
    'Apa itu Tas Siaga Bencana Kabut Asap di TEDUH READY?',
    'Tas Siaga adalah daftar periksa (checklist) perlengkapan penting yang harus disiapkan sebelum bencana asap terjadi, mencakup stok masker N95, obat asma rutin, cairan pembersih mata, dokumen penting tahan air, senter, peluit darurat, dan makanan kering.',
    'Pantau progres kelengkapan tas siaga Anda di menu TEDUH READY.',
    category: 'Kesiapsiagaan',
  ),
  _Faq(
    'Bagaimana cara mengatur Rencana Darurat Keluarga?',
    'Buka menu TEDUH READY › Rencana Darurat. Anda dapat mengisi titik kumpul evakuasi keluarga, kontak darurat kerabat di luar kota, faskes rujukan utama, serta daftar anggota keluarga yang memiliki kebutuhan khusus (bayi, disabilitas, lansia).',
    'Rencana darurat dapat dicetak atau dibagikan secara offline.',
    category: 'Kesiapsiagaan',
  ),
  _Faq(
    'Apa fungsi pengaturan Disabilitas dan Aksesibilitas di TEDUH?',
    'TEDUH menyediakan fitur inklusivitas ramah disabilitas seperti mode teks kontras tinggi, pembaca layar (voice navigation), navigasi suara berbahasa Indonesia (id-ID), serta bahasa sederhana (cognitive accessibility) untuk membantu semua lapisan masyarakat.',
    'Aktifkan di menu Profil › Pengaturan Aksesibilitas.',
    category: 'Kesiapsiagaan',
  ),
  _Faq(
    'Bagaimana cara mengaktifkan notifikasi peringatan udara buruk?',
    'Buka menu Profil › Notifikasi, lalu aktifkan sakelar "Peringatan Kualitas Udara". Anda dapat memilih batas ambang ISPU (misalnya saat menyentuh Tidak Sehat >100) agar aplikasi mengirimkan notifikasi peringatan dini.',
    'Notifikasi membantu Anda bersiap memakai masker sebelum berangkat kerja/sekolah.',
    category: 'Kesiapsiagaan',
  ),
  _Faq(
    'Apakah data pribadi profil saya aman di aplikasi TEDUH?',
    'Ya. Seluruh data profil kesiapsiagaan, riwayat kesehatan yang dimasukkan, serta preferensi tas siaga disimpan secara lokal di perangkat Anda menggunakan penyimpanan terenkripsi SharedPreferences dan tidak dijual ke pihak ketiga.',
    'TEDUH dibangun dengan prinsip privasi dan keselamatan pengguna.',
    category: 'Kesiapsiagaan',
  ),

  _Faq(
    'Nomor darurat nasional apa saja yang bisa dihubungi saat kebakaran lahan?',
    'Dalam kondisi darurat di Indonesia: Panggilan Darurat Nasional Terpadu: 112; Pemadam Kebakaran / Manggala Agni: 113; Ambulans / Kemenkes: 119; SAR / Basarnas: 115; Polisi: 110; BNPB / BPBD: (021) 51010112.',
    'Daftar kontak spesifik per provinsi tersedia di menu Kontak Darurat.',
    category: 'Bantuan Darurat',
  ),
  _Faq(
    'Siapa itu Manggala Agni dan bagaimana perannya saat karhutla?',
    'Manggala Agni adalah Brigade Pengendalian Kebakaran Hutan dan Lahan milik KLHK yang bertugas melakukan pencegahan, pemadaman langsung di lapangan (termasuk pemadaman kebakaran bawah tanah di lahan gambut), serta penanganan pasca-kebakaran.',
    'Nomor posko Manggala Agni daerah tercatat di direktori kontak TEDUH.',
    category: 'Bantuan Darurat',
  ),
  _Faq(
    'Bagaimana cara menghubungi Tim Pengembang & Dukungan TEDUH?',
    'Anda dapat menghubungi layanan bantuan pengguna TEDUH secara langsung melalui tombol WhatsApp "Hubungi Dukungan" di bagian bawah halaman Bantuan ini (nomor resmi: 0895-2978-1378). Layanan beroperasi setiap hari pukul 08.00–20.00 WIB.',
    'Kami siap menerima laporan kendala aplikasi, masukan fitur, dan pertanyaan data.',
    category: 'Bantuan Darurat',
  ),
  _Faq(
    'Bagaimana cara melaporkan titik kebakaran lahan yang saya lihat?',
    'Jika Anda melihat kebakaran lahan aktif, segera hubungi posko Damkar/BPBD terdekat di nomor 113 atau call center 112. Jangan mendekati lokasi kebakaran gambut karena tanah dapat ambles dan menghasilkan gas beracun tak terlihat.',
    'Sampaikan lokasi patokan yang jelas dan tingkat asap di sekitar lokasi.',
    category: 'Bantuan Darurat',
  ),
  _Faq(
    'Apa yang harus dilakukan jika anggota keluarga mengalami sesak napas berat akibat asap?',
    'Segera bawa ke ruangan ber-AC atau ruang berfilter udara bersih, longgarkan pakaian, posisikan duduk setengah tegak, berikan oksigen atau inhaler pereda jika memiliki resep dokter. Jika bibir membiru, bicara terbata-bata, atau mengorok, segera larikan ke IGD rumah sakit terdekat.',
    'Nomor darurat ambulans Kemenkes adalah 119.',
    category: 'Bantuan Darurat',
  ),

  _Faq(
    'Aplikasi tidak bisa memuat data atau muncul pesan "Gagal Memuat"?',
    'Periksa koneksi internet Anda (kuota atau Wi-Fi). Pastikan mode hemat daya agresif tidak mematikan koneksi latar belakang TEDUH. Anda juga dapat mencoba beralih ke Mode Offline untuk melihat data cache yang sudah tersimpan.',
    'Tarik layar ke bawah (pull to refresh) setelah koneksi stabil kembali.',
    category: 'Teknis',
  ),
  _Faq(
    'Suara sambutan atau panduan suara tidak berbunyi, apa penyebabnya?',
    'Pastikan volume Media perangkat Anda tidak dalam posisi bisu (mute). TEDUH menggunakan modul Text-to-Speech resmi bahasa Indonesia (id-ID). Pastikan mesin Google Speech Services atau TTS bawaan di pengaturan Android Anda telah terpasang paket bahasa Indonesia.',
    'Periksa: Pengaturan HP › Sistem › Aksesibilitas › Keluaran Text-to-Speech › Bahasa Indonesia.',
    category: 'Teknis',
  ),
  _Faq(
    'Mengapa ukuran huruf di aplikasi terlalu besar atau terlalu kecil?',
    'Anda dapat menyesuaikan ukuran huruf dan jarak baca sesuai kenyamanan mata di menu Profil › Pengaturan Tampilan › Ukuran Huruf, mulai dari ukuran Kecil, Sedang, hingga Ekstra Besar untuk kemudahan membaca.',
    'Pilihan ukuran teks langsung diterapkan seketika di seluruh halaman.',
    category: 'Teknis',
  ),
  _Faq(
    'Apakah aplikasi TEDUH mengonsumsi baterai yang besar?',
    'Tidak. TEDUH dirancang sangat efisien. Kami tidak menjalankan pelacakan koordinat GPS tanpa henti di latar belakang dan proses rendering grafik dioptimalkan dengan repainting terisolasi sehingga hemat daya baterai.',
    'Aplikasi ini aman digunakan saat kondisi pemadaman listrik berkepanjangan.',
    category: 'Teknis',
  ),
  _Faq(
    'Bagaimana cara membersihkan cache aplikasi TEDUH?',
    'Buka Pengaturan perangkat Android Anda › Aplikasi › TEDUH › Penyimpanan & Cache › Hapus Cache (Clear Cache). Data penting profil dan rencana darurat Anda tidak akan hilang karena tersimpan di SharedPreferences.',
    'Menghapus cache dapat menyegarkan kembali aset gambar jika terjadi galat visual.',
    category: 'Teknis',
  ),
];

class HelpFaqPage extends StatefulWidget {
  const HelpFaqPage({super.key});

  @override
  State<HelpFaqPage> createState() => _HelpFaqPageState();
}

class _HelpFaqPageState extends State<HelpFaqPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchC = TextEditingController();
  final _searchF = FocusNode();
  int? _open = 0;
  String _query = '';
  String _selectedCategory = 'Semua';
  final List<GlobalKey> _hk = List<GlobalKey>.generate(4, (_) => GlobalKey());

  static const List<String> _categories = [
    'Semua',
    'ISPU & Udara',
    'GPS & Lokasi',
    'Data & Sumber',
    'Peta & Satelit',
    'Analisis AI',
    'Mode Offline',
    'Kesiapsiagaan',
    'Bantuan Darurat',
    'Teknis',
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AppSettings.instance.animBehavior,
    )..forward();
  }

  List<CoachStep> get _tour => [
        CoachStep(
          target: _hk[0],
          title: 'Menu dan notifikasi',
          body: 'Ikon tiga garis membuka menu samping. Ikon lonceng membuka '
              'riwayat notifikasi.',
          radius: 22,
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _hk[1],
          title: 'Cari jawaban',
          body: 'Ketik kata kunci seperti masker atau ISPU, dan daftar '
              'pertanyaan langsung menyaring sesuai kata itu.',
          scrollAlignment: 0.1,
        ),
        CoachStep(
          target: _hk[2],
          title: 'Pertanyaan populer',
          body: 'Ketuk sebuah pertanyaan untuk membuka jawabannya, ketuk '
              'lagi untuk menutup.',
          scrollAlignment: 0.2,
        ),
        CoachStep(
          target: _hk[3],
          title: 'Hubungi Tim TEDUH',
          body: 'Ada masalah atau kendala saat memakai aplikasi TEDUH? '
              'Ketuk tombol bulat melayang ini untuk langsung terhubung ke '
              'WhatsApp Dukungan resmi Tim TEDUH.',
          radius: 30,
          scrollAlignment: 0.9,
        ),
      ];

  String _narration() {
    final b = StringBuffer('Ini seluruh isi halaman Bantuan dan FAQ. Ada '
        'kolom pencarian, penyaring kategori, lalu ${_faqs.length} pertanyaan informatif. ');
    for (int i = 0; i < 3 && i < _faqs.length; i++) {
      b.write('Pertanyaan ${i + 1}: ${_faqs[i].question} '
          '${_faqs[i].answer} ');
    }
    b.write('Di bagian bawah ada tombol Hubungi Dukungan WhatsApp Tim TEDUH di nomor 089529781378. ');
    return b.toString();
  }

  Future<void> _contactTeduhWhatsApp(BuildContext context) async {
    const phone = '6289529781378';
    const message =
        'Halo Tim TEDUH,\n\nSaya membutuhkan panduan atau mengalami kendala saat mengakses aplikasi '
        'TEDUH. Mohon bantuan dan arahannya untuk menyelesaikan kendala tersebut.'
        '\n\nTerima kasih.';
    final encoded = Uri.encodeComponent(message);
    final waUri = Uri.parse('https://wa.me/$phone?text=$encoded');
    final fallbackUri = Uri.parse('tel:+$phone');

    try {
      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(const ClipboardData(text: '089529781378'));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'WhatsApp tidak tersedia. Nomor Tim TEDUH (089529781378) '
                'telah disalin ke clipboard.',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kendala membuka WhatsApp: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _searchC.dispose();
    _searchF.dispose();
    super.dispose();
  }

  List<int> get _filtered {
    final q = _query.trim().toLowerCase();
    final cat = _selectedCategory;

    return [
      for (int i = 0; i < _faqs.length; i++)
        if ((cat == 'Semua' || _faqs[i].category == cat) &&
            (q.isEmpty ||
                _faqs[i].question.toLowerCase().contains(q) ||
                _faqs[i].answer.toLowerCase().contains(q) ||
                _faqs[i].highlight.toLowerCase().contains(q) ||
                _faqs[i].category.toLowerCase().contains(q)))
          i,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return VoiceScope(
      screen: 'help',
      tour: _tour,
      guide: PageGuide(
        content: _narration,
        endText: 'Itu seluruh fitur utama TEDUH. Panduan selesai. Kamu tidak '
            'perlu menekan tombol: cukup ucapkan perintah kapan saja, '
            'misalnya buka TEDUH NOW, buka TEDUH ACTION, bacakan kondisi '
            'udara, atau tanyakan apa saja kepada Asisten AI. Ucapkan '
            'ulangi panduan bila ingin mendengar penjelasan ini lagi.',
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFFBFCFA),
        drawerScrimColor: const Color(0x6B1A2622),
        drawer: const TeduhDrawer(current: HomeMenuItem.help),
        floatingActionButton: KeyedSubtree(
          key: _hk[3],
          child: FloatingActionButton(
            heroTag: 'fab_help_contact',
            onPressed: () => _contactTeduhWhatsApp(context),
            backgroundColor: TC.green,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            tooltip: 'Hubungi WhatsApp Tim TEDUH',
            child: const Icon(Icons.support_agent_rounded, size: 28),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: SoftLeavesPainter(_anim, const Color(0xFFDCEADA)),
                ),
              ),
            ),
            NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  backgroundColor: const Color(0xFFFBFCFA),
                  elevation: 0,
                  pinned: true,
                  floating: true,
                  snap: true,
                  toolbarHeight: 64,
                  automaticallyImplyLeading: false,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBFCFA),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SafeArea(
                      bottom: false,
                      child: KeyedSubtree(
                        key: _hk[0],
                        child: TeduhHeader(
                          accent: 'FAQ',
                          subtitle: 'Pusat bantuan & tanya jawab',
                          onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Reveal(
              animation: _anim,
              begin: 0.1,
              end: 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pusat Bantuan & FAQ',
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C3A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_faqs.length} panduan terverifikasi untuk napas lebih tenang.',
                    style: GoogleFonts.poppins(fontSize: 11.5, color: TC.hint),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Reveal(
              animation: _anim,
              begin: 0.2,
              end: 0.55,
              child: KeyedSubtree(
                key: _hk[1],
                child: AnimatedBuilder(
                  animation: _searchF,
                  builder: (context, _) {
                    final focused = _searchF.hasFocus;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: focused ? TC.green : TC.border,
                          width: focused ? 1.2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              size: 22, color: TC.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchC,
                              focusNode: _searchF,
                              cursorColor: TC.green,
                              textInputAction: TextInputAction.search,
                              onChanged: (v) => setState(() => _query = v),
                              style: GoogleFonts.poppins(
                                  fontSize: 12.5, color: TC.dark),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: 'Cari pertanyaan, masker, ISPU, GPS...',
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 12.5, color: TC.hint),
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchC.clear();
                                setState(() => _query = '');
                              },
                              child: const Icon(Icons.close_rounded,
                                  size: 20, color: TC.hint),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (final cat in _categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: _selectedCategory == cat
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _selectedCategory == cat
                                ? Colors.white
                                : TC.greenDeep,
                          ),
                        ),
                        selected: _selectedCategory == cat,
                        selectedColor: TC.greenDeep,
                        backgroundColor: TC.iconBox,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: _selectedCategory == cat
                                ? TC.greenDeep
                                : TC.border,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                              _open = null;
                            });
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory == 'Semua'
                      ? 'Semua Pertanyaan (${items.length})'
                      : 'Kategori: $_selectedCategory (${items.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C3A2E),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchC.clear();
                      setState(() {
                        _query = '';
                        _selectedCategory = 'Semua';
                      });
                    },
                    child: Text(
                      'Reset filter',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TC.green,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 34, color: TC.hint),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada hasil untuk "$_query" pada kategori $_selectedCategory',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 12, color: TC.hint),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (int k = 0; k < items.length; k++) ...[
                Reveal(
                  animation: _anim,
                  begin: 0.25 + (k % 8) * 0.04,
                  end: 0.65 + (k % 8) * 0.04,
                  child: KeyedSubtree(
                    key: k == 0 ? _hk[2] : null,
                    child: _FaqCard(
                      faq: _faqs[items[k]],
                      open: _open == items[k],
                      onTap: () => setState(
                        () => _open = _open == items[k] ? null : items[k],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

            const SizedBox(height: 14),

            Reveal(
              animation: _anim,
              begin: 0.6,
              end: 1.0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3EA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4E7DA)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.headset_mic_outlined,
                            size: 26, color: TC.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Masih butuh bantuan langsung?',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C3A2E),
                                ),
                              ),
                              Text(
                                'Tim TEDUH siap mendampingi via WhatsApp di 0895-2978-1378 (08.00–20.00 WIB).',
                                style: GoogleFonts.poppins(
                                    fontSize: 10, color: TC.hint),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SupportButton(
                      onTap: () => _contactTeduhWhatsApp(context),
                    ),
                  ],
                ),
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
}

class _FaqCard extends StatelessWidget {
  final _Faq faq;
  final bool open;
  final VoidCallback onTap;

  const _FaqCard({required this.faq, required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: open ? const Color(0xFFEAF5EE) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: open ? const Color(0xFFD3E8DA) : TC.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: open ? const Color(0xFFD7EDDF) : const Color(0xFFF0F4F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      faq.category,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: open ? TC.greenDeep : const Color(0xFF5B6E66),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: open ? TC.green : const Color(0xFF1C3A2E),
                          ),
                          child: Text(faq.question),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 22, color: TC.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFD7E8DC),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          faq.answer,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            height: 1.55,
                            color: TC.hint,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.check_circle_outline_rounded,
                                  size: 15, color: TC.green),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                faq.highlight,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: TC.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _SupportButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SupportButton({required this.onTap});

  @override
  State<_SupportButton> createState() => _SupportButtonState();
}

class _SupportButtonState extends State<_SupportButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: TC.green,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: TC.green.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 17, color: Colors.white),
                const SizedBox(width: 9),
                Text(
                  'Hubungi WhatsApp Dukungan (0895-2978-1378)',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
