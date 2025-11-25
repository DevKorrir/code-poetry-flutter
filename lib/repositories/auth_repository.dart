import '../models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/secure_storage_service.dart';

/// Authentication Repository
/// Handles all authentication logic and user state management
class AuthRepository {
  final AuthService _authService;
  final StorageService _storageService;

  AuthRepository({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService;

  // ============================================================
  // AUTHENTICATION STATE
  // ============================================================

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isSignedIn;

  /// Check if current user is guest
  bool get isGuest => _authService.isGuest;

  /// Get current user
  UserModel? get currentUser => _authService.getCurrentUserModel();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel.fromFirebaseUser(
        firebaseUser,
        isGuest: firebaseUser.isAnonymous,
        isPro: _isUserPro(),
      );
    });
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Save user data locally
      await _saveUserLocally(user);

      return user;
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      // Update Pro status from storage
      final isPro = _storageService.getBool(StorageKeys.isPro) ?? false;
      final updatedUser = user.copyWith(isPro: isPro);

      await _saveUserLocally(updatedUser);

      return updatedUser;
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();

      // Update Pro status
      final isPro = _storageService.getBool(StorageKeys.isPro) ?? false;
      final updatedUser = user.copyWith(isPro: isPro);

      await _saveUserLocally(updatedUser);

      return updatedUser;
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  /// Sign in with GitHub - USE AUTH SERVICE IMPLEMENTATION
  Future<UserModel> signInWithGitHub() async {
    try {
      final user = await _authService.signInWithGitHub();

      // Update Pro status
      final isPro = _storageService.getBool(StorageKeys.isPro) ?? false;
      final updatedUser = user.copyWith(isPro: isPro);

      await _saveUserLocally(updatedUser);

      return updatedUser;
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  /// Check for pending GitHub OAuth redirect result
  Future<UserModel?> checkPendingRedirectResult() async {
    try {
      final user = await _authService.getRedirectResult();

      if (user == null) {
        return null; // No pending redirect
      }

      // Update Pro status
      final isPro = _storageService.getBool(StorageKeys.isPro) ?? false;
      final updatedUser = user.copyWith(isPro: isPro);

      await _saveUserLocally(updatedUser);

      return updatedUser;
    } catch (e) {
      // Failed to get redirect result
      return null;
    }
  }

  /// Sign in as guest
  Future<UserModel> signInAsGuest() async {
    try {
      final user = await _authService.signInAsGuest();

      await _saveUserLocally(user);

      return user;
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  // ============================================================
  // PROVIDER INFO
  // ============================================================

  /// Check if user has GitHub provider
  bool hasGitHubProvider() {
    return _authService.hasGitHubProvider();
  }

  /// Get authentication provider name
  String getProviderName() {
    return _authService.getProviderName();
  }

  /// Check if has password provider
  bool hasPasswordProvider() {
    return _authService.hasPasswordProvider();
  }

  /// Check if has Google provider
  bool hasGoogleProvider() {
    return _authService.hasGoogleProvider();
  }

  /// Get GitHub token for API calls from secure storage
  Future<String?> getGitHubToken() async {
    return await _authService.getGitHubToken();
  }

  // ============================================================
  // GUEST CONVERSION
  // ============================================================

  /// Convert guest account to permanent account
  Future<UserModel> convertGuestToUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.convertGuestToUser(
        email: email,
        password: password,
      );

      await _saveUserLocally(user);

      return user;
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  // ============================================================
  // PASSWORD MANAGEMENT
  // ============================================================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  // ============================================================
  // PROFILE MANAGEMENT
  // ============================================================

  /// Update display name
  Future<void> updateDisplayName(String name) async {
    try {
      await _authService.updateDisplayName(name);

      // Update locally
      await _storageService.saveString(StorageKeys.userName, name);
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  /// Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _authService.updateEmail(newEmail);

      // Update locally
      await _storageService.saveString(StorageKeys.userEmail, newEmail);
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      return await _authService.isEmailVerified();
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // SIGN OUT & DELETION
  // ============================================================

  /// Sign out current user
  ///
  /// IMPORTANT: This clears ALL local data (poems, settings, etc.) to prevent
  /// data leakage between different user accounts. When the same user signs
  /// back in, their data will be automatically restored from Firestore via
  /// AuthViewModel._syncUserDataAfterLogin()
  Future<void> signOut() async {
    try {
      await _authService.signOut();

      // Clear ALL local user data to prevent data leakage between accounts
      // Note: Data is restored from cloud when user logs back in
      await _clearAllUserData();
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();

      // Clear all local data
      await _clearUserLocally();
      await _storageService.clearAllPoems();
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    }
  }

  // ============================================================
  // PRO SUBSCRIPTION
  // ============================================================

  /// Check if user is Pro
  bool _isUserPro() {
    return _storageService.getBool(StorageKeys.isPro) ?? false;
  }

  /// Upgrade to Pro (would integrate with payment service)
  Future<void> upgradeToPro() async {
    try {
      // In real app, this would:
      // 1. Process payment via Stripe/RevenueCat
      // 2. Verify payment on backend
      // 3. Update Firestore user document
      // 4. Update local storage

      // For now, just update local storage
      await _storageService.saveBool(StorageKeys.isPro, true);
    } catch (e) {
      throw AuthRepositoryException('Failed to upgrade: ${e.toString()}');
    }
  }

  /// Restore Pro purchase
  Future<bool> restoreProPurchase() async {
    try {
      // In real app, this would:
      // 1. Check with payment provider
      // 2. Verify receipt
      // 3. Restore Pro status

      // For now, check Firestore (if implemented)
      final isPro = _storageService.getBool(StorageKeys.isPro) ?? false;
      return isPro;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // USER DATA PERSISTENCE
  // ============================================================

  /// Save user data to local storage
  Future<void> _saveUserLocally(UserModel user) async {
    await _storageService.saveString(StorageKeys.userId, user.id);

    if (user.email != null) {
      await _storageService.saveString(StorageKeys.userEmail, user.email!);
    }

    if (user.displayName != null) {
      await _storageService.saveString(StorageKeys.userName, user.displayName!);
    }

    await _storageService.saveBool(StorageKeys.isGuest, user.isGuest);
    await _storageService.saveBool(StorageKeys.isPro, user.isPro);
  }

  /// Clear user data from local storage
  Future<void> _clearUserLocally() async {
    await _storageService.remove(StorageKeys.userId);
    await _storageService.remove(StorageKeys.userEmail);
    await _storageService.remove(StorageKeys.userName);
    await _storageService.remove(StorageKeys.isGuest);
    // Keep isPro in case user signs back in
  }

  /// Clear ALL user data including poems, stats, and secure tokens
  /// This prevents data leakage when switching between accounts
  Future<void> _clearAllUserData() async {
    // Clear basic user info
    await _clearUserLocally();
    
    // Clear user-specific stats and settings
    await _storageService.remove(StorageKeys.totalPoemsGenerated);
    await _storageService.remove(StorageKeys.poemsGeneratedToday);
    await _storageService.remove(StorageKeys.lastPoemDate);
    await _storageService.remove(StorageKeys.lastSyncTime);
    
    // Clear all poems data
    await _storageService.clearAllPoems();
    
    // Clear secure tokens (GitHub, Google, etc.)
    await _clearSecureTokens();
  }

  /// Clear all secure tokens to prevent unauthorized access
  Future<void> _clearSecureTokens() async {
    try {
      final secureStorage = SecureStorageService();
      if (secureStorage.isInitialized) {
        await secureStorage.delete(key: SecureStorageKeys.githubToken);
        await secureStorage.delete(key: SecureStorageKeys.googleToken);
        await secureStorage.delete(key: SecureStorageKeys.openaiApiKey);
        // Note: We don't call deleteAll() to preserve any other secure data
        // that might be unrelated to user authentication
      }
    } catch (e) {
      // Log error but don't fail sign out
      print('Warning: Failed to clear secure tokens: ${e.toString()}');
    }
  }

  /// Get locally saved user ID
  String? getLocalUserId() {
    return _storageService.getString(StorageKeys.userId);
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  PasswordStrength validatePassword(String password) {
    if (password.length < 6) {
      return PasswordStrength.tooShort;
    }

    if (password.length < 8) {
      return PasswordStrength.weak;
    }

    // Check for variety of characters
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasLowercase) strength++;
    if (hasUppercase) strength++;
    if (hasDigit) strength++;
    if (hasSpecial) strength++;

    if (strength >= 3 && password.length >= 12) {
      return PasswordStrength.strong;
    } else if (strength >= 2 && password.length >= 8) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  /// Get password strength message
  String getPasswordStrengthMessage(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.tooShort:
        return 'Password must be at least 6 characters';
      case PasswordStrength.weak:
        return 'Weak password. Add uppercase, numbers, or symbols.';
      case PasswordStrength.medium:
        return 'Medium strength password';
      case PasswordStrength.strong:
        return 'Strong password!';
    }
  }

  /// Get last sync time from storage
  String? getLastSyncTime() {
    return _storageService.getString(StorageKeys.lastSyncTime);
  }
}

/// Custom exception for auth repository
class AuthRepositoryException implements Exception {
  final String message;
  AuthRepositoryException(this.message);

  @override
  String toString() => 'AuthRepositoryException: $message';
}

/// Password strength enum
enum PasswordStrength {
  tooShort,
  weak,
  medium,
  strong,
}