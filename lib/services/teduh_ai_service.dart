import 'ai/ai_key_manager.dart';
import 'ai/teduh_ai_orchestrator.dart';

class TeduhAiService {
  TeduhAiService._();
  static final TeduhAiService instance = TeduhAiService._();

  Future<void> setApiKey(String key) async {
    await MultiApiKeyManager.instance.addKey(key);
  }

  Future<void> setMultipleKeys(List<String> keys) async {
    await MultiApiKeyManager.instance.setKeys(keys);
  }

  Future<String> sendMessage({
    required String userMessage,
    String? locationContext,
    String? airQualityContext,
  }) async {
    final response = await TeduhAiOrchestrator.instance.askAssistant(
      userQuestion: userMessage,
      userLocation: locationContext,
    );
    return response.mainAction;
  }
}
