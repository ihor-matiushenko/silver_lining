import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_config.dart';
import 'i_auth_provider.dart';

/// ⚡ SupabaseAuthProvider: Production implementation using live Supabase Flutter SDK
class SupabaseAuthProvider implements IAuthProvider {
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  String? get currentUserEmail => Supabase.instance.client.auth.currentUser?.email;

  @override
  String? get accessToken => Supabase.instance.client.auth.currentSession?.accessToken;

  @override
  bool get isAuthenticated => currentUserId != null;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // ignore: deprecated_member_use
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: AppConfig.supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('✅ [SupabaseAuthProvider] Initialized live Supabase Auth!');
    } catch (e) {
      debugPrint('⚠️ [SupabaseAuthProvider] Initialization note: $e');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    debugPrint('🔒 [SupabaseAuthProvider] Signed out.');
  }
}
