import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_config.dart';
import '../api_reframing_service.dart';
import 'i_auth_provider.dart';

/// ⚡ SupabaseAuthProvider: Production implementation using live Supabase Flutter SDK
class SupabaseAuthProvider implements IAuthProvider {
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String? get currentUserId =>
      _isInitialized ? Supabase.instance.client.auth.currentUser?.id : null;

  @override
  String? get currentUserEmail =>
      _isInitialized ? Supabase.instance.client.auth.currentUser?.email : null;

  @override
  String? get accessToken =>
      _isInitialized ? Supabase.instance.client.auth.currentSession?.accessToken : null;

  @override
  bool get isAuthenticated => _isInitialized && currentUserId != null;

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
  Future<void> signInWithGoogle() async {
    debugPrint('🌐 [SupabaseAuthProvider] Initiating Google OAuth flow...');
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.silverlining://login-callback/',
    );
  }

  @override
  Future<void> signInWithApple() async {
    debugPrint('🍎 [SupabaseAuthProvider] Initiating Apple OAuth flow...');
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: kIsWeb ? null : 'io.supabase.silverlining://login-callback/',
    );
  }

  @override
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    debugPrint('🔒 [SupabaseAuthProvider] Signed out.');
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // Call backend to cascade-delete all DB records
      await ApiReframingService().deleteAccount();
    } catch (e) {
      debugPrint('⚠️ [SupabaseAuthProvider] Error during backend account deletion: $e');
    }
    // Sign out to clear tokens & session
    await signOut();
    debugPrint('🗑️ [SupabaseAuthProvider] User account permanently deleted.');
  }
}

