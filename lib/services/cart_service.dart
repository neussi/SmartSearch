import 'package:smartsearch/config/api_config.dart';
import 'package:smartsearch/models/cart_item.dart';
import 'package:smartsearch/services/api_service.dart';

/// Service pour la gestion du panier
class CartService {
  final ApiService _apiService;

  CartService({required ApiService apiService}) : _apiService = apiService;

  /// Récupérer le panier
  Future<List<CartItem>> getCart() async {
    try {
      final response = await _apiService.get(ApiConfig.cartListEndpoint);

      final cartData = response['cart'] ?? response['items'] ?? [];

      return (cartData as List<dynamic>)
          .map((json) => CartItem.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Ajouter un article au panier
  Future<CartItem> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.cartAddEndpoint,
        body: {
          'productId': productId,
          'quantity': quantity,
        },
      );

      final cartItemData = response['cartItem'] ?? response['item'] ?? response;

      return CartItem.fromJson(cartItemData);
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour la quantité d'un article
  Future<CartItem> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConfig.cartUpdateEndpoint,
        body: {
          'cartItemId': cartItemId,
          'quantity': quantity,
        },
      );

      final cartItemData = response['cartItem'] ?? response['item'] ?? response;

      return CartItem.fromJson(cartItemData);
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer un article du panier
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _apiService.delete('${ApiConfig.cartRemoveEndpoint}/$cartItemId');
    } catch (e) {
      rethrow;
    }
  }

  /// Vider le panier
  Future<void> clearCart() async {
    try {
      await _apiService.delete(ApiConfig.cartEndpoint);
    } catch (e) {
      rethrow;
    }
  }

  /// Calculer le total du panier
  double calculateTotal(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Compter le nombre total d'articles
  int getTotalItemCount(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
