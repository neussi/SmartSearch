import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/animated_gradient_background.dart';
import 'package:smartsearch/widgets/glassmorphic_card.dart';
import 'package:smartsearch/widgets/animated_button.dart';
import 'package:smartsearch/widgets/loading_widget.dart';
import 'package:smartsearch/utils/helpers.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Panier',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (cartProvider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                _showClearCartDialog(context, cartProvider);
              },
            ),
        ],
      ),
      body: AnimatedGradientBackground(
        colors: const [
          Color(0xFF43e97b),
          Color(0xFF38f9d7),
          Color(0xFF4facfe),
          Color(0xFF00f2fe),
        ],
        child: SafeArea(
          child: cartProvider.isLoading
              ? const LoadingWidget(message: 'Chargement du panier...')
              : cartProvider.isEmpty
                  ? _buildEmptyCart()
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: cartProvider.items.length,
                            itemBuilder: (context, index) {
                              final item = cartProvider.items[index];
                              return FadeTransition(
                                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _controller,
                                    curve: Interval(
                                      (index * 0.1).clamp(0.0, 1.0),
                                      ((index + 1) * 0.1).clamp(0.0, 1.0),
                                    ),
                                  ),
                                ),
                                child: Dismissible(
                                  key: Key(item.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B6B),
                                          Color(0xFFEE5A6F),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    cartProvider.removeFromCart(item.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${item.product.name} retiré du panier',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: const Color(0xFFFF6B6B),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                  child: _CartItemCard(
                                    item: item,
                                    onQuantityChanged: (quantity) {
                                      cartProvider.updateQuantity(
                                        cartItemId: item.id,
                                        quantity: quantity,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, -10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total (${cartProvider.itemCount} articles)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    Helpers.formatPrice(cartProvider.totalPrice),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF667eea),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              AnimatedButton(
                                text: 'Commander',
                                icon: Icons.check_circle,
                                onPressed: () {
                                  _showOrderConfirmation(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: GlassmorphicCard(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Votre panier est vide',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez des produits pour commencer',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedButton(
              text: 'Continuer les achats',
              icon: Icons.shopping_bag,
              onPressed: () {
                Navigator.pop(context);
              },
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Vider le panier'),
        content: const Text(
          'Êtes-vous sûr de vouloir vider votre panier?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF43e97b),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Commande confirmée',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Votre commande a été enregistrée avec succès!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item;
  final Function(int) onQuantityChanged;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 100,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 100,
                height: 120,
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 100,
                height: 120,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Helpers.formatPrice(item.product.finalPrice),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667eea),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildQuantityButton(
                          icon: Icons.remove,
                          onPressed: () {
                            if (item.quantity > 1) {
                              onQuantityChanged(item.quantity - 1);
                            }
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.quantity.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildQuantityButton(
                          icon: Icons.add,
                          onPressed: () {
                            onQuantityChanged(item.quantity + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667eea),
            size: 18,
          ),
        ),
      ),
    );
  }
}
