import 'package:flutter/foundation.dart';
import '../models/poem_model.dart';
import '../repositories/poem_repository.dart';

enum SortOption {
  newestFirst,
  oldestFirst,
  favoritesFirst,
  byStyle,
}

class GalleryViewModel extends ChangeNotifier {
  final PoemRepository _poemRepository;

  GalleryViewModel(this._poemRepository);

  // State
  List<PoemModel> _poems = [];
  List<PoemModel> get poems => _poems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _selectedStyleFilter;
  String? get selectedStyleFilter => _selectedStyleFilter;

  SortOption _sortOption = SortOption.newestFirst;
  SortOption get sortOption => _sortOption;

  // ============================================================
  // LOAD POEMS
  // ============================================================

  Future<void> loadPoems() async {
    _setLoading(true);
    _clearError();

    try {
      _poems = await _poemRepository.getAllPoems();
      _applyFilter();
      _setLoading(false);
    } on PoemException catch (e) {
      _setError(e.message);
      _setLoading(false);
    }
  }

  Future<void> refreshPoems() async {
    await loadPoems();
  }

  // ============================================================
  // SORTING
  // ============================================================

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  // ============================================================
  // FILTERING
  // ============================================================

  void filterByStyle(String? style) {
    _selectedStyleFilter = style;
    _applyFilter();
  }

  void clearFilter() {
    _selectedStyleFilter = null;
    _applyFilter();
  }

  void _applyFilter() {
    if (_selectedStyleFilter == null) {
      notifyListeners();
      return;
    }

    // Filter is applied in getter
    notifyListeners();
  }

  List<PoemModel> get filteredPoems {
    // First apply style filter
    List<PoemModel> result = _selectedStyleFilter == null
        ? List.from(_poems)
        : _poems.where((poem) => poem.style == _selectedStyleFilter).toList();

    // Then apply sorting
    switch (_sortOption) {
      case SortOption.newestFirst:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldestFirst:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.favoritesFirst:
        result.sort((a, b) {
          if (a.isFavorite == b.isFavorite) {
            return b.createdAt.compareTo(a.createdAt); // Secondary sort by date
          }
          return a.isFavorite ? -1 : 1; // Favorites first
        });
        break;
      case SortOption.byStyle:
        result.sort((a, b) {
          final styleCompare = a.style.compareTo(b.style);
          if (styleCompare != 0) return styleCompare;
          return b.createdAt.compareTo(a.createdAt); // Secondary sort by date
        });
        break;
    }

    return result;
  }

  // ============================================================
  // POEM ACTIONS
  // ============================================================

  Future<bool> deletePoem(String poemId) async {
    try {
      await _poemRepository.deletePoem(poemId);
      _poems.removeWhere((poem) => poem.id == poemId);
      notifyListeners();
      return true;
    } on PoemException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  Future<void> toggleFavorite(PoemModel poem) async {
    try {
      await _poemRepository.toggleFavorite(poem);

      // Update local list
      final index = _poems.indexWhere((p) => p.id == poem.id);
      if (index != -1) {
        _poems[index] = poem.copyWith(isFavorite: !poem.isFavorite);
        notifyListeners();
      }
    } on PoemException catch (e) {
      _setError(e.message);
    }
  }

  // ============================================================
  // GETTERS
  // ============================================================

  bool get hasPoems => _poems.isNotEmpty;

  bool get hasFavorites => _poems.any((poem) => poem.isFavorite);

  int get totalPoems => _poems.length;

  List<PoemModel> get favoritePoems =>
      _poems.where((poem) => poem.isFavorite).toList();

  List<String> get availableStyles {
    final styles = _poems.map((poem) => poem.style).toSet().toList();
    styles.sort();
    return styles;
  }

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