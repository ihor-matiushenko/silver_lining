/// 🔐 IAuthProvider: Abstract Interface for Authentication Providers
abstract class IAuthProvider {
  bool get isInitialized;
  String? get currentUserId;
  String? get currentUserEmail;
  String? get accessToken;
  bool get isAuthenticated;

  Future<void> initialize();

  Future<void> signUp({
    required String email,
    required String password,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  /// Initiates OAuth Sign-In flow with Google
  Future<void> signInWithGoogle();

  /// Initiates OAuth Sign-In flow with Apple (required by Apple App Store Guideline 4.8)
  Future<void> signInWithApple();

  Future<void> signOut();

  /// Permanently deletes user account and purges all cloud data
  Future<void> deleteAccount();
}

