import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🔐 AuthService: Manages Supabase Auth, User Sessions, and JWT Access Tokens
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isInitialized = false;
  String? _mockToken;
  String? _mockUserId;
  String? _mockEmail;

  /// Returns true if Supabase SDK has been initialized
  bool get isInitialized => _isInitialized;

  /// Returns the current logged-in User ID (or null if Guest)
  String? get currentUserId {
    if (_isInitialized) {
      return Supabase.instance.client.auth.currentUser?.id ?? _mockUserId;
    }
    return _mockUserId;
  }

  /// Returns the current logged-in User Email (or null if Guest)
  String? get currentUserEmail {
    if (_isInitialized) {
      return Supabase.instance.client.auth.currentUser?.email ?? _mockEmail;
    }
    return _mockEmail;
  }

  /// Returns the JWT Access Token for attaching to FastAPI Authorization headers
  String? get accessToken {
    if (_isInitialized) {
      return Supabase.instance.client.auth.currentSession?.accessToken ?? _mockToken;
    }
    return _mockToken;
  }

  /// True if a user is currently logged in (not Guest)
  bool get isAuthenticated => currentUserId != null;

  /// Initializes Supabase Flutter SDK with project URL and Anon Key
  Future<void> initialize({
    String url = 'https://YOUR_SUPABASE_URL.supabase.co',
    String anonKey = 'YOUR_SUPABASE_ANON_KEY',
  }) async {
    if (_isInitialized) return;

    try {
      if (url.contains('YOUR_SUPABASE_URL')) {
        debugPrint('⚠️ Supabase URL not configured yet. Running in Development Auth Mode.');
        _isInitialized = false;
        return;
      }

      // ignore: deprecated_member_use
      await Supabase.initialize(url: url, anonKey: anonKey);
      _isInitialized = true;
      debugPrint('✅ Supabase Auth initialized successfully!');
    } catch (e) {
      debugPrint('⚠️ Supabase initialization note: $e');
    }
  }

  /// Sign Up with Email and Password
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) {
      // Development Mock Mode Fallback
      _mockUserId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      _mockEmail = email;
      _mockToken = 'mock_jwt_token_dev_mode';
      debugPrint('🔓 [Dev Auth] Mock Sign Up successful for $email');
      return null;
    }

    return await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign In with Email and Password
  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) {
      // Development Mock Mode Fallback
      _mockUserId = 'usr_logged_in_123';
      _mockEmail = email;
      _mockToken = 'mock_jwt_token_dev_mode';
      debugPrint('🔓 [Dev Auth] Mock Sign In successful for $email');
      return null;
    }

    return await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign Out
  Future<void> signOut() async {
    if (_isInitialized) {
      await Supabase.instance.client.auth.signOut();
    }
    _mockUserId = null;
    _mockEmail = null;
    _mockToken = null;
    debugPrint('🔒 User signed out.');
  }
}
