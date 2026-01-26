import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/utils/helpers.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/config/theme_config.dart';

/// ProductCard ULTRA PROFESSIONNEL avec design blanc & orange
/// Animations fluides, effets visuels WAOUH, interactions dynamiques
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        widget.onTap?.call();
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: {'id': widget.product.id},
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: ThemeConfig.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPressed
                  ? ThemeConfig.primaryColor.withValues(alpha: 0.4)
                  : ThemeConfig.primaryColor.withValues(alpha: 0.1),
              width: _isPressed ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? ThemeConfig.primaryColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _isPressed ? 16 : 20,
                offset: _isPressed ? const Offset(0, 4) : const Offset(0, 6),
                spreadRadius: _isPressed ? 2 : 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du produit
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'product_${widget.product.id}',
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: ThemeConfig.backgroundColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: ThemeConfig.backgroundColor,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: ThemeConfig.textSecondaryColor,
                            ),
                          ),
                        ),
                      ),
                      // Badge de réduction - Style orange AMÉLIORÉ
                      if (widget.product.hasDiscount)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        ThemeConfig.primaryColor,
                                        ThemeConfig.primaryLightColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeConfig.primaryColor.withValues(alpha: 0.5),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_offer,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        Helpers.formatDiscount(widget.product.discount),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      // Rating - Style minimaliste
                      if (widget.product.rating != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFC107),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.product.rating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Informations du produit
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nom du produit
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: ThemeConfig.textPrimaryColor,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Prix et bouton d'ajout au panier
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Prix barré si réduction
                                  if (widget.product.hasDiscount)
                                    Text(
                                      Helpers.formatPrice(widget.product.price),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: ThemeConfig.textSecondaryColor,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  // Prix final
                                  Text(
                                    Helpers.formatPrice(
                                      widget.product.finalPrice,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: ThemeConfig.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bouton d'ajout au panier - Orange AMÉLIORÉ
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onAddToCart,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        ThemeConfig.primaryColor,
                                        ThemeConfig.primaryLightColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeConfig.primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }
}
