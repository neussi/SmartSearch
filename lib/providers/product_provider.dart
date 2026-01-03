import 'package:flutter/foundation.dart';
import 'package:smartsearch/models/category.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/services/product_service.dart';

/// Provider pour la gestion des produits
class ProductProvider with ChangeNotifier {
  final ProductService _productService;

  List<Product> _products = [];
  List<Category> _categories = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;

  ProductProvider({required ProductService productService})
      : _productService = productService;

  // Getters
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charger tous les produits
  Future<void> loadProducts({String? category}) async {
    _setLoading(true);
    _clearError();

    try {
      _products = await _productService.getAllProducts(category: category);
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement des produits: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les catégories
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      _categories = await _productService.getCategories();
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement des catégories: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger un produit par ID
  Future<void> loadProductById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedProduct = await _productService.getProductById(id);
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement du produit: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les produits en promotion
  Future<void> loadDiscountedProducts() async {
    _setLoading(true);
    _clearError();

    try {
      _products = await _productService.getDiscountedProducts();
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement des promotions: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les produits populaires
  Future<void> loadPopularProducts({int limit = 10}) async {
    _setLoading(true);
    _clearError();

    try {
      _products = await _productService.getPopularProducts(limit: limit);
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement des produits populaires: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Filtrer les produits par prix
  List<Product> filterByPriceRange({
    required double minPrice,
    required double maxPrice,
  }) {
    return _products
        .where((product) =>
            product.finalPrice >= minPrice && product.finalPrice <= maxPrice)
        .toList();
  }

  /// Filtrer les produits avec réduction
  List<Product> getDiscountedProducts() {
    return _products.where((product) => product.hasDiscount).toList();
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
