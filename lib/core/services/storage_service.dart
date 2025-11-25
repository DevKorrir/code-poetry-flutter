import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/poem_model.dart';

/// Storage Service
/// Handles both local storage (Hive) and cloud storage (Firestore)
/// Local storage for offline access, Firestore for sync across devices
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Hive boxes
  static const String _poemsBoxName = 'poems';
  static const String _settingsBoxName = 'settings';

  late Box<dynamic> _poemsBox;
  late Box<dynamic> _settingsBox;
  late SharedPreferences _prefs;

  // Firestore instance (optional - only for logged-in users)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;

  /// Initialize storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Open boxes
      _poemsBox = await Hive.openBox(_poemsBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      _isInitialized = true;
    } catch (e) {
      throw StorageException('Failed to initialize storage: ${e.toString()}');
    }
  }

  // ============================================================
  // POEM STORAGE (Local)
  // ============================================================

  /// Save poem locally
  Future<void> savePoem(PoemModel poem) async {
    _ensureInitialized();
    try {
      await _poemsBox.put(poem.id, poem.toJson());
    } catch (e) {
      throw StorageException('Failed to save poem: ${e.toString()}');
    }
  }

  /// Get all poems from local storage
  Future<List<PoemModel>> getAllPoems() async {
    _ensureInitialized();
    try {
      final poems = <PoemModel>[];
      for (var key in _poemsBox.keys) {
        final data = _poemsBox.get(key) as Map<dynamic, dynamic>;
        final poemMap = Map<String, dynamic>.from(data);
        poems.add(PoemModel.fromJson(poemMap));
      }

      // Sort by creation date (newest first)
      poems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return poems;
    } catch (e) {
      throw StorageException('Failed to get poems: ${e.toString()}');
    }
  }

  /// Get poem by ID
  Future<PoemModel?> getPoemById(String id) async {
    _ensureInitialized();
    try {
      final data = _poemsBox.get(id);
      if (data == null) return null;

      final poemMap = Map<String, dynamic>.from(data as Map<dynamic, dynamic>);
      return PoemModel.fromJson(poemMap);
    } catch (e) {
      throw StorageException('Failed to get poem: ${e.toString()}');
    }
  }

  /// Delete poem by ID
  Future<void> deletePoem(String id) async {
    _ensureInitialized();
    try {
      await _poemsBox.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete poem: ${e.toString()}');
    }
  }

  /// Get poems by style
  Future<List<PoemModel>> getPoemsByStyle(String style) async {
    final allPoems = await getAllPoems();
    return allPoems.where((poem) => poem.style == style).toList();
  }

  /// Get recent poems (limit)
  Future<List<PoemModel>> getRecentPoems({int limit = 10}) async {
    final allPoems = await getAllPoems();
    return allPoems.take(limit).toList();
  }

  /// Clear all poems
  Future<void> clearAllPoems() async {
    _ensureInitialized();
    try {
      await _poemsBox.clear();
    } catch (e) {
      throw StorageException('Failed to clear poems: ${e.toString()}');
    }
  }

  /// Get total poem count
  Future<int> getPoemCount() async {
    _ensureInitialized();
    return _poemsBox.length;
  }

  // ============================================================
  // CLOUD STORAGE (Firestore - for logged-in users)
  // ============================================================

  /// Sync local poems to Firestore
  Future<void> syncPoemsToCloud(String userId) async {
    _ensureInitialized();
    try {
      final poems = await getAllPoems();
      final batch = _firestore.batch();

      for (var poem in poems) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('poems')
            .doc(poem.id);

        batch.set(docRef, poem.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw StorageException('Failed to sync to cloud: ${e.toString()}');
    }
  }

  /// Download poems from Firestore
  Future<void> syncPoemsFromCloud(String userId) async {
    _ensureInitialized();
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('poems')
          .get();

      for (var doc in snapshot.docs) {
        final poem = PoemModel.fromJson(doc.data());
        await savePoem(poem);
      }

      // Record the sync time
      await saveString(StorageKeys.lastSyncTime, DateTime.now().toIso8601String());
    } catch (e) {
      throw StorageException('Failed to sync from cloud: ${e.toString()}');
    }
  }

  /// Save poem to cloud only
  Future<void> savePoemToCloud(String userId, PoemModel poem) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('poems')
          .doc(poem.id)
          .set(poem.toJson());
    } catch (e) {
      throw StorageException('Failed to save to cloud: ${e.toString()}');
    }
  }

  /// Delete poem from cloud
  Future<void> deletePoemFromCloud(String userId, String poemId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('poems')
          .doc(poemId)
          .delete();
    } catch (e) {
      throw StorageException('Failed to delete from cloud: ${e.toString()}');
    }
  }

  /// Stream poems from Firestore (real-time updates)
  Stream<List<PoemModel>> streamPoemsFromCloud(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('poems')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PoemModel.fromJson(doc.data()))
          .toList();
    });
  }

  // ============================================================
  // SETTINGS STORAGE
  // ============================================================

  /// Save setting
  Future<void> saveSetting(String key, dynamic value) async {
    _ensureInitialized();
    try {
      await _settingsBox.put(key, value);
    } catch (e) {
      throw StorageException('Failed to save setting: ${e.toString()}');
    }
  }

  /// Get setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    _ensureInitialized();
    try {
      return _settingsBox.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Delete setting
  Future<void> deleteSetting(String key) async {
    _ensureInitialized();
    try {
      await _settingsBox.delete(key);
    } catch (e) {
      throw StorageException('Failed to delete setting: ${e.toString()}');
    }
  }

  // ============================================================
  // SHARED PREFERENCES (Simple key-value storage)
  // ============================================================

  /// Save string
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get string
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save int
  Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Get int
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Save bool
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get bool
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Remove key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all preferences
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // ============================================================
  // USER STATS
  // ============================================================

  /// Get total poems created
  Future<int> getTotalPoemsCreated() async {
    return await getPoemCount();
  }

  /// Get favorite style (most used)
  Future<String?> getFavoriteStyle() async {
    final poems = await getAllPoems();
    if (poems.isEmpty) return null;

    // Count styles
    final styleCounts = <String, int>{};
    for (var poem in poems) {
      styleCounts[poem.style] = (styleCounts[poem.style] ?? 0) + 1;
    }

    // Find most common
    String? favoriteStyle;
    int maxCount = 0;
    styleCounts.forEach((style, count) {
      if (count > maxCount) {
        maxCount = count;
        favoriteStyle = style;
      }
    });

    return favoriteStyle;
  }

  /// Get poems created today
  Future<int> getPoemsCreatedToday() async {
    final poems = await getAllPoems();
    final today = DateTime.now();

    return poems.where((poem) {
      final createdDate = poem.createdAt;
      return createdDate.year == today.year &&
          createdDate.month == today.month &&
          createdDate.day == today.day;
    }).length;
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Check if storage is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StorageException('Storage not initialized. Call initialize() first.');
    }
  }

  /// Export all poems as JSON (for backup)
  Future<String> exportPoemsAsJson() async {
    final poems = await getAllPoems();
    final jsonList = poems.map((poem) => poem.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// Import poems from JSON (for restore)
  Future<void> importPoemsFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      for (var json in jsonList) {
        final poem = PoemModel.fromJson(json as Map<String, dynamic>);
        await savePoem(poem);
      }
    } catch (e) {
      throw StorageException('Failed to import poems: ${e.toString()}');
    }
  }

  /// Get storage size (in bytes)
  Future<int> getStorageSize() async {
    _ensureInitialized();
    // Approximate size calculation
    int size = 0;
    for (var key in _poemsBox.keys) {
      final data = _poemsBox.get(key);
      size += jsonEncode(data).length;
    }
    return size;
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _poemsBox.close();
      await _settingsBox.close();
    }
  }
}

/// Custom exception for storage errors
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

/// Storage Keys Constants
class StorageKeys {
  StorageKeys._();

  // Settings
  static const String themeMode = 'theme_mode';
  static const String isOnboardingComplete = 'onboarding_complete';
  static const String lastSyncTime = 'last_sync_time';
  static const String isPro = 'is_pro';

  // User data
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isGuest = 'is_guest';

  // Stats
  static const String totalPoemsGenerated = 'total_poems_generated';
  static const String poemsGeneratedToday = 'poems_generated_today';
  static const String lastPoemDate = 'last_poem_date';
}