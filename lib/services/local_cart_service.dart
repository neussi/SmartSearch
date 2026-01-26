import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service de panier local avec SharedPreferences
class LocalCartService {
  static const String _cartKey = 'shopping_cart';

  /// Récupérer le panier
  Future<Map<String, int>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    
    if (cartJson == null) {
      return {};
    }
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(cartJson);
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }

  /// Ajouter un produit au panier
  Future<void> addToCart({required String productId, int quantity = 1}) async {
    final cart = await getCart();
    cart[productId] = (cart[productId] ?? 0) + quantity;
    await _saveCart(cart);
  }

  /// Retirer un produit du panier
  Future<void> removeFromCart({required String productId}) async {
    final cart = await getCart();
    cart.remove(productId);
    await _saveCart(cart);
  }

  /// Mettre à jour la quantité d'un produit
  Future<void> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    final cart = await getCart();
    if (quantity <= 0) {
      cart.remove(productId);
    } else {
      cart[productId] = quantity;
    }
    await _saveCart(cart);
  }

  /// Vider le panier
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  /// Obtenir le nombre total d'articles
  Future<int> getItemCount() async {
    final cart = await getCart();
    return cart.values.fold<int>(0, (sum, qty) => sum + qty);
  }

  /// Sauvegarder le panier
  Future<void> _saveCart(Map<String, int> cart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(cart));
  }
}
