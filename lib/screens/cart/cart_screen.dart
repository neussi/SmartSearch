import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/loading_widget.dart';
import 'package:smartsearch/utils/helpers.dart';

/// CartScreen ULTRA PROFESSIONNEL - Blanc & Orange uniquement
/// Design moderne avec animations fluides
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeConfig.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: ThemeConfig.primaryColor,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mon Panier',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          if (cartProvider.itemCount > 0)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeConfig.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: ThemeConfig.errorColor,
                  size: 20,
                ),
              ),
              onPressed: () => _showClearCartDialog(context, cartProvider),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cartProvider.isLoading
          ? const Center(child: LoadingWidget())
          : cartProvider.itemCount == 0
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartProvider.cartProducts.length,
                        itemBuilder: (context, index) {
                          final product = cartProvider.cartProducts[index];
                          final quantity = cartProvider.cart[product.id] ?? 0;
                          return _buildCartItem(product, quantity, cartProvider, index);
                        },
                      ),
                    ),
                    _buildCartSummary(cartProvider),
                  ],
                ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: ThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Votre panier est vide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ajoutez des produits pour commencer',
            style: TextStyle(
              fontSize: 16,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  ThemeConfig.primaryColor,
                  ThemeConfig.primaryLightColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ThemeConfig.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Continuer mes achats',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(product, int quantity, CartProvider cartProvider, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: ThemeConfig.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ThemeConfig.primaryColor.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeConfig.primaryColor.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Image produit
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: ThemeConfig.backgroundColor,
                          border: Border.all(
                            color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: product.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: ThemeConfig.primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.image_outlined,
                                  color: ThemeConfig.textSecondaryColor,
                                  size: 40,
                                ),
                              )
                            : Icon(
                                Icons.image_outlined,
                                color: ThemeConfig.textSecondaryColor,
                                size: 40,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Détails produit
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.textPrimaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Helpers.formatPrice(product.finalPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Contrôles quantité
                          Row(
                            children: [
                              _buildQuantityButton(
                                icon: Icons.remove,
                                onPressed: () {
                                  if (quantity > 1) {
                                    cartProvider.updateQuantity(
                                      productId: product.id,
                                      quantity: quantity - 1,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeConfig.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildQuantityButton(
                                icon: Icons.add,
                                onPressed: () {
                                  cartProvider.updateQuantity(
                                    productId: product.id,
                                    quantity: quantity + 1,
                                  );
                                },
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ThemeConfig.errorColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: ThemeConfig.errorColor,
                                    size: 20,
                                  ),
                                ),
                                onPressed: () {
                                  cartProvider.removeFromCart(productId: product.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: ThemeConfig.primaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sous-total',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
                Text(
                  Helpers.formatPrice(cartProvider.totalPrice * 0.9),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeConfig.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Livraison',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
                Text(
                  Helpers.formatPrice(cartProvider.totalPrice * 0.1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeConfig.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.textPrimaryColor,
                  ),
                ),
                Text(
                  Helpers.formatPrice(cartProvider.totalPrice),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ThemeConfig.primaryColor,
                      ThemeConfig.primaryLightColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConfig.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Commander
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Commande en cours de traitement...'),
                        backgroundColor: ThemeConfig.primaryColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Commander',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeConfig.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Vider le panier ?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeConfig.textPrimaryColor,
          ),
        ),
        content: const Text(
          'Voulez-vous vraiment supprimer tous les articles du panier ?',
          style: TextStyle(
            color: ThemeConfig.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: ThemeConfig.textSecondaryColor),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  ThemeConfig.errorColor,
                  ThemeConfig.errorColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.pop(context);
              },
              child: const Text(
                'Vider',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
