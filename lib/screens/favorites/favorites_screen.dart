import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/providers/favorites_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/product_card.dart';
import 'package:smartsearch/widgets/loading_widget.dart';

/// Écran des favoris avec gestion complète
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Charger les favoris
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _confirmClearFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Effacer les favoris',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Voulez-vous vraiment effacer tous vos favoris ?',
          style: TextStyle(color: ThemeConfig.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<FavoritesProvider>().clearFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favoris effacés'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ThemeConfig.primaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes Favoris',
                  style: TextStyle(
                    color: ThemeConfig.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                if (favoritesProvider.favoritesCount > 0)
                  Text(
                    '${favoritesProvider.favoritesCount} produit${favoritesProvider.favoritesCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: ThemeConfig.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              if (favoritesProvider.favoriteProducts.isNotEmpty) {
                return IconButton(
                  icon: const Icon(
                    Icons.delete_sweep,
                    color: ThemeConfig.errorColor,
                  ),
                  onPressed: _confirmClearFavorites,
                  tooltip: 'Effacer tout',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.isLoading) {
            return const Center(
              child: LoadingWidget(message: 'Chargement des favoris...'),
            );
          }

          if (favoritesProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: ThemeConfig.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    favoritesProvider.errorMessage!,
                    style: const TextStyle(
                      color: ThemeConfig.textSecondaryColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => favoritesProvider.loadFavorites(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (favoritesProvider.favoriteProducts.isEmpty) {
            return _buildEmptyState();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favoritesProvider.favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoritesProvider.favoriteProducts[index];
                
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.productDetail,
                              arguments: {'id': product.id},
                            );
                          },
                          onAddToCart: () {
                            context.read<CartProvider>().addToCart(
                                  productId: product.id,
                                  quantity: 1,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} ajouté au panier'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: ThemeConfig.primaryColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          showFavoriteButton: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.favorite_border,
              size: 80,
              color: ThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun favori',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ajoutez des produits à vos favoris\nen cliquant sur le coeur',
            style: TextStyle(
              fontSize: 16,
              color: ThemeConfig.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
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
                  Icon(Icons.explore_outlined, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Découvrir des produits',
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
}
