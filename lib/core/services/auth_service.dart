import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';

/// Authentication Service
/// Handles all Firebase Authentication operations
/// Supports: Email/Password, Google Sign-In, Guest Mode
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Check if user is guest
  bool get isGuest => currentUser?.isAnonymous ?? true;

  // ============================================================
  // EMAIL/PASSWORD AUTHENTICATION
  // ============================================================

  /// Sign up with email and password
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (min 6 characters)
  /// - [name]: User's display name (optional)
  ///
  /// Returns: [UserModel] on success
  /// Throws: [AuthException] on failure
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
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns: [UserModel] on success
  /// Throws: [AuthException] on failure
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
  ///
  /// Returns: [UserModel] on success
  /// Throws: [AuthException] on failure
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google sign in cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
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
  // GUEST MODE (Anonymous Authentication)
  // ============================================================

  /// Sign in as guest (anonymous)
  ///
  /// Returns: [UserModel] on success
  /// Throws: [AuthException] on failure
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
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns: [UserModel] on success
  /// Throws: [AuthException] on failure
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
      final userCredential =
      await currentUser!.linkWithCredential(credential);

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
  ///
  /// Parameters:
  /// - [email]: User's email address
  ///
  /// Throws: [AuthException] on failure
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
  ///
  /// Parameters:
  /// - [newPassword]: New password (min 6 characters)
  ///
  /// Throws: [AuthException] on failure
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
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      _validateEmail(newEmail);
      await currentUser!.updateEmail(newEmail);
      await currentUser!.reload();
    } on FirebaseAuthException catch (e) {
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
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

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

      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }

  // ============================================================
  // REAUTHENTICATION (Required for sensitive operations)
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

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
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