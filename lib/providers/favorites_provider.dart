import 'package:flutter/foundation.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/services/favorites_service.dart';
import 'package:smartsearch/services/product_service.dart';

/// Provider pour gérer les favoris
class FavoritesProvider with ChangeNotifier {
  final FavoritesService _favoritesService;
  final ProductService _productService;

  Set<String> _favoriteIds = {};
  List<Product> _favoriteProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  FavoritesProvider({
    required FavoritesService favoritesService,
    required ProductService productService,
  })  : _favoritesService = favoritesService,
        _productService = productService;

  // Getters
  Set<String> get favoriteIds => _favoriteIds;
  List<Product> get favoriteProducts => _favoriteProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get favoritesCount => _favoriteIds.length;

  /// Charger les favoris
  Future<void> loadFavorites() async {
    _setLoading(true);
    _clearError();

    try {
      _favoriteIds = await _favoritesService.getFavorites();
      await _loadFavoriteProducts();
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement des favoris: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les produits favoris
  Future<void> _loadFavoriteProducts() async {
    _favoriteProducts = [];
    for (var productId in _favoriteIds) {
      try {
        final product = await _productService.getProductById(productId);
        _favoriteProducts.add(product);
      } catch (e) {
        // Produit non trouvé, on le retire des favoris
        await _favoritesService.removeFromFavorites(productId);
        _favoriteIds.remove(productId);
      }
    }
  }

  /// Ajouter un produit aux favoris
  Future<void> addToFavorites(String productId) async {
    try {
      await _favoritesService.addToFavorites(productId);
      _favoriteIds.add(productId);
      
      // Charger le produit
      try {
        final product = await _productService.getProductById(productId);
        _favoriteProducts.add(product);
      } catch (e) {
        // Ignorer si le produit ne peut pas être chargé
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  /// Retirer un produit des favoris
  Future<void> removeFromFavorites(String productId) async {
    try {
      await _favoritesService.removeFromFavorites(productId);
      _favoriteIds.remove(productId);
      _favoriteProducts.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la suppression des favoris: $e');
    }
  }

  /// Basculer l'état favori d'un produit
  Future<bool> toggleFavorite(String productId) async {
    try {
      final isFavorite = await _favoritesService.toggleFavorite(productId);
      
      if (isFavorite) {
        _favoriteIds.add(productId);
        // Charger le produit
        try {
          final product = await _productService.getProductById(productId);
          _favoriteProducts.add(product);
        } catch (e) {
          // Ignorer si le produit ne peut pas être chargé
        }
      } else {
        _favoriteIds.remove(productId);
        _favoriteProducts.removeWhere((p) => p.id == productId);
      }
      
      notifyListeners();
      return isFavorite;
    } catch (e) {
      _setError('Erreur lors du basculement des favoris: $e');
      return false;
    }
  }

  /// Vérifier si un produit est favori
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  /// Effacer tous les favoris
  Future<void> clearFavorites() async {
    try {
      await _favoritesService.clearFavorites();
      _favoriteIds.clear();
      _favoriteProducts.clear();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de l\'effacement des favoris: $e');
    }
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
