import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Authentication ViewModel
/// Manages authentication state and operations
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  // ============================================================
  // STATE
  // ============================================================

  // Current user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _error;
  String? get error => _error;

  // Success message
  String? _successMessage;
  String? get successMessage => _successMessage;

  // ============================================================
  // AUTHENTICATION STATUS
  // ============================================================

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Check if user is guest
  bool get isGuest => _currentUser?.isGuest ?? true;

  /// Check if user is Pro
  bool get isPro => _currentUser?.isPro ?? false;

  /// Check if user is free tier
  bool get isFreeTier => isAuthenticated && !isGuest && !isPro;

  /// Get user display name
  String get displayName => _currentUser?.displayName ?? 'User';

  /// Get user email
  String? get email => _currentUser?.email;

  /// Check if user has password provider (can change password)
  bool hasPasswordProvider() => _authRepository.hasPasswordProvider();

  /// Check if GitHub is connected
  bool get hasGitHub => _authRepository.hasGitHubProvider();

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initialize and load current user
  Future<void> initialize() async {
    _currentUser = _authRepository.currentUser;

    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    if (!_validateSignUpInputs(email, password, password)) {
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      _currentUser = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      _setSuccess('Account created successfully!');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_validateSignInInputs(email, password)) {
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      _currentUser = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      _setSuccess('Welcome back!');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearMessages();

    try {
      _currentUser = await _authRepository.signInWithGoogle();

      _setSuccess('Signed in with Google!');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with GitHub
  Future<bool> signInWithGitHub() async {
    _setLoading(true);
    _clearMessages();

    try {
      _currentUser = await _authRepository.signInWithGitHub();

      _setSuccess('Connected with GitHub!');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Sign in as guest
  Future<bool> signInAsGuest() async {
    _setLoading(true);
    _clearMessages();

    try {
      _currentUser = await _authRepository.signInAsGuest();

      _setSuccess('Continuing as guest');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // GUEST CONVERSION
  // ============================================================

  /// Convert guest account to permanent account
  Future<bool> convertGuestToUser({
    required String email,
    required String password,
  }) async {
    if (!isGuest) {
      _setError('Current user is not a guest');
      return false;
    }

    if (!_validateSignUpInputs(email, password, password)) {
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      _currentUser = await _authRepository.convertGuestToUser(
        email: email,
        password: password,
      );

      _setSuccess('Account created! Your poems have been saved.');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // PASSWORD MANAGEMENT
  // ============================================================

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    if (!_authRepository.isValidEmail(email)) {
      _setError('Invalid email address');
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setSuccess('Password reset email sent!');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Update password
  Future<bool> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      _setError('Passwords do not match');
      return false;
    }

    final strength = _authRepository.validatePassword(newPassword);
    if (strength == PasswordStrength.tooShort) {
      _setError('Password must be at least 6 characters');
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      await _authRepository.updatePassword(newPassword);
      _setSuccess('Password updated successfully!');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // PROFILE MANAGEMENT
  // ============================================================

  /// Update display name
  Future<bool> updateDisplayName(String name) async {
    if (name.trim().isEmpty) {
      _setError('Name cannot be empty');
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      await _authRepository.updateDisplayName(name);

      // Update local user
      _currentUser = _currentUser?.copyWith(displayName: name);

      _setSuccess('Name updated!');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Update email
  Future<bool> updateEmail(String newEmail) async {
    if (!_authRepository.isValidEmail(newEmail)) {
      _setError('Invalid email address');
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      await _authRepository.updateEmail(newEmail);

      // Update local user
      _currentUser = _currentUser?.copyWith(email: newEmail);

      _setSuccess('Email updated! Please verify your new email.');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _clearMessages();

    try {
      await _authRepository.sendEmailVerification();
      _setSuccess('Verification email sent!');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // SIGN OUT & DELETION
  // ============================================================

  /// Sign out
  Future<bool> signOut() async {
    _setLoading(true);
    _clearMessages();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      _setSuccess('Signed out successfully');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearMessages();

    try {
      await _authRepository.deleteAccount();
      _currentUser = null;
      _setSuccess('Account deleted');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // PRO SUBSCRIPTION
  // ============================================================

  /// Upgrade to Pro
  Future<bool> upgradeToPro() async {
    _setLoading(true);
    _clearMessages();

    try {
      await _authRepository.upgradeToPro();

      // Update local user
      _currentUser = _currentUser?.copyWith(isPro: true);

      _setSuccess('Welcome to Pro! Enjoy unlimited poems!');
      _setLoading(false);
      return true;
    } on AuthRepositoryException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Restore Pro purchase
  Future<bool> restoreProPurchase() async {
    _setLoading(true);
    _clearMessages();

    try {
      final isPro = await _authRepository.restoreProPurchase();

      if (isPro) {
        _currentUser = _currentUser?.copyWith(isPro: true);
        _setSuccess('Pro subscription restored!');
      } else {
        _setError('No Pro subscription found');
      }

      _setLoading(false);
      return isPro;
    } catch (e) {
      _setError('Failed to restore purchase');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateSignInInputs(String email, String password) {
    if (email.trim().isEmpty) {
      _setError('Email cannot be empty');
      return false;
    }

    if (!_authRepository.isValidEmail(email)) {
      _setError('Invalid email address');
      return false;
    }

    if (password.isEmpty) {
      _setError('Password cannot be empty');
      return false;
    }

    return true;
  }

  bool _validateSignUpInputs(
      String email,
      String password,
      String confirmPassword,
      ) {
    if (email.trim().isEmpty) {
      _setError('Email cannot be empty');
      return false;
    }

    if (!_authRepository.isValidEmail(email)) {
      _setError('Invalid email address');
      return false;
    }

    if (password.isEmpty) {
      _setError('Password cannot be empty');
      return false;
    }

    if (password != confirmPassword) {
      _setError('Passwords do not match');
      return false;
    }

    final strength = _authRepository.validatePassword(password);
    if (strength == PasswordStrength.tooShort) {
      _setError('Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  /// Get password strength
  PasswordStrength getPasswordStrength(String password) {
    return _authRepository.validatePassword(password);
  }

  /// Get password strength message
  String getPasswordStrengthMessage(String password) {
    final strength = getPasswordStrength(password);
    return _authRepository.getPasswordStrengthMessage(strength);
  }

  // ============================================================
  // STATE MANAGEMENT HELPERS
  // ============================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _error = null;
    notifyListeners();
  }

  void _clearMessages() {
    _error = null;
    _successMessage = null;
  }

  /// Clear messages manually
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  // ============================================================
  // UTILITY
  // ============================================================

  /// Get auth provider name
  String getProviderName() {
    return _authRepository.getProviderName();
  }

  /// Get user tier description
  String getTierDescription() {
    if (isPro) return 'Pro';
    if (isGuest) return 'Guest';
    return 'Free';
  }
}