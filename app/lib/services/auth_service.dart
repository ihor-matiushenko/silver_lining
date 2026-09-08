import '../config/app_config.dart';
import 'providers/i_auth_provider.dart';
import 'providers/mock_auth_provider.dart';
import 'providers/supabase_auth_provider.dart';

/// 🔐 AuthService: Clean facade delegating to live Supabase or Mock Auth Provider
class AuthService implements IAuthProvider {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  late final IAuthProvider _provider;

  AuthService._internal({IAuthProvider? customProvider}) {
    if (customProvider != null) {
      _provider = customProvider;
    } else if (AppConfig.isSupabaseConfigured) {
      _provider = SupabaseAuthProvider();
    } else {
      _provider = MockAuthProvider();
    }
  }

  @override
  bool get isInitialized => _provider.isInitialized;

  @override
  String? get currentUserId => _provider.currentUserId;

  @override
  String? get currentUserEmail => _provider.currentUserEmail;

  @override
  String? get accessToken => _provider.accessToken;

  @override
  bool get isAuthenticated => _provider.isAuthenticated;

  @override
  Future<void> initialize() => _provider.initialize();

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) =>
      _provider.signUp(email: email, password: password);

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) =>
      _provider.signIn(email: email, password: password);

  @override
  Future<void> signOut() => _provider.signOut();
}
