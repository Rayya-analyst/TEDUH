# TEDUH
TEDUH (Tanggap terhadap Emisi dan Dampak Udara bagi Kesehatan) adalah aplikasi mobile berbasis AI untuk pemantauan kualitas udara, rekomendasi tindakan kesehatan kontekstual, dan kesiapsiagaan menghadapi kabut asap karhutla dengan pendekatan inklusif dan aksesibel.

1. Mode Disabilitas adaptif per jenis (paling unik). TEDUH tidak sekadar menambah text-to-speech. Setelah splash, aplikasi menanyakan dengan suara apakah pengguna penyandang disabilitas dan jenisnya, lalu menyesuaikan seluruh pengalaman:
Tunanetra: penjelasan suara tiap halaman, tanpa panduan visual, dikendalikan sepenuhnya dengan suara.
Low vision: teks sangat besar, kontras tinggi, huruf tebal, panduan disorot dan dibacakan.
Tunarungu: semua informasi berupa teks. Peringatan udara berbahaya memakai getar dan layar berkedip.
Tunawicara: tidak ada yang memaksa berbicara.
Tunadaksa: kendali suara tanpa menyentuh layar, tombol lebih besar.
Intelektual: bahasa sederhana, panduan dibacakan pelan, animasi dikurangi.
Ganda: gabungan semua dukungan.
2. Kendali suara hands-free dengan pemahaman perintah bahasa Indonesia, termasuk masuk dan daftar hanya dengan bicara (email "azka" otomatis menjadi azka@gmail.com) dan bertanya ke Asisten AI dengan suara.
3. Coach marks (panduan bersorot) di hampir semua halaman, menyorot kolom yang dijelaskan langkah demi langkah.
4. Peringatan udara berbahaya multi-indra: sirene singkat, lalu suara menjelaskan artinya dan memerintahkan siaga, ditambah getar dan kedip layar untuk tunarungu.
5. Rekomendasi kontekstual: aktivitas indoor atau outdoor otomatis mengikuti kualitas udara, aktivitas pengguna, dan kelompok sensitif.
6. TEDUH READY: kesiapsiagaan kabut asap (tas siaga, langkah harian, rencana darurat, kontak darurat).
7. Arsitektur siap AI: ContextRecommender sudah menghasilkan struktur yang sama dengan respons AI (alasan, langkah, alternatif, versi sederhana). Mengganti ke backend AI cukup mengubah satu fungsi tanpa mengubah tampilan.

# TEDUH: Hidup Sehat, Udara Sehat

Aplikasi Flutter yang membantu semua orang, termasuk penyandang disabilitas,
memahami kualitas udara dan bersiap menghadapi kabut asap.

## Masalah
Informasi kualitas udara umumnya hanya berupa angka dan grafik. Pengguna tidak
tahu apa yang aman dilakukan, dan penyandang disabilitas sering tidak bisa
memakainya sama sekali.

## Solusi
TEDUH mengubah data udara menjadi tindakan dan menyesuaikan dirinya dengan
cara pengguna memakai ponsel.

## Fitur unggulan
- **Mode Disabilitas adaptif (7 jenis):** tunanetra, low vision, tunarungu,
  tunawicara, tunadaksa, intelektual, dan ganda. Tiap jenis mendapat
  penanganan berbeda.
- **Kendali suara hands-free** berbahasa Indonesia, termasuk masuk dan daftar
  hanya dengan bicara.
- **Peringatan udara berbahaya multi-indra:** sirene, penjelasan suara, getar,
  dan kedip layar.
- **Rekomendasi aktivitas otomatis** sesuai ISPU, aktivitas, dan kelompok
  sensitif.
- **TEDUH READY:** tas siaga, langkah harian, rencana dan kontak darurat.
- **Panduan bersorot (coach marks)** di hampir semua halaman.

## Status
| Komponen | Status |
|---|---|
| Akun (Firebase Auth + Firestore) | Berjalan |
| Mode disabilitas, suara, coach marks | Berjalan |
| Rekomendasi aktivitas | Berjalan (berbasis aturan) |
| Data kualitas udara | Data contoh, belum dari API |
| Asisten AI dan Analisis AI | Antarmuka siap, balasan masih contoh; AI engine menyusul |

## Teknologi
Flutter, Firebase Authentication, Cloud Firestore, speech_to_text,
flutter_tts, audioplayers, shared_preferences.

## Menjalankan
1. `flutter pub get`
2. Pastikan konfigurasi Firebase tersedia (`firebase_options.dart`,
   `android/app/google-services.json`).
3. `flutter run`

## Rencana
- Menghubungkan data BMKG/KLHK secara langsung.
- Memasang AI engine lewat satu titik integrasi (`ContextRecommender.build`
  dan layanan Asisten AI) dengan kunci API tersimpan di backend.