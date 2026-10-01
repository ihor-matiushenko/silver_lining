import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'storage_service.dart';

/// 🌐 Dynamic Backend-Driven UI Localization Service
/// Fetches UI translations dynamically for ANY language code from /api/v1/l10n/{lang}
/// Zero hardcoding in Flutter app! Guaranteed fallback to English ('en').
class DynamicLocalizationService extends ChangeNotifier {
  final String baseUrl;
  final Map<String, Map<String, String>> _cache = {};

  // 'system' or explicit ISO code (e.g. 'uk', 'en', 'es', 'de', 'fr')
  String _selectedLanguage = 'system';
  String _currentLangCode = 'en';
  bool _isInitialized = false;

  DynamicLocalizationService({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  static final DynamicLocalizationService instance = DynamicLocalizationService();

  bool get isInitialized => _isInitialized;
  String get selectedLanguage => _selectedLanguage;
  String get currentLangCode => _currentLangCode;

  // Base English fallback dictionary for offline mode or network errors
  static const Map<String, String> baseEnglishFallback = {
    "appTitle": "Silver Lining",
    "reframePrompt": "What is weighing on your mind?",
    "reframeInputHint": "Share what happened today, your concerns, or what feels tough...",
    "reframeButton": "Find Silver Lining",
    "reframeButtonAction": "Reframe Thought ✨",
    "historyTitle": "Cloud History",
    "signInTitle": "Sign In to Sync History",
    "guestModeText": "Guest Mode (5 reframings / day)",
    "rateLimitWarning": "Guest limit reached. Sign up for unlimited access!",
    "favoriteLabel": "Favorites",
    "deleteConfirm": "Delete this record?",
    "languageAuto": "Auto-Detect Language",
    "languageTitle": "Language",
    "languageSystem": "Follow System",
    "accountTitle": "Account",
    "signOut": "Sign Out",
    "close": "Close",
  };

  /// Initializes the service from saved storage or device locale
  Future<void> init() async {
    final saved = await StorageService.getSavedLanguage();
    _selectedLanguage = saved ?? 'system';
    final effectiveCode = _resolveEffectiveLanguageCode(_selectedLanguage);
    await fetchUIStrings(effectiveCode);
    _isInitialized = true;
    notifyListeners();
  }

  /// Resolves the effective ISO language code given the selection ('system' or specific ISO code)
  String _resolveEffectiveLanguageCode(String selection) {
    if (selection == 'system') {
      final deviceLocale = PlatformDispatcher.instance.locale;
      final deviceCode = deviceLocale.languageCode.toLowerCase();
      return deviceCode.isNotEmpty ? deviceCode : 'en';
    }
    return selection.toLowerCase().trim();
  }

  /// Changes the user's language selection ('system', 'uk', 'en', etc.), updates cache and notifies UI
  Future<void> setLanguage(String langCode) async {
    _selectedLanguage = langCode;
    await StorageService.saveLanguage(langCode);
    final effectiveCode = _resolveEffectiveLanguageCode(langCode);
    await fetchUIStrings(effectiveCode);
    notifyListeners();
  }

  /// Fetches UI string map dynamically from backend for requested language code
  Future<Map<String, String>> fetchUIStrings(String langCode) async {
    final code = langCode.toLowerCase().trim().split('-')[0];
    _currentLangCode = code;

    if (_cache.containsKey(code)) {
      notifyListeners();
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
        notifyListeners();
        return strings;
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching dynamic localization for $langCode: $e');
    }

    // Fallback to base English strings if backend is offline or key missing
    _cache[code] = Map<String, String>.from(baseEnglishFallback);
    notifyListeners();
    return baseEnglishFallback;
  }

  /// Synchronously translates a UI key for current active language code, with English fallback
  String translate(String key) {
    final activeMap = _cache[_currentLangCode] ?? baseEnglishFallback;
    return activeMap[key] ?? baseEnglishFallback[key] ?? key;
  }
}
