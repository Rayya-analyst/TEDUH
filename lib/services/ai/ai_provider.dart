import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_key_manager.dart';

class AIResponse {
  final bool success;
  final String text;
  final String? model;
  final String? provider;
  final String? error;
  final int attempts;

  const AIResponse({
    required this.success,
    required this.text,
    this.model,
    this.provider,
    this.error,
    this.attempts = 1,
  });
}

abstract class AIProvider {
  String get providerName;

  Future<AIResponse> generateCompletion({
    required String systemPrompt,
    required String userPrompt,
    Duration timeout = const Duration(seconds: 15),
    int maxRetries = 3,
  });
}

class GeminiProvider implements AIProvider {
  String modelName;
  GeminiProvider({this.modelName = 'gemini-3.5-flash'});

  static const List<String> _fallbackModels = [
    'gemini-3.5-flash',
    'gemini-flash-latest',
    'gemini-3.8-flash',
    'gemini-2.5-flash',
  ];

  @override
  String get providerName => 'google_gemini';

  @override
  Future<AIResponse> generateCompletion({
    required String systemPrompt,
    required String userPrompt,
    Duration timeout = const Duration(seconds: 25),
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    String lastError = 'Tidak ada API Key yang tersedia.';

    while (attempts < maxRetries) {
      final activeKey = MultiApiKeyManager.instance.getNextAvailableKey();
      if (activeKey == null) {
        lastError = 'Semua API Key sedang dalam masa cooldown atau tidak tersedia.';
        break;
      }

      attempts++;
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=${activeKey.key}',
      );

      final body = jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt}
          ]
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': userPrompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 8192,
        }
      });

      try {
        final res = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(timeout);

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final partText = candidates[0]['content']?['parts']?[0]?['text'] as String?;
            if (partText != null && partText.trim().isNotEmpty) {
              MultiApiKeyManager.instance.reportSuccess(activeKey);
              return AIResponse(
                success: true,
                text: partText.trim(),
                model: modelName,
                provider: providerName,
                attempts: attempts,
              );
            }
          }
          lastError = 'Format respons dari Gemini kosong atau tidak valid.';
        } else if (res.statusCode == 404) {
          for (final fb in _fallbackModels) {
            if (fb != modelName) {
              modelName = fb;
              break;
            }
          }
          lastError = 'Model 404, beralih ke model fallback: $modelName';
        } else {
          MultiApiKeyManager.instance.reportFailure(activeKey, res.statusCode, res.body);
          lastError = 'HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'Error'}';
        }
      } on TimeoutException {
        MultiApiKeyManager.instance.reportFailure(activeKey, 408, '', isTimeout: true);
        lastError = 'Permintaan waktu habis (timeout).';
      } catch (e) {
        MultiApiKeyManager.instance.reportFailure(activeKey, 0, e.toString());
        lastError = 'Gangguan jaringan: $e';
      }
    }

    return AIResponse(
      success: false,
      text: '',
      model: modelName,
      provider: providerName,
      error: lastError,
      attempts: attempts,
    );
  }
}

