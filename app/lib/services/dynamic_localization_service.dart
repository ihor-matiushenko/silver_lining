import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 🌐 Dynamic Backend-Driven UI Localization Service
/// Fetches UI translations dynamically for ANY language code from /api/v1/l10n/{lang}
/// Zero hardcoding in Flutter app! Guaranteed fallback to English ('en').
class DynamicLocalizationService {
  final String baseUrl;
  final Map<String, Map<String, String>> _cache = {};
  String _currentLangCode = 'en';

  DynamicLocalizationService({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? 'http://127.0.0.1:8000';

  static final DynamicLocalizationService instance = DynamicLocalizationService();

  String get currentLangCode => _currentLangCode;

  // Base English fallback dictionary for offline mode or network errors
  static const Map<String, String> baseEnglishFallback = {
    "appTitle": "Silver Lining",
    "reframePrompt": "What is weighing on your mind?",
    "reframeButton": "Find Silver Lining",
    "historyTitle": "Cloud History",
    "signInTitle": "Sign In to Sync History",
    "guestModeText": "Guest Mode (5 reframings / day)",
    "rateLimitWarning": "Guest limit reached. Sign up for unlimited access!",
    "favoriteLabel": "Favorites",
    "deleteConfirm": "Delete this record?",
    "languageAuto": "Auto-Detect Language",
  };

  /// Fetches UI string map dynamically from backend for requested language code
  Future<Map<String, String>> fetchUIStrings(String langCode) async {
    final code = langCode.toLowerCase().trim().split('-')[0];
    _currentLangCode = code;

    if (_cache.containsKey(code)) {
      return _cache[code]!;
    }

    final uri = Uri.parse('$baseUrl/api/v1/l10n/$code');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> stringsJson = data['strings'] ?? {};
        final Map<String, String> strings = stringsJson.map(
          (k, v) => MapEntry(k, v.toString()),
        );
        _cache[code] = strings;
        return strings;
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching dynamic localization for $langCode: $e');
    }

    // Fallback to base English strings if backend is offline or key missing
    _cache[code] = Map<String, String>.from(baseEnglishFallback);
    return baseEnglishFallback;
  }

  /// Synchronously translates a UI key for current active language code, with English fallback
  String translate(String key) {
    final activeMap = _cache[_currentLangCode] ?? baseEnglishFallback;
    return activeMap[key] ?? baseEnglishFallback[key] ?? key;
  }
}
