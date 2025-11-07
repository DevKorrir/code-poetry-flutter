import 'package:flutter/foundation.dart';
import '../models/poem_model.dart';
import '../repositories/poem_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final PoemRepository _poemRepository;

  HomeViewModel(this._poemRepository);

  // State
  List<PoemModel> _recentPoems = [];
  List<PoemModel> get recentPoems => _recentPoems;

  PoemStatistics? _statistics;
  PoemStatistics? get statistics => _statistics;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initialize() async {
    await loadDashboard();
  }

  Future<void> loadDashboard() async {
    _setLoading(true);
    _clearError();

    try {
      // Load recent poems
      _recentPoems = await _poemRepository.getRecentPoems(limit: 5);

      // Load statistics
      _statistics = await _poemRepository.getStatistics();

      _setLoading(false);
    } on PoemException catch (e) {
      _setError(e.message);
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Future<int> getRemainingPoems({
    required bool isGuest,
    required bool isPro,
  }) async {
    return await _poemRepository.getRemainingPoems(
      isGuest: isGuest,
      isPro: isPro,
    );
  }

  Future<bool> canGeneratePoem({
    required bool isGuest,
    required bool isPro,
  }) async {
    return await _poemRepository.canGeneratePoem(
      isGuest: isGuest,
      isPro: isPro,
    );
  }

  // ============================================================
  // GETTERS
  // ============================================================

  bool get hasRecentPoems => _recentPoems.isNotEmpty;

  int get totalPoems => _statistics?.totalPoems ?? 0;

  String? get favoriteStyle => _statistics?.favoriteStyle;

  int get poemsToday => _statistics?.poemsToday ?? 0;

  // ============================================================
  // STATE HELPERS
  // ============================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}