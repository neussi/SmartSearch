import 'package:flutter/foundation.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/services/local_cart_service.dart';
import 'package:smartsearch/services/product_service.dart';

/// Provider pour la gestion du panier local
class CartProvider with ChangeNotifier {
  final LocalCartService _cartService;
  final ProductService _productService;

  Map<String, int> _cart = {};
  List<Product> _cartProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  CartProvider({
    required LocalCartService cartService,
    required ProductService productService,
  })  : _cartService = cartService,
        _productService = productService;

  // Getters
  Map<String, int> get cart => _cart;
  List<Product> get cartProducts => _cartProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cart.values.fold(0, (sum, qty) => sum + qty);
  
  double get totalPrice {
    double total = 0;
    for (var product in _cartProducts) {
      final quantity = _cart[product.id] ?? 0;
      total += product.finalPrice * quantity;
    }
    return total;
  }

  /// Charger le panier
  Future<void> loadCart() async {
    _setLoading(true);
    try {
      _cart = await _cartService.getCart();
      await _loadCartProducts();
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement du panier: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les produits du panier
  Future<void> _loadCartProducts() async {
    _cartProducts = [];
    for (var productId in _cart.keys) {
      try {
        final product = await _productService.getProductById(productId);
        _cartProducts.add(product);
      } catch (e) {
        // Produit non trouvé, on le retire du panier
        await _cartService.removeFromCart(productId: productId);
        _cart.remove(productId);
      }
    }
  }

  /// Ajouter un produit au panier
  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _cartService.addToCart(
        productId: productId,
        quantity: quantity,
      );
      await loadCart();
      return true;
    } catch (e) {
      _setError('Erreur d\'ajout au panier: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mettre à jour la quantité
  Future<bool> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _cartService.updateQuantity(
        productId: productId,
        quantity: quantity,
      );
      await loadCart();
      return true;
    } catch (e) {
      _setError('Erreur de mise à jour: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Retirer un produit du panier
  Future<bool> removeFromCart({required String productId}) async {
    _setLoading(true);
    _clearError();

    try {
      await _cartService.removeFromCart(productId: productId);
      await loadCart();
      return true;
    } catch (e) {
      _setError('Erreur de suppression: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Vider le panier
  Future<bool> clearCart() async {
    _setLoading(true);
    _clearError();

    try {
      await _cartService.clearCart();
      _cart = {};
      _cartProducts = [];
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur de vidage du panier: $e');
      return false;
    } finally {
      _setLoading(false);
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
