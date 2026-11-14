import '../../state/app_settings.dart';
import '../context_recommendation.dart';
import 'ai_key_manager.dart';
import 'ai_provider.dart';
import 'teduh_knowledge_base.dart';

class TeduhAiResponse {
  final bool success;
  final String type; 
  final Map<String, dynamic> context;
  final Map<String, dynamic> analysis;
  final Map<String, dynamic> recommendation;
  final Map<String, dynamic> accessibility;
  final Map<String, dynamic> metadata;
  final List<String> citations;

  const TeduhAiResponse({
    required this.success,
    required this.type,
    required this.context,
    required this.analysis,
    required this.recommendation,
    required this.accessibility,
    required this.metadata,
    this.citations = const [],
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'type': type,
        'context': context,
        'analysis': analysis,
        'recommendation': recommendation,
        'accessibility': accessibility,
        'metadata': metadata,
        'citations': citations,
      };

  String get speakableText => accessibility['speakable_text'] ?? recommendation['action'] ?? '';
  String get simpleExplanation => accessibility['simple_explanation'] ?? '';
  String get title => recommendation['title'] ?? analysis['title'] ?? 'Rekomendasi TEDUH';
  String get mainAction => recommendation['action'] ?? '';
  String get reason => recommendation['reason'] ?? '';
  String get priority => recommendation['priority'] ?? 'medium';
  List<String> get alternatives => List<String>.from(recommendation['alternatives'] ?? []);
}

class TeduhAiOrchestrator {
  TeduhAiOrchestrator._();
  static final TeduhAiOrchestrator instance = TeduhAiOrchestrator._();

  AIProvider _provider = GeminiProvider();

  void setProvider(AIProvider provider) {
    _provider = provider;
  }

  static const String masterSystemPrompt = '''
Kamu adalah TEDUH AI, asisten kecerdasan buatan profesional dan ramah untuk aplikasi TEDUH (Sistem Pemantauan Kualitas Udara dan Kesiapsiagaan Karhutla Kalimantan).

PERAN & TUGAS UTAMA:
Kamu adalah asisten cerdas lingkungan, kesehatan pernapasan, dan kesiapsiagaan kebakaran hutan dan lahan (Karhutla). Kamu mampu menjawab pertanyaan mendalam seputar:
1. Karhutla: Penyebab kebakaran hutan/lahan, mekanisme api bawah tanah gambut (smoldering), deteksi titik panas (hotspot satelit Terra/Aqua/Suomi-NPP VIIRS), pencegahan 3R (rewetting, revegetation, revitalization), sekat kanal, pemadaman Manggala Agni, suntik gambut, water bombing, dan operasi TMC.
2. Kesehatan: Dampak polutan partikulat PM2.5, PM10, gas CO, NO2, O3, ISPA, perlindungan kelompok rentan (anak-anak, balita, lansia, ibu hamil, penderita asma/jantung), standar masker N95/KN95, pembuatan ruang aman (clean room), dan tanda darurat pernapasan untuk ke IGD.
3. Ekosistem & Lingkungan: Dampak terhadap satwa endemik (Orangutan, Bekantan, Enggang), flora langka (Ramin, Jelutung), kerusakan kubah gambut, hidrofobisitas tanah, siklus dan pelepasan cadangan karbon masif.
4. Iklim & Atmosfer: Hubungan Karhutla dengan El Nino, IOD positif, pemanasan global, aerosol asap lintas batas (transboundary haze), dan solar dimming.
5. Fitur Aplikasi TEDUH: TEDUH NOW (ISPU stasiun KLHK), TEDUH ACTION (rekomendasi aktivitas kontekstual), TEDUH READY (checklist tas siaga bencana), dan Mode Offline.

PRINSIP KOMUNIKASI:
1. Gunakan Bahasa Indonesia yang baik, santun, hangat, solutif, dan mudah dipahami masyarakat luas.
2. Jelaskan konsep ilmiah secara sederhana namun akurat. Hubungkan dengan konteks lokal Kalimantan bila relevan.
3. Hubungkan jawaban dengan tindakan praktis perlindungan diri (misal: rekomendasi masker N95, kurangi aktivitas luar, atau cek fitur TEDUH ACTION / TEDUH READY).
4. Jangan pernah memberikan diagnosis medis definitif. Jika pengguna mengeluhkan sesak napas berat, bibir kebiruan, atau nyeri dada, ingatkan dengan tegas untuk segera ke IGD atau fasilitas kesehatan terdekat.
5. Gunakan fakta dari Dokumen Knowledge Base dan data kualitas udara terkini yang dilampirkan.
6. Untuk salam atau percakapan ramah, jawab dengan hangat dan siap membantu.
''';

  Future<void> initialize({List<String>? initialApiKeys}) async {
    await MultiApiKeyManager.instance.initialize(initialKeys: initialApiKeys);
    await TeduhKnowledgeBase.instance.initialize();
  }

  TeduhAiResponse generateContextAwareRecommendation({
    required AirSnapshot air,
    required TeduhActivity activity,
    bool sensitive = false,
  }) {
    final baseRec = ContextRecommender.build(
      air: air,
      activity: activity,
      sensitive: sensitive,
    );

    final priority = air.ispu > 300
        ? 'high'
        : air.ispu > 100
            ? 'high'
            : air.ispu > 50
                ? 'medium'
                : 'low';

    final category = air.ispu <= 50
        ? 'good'
        : air.ispu <= 100
            ? 'moderate'
            : air.ispu <= 200
                ? 'unhealthy'
                : air.ispu <= 300
                    ? 'very_unhealthy'
                    : 'hazardous';

    final now = DateTime.now();

    final response = TeduhAiResponse(
      success: true,
      type: 'context_aware_recommendation',
      context: {
        'aqi': air.ispu,
        'category': category,
        'pm25': air.pm25Value,
        'activity': activity.label,
        'time': ContextRecommender.timeOfDay(now),
        'location': air.location,
        'sensitive_group': sensitive,
      },
      analysis: {
        'title': 'Kualitas Udara ${air.status}',
        'summary': 'ISPU ${air.ispu} (${air.sourceText}).',
        'explanation': air.ispu > 100
            ? 'Partikel polusi PM2.5 (${air.pm25}) berada di atas batas aman, dapat membebani pernapasan.'
            : 'Udara dalam batas aman untuk mayoritas aktivitas.',
      },
      recommendation: {
        'title': baseRec.headline,
        'action': baseRec.steps.isNotEmpty ? baseRec.steps.first : 'Ikuti panduan umum perlindungan diri.',
        'reason': baseRec.reason,
        'priority': priority,
        'alternatives': baseRec.alternatives,
        'relevance_time': 'Kondisi diperbarui ${air.updatedAt}',
        'source': air.sourceName,
      },
      accessibility: {
        'simple_explanation': baseRec.headlineSimple,
        'short_summary': baseRec.reasonSimple,
        'speakable_text': baseRec.spoken(simple: true),
      },
      metadata: {
        'source': 'teduh_backend',
        'data_timestamp': air.updatedAt,
        'generated_at': now.toIso8601String(),
        'model': 'teduh_context_engine_v1',
        'provider': 'teduh_local',
      },
      citations: [air.sourceName, 'Pedoman Standar ISPU KLHK'],
    );

    return response;
  }

  TeduhAiResponse analyzeAirQuality(AirSnapshot air) {
    final now = DateTime.now();
    final isDanger = air.ispu > 200;
    final isUnhealthy = air.ispu > 100;

    String simpleExplanation;
    String speakableText;

    if (air.ispu <= 50) {
      simpleExplanation = 'Udara sangat bersih dan sehat. Aman untuk segala aktivitas di luar.';
      speakableText = 'Kualitas udara saat ini baik. Udara bersih dan aman untuk beraktivitas.';
    } else if (air.ispu <= 100) {
      simpleExplanation = 'Udara cukup bersih. Boleh beraktivitas, namun perhatikan bila langit mulai berasap.';
      speakableText = 'Kualitas udara sedang. Masih aman untuk sebagian besar orang.';
    } else if (air.ispu <= 200) {
      simpleExplanation = 'Udara tidak sehat karena partikel polusi bertambah. Sebaiknya kurangi aktivitas berat di luar.';
      speakableText = 'Kualitas udara tidak sehat. Kurangi aktivitas berat di luar ruangan dan gunakan masker respirator jika harus keluar.';
    } else {
      simpleExplanation = 'Udara sangat berbahaya. Jangan beraktivitas di luar. Tutup rapat pintu dan jendela.';
      speakableText = 'Peringatan kualitas udara berbahaya. Segera hindari paparan luar dan tetap di dalam ruangan berfilter.';
    }

    return TeduhAiResponse(
      success: true,
      type: 'ai_analysis',
      context: {
        'aqi': air.ispu,
        'status': air.status,
        'pm25': air.pm25Value,
        'location': air.location,
        'source': air.sourceName,
      },
      analysis: {
        'title': 'Analisis Kualitas Udara ${air.location}',
        'summary': 'Nilai ISPU mencapai ${air.ispu} dengan status ${air.status}.',
        'explanation': 'Konsentrasi PM2.5 adalah ${air.pm25}. Pengukuran diperoleh dari ${air.sourceName} pada ${air.updatedAt}.',
      },
      recommendation: {
        'title': isDanger ? 'Tingkat Bahaya Tinggi' : (isUnhealthy ? 'Kewaspadaan Diperlukan' : 'Aktivitas Normal'),
        'action': isDanger ? 'Hindari seluruh aktivitas luar ruangan.' : (isUnhealthy ? 'Gunakan masker N95 bila keluar.' : 'Tetap pantau kondisi berkala.'),
        'reason': 'Partikulat halus PM2.5 dapat menembus saluran pernapasan bagian dalam.',
        'priority': isDanger ? 'high' : (isUnhealthy ? 'medium' : 'low'),
        'alternatives': ['Pindah ke ruangan ber-AC dengan sirkulasi dalam', 'Gunakan pembersih udara HEPA jika ada'],
      },
      accessibility: {
        'simple_explanation': simpleExplanation,
        'short_summary': 'ISPU ${air.ispu} - ${air.status}',
        'speakable_text': speakableText,
      },
      metadata: {
        'source': 'teduh_backend',
        'data_timestamp': air.updatedAt,
        'generated_at': now.toIso8601String(),
        'model': 'teduh_analysis_engine',
        'provider': 'teduh_local',
      },
      citations: [air.sourceName],
    );
  }

  Future<TeduhAiResponse> askAssistant({
    required String userQuestion,
    AirSnapshot? liveAir,
    String? userLocation,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final now = DateTime.now();

    final retrieved = TeduhKnowledgeBase.instance.retrieve(query: userQuestion, maxResults: 3);

    final citations = retrieved.map((r) => r.document.source).toSet().toList();
    if (liveAir != null) citations.add(liveAir.sourceName);

    final airContextText = liveAir != null
        ? 'Data Udara Terkini di ${liveAir.location}: ISPU ${liveAir.ispu} (${liveAir.status}), PM2.5: ${liveAir.pm25}, Sumber: ${liveAir.sourceName} (${liveAir.updatedAt}).'
        : 'Data udara lokal belum tersedia secara spesifik.';

    final kbContextText = retrieved.isNotEmpty
        ? retrieved.map((r) => '• [${r.document.title}] (${r.document.source}): ${r.document.content}').join('\n\n')
        : 'Tidak ada dokumen spesifik yang cocok di Knowledge Base.';

    String historyContextText = '';
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      final recent = conversationHistory.length > 6
          ? conversationHistory.sublist(conversationHistory.length - 6)
          : conversationHistory;
      historyContextText = 'RIWAYAT PERCAKAPAN SEBELUMNYA:\n'
          '${recent.map((turn) => '${turn['role'] == 'user' ? 'User' : 'Assistant'}: ${turn['text']}').join('\n')}'
          '\n\n';
    }

    final prompt = '''
KONTEKS SISTEM TEDUH TERKINI:
$airContextText

DOKUMEN KNOWLEDGE BASE TERVERIFIKASI:
$kbContextText

${historyContextText}PERTANYAAN PENGGUNA TERBARU:
"$userQuestion"

PETUNJUK FORMAT JAWABAN:
1. Langsung berikan jawaban yang tuntas, lengkap, dan terstruktur rapi dengan poin-poin jelas (gunakan bullet point atau nomor).
2. Hindari basa-basi pembuka yang berulang atau terlalu panjang (jangan selalu mengulang "Halo! Kembali lagi dengan TEDUH AI"). Langsung fokus ke solusi dan penjelasan inti.
3. Gunakan Bahasa Indonesia yang lugas, teratur, dan mudah dipahami.
4. Gunakan penekanan tebal (bold) untuk istilah atau langkah penting.
5. Pastikan seluruh kalimat selesai secara utuh dan TIDAK terpotong di tengah jalan.
6. Jika terkait kabut asap Karhutla, berikan langkah konkret perlindungan diri (masker N95, ruang bersih, dll).
7. Jika ada keluhan sesak napas berat, ingatkan segera ke IGD atau fasilitas kesehatan terdekat.
''';

    if (MultiApiKeyManager.instance.hasValidKeys) {
      final aiRes = await _provider.generateCompletion(
        systemPrompt: masterSystemPrompt,
        userPrompt: prompt,
      );

      if (aiRes.success && aiRes.text.isNotEmpty) {
        return TeduhAiResponse(
          success: true,
          type: 'assistant_chat',
          context: {
            'location': liveAir?.location ?? userLocation ?? 'Palangka Raya',
            'aqi': liveAir?.ispu,
            'question': userQuestion,
          },
          analysis: {
            'title': 'Jawaban Asisten TEDUH',
            'summary': 'Jawaban dihasilkan berdasarkan Basis Pengetahuan TEDUH.',
            'explanation': aiRes.text,
          },
          recommendation: {
            'title': 'Tindakan yang Disarankan',
            'action': aiRes.text,
            'reason': 'Disesuaikan dengan panduan kesehatan dan kondisi udara.',
            'priority': liveAir != null && liveAir.ispu > 150 ? 'high' : 'medium',
            'alternatives': [],
          },
          accessibility: {
            'simple_explanation': aiRes.text,
            'short_summary': 'Jawaban TEDUH AI',
            'speakable_text': aiRes.text,
          },
          metadata: {
            'source': 'teduh_orchestrator',
            'data_timestamp': liveAir?.updatedAt,
            'generated_at': now.toIso8601String(),
            'model': aiRes.model,
            'provider': aiRes.provider,
          },
          citations: citations,
        );
      }
    }

    final fallbackText = _generateGroundedFallback(
      question: userQuestion,
      retrieved: retrieved,
      liveAir: liveAir,
      citations: citations,
    );

    return TeduhAiResponse(
      success: true,
      type: 'assistant_chat',
      context: {
        'location': liveAir?.location ?? userLocation ?? 'Palangka Raya',
        'aqi': liveAir?.ispu,
        'question': userQuestion,
      },
      analysis: {
        'title': 'Jawaban Asisten TEDUH (Knowledge Base Resmi)',
        'summary': 'Jawaban diambil langsung dari Basis Pengetahuan terverifikasi TEDUH.',
        'explanation': fallbackText,
      },
      recommendation: {
        'title': 'Panduan TEDUH',
        'action': fallbackText,
        'reason': 'Berdasarkan pedoman resmi pencegahan kabut asap dan kualitas udara.',
        'priority': liveAir != null && liveAir.ispu > 150 ? 'high' : 'medium',
        'alternatives': [],
      },
      accessibility: {
        'simple_explanation': fallbackText,
        'short_summary': 'Panduan Resmi TEDUH',
        'speakable_text': fallbackText,
      },
      metadata: {
        'source': 'teduh_knowledge_base',
        'data_timestamp': liveAir?.updatedAt,
        'generated_at': now.toIso8601String(),
        'model': 'teduh_rag_engine_local',
        'provider': 'teduh_local_kb',
      },
      citations: citations,
    );
  }

  String _generateGroundedFallback({
    required String question,
    required List<RetrievalResult> retrieved,
    AirSnapshot? liveAir,
    required List<String> citations,
  }) {
    final qLower = question.toLowerCase();

    if (qLower.contains('halo') || qLower.contains('hai') || qLower.contains('selamat pagi') ||
        qLower.contains('selamat siang') || qLower.contains('selamat sore') || qLower.contains('selamat malam') ||
        qLower.contains('assalamu') || qLower.contains('siapa kamu') || qLower.contains('bisa apa') ||
        qLower.contains('kenalan')) {
      final airInfo = liveAir != null
          ? ' Saat ini di ${liveAir.location}, ISPU tercatat ${liveAir.ispu} (${liveAir.status}) dengan konsentrasi PM2.5 ${liveAir.pm25}.'
          : '';
      return 'Halo! Saya TEDUH AI, asisten pintar perlindungan kesehatan lingkungan dan kesiapsiagaan kebakaran hutan dan lahan (Karhutla) untuk wilayah Kalimantan.$airInfo\n\n'
          'Anda dapat menanyakan hal-hal seperti:\n'
          '• Kondisi kualitas udara terkini dan rekomendasi aktivitas harian.\n'
          '• Penyebab Karhutla, api bawah tanah gambut (smoldering), dan pemadaman Manggala Agni.\n'
          '• Dampak polutan PM2.5, perlindungan kelompok rentan, dan standar masker N95.\n'
          '• Kerusakan ekosistem gambut, flora fauna endemik, dan pelepasan emisi karbon.\n'
          '• Panduan Tas Siaga Bencana di menu TEDUH READY.\n\n'
          'Ada yang ingin Anda tanyakan atau konsultasikan hari ini?';
    }

    if (qLower.contains('terima kasih') || qLower.contains('makasih') || qLower.contains('thanks') ||
        qLower.contains('mantap') || qLower.contains('baiklah') || qLower.contains('oke terima') ||
        qLower == 'oke' || qLower == 'ok' || qLower == 'siap') {
      return 'Sama-sama! Senang bisa membantu Anda. Selalu utamakan kesehatan pernapasan, pastikan sirkulasi udara di rumah tetap bersih, dan pantau terus kualitas udara berkala di aplikasi TEDUH. Tetap aman dan sehat!';
    }

    if (qLower.contains('kondisi udara') || qLower.contains('hari ini') || qLower.contains('ispu') ||
        qLower.contains('sekarang') || qLower.contains('pm2.5') || qLower.contains('angka udara') ||
        qLower.contains('aman keluar') || qLower.contains('boleh keluar') || qLower.contains('bisa keluar')) {
      if (liveAir != null) {
        String advice;
        if (liveAir.ispu > 200) {
          advice = 'Status BERBAHAYA. Sangat disarankan untuk TIDAK keluar ruangan. Tutup rapat pintu dan jendela, nyalakan air purifier atau filter HEPA di ruang bersih Anda. Jika mendesak harus keluar, kenakan respirator N95 rapat.';
        } else if (liveAir.ispu > 100) {
          advice = 'Status TIDAK SEHAT. Disarankan membatasi atau menunda aktivitas fisik di luar ruangan. Kelompok sensitif (anak-anak, lansia, ibu hamil, penderita asma) sebaiknya tetap di dalam ruangan. Wajib gunakan masker N95 jika beraktivitas luar.';
        } else if (liveAir.ispu > 50) {
          advice = 'Status SEDANG. Masih aman untuk mayoritas aktivitas di luar, namun kelompok yang sangat sensitif disarankan waspada jika mulai tercium bau asap pekat.';
        } else {
          advice = 'Kualitas udara BAIK. Aman dan sehat untuk semua aktivitas luar ruangan.';
        }
        return 'Data Kualitas Udara Terkini di ${liveAir.location}:\n'
            '• Indeks ISPU: ${liveAir.ispu} (${liveAir.status})\n'
            '• Konsentrasi Partikulat PM2.5: ${liveAir.pm25}\n'
            '• Sumber Resmi: ${liveAir.sourceName} (${liveAir.updatedAt})\n\n'
            'Rekomendasi Perlindungan:\n$advice\n\n'
            'Anda juga dapat membuka menu TEDUH ACTION untuk rekomendasi aktivitas yang lebih disesuaikan.';
      }
    }

    if (retrieved.isNotEmpty) {
      final buffer = StringBuffer();
      final primary = retrieved.first.document;

      buffer.writeln(primary.content);

      if (retrieved.length > 1 && retrieved[1].document.documentId != primary.documentId) {
        final secondary = retrieved[1].document;
        buffer.writeln('\nInformasi Pelengkap (${secondary.title}):');
        buffer.writeln(secondary.content);
      }

      if (primary.category == 'karhutla' || primary.category == 'kualitas_udara') {
        buffer.writeln('\nTindakan Praktis: Pantau indeks ISPU secara berkala di halaman TEDUH NOW, dan gunakan panduan TEDUH ACTION sebelum beraktivitas di luar.');
      } else if (primary.category == 'keselamatan' || primary.category == 'kesehatan') {
        buffer.writeln('\nTindakan Praktis: Lengkapi checklist Tas Siaga Bencana dan kontak darurat resmi Posko Karhutla di menu TEDUH READY.');
      }

      if (citations.isNotEmpty) {
        buffer.writeln('\n(Sumber Referensi: ${citations.join(', ')})');
      }
      return buffer.toString().trim();
    }

    if (qLower.contains('karhutla') || qLower.contains('kebakaran') || qLower.contains('gambut') ||
        qLower.contains('api') || qLower.contains('manggala') || qLower.contains('hotspot')) {
      return 'Mengenai Kebakaran Hutan dan Lahan (Karhutla) di Kalimantan:\n'
          '• Penyebab: Mayoritas dipicu pembukaan lahan dengan cara membakar yang murah, drainase kanalisasi gambut liar yang membuat gambut kering, dan anomali kemarau panjang El Nino.\n'
          '• Mekanisme: Kebakaran gambut terjadi di bawah tanah (smoldering combustion) tanpa lidah api terbuka hingga kedalaman beberapa meter, minim oksigen, dan menghasilkan asap pekat berkadar CO dan PM2.5 sangat tinggi.\n'
          '• Deteksi & Penanganan: Terdeteksi via satelit Terra/Aqua MODIS dan VIIRS 375m. Pemadaman memerlukan teknik suntik gambut bertekanan tinggi oleh Manggala Agni, water bombing helikopter, serta TMC (hujan buatan).\n'
          '• Mitigasi Jangka Panjang: Program 3R (Rewetting sekat kanal, Revegetation penanaman kembali, dan Revitalization ekonomi warga).';
    }

    if (qLower.contains('kesehatan') || qLower.contains('ispa') || qLower.contains('paru') ||
        qLower.contains('polutan') || qLower.contains('gejala') || qLower.contains('racun') ||
        qLower.contains('dampak')) {
      return 'Dampak Kabut Asap Karhutla terhadap Kesehatan:\n'
          '• Polutan Utama: Partikulat halus PM2.5 dapat menembus silia paru-paru hingga kantung alveoli dan aliran darah, memicu peradangan sistemik dan serangan asma.\n'
          '• Gas Beracun: CO berikatan dengan hemoglobin membentuk HbCO yang memicu hipoksia, pusing, dan sesak napas. Gas NO2 dan O3 merusak mukosa saluran napas.\n'
          '• Kelompok Rentan: Balita/anak (laju pernapasan lebih tinggi), lansia, penderita asma/jantung, dan ibu hamil (risiko hipoksia janin dan BBLR) memiliki risiko tertinggi.\n'
          '• Perlindungan: Gunakan masker respirator N95/KN95 (masker kain/bedah tidak memadai untuk PM2.5) dan buat ruang bersih (clean room) di rumah.\n\n'
          'Tanda Darurat: Jika mengalami sesak napas berat, bibir kebiruan, atau nyeri dada menekan, segera ke IGD terdekat!';
    }

    if (qLower.contains('ekosistem') || qLower.contains('hewan') || qLower.contains('satwa') ||
        qLower.contains('orangutan') || qLower.contains('bekantan') || qLower.contains('flora') ||
        qLower.contains('fauna') || qLower.contains('karbon')) {
      return 'Dampak Karhutla terhadap Ekosistem dan Iklim:\n'
          '• Satwa Endemik: Menghancurkan habitat Orangutan Kalimantan, Bekantan, dan Burung Enggang, memicu malnutrisi, infeksi pernapasan, dan konflik satwa-manusia.\n'
          '• Flora Langka: Spesies kayu rawa gambut berharga seperti Ramin dan Jelutung mengalami kepunahan lokal.\n'
          '• Kerusakan Tanah & Air: Gambut terbakar menjadi hidrofobik (menolak air) sehingga memicu banjir di musim hujan. Air rawa tercemar abu alkali dan asam.\n'
          '• Pelepasan Karbon: Lahan gambut yang tadinya penyerap karbon (carbon sink) berubah menjadi sumber emisi karbon raksasa (carbon source), melepaskan jutaan ton CO2 dan metana ke atmosfer.';
    }

    if (qLower.contains('teduh') || qLower.contains('aplikasi') || qLower.contains('fitur') ||
        qLower.contains('cara pakai') || qLower.contains('kontak darurat') || qLower.contains('bantuan')) {
      return 'Aplikasi TEDUH adalah pendamping perlindungan kesehatan lingkungan masyarakat Kalimantan:\n'
          '1. TEDUH NOW: Menampilkan data kualitas udara real-time (ISPU dan PM2.5) dari stasiun KLHK resmi beserta grafik tren dan analisis AI.\n'
          '2. TEDUH ACTION: Rekomendasi aktivitas kontekstual yang disesuaikan dengan kondisi udara dan pilihan kegiatan Anda.\n'
          '3. TEDUH READY: Panduan kesiapsiagaan bencana, checklist Tas Siaga, dan nomor darurat resmi Posko Karhutla (BPBD 117, PSC 119, Damkar 113).\n'
          '4. MODE OFFLINE: Mengunduh paket data 5 provinsi Kalimantan agar tetap bisa diakses tanpa sinyal internet.\n\n'
          'Silakan pilih menu di navigasi bawah untuk mulai menggunakan fitur-fitur tersebut.';
    }

    if (qLower.contains('masker') || qLower.contains('n95') || qLower.contains('kn95') ||
        qLower.contains('pelindung') || qLower.contains('filter')) {
      return 'Panduan Memilih Masker Pelindung Asap:\n'
          '• N95/KN95 (Direkomendasikan): Menyaring ≥95% partikel udara termasuk PM2.5. Pastikan masker menempel rapat di wajah tanpa celah. Ini standar yang ditetapkan NIOSH dan WHO untuk perlindungan asap Karhutla.\n'
          '• Masker Bedah: Hanya melindungi dari droplet besar, TIDAK mampu menyaring PM2.5 yang berukuran <2.5 mikrometer.\n'
          '• Masker Kain: Efisiensi filtrasi PM2.5 sangat rendah (10-30%), tidak direkomendasikan saat udara tidak sehat.\n'
          '• Cara Memakai Benar: Tekan klip logam di hidung, rapatkan tepi bawah ke dagu, hindari celah di sisi pipi.\n'
          '• Masa Pakai: N95 sekali pakai atau maksimal 8 jam atau saat lembap/kotor.\n\n'
          'Tips: Beli masker berlabel SNI atau standar NIOSH N95/KF94 Korea untuk jaminan mutu.';
    }

    if (qLower.contains('ruang bersih') || qLower.contains('clean room') || qLower.contains('ruangan aman') ||
        qLower.contains('filter udara') || qLower.contains('air purifier') || qLower.contains('hepa')) {
      return 'Cara Membuat Ruang Bersih (Clean Room) di Rumah:\n'
          '1. Pilih Ruangan: Pilih 1 ruangan dengan jendela minimal (kamar tidur atau ruang keluarga kecil).\n'
          '2. Tutup Semua Celah: Pasang lakban atau kain lembap di celah bawah pintu dan jendela yang tidak digunakan.\n'
          '3. Pasang Air Purifier HEPA: Letakkan di tengah ruangan. Filter HEPA H13 efektif menyaring partikel PM2.5 dan PM10.\n'
          '4. Alternatif DIY: Kipas angin + filter HEPA dari toko online (DIY Corsi-Rosenthal Box) terbukti efektif mengurangi PM2.5 dalam ruangan >80%.\n'
          '5. Jaga Kelembapan: Gunakan humidifier agar polutan tidak terlalu kering dan mudah terhirup.\n'
          '6. Hindari Aktivitas yang Menambah Polutan: Jangan merokok, menggoreng, atau membakar lilin di dalam ruang bersih.\n\n'
          'Ruang bersih sangat penting bagi balita, lansia, dan penderita asma saat ISPU > 100.';
    }

    if (qLower.contains('igd') || qLower.contains('darurat') || qLower.contains('segera') ||
        qLower.contains('kapan') || qLower.contains('tanda bahaya') || qLower.contains('gawat')) {
      return 'Kapan Harus Segera ke IGD karena Polusi Udara/Kabut Asap:\n\n'
          'SEGERA ke IGD jika mengalami:\n'
          '• Sesak napas berat yang tidak membaik dengan istirahat\n'
          '• Bibir atau ujung jari membiru (sianosis) — tanda kekurangan oksigen\n'
          '• Nyeri atau rasa tertekan di dada\n'
          '• Penurunan kesadaran atau kebingungan mendadak\n'
          '• Anak-anak dengan napas cepat >60x/menit atau perut kembang-kempis tidak normal\n'
          '• Serangan asma yang tidak respons dengan inhaler\n\n'
          'Nomor Darurat:\n'
          '• IGD 118 (Ambulans Nasional)\n'
          '• PSC 119 (Pusat Krisis Kemenkes)\n'
          '• BPBD 117 (Bencana/Karhutla)\n'
          '• Pemadam 113\n\n'
          'Jangan menunggu jika gejala memberat. Polutan PM2.5 dapat memicu serangan akut yang progresif dalam hitungan menit.';
    }

    if (qLower.contains('balita') || qLower.contains('anak') || qLower.contains('bayi') ||
        qLower.contains('pm2.5') || qLower.contains('pm 2.5') || qLower.contains('kelompok rentan') ||
        qLower.contains('hamil') || qLower.contains('lansia')) {
      return 'Dampak PM2.5 bagi Balita dan Kelompok Rentan:\n\n'
          'Balita & Anak (0-12 tahun):\n'
          '• Paru-paru masih berkembang, laju napas 2-3x lebih tinggi dari dewasa → paparan relatif lebih besar\n'
          '• Risiko: ISPA berulang, pneumonia, penurunan fungsi paru permanen, gangguan perkembangan otak\n'
          '• Perlindungan: Hindari bawa anak ke luar saat ISPU > 50, pastikan ruang tidur berfilter\n\n'
          'Ibu Hamil:\n'
          '• PM2.5 masuk ke aliran darah dan melewati plasenta → risiko hipoksia janin\n'
          '• Dampak: Bayi berat lahir rendah (BBLR), kelahiran prematur, gangguan neurokognitif janin\n\n'
          'Lansia & Penderita Asma/Jantung:\n'
          '• PM2.5 memperparah inflamasi saluran napas dan memicu serangan asma\n'
          '• Risiko serangan jantung meningkat karena PM2.5 masuk ke aliran darah dan mempengaruhi koagulasi\n\n'
          'Rekomendasi Umum: Saat ISPU > 100, semua kelompok rentan sebaiknya tidak beraktivitas di luar. Gunakan masker N95 dan pastikan ruang dalam bersih dengan air purifier HEPA.';
    }

    if (qLower.contains('sesak') || qLower.contains('napas') || qLower.contains('pertolongan pertama') ||
        qLower.contains('p3k') || qLower.contains('asma') || qLower.contains('bronkitis')) {
      return 'Pertolongan Pertama Saat Sesak Napas akibat Polusi:\n\n'
          '1. Pindahkan ke Tempat Aman: Segera masuk ke ruangan tertutup dengan udara bersih, jauh dari sumber polusi.\n'
          '2. Posisi Duduk Tegak: Duduk condong ke depan, tangan bertumpu di lutut — ini membuka saluran napas lebih lebar.\n'
          '3. Kendurkan Pakaian: Longgarkan kerah baju, ikat pinggang, atau apapun yang menghambat pernapasan.\n'
          '4. Hirup Napas Dalam: Tarik napas perlahan lewat hidung 4 detik, tahan 1 detik, buang perlahan lewat mulut 6 detik.\n'
          '5. Jika Penderita Asma: Gunakan inhaler bronkodilator (Salbutamol/Ventolin) 2-4 semprotan, tunggu 15 menit.\n'
          '6. Pasang Oksigen: Jika tersedia tabung oksigen, berikan 2-4 liter/menit lewat masker.\n\n'
          'SEGERA ke IGD jika:\n'
          '• Sesak tidak membaik dalam 15 menit\n'
          '• Bibir/kuku membiru\n'
          '• Kesadaran menurun\n'
          '• Anak < 5 tahun dengan napas > 60x/menit';
    }

    return 'Halo! Saya asisten TEDUH AI, siap mendampingi Anda seputar kualitas udara dan kesiapsiagaan lingkungan di Indonesia:\n\n'
        'Kualitas Udara & PM2.5: Pemantauan ISPU real-time, standar WHO vs KLHK, dampak partikel halus\n'
        'Perlindungan Diri: Standar masker N95/KN95 vs masker kain/bedah, cara membuat ruang bersih (clean room)\n'
        'Karhutla & Gambut: Penyebab kebakaran gambut bawah tanah (smoldering), mitigasi sekat kanal 3R\n'
        'Kelompok Rentan: Perlindungan ekstra untuk balita, ibu hamil, lansia, dan penderita asma/jantung\n'
        'Tindakan Darurat: Tanda kegawatan pernapasan, kapan segera ke IGD, nomor darurat 118/119/117\n'
        'Ekosistem & Iklim: Perlindungan satwa Orangutan, flora gambut, dan emisi kabut asap lintas batas\n\n'
        'Silakan tanyakan hal spesifik yang ingin Anda ketahui, saya siap membantu!';
  }
}
