import 'package:flutter/foundation.dart';

import '../models/poem_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/constants/feature_limits.dart';

/// Poem Repository
/// Mediates between ViewModels and Services
/// Handles business logic for poem operations
class PoemRepository {
  final ApiService _apiService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;

  PoemRepository({
    required ApiService apiService,
    required StorageService storageService,
    required ConnectivityService connectivityService,
  })  : _apiService = apiService,
        _storageService = storageService,
        _connectivityService = connectivityService;

  // ============================================================
  // POEM GENERATION
  // ============================================================

  /// Generate a new poem from code
  ///
  /// Throws [PoemException] if generation fails
  Future<PoemModel> generatePoem({
    required String code,
    required String language,
    required String style,
  }) async {
    try {
      // Check internet connection
      if (!_connectivityService.isConnected) {
        throw PoemException('No internet connection. Please check your network.');
      }

      // Validate inputs
      _validatePoemInput(code, language, style);

      // Generate poem using API
      final poemText = await _apiService.generatePoem(
        code: code,
        language: language,
        style: style,
      );

      // Create poem model
      final poem = PoemModel(
        code: code,
        language: language,
        style: style,
        poem: poemText,
      );

      // Save to local storage
      await _storageService.savePoem(poem);

      // Also save to cloud for logged-in users (fire and forget)
      _syncPoemToCloud(poem);

      return poem;
    } on ApiException catch (e) {
      throw PoemException('Failed to generate poem: ${e.message}');
    } on StorageException catch (e) {
      throw PoemException('Failed to save poem: ${e.message}');
    } catch (e) {
      throw PoemException('Unexpected error: ${e.toString()}');
    }
  }

  /// Regenerate poem with same code but different style
  Future<PoemModel> regeneratePoem({
    required String code,
    required String language,
    required String newStyle,
  }) async {
    return generatePoem(
      code: code,
      language: language,
      style: newStyle,
    );
  }

  // ============================================================
  // POEM RETRIEVAL
  // ============================================================

  /// Get all poems from storage
  Future<List<PoemModel>> getAllPoems() async {
    try {
      return await _storageService.getAllPoems();
    } on StorageException catch (e) {
      throw PoemException('Failed to load poems: ${e.message}');
    }
  }

  /// Get poem by ID
  Future<PoemModel?> getPoemById(String id) async {
    try {
      return await _storageService.getPoemById(id);
    } on StorageException catch (e) {
      throw PoemException('Failed to load poem: ${e.message}');
    }
  }

  /// Get poems by style
  Future<List<PoemModel>> getPoemsByStyle(String style) async {
    try {
      return await _storageService.getPoemsByStyle(style);
    } on StorageException catch (e) {
      throw PoemException('Failed to load poems: ${e.message}');
    }
  }

  /// Get recent poems (limited)
  Future<List<PoemModel>> getRecentPoems({int limit = 10}) async {
    try {
      return await _storageService.getRecentPoems(limit: limit);
    } on StorageException catch (e) {
      throw PoemException('Failed to load poems: ${e.message}');
    }
  }

  // ============================================================
  // POEM MANAGEMENT
  // ============================================================

  /// Update poem (toggle favorite, etc.)
  Future<void> updatePoem(PoemModel poem) async {
    try {
      await _storageService.savePoem(poem);
      
      // Also update in cloud for logged-in users (fire and forget)
      _syncPoemToCloud(poem);
    } on StorageException catch (e) {
      throw PoemException('Failed to update poem: ${e.message}');
    }
  }

  /// Delete poem
  Future<void> deletePoem(String poemId) async {
    try {
      await _storageService.deletePoem(poemId);
      
      // Also delete from cloud for logged-in users (fire and forget)
      _syncPoemDeletionToCloud(poemId);
    } on StorageException catch (e) {
      throw PoemException('Failed to delete poem: ${e.message}');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(PoemModel poem) async {
    final updatedPoem = poem.copyWith(isFavorite: !poem.isFavorite);
    await updatePoem(updatedPoem);
  }

  /// Clear all poems
  Future<void> clearAllPoems() async {
    try {
      await _storageService.clearAllPoems();
    } on StorageException catch (e) {
      throw PoemException('Failed to clear poems: ${e.message}');
    }
  }

  // ============================================================
  // CLOUD SYNC (for logged-in users)
  // ============================================================

  /// Sync poems to cloud
  Future<void> syncToCloud(String userId) async {
    try {
      if (!_connectivityService.isConnected) {
        throw PoemException('No internet connection');
      }

      await _storageService.syncPoemsToCloud(userId);
    } on StorageException catch (e) {
      throw PoemException('Sync failed: ${e.message}');
    }
  }

  /// Sync poems from cloud
  Future<void> syncFromCloud(String userId) async {
    try {
      if (!_connectivityService.isConnected) {
        throw PoemException('No internet connection');
      }

      await _storageService.syncPoemsFromCloud(userId);
    } on StorageException catch (e) {
      throw PoemException('Sync failed: ${e.message}');
    }
  }

  /// Save poem to cloud
  Future<void> savePoemToCloud(String userId, PoemModel poem) async {
    try {
      if (!_connectivityService.isConnected) {
        return; // Fail silently, will sync later
      }

      await _storageService.savePoemToCloud(userId, poem);
    } catch (e) {
      // Fail silently - poem is saved locally
    }
  }

  /// Delete poem from cloud
  Future<void> deletePoemFromCloud(String userId, String poemId) async {
    try {
      if (!_connectivityService.isConnected) {
        return; // Fail silently
      }

      await _storageService.deletePoemFromCloud(userId, poemId);
    } catch (e) {
      // Fail silently
    }
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Get total poem count
  Future<int> getPoemCount() async {
    try {
      return await _storageService.getPoemCount();
    } catch (e) {
      return 0;
    }
  }

  /// Get favorite style
  Future<String?> getFavoriteStyle() async {
    try {
      return await _storageService.getFavoriteStyle();
    } catch (e) {
      return null;
    }
  }

  /// Get poems created today
  Future<int> getPoemsCreatedToday() async {
    try {
      return await _storageService.getPoemsCreatedToday();
    } catch (e) {
      return 0;
    }
  }

  /// Get statistics summary
  Future<PoemStatistics> getStatistics() async {
    final total = await getPoemCount();
    final favoriteStyle = await getFavoriteStyle();
    final todayCount = await getPoemsCreatedToday();

    return PoemStatistics(
      totalPoems: total,
      favoriteStyle: favoriteStyle,
      poemsToday: todayCount,
    );
  }

  // ============================================================
  // RATE LIMITING (for free tier)
  // ============================================================

  /// Check if user can generate poem (rate limit check)
  Future<bool> canGeneratePoem({
    required bool isGuest,
    required bool isPro,
  }) async {
    if (isPro) return true; // Pro users have unlimited

    final todayCount = await getPoemsCreatedToday();

    // Both guests and free users have the same limit now
    return todayCount < FeatureLimits.freePoemsPerDay;
  }

  /// Get remaining poems for today
  Future<int> getRemainingPoems({
    required bool isGuest,
    required bool isPro,
  }) async {
    if (isPro) return 999; // Unlimited

    final todayCount = await getPoemsCreatedToday();
    final limit = FeatureLimits.freePoemsPerDay; // Same limit for guests and free users

    return (limit - todayCount).clamp(0, limit);
  }

  // ============================================================
  // BACKUP/RESTORE
  // ============================================================

  /// Export all poems as JSON
  Future<String> exportPoems() async {
    try {
      return await _storageService.exportPoemsAsJson();
    } on StorageException catch (e) {
      throw PoemException('Export failed: ${e.message}');
    }
  }

  /// Import poems from JSON
  Future<void> importPoems(String jsonString) async {
    try {
      await _storageService.importPoemsFromJson(jsonString);
    } on StorageException catch (e) {
      throw PoemException('Import failed: ${e.message}');
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  void _validatePoemInput(String code, String language, String style) {
    if (code.trim().isEmpty) {
      throw PoemException('Code cannot be empty');
    }

    if (code.length > 10000) {
      throw PoemException('Code is too long (max 10,000 characters)');
    }

    if (language.trim().isEmpty) {
      throw PoemException('Language must be specified');
    }

    if (style.trim().isEmpty) {
      throw PoemException('Style must be specified');
    }

    final validStyles = ['haiku', 'sonnet', 'free verse', 'cyberpunk'];
    if (!validStyles.contains(style.toLowerCase())) {
      throw PoemException('Invalid poetry style');
    }
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  /// Check if cloud sync should occur for the current user
  /// Returns the userId if sync should occur, null otherwise
  String? _getUserIdForCloudSync() {
    try {
      final userId = _storageService.getString(StorageKeys.userId);
      final isGuest = _storageService.getBool(StorageKeys.isGuest) ?? true;
      
      if (userId != null && userId.isNotEmpty && !isGuest) {
        return userId;
      }
    } catch (e) {
      debugPrint('Error checking cloud sync eligibility: $e');
    }
    return null;
  }

  /// Sync poem to cloud (fire and forget - don't block on failure)
  void _syncPoemToCloud(PoemModel poem) async {
    try {
      final userId = _getUserIdForCloudSync();
      if (userId != null) {
        await _storageService.savePoemToCloud(userId, poem);
      }
    } catch (e) {
      // Fail silently - poem is already saved locally
      debugPrint('Cloud sync failed for poem ${poem.id}: $e');
    }
  }

  /// Sync poem deletion to cloud (fire and forget)
  void _syncPoemDeletionToCloud(String poemId) async {
    try {
      final userId = _getUserIdForCloudSync();
      if (userId != null) {
        await _storageService.deletePoemFromCloud(userId, poemId);
      }
    } catch (e) {
      // Fail silently - poem is already deleted locally
      debugPrint('Cloud deletion sync failed for poem $poemId: $e');
    }
  }
}

/// Custom exception for poem operations
class PoemException implements Exception {
  final String message;
  PoemException(this.message);

  @override
  String toString() => 'PoemException: $message';
}

/// Statistics model
class PoemStatistics {
  final int totalPoems;
  final String? favoriteStyle;
  final int poemsToday;

  PoemStatistics({
    required this.totalPoems,
    this.favoriteStyle,
    required this.poemsToday,
  });
}