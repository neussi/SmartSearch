import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:smartsearch/models/search_result.dart';
import 'package:smartsearch/services/search_service.dart';

/// Provider pour la gestion de la recherche
class SearchProvider with ChangeNotifier {
  final SearchService _searchService;

  SearchResult? _lastSearchResult;
  bool _isLoading = false;
  String? _errorMessage;
  List<SearchResult> _searchHistory = [];

  SearchProvider({required SearchService searchService})
      : _searchService = searchService;

  // Getters
  SearchResult? get lastSearchResult => _lastSearchResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SearchResult> get searchHistory => _searchHistory;
  bool get hasResults => _lastSearchResult != null && _lastSearchResult!.products.isNotEmpty;

  /// Recherche par texte
  Future<void> searchByText({
    required String query,
    int? limit,
  }) async {
    if (query.trim().isEmpty) {
      _setError('Veuillez entrer une recherche');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _lastSearchResult = await _searchService.searchByText(
        query: query,
        limit: limit,
      );

      _addToHistory(_lastSearchResult!);
      notifyListeners();
    } catch (e) {
      _setError('Erreur de recherche: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Recherche par image
  Future<void> searchByImage({
    required File imageFile,
    int? limit,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _lastSearchResult = await _searchService.searchByImage(
        imageFile: imageFile,
        limit: limit,
      );

      _addToHistory(_lastSearchResult!);
      notifyListeners();
    } catch (e) {
      _setError('Erreur de recherche par image: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Recherche multimodale
  Future<void> searchMultimodal({
    required String textQuery,
    required File imageFile,
    double textWeight = 0.5,
    double imageWeight = 0.5,
    int? limit,
  }) async {
    if (textQuery.trim().isEmpty) {
      _setError('Veuillez entrer une recherche');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _lastSearchResult = await _searchService.searchMultimodal(
        textQuery: textQuery,
        imageFile: imageFile,
        textWeight: textWeight,
        imageWeight: imageWeight,
        limit: limit,
      );

      _addToHistory(_lastSearchResult!);
      notifyListeners();
    } catch (e) {
      _setError('Erreur de recherche multimodale: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Ajouter à l'historique de recherche
  void _addToHistory(SearchResult result) {
    _searchHistory.insert(0, result);

    // Limiter l'historique à 20 recherches
    if (_searchHistory.length > 20) {
      _searchHistory = _searchHistory.sublist(0, 20);
    }
  }

  /// Effacer l'historique de recherche
  void clearHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  /// Effacer les résultats actuels
  void clearResults() {
    _lastSearchResult = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
