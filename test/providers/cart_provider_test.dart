import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:smartsearch/models/cart_item.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/services/cart_service.dart';

// Générer les mocks
@GenerateMocks([CartService])
import 'cart_provider_test.mocks.dart';

void main() {
  group('CartProvider', () {
    late CartProvider cartProvider;
    late MockCartService mockCartService;

    // Données de test
    final testProduct = Product(
      id: '1',
      name: 'Test Product',
      description: 'Description',
      price: 10000,
      discountPercentage: 10,
      category: 'Test',
      imageUrl: 'http://example.com/image.jpg',
      rating: 4.5,
      
    );

    final testCartItem = CartItem(
      id: 'cart1',
      product: testProduct,
      quantity: 2,
      addedAt: DateTime.now(),
    );

    setUp(() {
      // Créer un mock du service avant chaque test
      mockCartService = MockCartService();
      cartProvider = CartProvider(cartService: mockCartService);
    });

    group('loadCart', () {
      test('devrait charger le panier avec succès', () async {
        // Arrange
        when(mockCartService.getCart())
            .thenAnswer((_) async => [testCartItem]);

        // Act
        await cartProvider.loadCart();

        // Assert
        expect(cartProvider.items, [testCartItem]);
        expect(cartProvider.isLoading, false);
        expect(cartProvider.errorMessage, null);
        verify(mockCartService.getCart()).called(1);
      });

      test('devrait gérer les erreurs de chargement', () async {
        // Arrange
        when(mockCartService.getCart())
            .thenThrow(Exception('Erreur réseau'));

        // Act
        await cartProvider.loadCart();

        // Assert
        expect(cartProvider.items, isEmpty);
        expect(cartProvider.isLoading, false);
        expect(cartProvider.errorMessage, contains('Erreur'));
      });
    });

    group('addToCart', () {
      test('devrait ajouter un produit au panier', () async {
        // Arrange
        when(mockCartService.addToCart(
          productId: anyNamed('productId'),
          quantity: anyNamed('quantity'),
        )).thenAnswer((_) async => testCartItem);

        // Act
        final success = await cartProvider.addToCart(
          productId: '1',
          quantity: 2,
        );

        // Assert
        expect(success, true);
        expect(cartProvider.items, contains(testCartItem));
        expect(cartProvider.errorMessage, null);
      });

      test('devrait gérer les erreurs d\'ajout', () async {
        // Arrange
        when(mockCartService.addToCart(
          productId: anyNamed('productId'),
          quantity: anyNamed('quantity'),
        )).thenThrow(Exception('Produit indisponible'));

        // Act
        final success = await cartProvider.addToCart(
          productId: '1',
          quantity: 2,
        );

        // Assert
        expect(success, false);
        expect(cartProvider.items, isEmpty);
        expect(cartProvider.errorMessage, contains('Erreur'));
      });
    });

    group('updateQuantity', () {
      test('devrait mettre à jour la quantité d\'un article', () async {
        // Arrange
        cartProvider.items.add(testCartItem);
        final updatedItem = testCartItem.copyWith(quantity: 5);

        when(mockCartService.updateCartItem(
          cartItemId: anyNamed('cartItemId'),
          quantity: anyNamed('quantity'),
        )).thenAnswer((_) async => updatedItem);

        // Act
        final success = await cartProvider.updateQuantity(
          cartItemId: 'cart1',
          quantity: 5,
        );

        // Assert
        expect(success, true);
        expect(cartProvider.items.first.quantity, 5);
      });

      test('devrait supprimer l\'article si quantité <= 0', () async {
        // Arrange
        cartProvider.items.add(testCartItem);

        when(mockCartService.removeFromCart(any))
            .thenAnswer((_) async => {});

        // Act
        final success = await cartProvider.updateQuantity(
          cartItemId: 'cart1',
          quantity: 0,
        );

        // Assert
        expect(success, true);
        expect(cartProvider.items, isEmpty);
      });
    });

    group('removeFromCart', () {
      test('devrait supprimer un article du panier', () async {
        // Arrange
        cartProvider.items.add(testCartItem);

        when(mockCartService.removeFromCart(any))
            .thenAnswer((_) async => {});

        // Act
        final success = await cartProvider.removeFromCart('cart1');

        // Assert
        expect(success, true);
        expect(cartProvider.items, isEmpty);
        verify(mockCartService.removeFromCart('cart1')).called(1);
      });

      test('devrait gérer les erreurs de suppression', () async {
        // Arrange
        cartProvider.items.add(testCartItem);

        when(mockCartService.removeFromCart(any))
            .thenThrow(Exception('Erreur serveur'));

        // Act
        final success = await cartProvider.removeFromCart('cart1');

        // Assert
        expect(success, false);
        expect(cartProvider.items, isNotEmpty);
        expect(cartProvider.errorMessage, contains('Erreur'));
      });
    });

    group('clearCart', () {
      test('devrait vider le panier', () async {
        // Arrange
        cartProvider.items.add(testCartItem);

        when(mockCartService.clearCart())
            .thenAnswer((_) async => {});

        // Act
        final success = await cartProvider.clearCart();

        // Assert
        expect(success, true);
        expect(cartProvider.items, isEmpty);
        verify(mockCartService.clearCart()).called(1);
      });
    });

    group('getters', () {
      test('isEmpty devrait retourner true si le panier est vide', () {
        expect(cartProvider.isEmpty, true);
      });

      test('isEmpty devrait retourner false si le panier contient des articles', () {
        cartProvider.items.add(testCartItem);
        expect(cartProvider.isEmpty, false);
      });

      test('itemCount devrait retourner le nombre total d\'articles', () {
        // Arrange
        when(mockCartService.getTotalItemCount(any)).thenReturn(2);
        cartProvider.items.add(testCartItem);

        // Act & Assert
        expect(cartProvider.itemCount, 2);
      });

      test('totalPrice devrait calculer le prix total', () {
        // Arrange
        when(mockCartService.calculateTotal(any)).thenReturn(18000.0);
        cartProvider.items.add(testCartItem);

        // Act & Assert
        expect(cartProvider.totalPrice, 18000.0);
      });
    });
  });
}