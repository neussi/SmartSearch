import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/providers/multi_cart_provider.dart';
import 'package:smartsearch/models/cart.dart';
import 'package:smartsearch/widgets/loading_widget.dart';

/// Écran de gestion des paniers multiples
class MultiCartScreen extends StatefulWidget {
  const MultiCartScreen({super.key});

  @override
  State<MultiCartScreen> createState() => _MultiCartScreenState();
}

class _MultiCartScreenState extends State<MultiCartScreen>
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MultiCartProvider>().loadCarts();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showCreateCartDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Nouveau Panier',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du panier',
                hintText: 'Ex: Panier Bureau',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Ex: Matériel pour le bureau',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final name = nameController.text.trim();
      if (name.isNotEmpty) {
        final success = await context.read<MultiCartProvider>().createCart(
              name: name,
              description: descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
            );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Panier créé avec succès'),
                backgroundColor: ThemeConfig.primaryColor,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Limite de 5 paniers atteinte'),
                backgroundColor: ThemeConfig.errorColor,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _showRenameDialog(Cart cart) async {
    final nameController = TextEditingController(text: cart.name);
    final descriptionController =
        TextEditingController(text: cart.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Renommer le Panier',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du panier',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final name = nameController.text.trim();
      if (name.isNotEmpty) {
        await context.read<MultiCartProvider>().renameCart(
              cartId: cart.id,
              newName: name,
              newDescription: descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
            );
      }
    }
  }

  Future<void> _confirmDelete(Cart cart) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Supprimer le Panier',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer "${cart.name}" ?\nTous les articles seront perdus.',
          style: const TextStyle(color: ThemeConfig.textSecondaryColor),
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
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<MultiCartProvider>().deleteCart(cart.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Panier supprimé'),
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
        title: Consumer<MultiCartProvider>(
          builder: (context, cartProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes Paniers',
                  style: TextStyle(
                    color: ThemeConfig.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  '${cartProvider.cartsCount}/5 paniers',
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
          Consumer<MultiCartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.canCreateCart) {
                return IconButton(
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: ThemeConfig.primaryColor,
                  ),
                  onPressed: _showCreateCartDialog,
                  tooltip: 'Nouveau panier',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MultiCartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(
              child: LoadingWidget(message: 'Chargement des paniers...'),
            );
          }

          if (cartProvider.errorMessage != null) {
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
                    cartProvider.errorMessage!,
                    style: const TextStyle(
                      color: ThemeConfig.textSecondaryColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => cartProvider.loadCarts(),
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

          if (cartProvider.carts.isEmpty) {
            return _buildEmptyState();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cartProvider.carts.length,
              itemBuilder: (context, index) {
                final cart = cartProvider.carts[index];
                final isActive = cart.id == cartProvider.activeCartId;
                
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: _buildCartCard(cart, isActive, cartProvider),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<MultiCartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.canCreateCart && cartProvider.carts.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: _showCreateCartDialog,
              backgroundColor: ThemeConfig.primaryColor,
              icon: const Icon(Icons.add),
              label: const Text('Nouveau Panier'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCartCard(Cart cart, bool isActive, MultiCartProvider provider) {
    final total = provider.getCartTotal(cart.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? ThemeConfig.primaryColor
              : ThemeConfig.primaryColor.withValues(alpha: 0.1),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? ThemeConfig.primaryColor.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isActive ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            provider.setActiveCart(cart.id);
            Navigator.pushNamed(
              context,
              AppRoutes.cart,
              arguments: {'cartId': cart.id},
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? ThemeConfig.primaryColor
                            : ThemeConfig.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        color: isActive ? Colors.white : ThemeConfig.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  cart.name,
                                  style: const TextStyle(
                                    color: ThemeConfig.textPrimaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ThemeConfig.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'ACTIF',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (cart.description != null)
                            Text(
                              cart.description!,
                              style: const TextStyle(
                                color: ThemeConfig.textSecondaryColor,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 12),
                              Text('Renommer'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.content_copy, size: 20),
                              SizedBox(width: 12),
                              Text('Dupliquer'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'clear',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep, size: 20),
                              SizedBox(width: 12),
                              Text('Vider'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: ThemeConfig.errorColor),
                              SizedBox(width: 12),
                              Text('Supprimer', style: TextStyle(color: ThemeConfig.errorColor)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        switch (value) {
                          case 'rename':
                            _showRenameDialog(cart);
                            break;
                          case 'duplicate':
                            final success = await provider.duplicateCart(cart.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success
                                      ? 'Panier dupliqué'
                                      : 'Limite de paniers atteinte'),
                                  backgroundColor: success
                                      ? ThemeConfig.primaryColor
                                      : ThemeConfig.errorColor,
                                ),
                              );
                            }
                            break;
                          case 'clear':
                            await provider.clearCart(cart.id);
                            break;
                          case 'delete':
                            _confirmDelete(cart);
                            break;
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag,
                          size: 16,
                          color: ThemeConfig.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${cart.totalItems} article${cart.totalItems > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: ThemeConfig.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${total.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: ThemeConfig.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
              Icons.shopping_cart_outlined,
              size: 80,
              color: ThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun panier',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Créez votre premier panier\npour commencer vos achats',
            style: TextStyle(
              fontSize: 16,
              color: ThemeConfig.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showCreateCartDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Créer un Panier'),
          ),
        ],
      ),
    );
  }
}
