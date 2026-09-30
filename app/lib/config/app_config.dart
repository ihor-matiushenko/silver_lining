import 'package:flutter/foundation.dart';

/// ⚙️ AppConfig: Centralized Configuration & Environment Feature Flags
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_SUPABASE_URL.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static const bool forceMockAuth = bool.fromEnvironment(
    'USE_MOCK_AUTH',
    defaultValue: false,
  );

  /// Returns true if Supabase URL and Anon Key are valid and configured
  static bool get isSupabaseConfigured {
    if (forceMockAuth) return false;
    return supabaseUrl.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE_URL') &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY');
  }

  /// 🌐 Centralized Backend Base URL with automatic platform discovery
  /// (e.g. Android Emulator localhost is mapped to 10.0.2.2:8000)
  static String get apiBaseUrl {
    const overrideUrl = String.fromEnvironment('API_BASE_URL');
    if (overrideUrl.isNotEmpty) return overrideUrl;

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }
}

