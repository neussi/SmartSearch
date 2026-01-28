import 'package:flutter/foundation.dart';
import 'package:smartsearch/models/cart.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/services/multi_cart_service.dart';
import 'package:smartsearch/services/product_service.dart';

/// Provider pour gérer plusieurs paniers
class MultiCartProvider with ChangeNotifier {
  final MultiCartService _cartService;
  final ProductService _productService;

  List<Cart> _carts = [];
  String? _activeCartId;
  Map<String, List<Product>> _cartProducts = {};
  bool _isLoading = false;
  String? _errorMessage;

  MultiCartProvider({
    required MultiCartService cartService,
    required ProductService productService,
  })  : _cartService = cartService,
        _productService = productService;

  // Getters
  List<Cart> get carts => _carts;
  String? get activeCartId => _activeCartId;
  Cart? get activeCart => _carts.isEmpty ? null : _carts.firstWhere(
        (c) => c.id == _activeCartId,
        orElse: () => _carts.first,
      );
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get cartsCount => _carts.length;
  bool get canCreateCart => _carts.length < MultiCartService.maxCarts;

  /// Charger tous les paniers
  Future<void> loadCarts() async {
    _setLoading(true);
    _clearError();

    try {
      _carts = await _cartService.getAllCarts();
      _activeCartId = await _cartService.getActiveCartId();
      
      // Charger les produits pour chaque panier
      for (var cart in _carts) {
        await _loadCartProducts(cart.id);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement des paniers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les produits d'un panier
  Future<void> _loadCartProducts(String cartId) async {
    final cart = _carts.firstWhere((c) => c.id == cartId);
    final products = <Product>[];
    
    for (var productId in cart.items.keys) {
      try {
        final product = await _productService.getProductById(productId);
        products.add(product);
      } catch (e) {
        // Produit non trouvé, on le retire du panier
        await _cartService.removeFromCart(
          cartId: cartId,
          productId: productId,
        );
      }
    }
    
    _cartProducts[cartId] = products;
  }

  /// Créer un nouveau panier
  Future<bool> createCart({
    required String name,
    String? description,
  }) async {
    _clearError();

    try {
      final newCart = await _cartService.createCart(
        name: name,
        description: description,
      );
      
      if (newCart == null) {
        _setError('Limite de paniers atteinte (${MultiCartService.maxCarts} max)');
        return false;
      }
      
      _carts.add(newCart);
      _cartProducts[newCart.id] = [];
      
      // Si c'est le premier panier, le définir comme actif
      if (_carts.length == 1) {
        _activeCartId = newCart.id;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de la création du panier: $e');
      return false;
    }
  }

  /// Supprimer un panier
  Future<void> deleteCart(String cartId) async {
    try {
      await _cartService.deleteCart(cartId);
      _carts.removeWhere((c) => c.id == cartId);
      _cartProducts.remove(cartId);
      
      // Mettre à jour le panier actif
      if (_activeCartId == cartId) {
        _activeCartId = _carts.isNotEmpty ? _carts.first.id : null;
        await _cartService.setActiveCart(_activeCartId);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la suppression du panier: $e');
    }
  }

  /// Définir le panier actif
  Future<void> setActiveCart(String cartId) async {
    try {
      await _cartService.setActiveCart(cartId);
      _activeCartId = cartId;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du changement de panier: $e');
    }
  }

  /// Ajouter un produit au panier actif
  Future<void> addToActiveCart({
    required String productId,
    int quantity = 1,
  }) async {
    if (_activeCartId == null) {
      // Créer un panier par défaut
      await createCart(name: 'Mon Panier');
    }
    
    if (_activeCartId != null) {
      await addToCart(
        cartId: _activeCartId!,
        productId: productId,
        quantity: quantity,
      );
    }
  }

  /// Ajouter un produit à un panier spécifique
  Future<void> addToCart({
    required String cartId,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      await _cartService.addToCart(
        cartId: cartId,
        productId: productId,
        quantity: quantity,
      );
      
      // Recharger le panier
      final updatedCart = await _cartService.getCart(cartId);
      if (updatedCart != null) {
        final index = _carts.indexWhere((c) => c.id == cartId);
        if (index != -1) {
          _carts[index] = updatedCart;
        }
        
        // Charger le produit si nécessaire
        if (!_cartProducts[cartId]!.any((p) => p.id == productId)) {
          try {
            final product = await _productService.getProductById(productId);
            _cartProducts[cartId]!.add(product);
          } catch (e) {
            // Ignorer si le produit ne peut pas être chargé
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de l\'ajout au panier: $e');
    }
  }

  /// Retirer un produit d'un panier
  Future<void> removeFromCart({
    required String cartId,
    required String productId,
  }) async {
    try {
      await _cartService.removeFromCart(
        cartId: cartId,
        productId: productId,
      );
      
      // Recharger le panier
      final updatedCart = await _cartService.getCart(cartId);
      if (updatedCart != null) {
        final index = _carts.indexWhere((c) => c.id == cartId);
        if (index != -1) {
          _carts[index] = updatedCart;
        }
        
        _cartProducts[cartId]?.removeWhere((p) => p.id == productId);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la suppression: $e');
    }
  }

  /// Mettre à jour la quantité
  Future<void> updateQuantity({
    required String cartId,
    required String productId,
    required int quantity,
  }) async {
    try {
      await _cartService.updateQuantity(
        cartId: cartId,
        productId: productId,
        quantity: quantity,
      );
      
      // Recharger le panier
      final updatedCart = await _cartService.getCart(cartId);
      if (updatedCart != null) {
        final index = _carts.indexWhere((c) => c.id == cartId);
        if (index != -1) {
          _carts[index] = updatedCart;
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la mise à jour: $e');
    }
  }

  /// Vider un panier
  Future<void> clearCart(String cartId) async {
    try {
      await _cartService.clearCart(cartId);
      
      final updatedCart = await _cartService.getCart(cartId);
      if (updatedCart != null) {
        final index = _carts.indexWhere((c) => c.id == cartId);
        if (index != -1) {
          _carts[index] = updatedCart;
        }
        _cartProducts[cartId] = [];
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du vidage du panier: $e');
    }
  }

  /// Renommer un panier
  Future<void> renameCart({
    required String cartId,
    required String newName,
    String? newDescription,
  }) async {
    try {
      await _cartService.renameCart(
        cartId: cartId,
        newName: newName,
        newDescription: newDescription,
      );
      
      final updatedCart = await _cartService.getCart(cartId);
      if (updatedCart != null) {
        final index = _carts.indexWhere((c) => c.id == cartId);
        if (index != -1) {
          _carts[index] = updatedCart;
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du renommage: $e');
    }
  }

  /// Dupliquer un panier
  Future<bool> duplicateCart(String cartId) async {
    try {
      final newCart = await _cartService.duplicateCart(cartId);
      
      if (newCart == null) {
        _setError('Limite de paniers atteinte');
        return false;
      }
      
      _carts.add(newCart);
      
      // Copier les produits
      final originalProducts = _cartProducts[cartId] ?? [];
      _cartProducts[newCart.id] = List.from(originalProducts);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de la duplication: $e');
      return false;
    }
  }

  /// Déplacer un produit entre paniers
  Future<void> moveProduct({
    required String fromCartId,
    required String toCartId,
    required String productId,
  }) async {
    try {
      await _cartService.moveProduct(
        fromCartId: fromCartId,
        toCartId: toCartId,
        productId: productId,
      );
      
      await loadCarts();
    } catch (e) {
      _setError('Erreur lors du déplacement: $e');
    }
  }

  /// Obtenir les produits d'un panier
  List<Product> getCartProducts(String cartId) {
    return _cartProducts[cartId] ?? [];
  }

  /// Obtenir le total d'un panier
  double getCartTotal(String cartId) {
    final cart = _carts.firstWhere((c) => c.id == cartId);
    final products = _cartProducts[cartId] ?? [];
    
    double total = 0;
    for (var product in products) {
      final quantity = cart.getQuantity(product.id);
      total += product.finalPrice * quantity;
    }
    
    return total;
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
