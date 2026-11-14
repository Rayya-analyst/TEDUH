import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum KeyStatus {
  active,
  rateLimited,
  quotaExceeded,
  temporarilyUnavailable,
  invalid,
  disabled,
}

class AIKey {
  final String key;
  KeyStatus status;
  int failureCount;
  int successCount;
  DateTime? cooldownUntil;
  DateTime? lastUsed;
  String? lastErrorReason;

  AIKey({
    required this.key,
    this.status = KeyStatus.active,
    this.failureCount = 0,
    this.successCount = 0,
    this.cooldownUntil,
    this.lastUsed,
    this.lastErrorReason,
  });

  String get maskedKey {
    if (key.length <= 8) return '***';
    return '${key.substring(0, 6)}...${key.substring(key.length - 4)}';
  }

  bool get isAvailable {
    if (status == KeyStatus.invalid || status == KeyStatus.disabled) {
      return false;
    }
    if (cooldownUntil != null && DateTime.now().isBefore(cooldownUntil!)) {
      return false;
    }
    if (cooldownUntil != null && DateTime.now().isAfter(cooldownUntil!)) {
      status = KeyStatus.active;
      cooldownUntil = null;
    }
    return status == KeyStatus.active;
  }

  Map<String, dynamic> toJson() => {
        'masked': maskedKey,
        'status': status.name,
        'failureCount': failureCount,
        'successCount': successCount,
        'cooldownUntil': cooldownUntil?.toIso8601String(),
        'lastUsed': lastUsed?.toIso8601String(),
        'lastError': lastErrorReason,
      };
}

class MultiApiKeyManager extends ChangeNotifier {
  MultiApiKeyManager._();
  static final MultiApiKeyManager instance = MultiApiKeyManager._();

  static const String _prefStorageKey = 'teduh_ai_api_keys_v1';
  final List<AIKey> _keys = [];
  int _currentIndex = 0;

  List<AIKey> get keys => List.unmodifiable(_keys);

  bool get hasValidKeys => _keys.any((k) => k.status != KeyStatus.invalid && k.status != KeyStatus.disabled);

  static const List<String> defaultBuiltInKeys = [];

  Future<void> initialize({List<String>? initialKeys}) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefStorageKey) ?? [];

    final combined = <String>{};
    const envKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) combined.add(envKey.trim());

    if (initialKeys != null) {
      for (final k in initialKeys) {
        final trimmed = k.trim();
        if (trimmed.isNotEmpty) combined.add(trimmed);
      }
    }
    for (final k in saved) {
      final trimmed = k.trim();
      if (trimmed.isNotEmpty) combined.add(trimmed);
    }

    if (combined.isEmpty) {
      combined.addAll(defaultBuiltInKeys);
    }

    _keys.clear();
    for (final k in combined) {
      _keys.add(AIKey(key: k));
    }
    notifyListeners();
  }

  Future<void> addKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty || _keys.any((k) => k.key == trimmed)) return;
    _keys.add(AIKey(key: trimmed));
    await _persistKeys();
    notifyListeners();
  }

  Future<void> removeKeyAt(int index) async {
    if (index >= 0 && index < _keys.length) {
      _keys.removeAt(index);
      await _persistKeys();
      notifyListeners();
    }
  }

  Future<void> setKeys(List<String> keyStrings) async {
    _keys.clear();
    for (final k in keyStrings) {
      final trimmed = k.trim();
      if (trimmed.isNotEmpty && !_keys.any((x) => x.key == trimmed)) {
        _keys.add(AIKey(key: trimmed));
      }
    }
    await _persistKeys();
    notifyListeners();
  }

  Future<void> _persistKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefStorageKey, _keys.map((k) => k.key).toList());
  }

  AIKey? getNextAvailableKey() {
    if (_keys.isEmpty) return null;

    final count = _keys.length;
    for (int i = 0; i < count; i++) {
      final idx = (_currentIndex + i) % count;
      final candidate = _keys[idx];
      if (candidate.isAvailable) {
        _currentIndex = (idx + 1) % count;
        candidate.lastUsed = DateTime.now();
        return candidate;
      }
    }
    return null; 
  }

  void reportSuccess(AIKey key) {
    key.successCount++;
    key.failureCount = 0;
    key.status = KeyStatus.active;
    key.cooldownUntil = null;
    key.lastErrorReason = null;
    notifyListeners();
  }

  void reportFailure(AIKey key, int statusCode, String responseBody, {bool isTimeout = false}) {
    key.failureCount++;
    key.lastUsed = DateTime.now();

    final bodyLower = responseBody.toLowerCase();
    final randomJitter = math.Random().nextInt(5); 

    if (isTimeout) {
      key.status = KeyStatus.temporarilyUnavailable;
      key.cooldownUntil = DateTime.now().add(Duration(seconds: 15 + randomJitter));
      key.lastErrorReason = 'Timeout koneksi';
    } else if (statusCode == 429) {
      key.status = KeyStatus.rateLimited;
      final backoff = math.min(180, 30 * math.pow(2, math.min(key.failureCount - 1, 3)).toInt());
      key.cooldownUntil = DateTime.now().add(Duration(seconds: backoff + randomJitter));
      key.lastErrorReason = 'Rate limit (HTTP 429)';
    } else if (statusCode == 401 || statusCode == 403 || bodyLower.contains('api_key_invalid') || bodyLower.contains('permission_denied')) {
      key.status = KeyStatus.invalid;
      key.cooldownUntil = null;
      key.lastErrorReason = 'Kunci tidak valid / Ditolak (HTTP $statusCode)';
    } else if (bodyLower.contains('quota_exceeded') || bodyLower.contains('resource_exhausted') || bodyLower.contains('billing')) {
      key.status = KeyStatus.quotaExceeded;
      key.cooldownUntil = DateTime.now().add(Duration(minutes: 15 + randomJitter));
      key.lastErrorReason = 'Kuota habis';
    } else if (statusCode >= 500) {
      key.status = KeyStatus.temporarilyUnavailable;
      key.cooldownUntil = DateTime.now().add(Duration(seconds: 20 + randomJitter));
      key.lastErrorReason = 'Gangguan server provider (HTTP $statusCode)';
    } else {
      key.status = KeyStatus.temporarilyUnavailable;
      key.cooldownUntil = DateTime.now().add(Duration(seconds: 10 + randomJitter));
      key.lastErrorReason = 'Error HTTP $statusCode';
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> getDiagnostics() => _keys.map((k) => k.toJson()).toList();
}

