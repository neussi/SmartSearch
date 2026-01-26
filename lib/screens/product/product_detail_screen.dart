import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/providers/product_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/loading_widget.dart';
import 'package:smartsearch/utils/helpers.dart';

/// ProductDetailScreen avec design blanc & orange cohérent
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductById(widget.productId);
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();

    if (productProvider.isLoading) {
      return const Scaffold(
        backgroundColor: ThemeConfig.backgroundColor,
        body: LoadingWidget(message: 'Chargement du produit...'),
      );
    }

    if (productProvider.selectedProduct == null) {
      return Scaffold(
        backgroundColor: ThemeConfig.backgroundColor,
        appBar: AppBar(
          backgroundColor: ThemeConfig.surfaceColor,
          title: const Text('Produit'),
        ),
        body: const Center(
          child: Text('Produit non trouvé'),
        ),
      );
    }

    final product = productProvider.selectedProduct!;

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
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: ThemeConfig.primaryColor,
                size: 20,
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du produit
                Hero(
                  tag: 'product_${product.id}',
                  child: Container(
                    height: size.height * 0.4,
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeConfig.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: ThemeConfig.backgroundColor,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: ThemeConfig.primaryColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: ThemeConfig.backgroundColor,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: ThemeConfig.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges (promotion et note)
                          Row(
                            children: [
                              if (product.hasDiscount)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        ThemeConfig.errorColor,
                                        ThemeConfig.errorColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeConfig.errorColor.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    Helpers.formatDiscount(product.discount),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (product.rating != null) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.rating!.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Nom du produit
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.textPrimaryColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Catégorie
                          if (product.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                product.category!,
                                style: const TextStyle(
                                  color: ThemeConfig.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Prix
                          Row(
                            children: [
                              if (product.hasDiscount)
                                Text(
                                  Helpers.formatPrice(product.price),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: ThemeConfig.textSecondaryColor,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              if (product.hasDiscount) const SizedBox(width: 12),
                              Text(
                                Helpers.formatPrice(product.finalPrice),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeConfig.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: ThemeConfig.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Quantité
                          const Text(
                            'Quantité',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildQuantityButton(
                                icon: Icons.remove,
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                },
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeConfig.primaryColor,
                                  ),
                                ),
                              ),
                              _buildQuantityButton(
                                icon: Icons.add,
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bouton Ajouter au panier (fixé en bas)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
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
                child: SizedBox(
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
                      onPressed: cartProvider.isLoading
                          ? null
                          : () async {
                              final success = await cartProvider.addToCart(
                                productId: product.id,
                                quantity: _quantity,
                              );

                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$_quantity x ${product.name} ajouté au panier',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: ThemeConfig.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Voir',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/cart');
                                      },
                                    ),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              } else if (!success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      cartProvider.errorMessage ?? 'Erreur lors de l\'ajout',
                                    ),
                                    backgroundColor: ThemeConfig.errorColor,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: cartProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Ajouter au Panier',
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
              ),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: ThemeConfig.primaryColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
