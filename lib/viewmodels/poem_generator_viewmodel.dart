import 'package:flutter/foundation.dart';
import '../models/poem_model.dart';
import '../repositories/poem_repository.dart';

/// Poem Generator ViewModel
/// Manages state for poem generation flow
class PoemGeneratorViewModel extends ChangeNotifier {
  final PoemRepository _poemRepository;

  PoemGeneratorViewModel(this._poemRepository);

  // ============================================================
  // STATE
  // ============================================================

  // Current code input
  String _code = '';
  String get code => _code;

  // Selected language
  String _language = 'python';
  String get language => _language;

  // Selected poetry style
  String _style = 'haiku';
  String get style => _style;

  // Generated poem
  PoemModel? _generatedPoem;
  PoemModel? get generatedPoem => _generatedPoem;

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
  // INPUT METHODS
  // ============================================================

  /// Update code input
  void updateCode(String newCode) {
    _code = newCode;
    _clearError();
    notifyListeners();
  }

  /// Update selected language
  void updateLanguage(String newLanguage) {
    _language = newLanguage;
    notifyListeners();
  }

  /// Update selected style
  void updateStyle(String newStyle) {
    _style = newStyle;
    notifyListeners();
  }

  /// Clear all inputs
  void clearInputs() {
    _code = '';
    _language = 'python';
    _style = 'haiku';
    _generatedPoem = null;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // ============================================================
  // POEM GENERATION
  // ============================================================

  /// Generate poem from current inputs
  Future<bool> generatePoem({
    required bool isGuest,
    required bool isPro,
  }) async {
    // Validate inputs
    if (!_validateInputs()) {
      return false;
    }

    // Check rate limits
    final canGenerate = await _poemRepository.canGeneratePoem(
      isGuest: isGuest,
      isPro: isPro,
    );

    if (!canGenerate) {
      final remaining = await _poemRepository.getRemainingPoems(
        isGuest: isGuest,
        isPro: isPro,
      );
      _setError('Daily limit reached. You have $remaining poems remaining today.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final poem = await _poemRepository.generatePoem(
        code: _code,
        language: _language,
        style: _style,
      );

      _generatedPoem = poem;
      _setSuccess('Poem generated successfully!');
      _setLoading(false);
      return true;
    } on PoemException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to generate poem: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Regenerate poem with different style
  Future<bool> regenerateWithStyle(
      String newStyle, {
        required bool isGuest,
        required bool isPro,
      }) async {
    updateStyle(newStyle);
    return await generatePoem(isGuest: isGuest, isPro: isPro);
  }

  // ============================================================
  // POEM ACTIONS
  // ============================================================

  /// Save current poem to favorites
  Future<bool> savePoem() async {
    if (_generatedPoem == null) {
      _setError('No poem to save');
      return false;
    }

    try {
      await _poemRepository.updatePoem(_generatedPoem!);
      _setSuccess('Poem saved to gallery!');
      return true;
    } on PoemException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    if (_generatedPoem == null) return;

    try {
      await _poemRepository.toggleFavorite(_generatedPoem!);
      _generatedPoem = _generatedPoem!.copyWith(
        isFavorite: !_generatedPoem!.isFavorite,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to update favorite status');
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateInputs() {
    if (_code.trim().isEmpty) {
      _setError('Please enter some code');
      return false;
    }

    if (_code.length > 10000) {
      _setError('Code is too long (max 10,000 characters)');
      return false;
    }

    if (_language.trim().isEmpty) {
      _setError('Please select a language');
      return false;
    }

    if (_style.trim().isEmpty) {
      _setError('Please select a poetry style');
      return false;
    }

    return true;
  }

  /// Check if inputs are valid
  bool get isInputValid {
    return _code.trim().isNotEmpty &&
        _language.trim().isNotEmpty &&
        _style.trim().isNotEmpty &&
        _code.length <= 10000;
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Get remaining poems for today
  Future<int> getRemainingPoems({
    required bool isGuest,
    required bool isPro,
  }) async {
    return await _poemRepository.getRemainingPoems(
      isGuest: isGuest,
      isPro: isPro,
    );
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

  void _clearError() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _error = null;
    notifyListeners();
  }

  /// Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // ============================================================
  // GETTERS FOR UI
  // ============================================================

  /// Check if has generated poem
  bool get hasPoem => _generatedPoem != null;

  /// Get code line count
  int get codeLineCount => _code.split('\n').length;

  /// Get code character count
  int get codeCharCount => _code.length;

  /// Check if code is within limits
  bool get isCodeWithinLimit => _code.length <= 10000;
}