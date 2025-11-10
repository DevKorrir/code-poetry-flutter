import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service
/// Handles sensitive credentials like OAuth tokens using platform-specific secure storage
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences (Keystore)
class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // FlutterSecureStorage instance with platform-specific options
  late final FlutterSecureStorage _secureStorage;

  bool _isInitialized = false;

  /// Initialize secure storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configure platform-specific options
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
    );

    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    );

    _secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );

    _isInitialized = true;
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  // ============================================================
  // WRITE OPERATIONS
  // ============================================================

  /// Save a secure value
  Future<void> write({
    required String key,
    required String value,
  }) async {
    if (!_isInitialized) {
      throw SecureStorageException('SecureStorageService not initialized');
    }

    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException('Failed to write secure value: ${e.toString()}');
    }
  }

  // ============================================================
  // READ OPERATIONS
  // ============================================================

  /// Read a secure value
  Future<String?> read({required String key}) async {
    if (!_isInitialized) {
      throw SecureStorageException('SecureStorageService not initialized');
    }

    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to read secure value: ${e.toString()}');
    }
  }

  /// Check if a key exists
  Future<bool> containsKey({required String key}) async {
    if (!_isInitialized) {
      throw SecureStorageException('SecureStorageService not initialized');
    }

    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      throw SecureStorageException('Failed to check key: ${e.toString()}');
    }
  }

  // ============================================================
  // DELETE OPERATIONS
  // ============================================================

  /// Delete a secure value
  Future<void> delete({required String key}) async {
    if (!_isInitialized) {
      throw SecureStorageException('SecureStorageService not initialized');
    }

    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to delete secure value: ${e.toString()}');
    }
  }

  /// Delete all secure values
  Future<void> deleteAll() async {
    if (!_isInitialized) {
      throw SecureStorageException('SecureStorageService not initialized');
    }

    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to delete all secure values: ${e.toString()}');
    }
  }

  // ============================================================
  // UTILITY
  // ============================================================

  /// Get all keys
  Future<List<String>> getAllKeys() async {
    if (!_isInitialized) {
      throw SecureStorageException('SecureStorageService not initialized');
    }

    try {
      final all = await _secureStorage.readAll();
      return all.keys.toList();
    } catch (e) {
      throw SecureStorageException('Failed to get all keys: ${e.toString()}');
    }
  }
}

/// Secure Storage Exception
class SecureStorageException implements Exception {
  final String message;
  SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}

/// Secure Storage Keys
/// Centralized key constants for secure storage
class SecureStorageKeys {
  // OAuth Tokens
  static const String githubToken = 'github_oauth_token';
  static const String googleToken = 'google_oauth_token';
  
  // API Keys (if needed)
  static const String openaiApiKey = 'openai_api_key';
  
  // Add more secure keys as needed
}
