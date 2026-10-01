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

  Future<void> signOut();

  /// Permanently deletes user account and purges all cloud data
  Future<void> deleteAccount();
}

