import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teduh/services/ai/ai_key_manager.dart';
import 'package:teduh/services/ai/teduh_ai_orchestrator.dart';
import 'package:teduh/services/ai/teduh_knowledge_base.dart';
import 'package:teduh/services/context_recommendation.dart';
import 'package:teduh/state/app_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MultiApiKeyManager Tests', () {
    late MultiApiKeyManager keyManager;

    setUp(() async {
      keyManager = MultiApiKeyManager.instance;
      await keyManager.setKeys([
        'AIzaSyTestKeyOneAlpha1111',
        'AIzaSyTestKeyTwoBeta2222',
        'AIzaSyTestKeyThreeGamma333',
      ]);
    });

    test('Masking API Key melindungi kredensial', () {
      final key = AIKey(key: 'AIzaSy123456789SecretKey');
      expect(key.maskedKey, equals('AIzaSy...tKey'));
      expect(key.maskedKey.contains('123456789Secret'), isFalse);
    });

    test('Round-Robin Key Rotation memilih kunci aktif bergiliran', () {
      final key1 = keyManager.getNextAvailableKey();
      final key2 = keyManager.getNextAvailableKey();
      final key3 = keyManager.getNextAvailableKey();
      final key4 = keyManager.getNextAvailableKey();

      expect(key1?.key, equals('AIzaSyTestKeyOneAlpha1111'));
      expect(key2?.key, equals('AIzaSyTestKeyTwoBeta2222'));
      expect(key3?.key, equals('AIzaSyTestKeyThreeGamma333'));
      expect(key4?.key, equals('AIzaSyTestKeyOneAlpha1111'));
    });

    test('Failover saat HTTP 429 (Rate Limit) memicu Cooldown dan ganti ke Key berikutnya', () {
      final key1 = keyManager.getNextAvailableKey()!;
      expect(key1.status, equals(KeyStatus.active));

      keyManager.reportFailure(key1, 429, '{"error": {"code": 429, "message": "Resource has been exhausted"}}');

      expect(key1.status, equals(KeyStatus.rateLimited));
      expect(key1.isAvailable, isFalse);
      expect(key1.cooldownUntil, isNotNull);

      final nextKey = keyManager.getNextAvailableKey()!;
      expect(nextKey.key, isNot(equals(key1.key)));
      expect(nextKey.isAvailable, isTrue);
    });

    test('Kunci HTTP 401/403 ditandai sebagai INVALID secara permanen', () {
      final key1 = keyManager.getNextAvailableKey()!;
      keyManager.reportFailure(key1, 401, 'API_KEY_INVALID');

      expect(key1.status, equals(KeyStatus.invalid));
      expect(key1.isAvailable, isFalse);
      expect(key1.cooldownUntil, isNull);
    });
  });

  group('TeduhKnowledgeBase RAG Tests', () {
    late TeduhKnowledgeBase kb;

    setUp(() async {
      kb = TeduhKnowledgeBase.instance;
      await kb.initialize();
    });

    test('Pencarian "masker" menghasilkan panduan masker N95 dengan sitasi', () {
      final results = kb.retrieve(query: 'masker apa yang bagus untuk asap');
      expect(results, isNotEmpty);
      expect(results.first.document.category, equals('keselamatan'));
      expect(results.first.document.content.toLowerCase().contains('n95'), isTrue);
      expect(results.first.document.source, isNotEmpty);
    });

    test('Pencarian "ruang aman" menghasilkan panduan clean room di rumah', () {
      final results = kb.retrieve(query: 'bagaimana membuat ruang aman tanpa penyaring hepa');
      expect(results, isNotEmpty);
      expect(results.first.document.content.toLowerCase().contains('jendela'), isTrue);
    });

    test('Dokumen berstatus DRAFT tidak akan dimunculkan ke publik', () {
      kb.addDocument(const KBDocument(
        documentId: 'TEST-DRAFT-01',
        category: 'panduan',
        title: 'Panduan Rahasia Belum Terverifikasi',
        content: 'Isi draft rahasia.',
        source: 'Internal',
        version: '0.1',
        status: DocStatus.draft,
        updatedAt: '2026-11-11',
        keywords: ['rahasia', 'draft'],
      ));

      final results = kb.retrieve(query: 'rahasia draft');
      expect(results.any((r) => r.document.documentId == 'TEST-DRAFT-01'), isFalse);
    });
  });

  group('TeduhAiOrchestrator Contract & Recommendation Tests', () {
    late TeduhAiOrchestrator orchestrator;

    setUp(() async {
      orchestrator = TeduhAiOrchestrator.instance;
      await orchestrator.initialize();
    });

    test('Context-Aware Action Recommendation menghasilkan kontrak JSON standar', () {
      const air = AirSnapshot(
        source: MonitoringSource.klhk,
        sourceName: 'Stasiun KLHK Jekan Raya',
        sourceText: 'BMKG dan KLHK',
        ispuValue: '462',
        ispuLabel: '462 ISPU',
        pm25: '883.2 µg/m³',
        ispu: 462,
        pm25Value: 883.2,
        status: 'Berbahaya',
        location: 'Jekan Raya, Palangka Raya',
        updatedAt: '14.30 WIB',
      );

      final response = orchestrator.generateContextAwareRecommendation(
        air: air,
        activity: TeduhActivity.olahraga,
        sensitive: true,
      );

      expect(response.success, isTrue);
      expect(response.type, equals('context_aware_recommendation'));

      final json = response.toJson();
      expect(json.containsKey('context'), isTrue);
      expect(json.containsKey('analysis'), isTrue);
      expect(json.containsKey('recommendation'), isTrue);
      expect(json.containsKey('accessibility'), isTrue);
      expect(json.containsKey('metadata'), isTrue);

      expect(response.context['aqi'], equals(462));
      expect(response.priority, equals('high'));
      expect(response.mainAction.toLowerCase().contains('tunda') || response.mainAction.toLowerCase().contains('hindari'), isTrue);
      expect(response.speakableText, isNotEmpty);
      expect(response.simpleExplanation, isNotEmpty);
      expect(response.citations, contains('Stasiun KLHK Jekan Raya'));
    });

    test('askAssistant memberikan jawaban grounded jika offline / tanpa API key', () async {
      const air = AirSnapshot(
        source: MonitoringSource.satelit,
        sourceName: 'Stasiun BMKG Palangka Raya',
        sourceText: 'BMKG',
        ispuValue: '210',
        ispuLabel: '210 ISPU',
        pm25: '250.0 µg/m³',
        ispu: 210,
        pm25Value: 250.0,
        status: 'Sangat Tidak Sehat',
        location: 'Palangka Raya',
        updatedAt: '12.00 WIB',
      );

      final res = await orchestrator.askAssistant(
        userQuestion: 'Apakah masker kain cukup untuk asap ini?',
        liveAir: air,
      );

      expect(res.success, isTrue);
      expect(res.mainAction.toLowerCase().contains('n95') || res.mainAction.toLowerCase().contains('kain tidak'), isTrue);
      expect(res.citations, isNotEmpty);
      expect(res.mainAction.contains('belum tercatat dalam basis pengetahuan'), isFalse);
    });

    test('askAssistant menjawab pertanyaan mendalam Karhutla (penyebab & api gambut)', () async {
      final res = await orchestrator.askAssistant(
        userQuestion: 'Apa penyebab kebakaran hutan dan bagaimana api merambat di lahan gambut?',
      );
      expect(res.success, isTrue);
      final text = res.mainAction.toLowerCase();
      expect(text.contains('gambut') || text.contains('smoldering') || text.contains('bawah tanah'), isTrue);
      expect(text.contains('belum tercatat dalam basis pengetahuan'), isFalse);
    });

    test('askAssistant menjawab pertanyaan kesehatan polutan & kelompok rentan', () async {
      final res = await orchestrator.askAssistant(
        userQuestion: 'Apa dampak partikel PM2.5 bagi balita dan ibu hamil?',
      );
      expect(res.success, isTrue);
      final text = res.mainAction.toLowerCase();
      expect(text.contains('balita') || text.contains('rentan') || text.contains('alveoli') || text.contains('paru'), isTrue);
      expect(text.contains('belum tercatat dalam basis pengetahuan'), isFalse);
    });

    test('askAssistant menjawab pertanyaan ekosistem & siklus karbon', () async {
      final res = await orchestrator.askAssistant(
        userQuestion: 'Bagaimana dampak karhutla terhadap satwa orangutan dan emisi karbon?',
      );
      expect(res.success, isTrue);
      final text = res.mainAction.toLowerCase();
      expect(text.contains('orangutan') || text.contains('karbon') || text.contains('sink'), isTrue);
      expect(text.contains('belum tercatat dalam basis pengetahuan'), isFalse);
    });

    test('askAssistant merespons salam percakapan dengan ramah dan edukatif', () async {
      final res = await orchestrator.askAssistant(
        userQuestion: 'Halo TEDUH, kamu bisa bantu apa saja?',
      );
      expect(res.success, isTrue);
      final text = res.mainAction.toLowerCase();
      expect(text.contains('halo') || text.contains('asisten') || text.contains('teduh ai'), isTrue);
      expect(text.contains('belum tercatat dalam basis pengetahuan'), isFalse);
    });
  });
}
