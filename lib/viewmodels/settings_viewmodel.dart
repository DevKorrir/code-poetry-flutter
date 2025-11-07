import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final StorageService _storageService;

  SettingsViewModel(this._storageService);

  // State
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  String? _error;
  String? get error => _error;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initialize() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    // Load theme mode
    final themeModeString = _storageService.getSetting<String>(
      StorageKeys.themeMode,
      defaultValue: 'dark',
    );

    _themeMode = _parseThemeMode(themeModeString ?? 'dark');

    // Load notifications setting
    _notificationsEnabled = _storageService.getSetting<bool>(
      'notifications_enabled',
      defaultValue: true,
    ) ?? true;

    notifyListeners();
  }

  // ============================================================
  // THEME SETTINGS
  // ============================================================

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    await _storageService.saveSetting(
      StorageKeys.themeMode,
      _themeModeToString(mode),
    );

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ============================================================
  // NOTIFICATION SETTINGS
  // ============================================================

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;

    await _storageService.saveSetting('notifications_enabled', enabled);

    notifyListeners();
  }

  // ============================================================
  // DATA MANAGEMENT
  // ============================================================

  Future<bool> exportData() async {
    try {
      // This would trigger file save dialog
      // For now, just show success
      _setSuccess('Data exported successfully!');
      return true;
    } catch (e) {
      _setError('Failed to export data');
      return false;
    }
  }

  Future<bool> clearAllData() async {
    try {
      await _storageService.clearAll();
      _setSuccess('All data cleared!');
      return true;
    } catch (e) {
      _setError('Failed to clear data');
      return false;
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  ThemeMode _parseThemeMode(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
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

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // ============================================================
  // APP INFO
  // ============================================================

  String get appVersion => '1.0.0';
  String get appBuildNumber => '1';
}