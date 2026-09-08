import 'package:flutter/foundation.dart';
import 'i_auth_provider.dart';

/// 🧪 MockAuthProvider: Isolated mock implementation for offline dev & UI testing
class MockAuthProvider implements IAuthProvider {
  bool _isInitialized = true;
  String? _mockUserId;
  String? _mockEmail;
  String? _mockToken;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String? get currentUserId => _mockUserId;

  @override
  String? get currentUserEmail => _mockEmail;

  @override
  String? get accessToken => _mockToken;

  @override
  bool get isAuthenticated => _mockUserId != null;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    debugPrint('🧪 [MockAuthProvider] Running in Mock Development Mode.');
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    _mockUserId = 'usr_mock_${DateTime.now().millisecondsSinceEpoch}';
    _mockEmail = email;
    _mockToken = 'dev_mock_jwt_token';
    debugPrint('🔓 [MockAuthProvider] Mock Sign Up successful for $email');
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _mockUserId = 'usr_mock_logged_in_123';
    _mockEmail = email;
    _mockToken = 'dev_mock_jwt_token';
    debugPrint('🔓 [MockAuthProvider] Mock Sign In successful for $email');
  }

  @override
  Future<void> signOut() async {
    _mockUserId = null;
    _mockEmail = null;
    _mockToken = null;
    debugPrint('🔒 [MockAuthProvider] Mock Signed out.');
  }
}
