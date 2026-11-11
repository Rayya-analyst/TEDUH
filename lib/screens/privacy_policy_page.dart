import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/teduh_common.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'policy',
        tour: const [
          CoachStep(title: 'Privasi Anda Terjaga', body: 'Ringkasan komitmen TEDUH melindungi informasi dan data pribadimu.'),
          CoachStep(title: 'Pengumpulan dan penggunaan', body: 'Bagian satu dan dua menjelaskan data apa yang dikumpulkan, yaitu nama, email, dan lokasi, serta untuk apa data itu dipakai.'),
          CoachStep(title: 'Keamanan data', body: 'Bagian tiga menjelaskan perlindungan enkripsi dan otentikasi Firebase, dan bahwa datamu tidak dijual kepada pihak ketiga.'),
          CoachStep(title: 'Hak kamu', body: 'Bagian empat dan lima menjelaskan bahwa kamu bisa memperbarui data, mengatur izin lokasi, mengubah kata sandi, atau menghapus akun, serta cara menghubungi kami.'),
        ],
        guide: PageGuide(
          content: () => 'Ini halaman Kebijakan Privasi. Isinya lima bagian: pengumpulan informasi, penggunaan informasi, keamanan data, kendali dan hak pengguna, dan cara menghubungi kami. Datamu tidak dijual kepada pihak ketiga.',
        ),
        child: _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    return TeduhPage(
      title: 'Kebijakan Privasi',
      builder: (context, anim) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            animation: anim,
            begin: 0.1,
            end: 0.55,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TC.heroTop, TC.heroBottom],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: TC.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: TC.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privasi Anda Terjaga',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: TC.dark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Komitmen TEDUH dalam melindungi informasi dan data pribadi Anda.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: TC.hint,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Reveal(
            animation: anim,
            begin: 0.25,
            end: 0.7,
            child: _buildSection(
              title: '1. Pengumpulan Informasi',
              body:
                  'TEDUH mengumpulkan informasi yang Anda berikan saat pendaftaran '
                  'akun (seperti nama dan alamat email) serta data lokasi perangkat Anda '
                  'guna menyajikan indeks kualitas udara (ISPU/AQI) yang akurat dan relevan.',
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            animation: anim,
            begin: 0.35,
            end: 0.8,
            child: _buildSection(
              title: '2. Penggunaan Informasi',
              body:
                  'Informasi yang terkumpul digunakan untuk menyajikan rekomendasi kesehatan, '
                  'peringatan dini kualitas udara, mendukung fitur bantuan suara dan '
                  'aksesibilitas, serta meningkatkan keandalan layanan aplikasi.',
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            animation: anim,
            begin: 0.45,
            end: 0.85,
            child: _buildSection(
              title: '3. Keamanan Data',
              body:
                  'Kami menerapkan standar keamanan enkripsi dan otentikasi Firebase untuk '
                  'melindungi data pribadi Anda dari akses tidak sah. Data Anda tidak akan '
                  'dijual atau dibagikan kepada pihak ketiga untuk kepentingan komersial.',
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            animation: anim,
            begin: 0.55,
            end: 0.9,
            child: _buildSection(
              title: '4. Kendali & Hak Pengguna',
              body:
                  'Anda memiliki kontrol penuh atas akun Anda. Anda dapat memperbarui data profil, '
                  'mengatur izin lokasi, mengubah kata sandi, atau menghapus akun Anda '
                  'secara permanen kapan saja melalui menu Pengaturan Privasi & Keamanan.',
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            animation: anim,
            begin: 0.65,
            end: 0.95,
            child: _buildSection(
              title: '5. Hubungi Kami',
              body:
                  'Jika Anda memiliki pertanyaan terkait Kebijakan Privasi ini atau penanganan '
                  'data Anda di aplikasi TEDUH, silakan hubungi tim kami melalui menu Bantuan & FAQ.',
            ),
          ),
          const SizedBox(height: 26),
          Reveal(
            animation: anim,
            begin: 0.75,
            end: 1.0,
            child: const NoteRow(
              icon: Icons.lock_outline_rounded,
              text: 'Data Anda dilindungi sesuai standar privasi TEDUH.',
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: TC.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: const Color(0xFF4A5852),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
