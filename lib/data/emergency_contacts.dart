library;

class EmergencyContact {
  final String name;
  final String function;
  final String phone;
  final String? address;
  final String regionId; 
  final String? subRegion;
  final bool verified;
  final String? sourceUrl;
  final String? verifiedNote;

  const EmergencyContact({
    required this.name,
    required this.function,
    required this.phone,
    this.address,
    required this.regionId,
    this.subRegion,
    required this.verified,
    this.sourceUrl,
    this.verifiedNote,
  });
}

class EmergencyContacts {
  EmergencyContacts._();

  static const List<EmergencyContact> _all = [
    EmergencyContact(
      name: 'BNPB — Badan Nasional Penanggulangan Bencana',
      function: 'Penanggulangan bencana nasional & informasi hotspot karhutla',
      phone: '117',
      regionId: 'nasional',
      verified: true,
      sourceUrl: 'https://bnpb.go.id',
      verifiedNote: 'Hotline BNPB 117, aktif 24 jam (ext. 7 untuk kebakaran hutan)',
    ),
    EmergencyContact(
      name: 'PSC 119 — Pusat Komando Layanan Kesehatan',
      function: 'Ambulans dan layanan kesehatan darurat',
      phone: '119',
      regionId: 'nasional',
      verified: true,
      sourceUrl: 'https://sehatnegeriku.kemkes.go.id',
      verifiedNote: 'PSC 119 tersedia di ibukota provinsi, ketersediaan per kab/kota bervariasi',
    ),
    EmergencyContact(
      name: 'Pemadam Kebakaran Nasional',
      function: 'Layanan pemadam kebakaran',
      phone: '113',
      regionId: 'nasional',
      verified: true,
      verifiedNote: 'Nomor nasional, penanganan oleh Dinas Pemadam setempat',
    ),
    EmergencyContact(
      name: 'Layanan Darurat Terpadu',
      function: 'Layanan darurat terintegrasi (polisi, ambulans, pemadam)',
      phone: '112',
      regionId: 'nasional',
      verified: true,
      verifiedNote: 'Implementasi aktif bervariasi per kabupaten/kota. Hubungi jika 113/119 tidak aktif.',
    ),
    EmergencyContact(
      name: 'BPBD Provinsi Kalimantan Barat',
      function: 'Penanggulangan bencana provinsi termasuk karhutla',
      phone: '0561-737555',
      address: 'Jl. Sutan Syahrir No.1, Pontianak',
      regionId: 'kalbar',
      subRegion: 'Pontianak (Provinsi)',
      verified: true,
      sourceUrl: 'https://bpbd.kalbarprov.go.id',
      verifiedNote: 'Nomor kantor BPBD Kalbar, terverifikasi dari situs resmi',
    ),
    EmergencyContact(
      name: 'Dinas Pemadam Kebakaran Kota Pontianak',
      function: 'Pemadam kebakaran hutan dan lahan Kota Pontianak',
      phone: '0561-734999',
      regionId: 'kalbar',
      subRegion: 'Kota Pontianak',
      verified: true,
      verifiedNote: 'Nomor Damkar Kota Pontianak, terverifikasi dari situs Pemkot',
    ),
    EmergencyContact(
      name: 'RSUD dr. Soedarso Pontianak',
      function: 'Rumah sakit rujukan provinsi — IGD 24 jam',
      phone: '0561-737701',
      address: 'Jl. Dr. Soedarso, Pontianak',
      regionId: 'kalbar',
      subRegion: 'Kota Pontianak',
      verified: true,
      sourceUrl: 'https://rsudsoedarsopnk.go.id',
    ),
    EmergencyContact(
      name: 'PSC 119 Kalimantan Barat',
      function: 'Layanan kesehatan darurat Kalimantan Barat',
      phone: '119',
      regionId: 'kalbar',
      verified: true,
    ),
    EmergencyContact(
      name: 'BPBD Provinsi Kalimantan Tengah',
      function: 'Penanggulangan bencana & karhutla Kalimantan Tengah',
      phone: '0536-3230590',
      address: 'Jl. RTA Milono Km. 2, Palangka Raya',
      regionId: 'kalteng',
      subRegion: 'Palangka Raya (Provinsi)',
      verified: true,
      sourceUrl: 'https://bpbd.kalteng.go.id',
      verifiedNote: 'Nomor BPBD Kalteng terverifikasi',
    ),
    EmergencyContact(
      name: 'Manggala Agni — KLHK Kalimantan Tengah',
      function: 'Brigade pengendalian kebakaran hutan dan lahan KLHK',
      phone: '0536-3220144',
      regionId: 'kalteng',
      subRegion: 'Palangka Raya',
      verified: true,
      sourceUrl: 'https://ppid.menlhk.go.id',
      verifiedNote: 'Daops Palangka Raya, terverifikasi KLHK',
    ),
    EmergencyContact(
      name: 'RSUD dr. Doris Sylvanus',
      function: 'Rumah sakit rujukan provinsi — IGD 24 jam',
      phone: '0536-3221764',
      address: 'Jl. RTA Milono No.12, Palangka Raya',
      regionId: 'kalteng',
      subRegion: 'Kota Palangka Raya',
      verified: true,
      sourceUrl: 'https://rsud.kalteng.go.id',
    ),
    EmergencyContact(
      name: 'PSC 119 Kalimantan Tengah',
      function: 'Layanan kesehatan darurat Kalimantan Tengah',
      phone: '119',
      regionId: 'kalteng',
      verified: true,
    ),
    EmergencyContact(
      name: 'BPBD Provinsi Kalimantan Selatan',
      function: 'Penanggulangan bencana & karhutla Kalimantan Selatan',
      phone: '0511-3304877',
      address: 'Jl. Gubernur Syarkawi No.3, Banjarbaru',
      regionId: 'kalsel',
      subRegion: 'Banjarbaru (Provinsi)',
      verified: true,
      sourceUrl: 'https://bpbd.kalselprov.go.id',
    ),
    EmergencyContact(
      name: 'Dinas Pemadam Kebakaran Kota Banjarmasin',
      function: 'Pemadam kebakaran Kota Banjarmasin',
      phone: '0511-3367113',
      regionId: 'kalsel',
      subRegion: 'Kota Banjarmasin',
      verified: true,
      verifiedNote: 'Terverifikasi dari situs Pemkot Banjarmasin',
    ),
    EmergencyContact(
      name: 'RSUD Ulin Banjarmasin',
      function: 'Rumah sakit rujukan provinsi — IGD 24 jam',
      phone: '0511-3252180',
      address: 'Jl. Jend. A. Yani No.43, Banjarmasin',
      regionId: 'kalsel',
      subRegion: 'Kota Banjarmasin',
      verified: true,
    ),
    EmergencyContact(
      name: 'PSC 119 Kalimantan Selatan',
      function: 'Layanan kesehatan darurat Kalimantan Selatan',
      phone: '119',
      regionId: 'kalsel',
      verified: true,
    ),
    EmergencyContact(
      name: 'BPBD Provinsi Kalimantan Timur',
      function: 'Penanggulangan bencana & karhutla Kalimantan Timur',
      phone: '0541-7779911',
      address: 'Jl. Basuki Rahmat No.68, Samarinda',
      regionId: 'kaltim',
      subRegion: 'Samarinda (Provinsi)',
      verified: true,
      sourceUrl: 'https://bpbd.kaltimprov.go.id',
    ),
    EmergencyContact(
      name: 'Dinas Pemadam Kebakaran Kota Samarinda',
      function: 'Pemadam kebakaran Kota Samarinda',
      phone: '0541-741113',
      regionId: 'kaltim',
      subRegion: 'Kota Samarinda',
      verified: true,
    ),
    EmergencyContact(
      name: 'RSUD Abdul Wahab Sjahranie',
      function: 'Rumah sakit rujukan provinsi — IGD 24 jam',
      phone: '0541-738118',
      address: 'Jl. Dr. Soetomo No.1, Samarinda',
      regionId: 'kaltim',
      subRegion: 'Kota Samarinda',
      verified: true,
    ),
    EmergencyContact(
      name: 'PSC 119 Kalimantan Timur',
      function: 'Layanan kesehatan darurat Kalimantan Timur',
      phone: '119',
      regionId: 'kaltim',
      verified: true,
    ),
    EmergencyContact(
      name: 'BPBD Provinsi Kalimantan Utara',
      function: 'Penanggulangan bencana & karhutla Kalimantan Utara',
      phone: '0552-2033600',
      address: 'Jl. Kolonel Soetadji, Tanjung Selor',
      regionId: 'kaltara',
      subRegion: 'Tanjung Selor (Provinsi)',
      verified: true,
      sourceUrl: 'https://bpbd.kaltaraprov.go.id',
      verifiedNote: 'Nomor kantor BPBD Kaltara — cek juga situs resmi untuk update',
    ),
    EmergencyContact(
      name: 'RSUD Tanjung Selor',
      function: 'Rumah sakit rujukan — IGD 24 jam',
      phone: '0552-2021118',
      address: 'Jl. Kolonel Soetadji, Tanjung Selor',
      regionId: 'kaltara',
      subRegion: 'Tanjung Selor',
      verified: false,
      verifiedNote: 'Nomor belum terverifikasi ulang — periksa situs RSUD Tanjung Selor atau Pemda Kaltara',
    ),
    EmergencyContact(
      name: 'PSC 119 Kalimantan Utara',
      function: 'Layanan kesehatan darurat (ketersediaan bervariasi)',
      phone: '119',
      regionId: 'kaltara',
      verified: true,
      verifiedNote: 'PSC 119 mungkin belum aktif di semua kab/kota Kaltara — gunakan BPBD jika tidak terhubung',
    ),
  ];
  static List<EmergencyContact> getForRegion(String regionId) {
    final regional = _all.where((c) => c.regionId == regionId).toList();
    final nasional = _all.where((c) => c.regionId == 'nasional').toList();
    return [...regional, ...nasional];
  }

  static List<EmergencyContact> get all => _all;
}

