import 'package:flutter/foundation.dart';
import 'package:smartsearch/models/cart_item.dart';
import 'package:smartsearch/services/cart_service.dart';

/// Provider pour la gestion du panier
class CartProvider with ChangeNotifier {
  final CartService _cartService;

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  CartProvider({required CartService cartService})
      : _cartService = cartService;

  // Getters
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cartService.getTotalItemCount(_items);
  double get totalPrice => _cartService.calculateTotal(_items);
  bool get isEmpty => _items.isEmpty;

  /// Charger le panier
  Future<void> loadCart() async {
    _setLoading(true);
    _clearError();

    try {
      _items = await _cartService.getCart();
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement du panier: $e');
    } finally {
      _setLoading(false);
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
      final cartItem = await _cartService.addToCart(
        productId: productId,
        quantity: quantity,
      );

      // Vérifier si l'article existe déjà
      final existingIndex = _items.indexWhere((item) => item.id == cartItem.id);

      if (existingIndex != -1) {
        _items[existingIndex] = cartItem;
      } else {
        _items.add(cartItem);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur d\'ajout au panier: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mettre à jour la quantité d'un article
  Future<bool> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return removeFromCart(cartItemId);
    }

    _setLoading(true);
    _clearError();

    try {
      final updatedItem = await _cartService.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      final index = _items.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Erreur de mise à jour: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprimer un article du panier
  Future<bool> removeFromCart(String cartItemId) async {
    _setLoading(true);
    _clearError();

    try {
      await _cartService.removeFromCart(cartItemId);
      _items.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
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
      _items.clear();
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
