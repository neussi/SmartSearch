import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsearch/models/cart.dart';

/// Service pour gérer plusieurs paniers
class MultiCartService {
  static const String _cartsKey = 'user_carts';
  static const String _activeCartIdKey = 'active_cart_id';
  static const int maxCarts = 5;

  /// Récupérer tous les paniers
  Future<List<Cart>> getAllCarts() async {
    final prefs = await SharedPreferences.getInstance();
    final cartsJson = prefs.getString(_cartsKey);
    
    if (cartsJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> cartsList = jsonDecode(cartsJson);
      return cartsList.map((json) => Cart.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarder tous les paniers
  Future<void> _saveCarts(List<Cart> carts) async {
    final prefs = await SharedPreferences.getInstance();
    final cartsJson = jsonEncode(carts.map((c) => c.toJson()).toList());
    await prefs.setString(_cartsKey, cartsJson);
  }

  /// Créer un nouveau panier
  Future<Cart?> createCart({
    required String name,
    String? description,
  }) async {
    final carts = await getAllCarts();
    
    // Vérifier la limite
    if (carts.length >= maxCarts) {
      return null;
    }
    
    // Créer le nouveau panier
    final newCart = Cart.create(
      name: name,
      description: description,
    );
    
    carts.add(newCart);
    await _saveCarts(carts);
    
    // Si c'est le premier panier, le définir comme actif
    if (carts.length == 1) {
      await setActiveCart(newCart.id);
    }
    
    return newCart;
  }

  /// Obtenir un panier par ID
  Future<Cart?> getCart(String cartId) async {
    final carts = await getAllCarts();
    try {
      return carts.firstWhere((c) => c.id == cartId);
    } catch (e) {
      return null;
    }
  }

  /// Mettre à jour un panier
  Future<void> updateCart(Cart cart) async {
    final carts = await getAllCarts();
    final index = carts.indexWhere((c) => c.id == cart.id);
    
    if (index != -1) {
      carts[index] = cart;
      await _saveCarts(carts);
    }
  }

  /// Supprimer un panier
  Future<void> deleteCart(String cartId) async {
    final carts = await getAllCarts();
    carts.removeWhere((c) => c.id == cartId);
    await _saveCarts(carts);
    
    // Si c'était le panier actif, changer pour un autre
    final activeCartId = await getActiveCartId();
    if (activeCartId == cartId) {
      if (carts.isNotEmpty) {
        await setActiveCart(carts.first.id);
      } else {
        await setActiveCart(null);
      }
    }
  }

  /// Ajouter un produit à un panier
  Future<void> addToCart({
    required String cartId,
    required String productId,
    int quantity = 1,
  }) async {
    final cart = await getCart(cartId);
    if (cart == null) return;
    
    final items = Map<String, int>.from(cart.items);
    items[productId] = (items[productId] ?? 0) + quantity;
    
    final updatedCart = cart.copyWith(items: items);
    await updateCart(updatedCart);
  }

  /// Retirer un produit d'un panier
  Future<void> removeFromCart({
    required String cartId,
    required String productId,
  }) async {
    final cart = await getCart(cartId);
    if (cart == null) return;
    
    final items = Map<String, int>.from(cart.items);
    items.remove(productId);
    
    final updatedCart = cart.copyWith(items: items);
    await updateCart(updatedCart);
  }

  /// Mettre à jour la quantité d'un produit
  Future<void> updateQuantity({
    required String cartId,
    required String productId,
    required int quantity,
  }) async {
    final cart = await getCart(cartId);
    if (cart == null) return;
    
    final items = Map<String, int>.from(cart.items);
    
    if (quantity <= 0) {
      items.remove(productId);
    } else {
      items[productId] = quantity;
    }
    
    final updatedCart = cart.copyWith(items: items);
    await updateCart(updatedCart);
  }

  /// Vider un panier
  Future<void> clearCart(String cartId) async {
    final cart = await getCart(cartId);
    if (cart == null) return;
    
    final updatedCart = cart.copyWith(items: {});
    await updateCart(updatedCart);
  }

  /// Obtenir l'ID du panier actif
  Future<String?> getActiveCartId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeCartIdKey);
  }

  /// Définir le panier actif
  Future<void> setActiveCart(String? cartId) async {
    final prefs = await SharedPreferences.getInstance();
    if (cartId == null) {
      await prefs.remove(_activeCartIdKey);
    } else {
      await prefs.setString(_activeCartIdKey, cartId);
    }
  }

  /// Obtenir le panier actif
  Future<Cart?> getActiveCart() async {
    final activeCartId = await getActiveCartId();
    if (activeCartId == null) return null;
    return await getCart(activeCartId);
  }

  /// Renommer un panier
  Future<void> renameCart({
    required String cartId,
    required String newName,
    String? newDescription,
  }) async {
    final cart = await getCart(cartId);
    if (cart == null) return;
    
    final updatedCart = cart.copyWith(
      name: newName,
      description: newDescription,
    );
    await updateCart(updatedCart);
  }

  /// Dupliquer un panier
  Future<Cart?> duplicateCart(String cartId) async {
    final carts = await getAllCarts();
    
    // Vérifier la limite
    if (carts.length >= maxCarts) {
      return null;
    }
    
    final cart = await getCart(cartId);
    if (cart == null) return null;
    
    final newCart = Cart.create(
      name: '${cart.name} (Copie)',
      description: cart.description,
    ).copyWith(items: Map<String, int>.from(cart.items));
    
    carts.add(newCart);
    await _saveCarts(carts);
    
    return newCart;
  }

  /// Déplacer un produit d'un panier à un autre
  Future<void> moveProduct({
    required String fromCartId,
    required String toCartId,
    required String productId,
  }) async {
    final fromCart = await getCart(fromCartId);
    final toCart = await getCart(toCartId);
    
    if (fromCart == null || toCart == null) return;
    
    final quantity = fromCart.getQuantity(productId);
    if (quantity == 0) return;
    
    // Retirer du panier source
    await removeFromCart(cartId: fromCartId, productId: productId);
    
    // Ajouter au panier destination
    await addToCart(
      cartId: toCartId,
      productId: productId,
      quantity: quantity,
    );
  }
}
