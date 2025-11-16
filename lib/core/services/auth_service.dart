import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
import 'secure_storage_service.dart';

/// Authentication Service
/// Handles all Firebase Authentication operations
/// Supports: Email/Password, Google Sign-In, GitHub, Guest Mode
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Modern, Corrected Initialization
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Secure storage for sensitive credentials
  final SecureStorageService _secureStorage = SecureStorageService();

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Check if user is guest
  bool get isGuest => currentUser?.isAnonymous ?? true;

  // ============================================================
  // GITHUB TOKEN MANAGEMENT
  // ============================================================

  /// Store GitHub token securely
  Future<void> storeGitHubToken(String token) async {
    await _secureStorage.write(
      key: SecureStorageKeys.githubToken,
      value: token,
    );
  }

  /// Get stored GitHub token
  Future<String?> getGitHubToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.githubToken);
  }

  /// Clear GitHub token
  Future<void> clearGitHubToken() async {
    await _secureStorage.delete(key: SecureStorageKeys.githubToken);
  }

  // ============================================================
  // EMAIL/PASSWORD AUTHENTICATION
  // ============================================================

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      // Validate inputs
      _validateEmail(email);
      _validatePassword(password);

      // Create user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Failed to create user');
      }

      // Update display name if provided
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload();
      }

      return UserModel.fromFirebaseUser(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      _validateEmail(email);
      if (password.isEmpty) {
        throw AuthException('Password cannot be empty');
      }

      // Sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Sign in failed');
      }

      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  // ============================================================
  // GOOGLE SIGN-IN
  // ============================================================

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        throw AuthException('Google sign in cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create credential using ID Token ONLY
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Google sign in failed');
      }

      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  // ============================================================
  // GITHUB SIGN-IN (FIXED VERSION)
  // ============================================================

  /// Sign in with GitHub (Firebase OAuth) - FIXED VERSION
  Future<UserModel> signInWithGitHub() async {
    try {
      // Create GitHub provider
      final githubProvider = GithubAuthProvider();

      // Add scopes for repository access
      githubProvider.addScope('repo');
      githubProvider.addScope('read:user');
      githubProvider.addScope('user:email');

      // Set custom parameters to help with sessionStorage issues
      githubProvider.setCustomParameters({
        'allow_signup': 'true',
        'prompt': 'consent', // Force consent screen to help with state issues
      });

      final UserCredential userCredential;

      if (kIsWeb) {
        // Web: Use popup to avoid sessionStorage issues
        userCredential = await _auth.signInWithPopup(githubProvider);
      } else {
        // Mobile: Use signInWithProvider with retry logic
        try {
          userCredential = await _auth.signInWithProvider(githubProvider);
        } catch (e) {
          // Check if it's a sessionStorage error
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('sessionstorage') ||
              errorString.contains('missing initial state') ||
              errorString.contains('storage-partitioned')) {

            // RETRY WITH DIFFERENT APPROACH
            return await _signInWithGitHubFallback();
          }
          rethrow;
        }
      }

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('GitHub sign in failed - no user returned');
      }

      // Get GitHub access token from credential
      final credential = userCredential.credential;
      if (credential is OAuthCredential) {
        final accessToken = credential.accessToken;

        // Store token securely for GitHub API access
        if (accessToken != null && accessToken.isNotEmpty) {
          await storeGitHubToken(accessToken);
        }
      }

      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      // Handle specific GitHub OAuth errors
      if (e.code == 'account-exists-with-different-credential') {
        throw AuthException(
            'An account already exists with the same email but different sign-in method. '
                'Please sign in using that method and link your GitHub account.'
        );
      } else if (e.code == 'invalid-credential' || e.code == 'invalid-verification-code') {
        throw AuthException('GitHub authentication failed. Please try again.');
      }

      // Check for sessionStorage-related errors
      if (e.message?.toLowerCase().contains('sessionstorage') == true ||
          e.message?.toLowerCase().contains('missing initial state') == true) {
        // Try fallback method
        return await _signInWithGitHubFallback();
      }

      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      // Handle general errors
      if (e is AuthException) rethrow;

      final errorString = e.toString().toLowerCase();

      // Check for cancellation
      if (errorString.contains('canceled') || errorString.contains('cancelled')) {
        throw AuthException('GitHub sign in was cancelled');
      }

      // Check for sessionStorage errors
      if (errorString.contains('sessionstorage') ||
          errorString.contains('missing initial state') ||
          errorString.contains('storage-partitioned')) {
        // Try fallback method
        return await _signInWithGitHubFallback();
      }

      throw AuthException('GitHub sign in failed: ${e.toString()}');
    }
  }

  /// Fallback method for GitHub sign-in when sessionStorage fails
  Future<UserModel> _signInWithGitHubFallback() async {
    try {
      // Alternative approach: Use deep link flow
      final githubProvider = GithubAuthProvider();
      githubProvider.addScope('repo');
      githubProvider.addScope('read:user');
      githubProvider.addScope('user:email');

      // Set different parameters for fallback
      githubProvider.setCustomParameters({
        'allow_signup': 'true',
        'prompt': 'login', // Force fresh login
      });

      // Use a different approach - sign in with redirect then get result
      if (kIsWeb) {
        await _auth.signInWithRedirect(githubProvider);
        // On web, this will redirect away from the app
        throw AuthException('Redirect completed - please check the browser');
      } else {
        // On mobile, try one more time with the regular approach
        // Sometimes it works on second attempt
        final userCredential = await _auth.signInWithProvider(githubProvider);
        final user = userCredential.user;

        if (user == null) {
          throw AuthException('GitHub sign in failed after retry');
        }

        // Store token if available
        final credential = userCredential.credential;
        if (credential is OAuthCredential) {
          final accessToken = credential.accessToken;
          if (accessToken != null && accessToken.isNotEmpty) {
            await storeGitHubToken(accessToken);
          }
        }

        return UserModel.fromFirebaseUser(user);
      }
    } catch (e) {
      throw AuthException(
          'GitHub authentication requires browser storage access. '
              'Please try:\n\n'
              '1. Update your browser to the latest version\n'
              '2. Clear browser cache and cookies\n'
              '3. Try using Email/Password or Google sign-in instead\n'
              '4. Try again in a few minutes'
      );
    }
  }

  /// Check for pending redirect result (primarily for web)
  Future<UserModel?> getRedirectResult() async {
    try {
      // Only check redirect result on web
      if (!kIsWeb) {
        return null;
      }

      final userCredential = await _auth.getRedirectResult();

      if (userCredential.user == null) {
        return null;
      }

      // Get GitHub access token if available
      final credential = userCredential.credential;
      if (credential is OAuthCredential) {
        final accessToken = credential.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          await storeGitHubToken(accessToken);
        }
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      // Silently fail - this might not be a GitHub redirect
      return null;
    }
  }

  // ============================================================
  // GUEST MODE (Anonymous Authentication)
  // ============================================================

  /// Sign in as guest (anonymous)
  Future<UserModel> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Guest sign in failed');
      }

      return UserModel.fromFirebaseUser(user, isGuest: true);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Guest sign in failed: ${e.toString()}');
    }
  }

  /// Convert guest account to permanent account
  Future<UserModel> convertGuestToUser({
    required String email,
    required String password,
  }) async {
    try {
      if (!isGuest) {
        throw AuthException('Current user is not a guest');
      }

      _validateEmail(email);
      _validatePassword(password);

      // Create credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Link credential to current anonymous user
      final userCredential = await currentUser!.linkWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Failed to convert guest account');
      }

      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Account conversion failed: ${e.toString()}');
    }
  }

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _validateEmail(email);
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Failed to send reset email: ${e.toString()}');
    }
  }

  /// Update password (for logged-in user)
  Future<void> updatePassword(String newPassword) async {
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      _validatePassword(newPassword);
      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Failed to update password: ${e.toString()}');
    }
  }

  // ============================================================
  // USER PROFILE
  // ============================================================

  /// Update display name
  Future<void> updateDisplayName(String name) async {
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      await currentUser!.updateDisplayName(name);
      await currentUser!.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Failed to update name: ${e.toString()}');
    }
  }

  /// Update email
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('No user signed in');
    }

    _validateEmail(newEmail);

    try {
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException('requires-recent-login');
      }
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Failed to update email: ${e.toString()}');
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      if (currentUser!.emailVerified) {
        throw AuthException('Email already verified');
      }

      await currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Failed to send verification: ${e.toString()}');
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    if (currentUser == null) return false;
    await currentUser!.reload();
    return currentUser!.emailVerified;
  }

  // ============================================================
  // SIGN OUT & ACCOUNT DELETION
  // ============================================================

  /// Sign out current user
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear GitHub token
      await clearGitHubToken();

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      // Clear GitHub token before deleting account
      await clearGitHubToken();
      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }

  // ============================================================
  // REAUTHENTICATION
  // ============================================================

  /// Reauthenticate with email/password
  Future<void> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Reauthentication failed: ${e.toString()}');
    }
  }

  /// Reauthenticate with Google
  Future<void> reauthenticateWithGoogle() async {
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        throw AuthException('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Reauthentication failed: ${e.toString()}');
    }
  }

  // ============================================================
  // VALIDATION HELPERS
  // ============================================================

  void _validateEmail(String email) {
    if (email.isEmpty) {
      throw AuthException('Email cannot be empty');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      throw AuthException('Invalid email address');
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw AuthException('Password cannot be empty');
    }

    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }
  }

  // ============================================================
  // ERROR MESSAGE MAPPER
  // ============================================================

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your internet connection';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email';
      case 'invalid-credential':
        return 'Invalid authentication credentials';
      default:
        return 'Authentication error: $code';
    }
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Get current user as UserModel
  UserModel? getCurrentUserModel() {
    if (currentUser == null) return null;
    return UserModel.fromFirebaseUser(
      currentUser!,
      isGuest: currentUser!.isAnonymous,
    );
  }

  /// Check if user has password provider
  bool hasPasswordProvider() {
    if (currentUser == null) return false;
    return currentUser!.providerData
        .any((info) => info.providerId == 'password');
  }

  /// Check if user has Google provider
  bool hasGoogleProvider() {
    if (currentUser == null) return false;
    return currentUser!.providerData
        .any((info) => info.providerId == 'google.com');
  }

  /// Check if user has GitHub provider
  bool hasGitHubProvider() {
    if (currentUser == null) return false;
    return currentUser!.providerData
        .any((info) => info.providerId == 'github.com');
  }

  /// Get provider name
  String getProviderName() {
    if (currentUser == null) return 'None';
    if (currentUser!.isAnonymous) return 'Guest';

    final providers = currentUser!.providerData;
    if (providers.isEmpty) return 'Unknown';

    final providerId = providers.first.providerId;
    switch (providerId) {
      case 'password':
        return 'Email';
      case 'google.com':
        return 'Google';
      case 'github.com':
        return 'GitHub';
      default:
        return providerId;
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}