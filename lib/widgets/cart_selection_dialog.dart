import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/models/cart.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/providers/multi_cart_provider.dart';

/// Dialog professionnel pour sélectionner le panier de destination
class CartSelectionDialog extends StatefulWidget {
  final Product product;
  final int quantity;

  const CartSelectionDialog({
    super.key,
    required this.product,
    this.quantity = 1,
  });

  /// Méthode statique pour afficher le dialog
  static Future<bool?> show({
    required BuildContext context,
    required Product product,
    int quantity = 1,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CartSelectionDialog(
        product: product,
        quantity: quantity,
      ),
    );
  }

  @override
  State<CartSelectionDialog> createState() => _CartSelectionDialogState();
}

class _CartSelectionDialogState extends State<CartSelectionDialog> {
  String? _selectedCartId;
  final _newCartNameController = TextEditingController();
  bool _isCreatingNew = false;

  @override
  void dispose() {
    _newCartNameController.dispose();
    super.dispose();
  }

  Future<void> _addToCart(MultiCartProvider cartProvider) async {
    if (_isCreatingNew) {
      // Créer un nouveau panier
      final name = _newCartNameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez entrer un nom pour le panier'),
            backgroundColor: ThemeConfig.errorColor,
          ),
        );
        return;
      }

      final success = await cartProvider.createCart(name: name);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Limite de 5 paniers atteinte'),
              backgroundColor: ThemeConfig.errorColor,
            ),
          );
        }
        return;
      }

      // Ajouter au nouveau panier (qui devient actif)
      await cartProvider.addToActiveCart(
        productId: widget.product.id,
        quantity: widget.quantity,
      );
    } else if (_selectedCartId != null) {
      // Ajouter au panier sélectionné
      await cartProvider.addToCart(
        cartId: _selectedCartId!,
        productId: widget.product.id,
        quantity: widget.quantity,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiCartProvider>(
      builder: (context, cartProvider, child) {
        // Initialiser la sélection avec le panier actif
        if (_selectedCartId == null && cartProvider.activeCartId != null) {
          _selectedCartId = cartProvider.activeCartId;
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ThemeConfig.primaryColor,
                        ThemeConfig.primaryLightColor,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ajouter au Panier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Choisissez votre panier',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Produit
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeConfig.backgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.product.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: ThemeConfig.backgroundColor,
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                color: ThemeConfig.textPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${widget.product.finalPrice.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    color: ThemeConfig.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'x${widget.quantity}',
                                  style: const TextStyle(
                                    color: ThemeConfig.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste des paniers
                Flexible(
                  child: cartProvider.carts.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Paniers existants
                            ...cartProvider.carts.map((cart) {
                              final isSelected = _selectedCartId == cart.id;
                              final isActive = cart.id == cartProvider.activeCartId;

                              return _buildCartOption(
                                cart: cart,
                                isSelected: isSelected,
                                isActive: isActive,
                                onTap: () {
                                  setState(() {
                                    _selectedCartId = cart.id;
                                    _isCreatingNew = false;
                                  });
                                },
                              );
                            }).toList(),

                            // Option créer nouveau panier
                            if (cartProvider.canCreateCart) ...[
                              const SizedBox(height: 8),
                              _buildCreateNewOption(),
                            ],
                          ],
                        ),
                ),

                // Boutons d'action
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeConfig.surfaceColor,
                    border: Border(
                      top: BorderSide(
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: ThemeConfig.textSecondaryColor,
                            ),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: (_selectedCartId != null || _isCreatingNew)
                              ? () => _addToCart(cartProvider)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConfig.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor:
                                ThemeConfig.textSecondaryColor.withValues(alpha: 0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_shopping_cart, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _isCreatingNew ? 'Créer et Ajouter' : 'Ajouter',
                                style: const TextStyle(
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartOption({
    required Cart cart,
    required bool isSelected,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? ThemeConfig.primaryColor.withValues(alpha: 0.1)
                  : ThemeConfig.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ThemeConfig.primaryColor
                    : ThemeConfig.primaryColor.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? ThemeConfig.primaryColor
                          : ThemeConfig.textSecondaryColor,
                      width: 2,
                    ),
                    color: isSelected ? ThemeConfig.primaryColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Icône panier
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? ThemeConfig.primaryColor
                        : ThemeConfig.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 20,
                    color: isActive ? Colors.white : ThemeConfig.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Infos panier
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cart.name,
                              style: TextStyle(
                                color: ThemeConfig.textPrimaryColor,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
                      const SizedBox(height: 4),
                      Text(
                        '${cart.totalItems} article${cart.totalItems > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: ThemeConfig.textSecondaryColor,
                          fontSize: 14,
                        ),
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
  }

  Widget _buildCreateNewOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCreatingNew
            ? ThemeConfig.primaryColor.withValues(alpha: 0.1)
            : ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCreatingNew
              ? ThemeConfig.primaryColor
              : ThemeConfig.primaryColor.withValues(alpha: 0.2),
          width: _isCreatingNew ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isCreatingNew = !_isCreatingNew;
                if (_isCreatingNew) {
                  _selectedCartId = null;
                }
              });
            },
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isCreatingNew
                          ? ThemeConfig.primaryColor
                          : ThemeConfig.textSecondaryColor,
                      width: 2,
                    ),
                    color: _isCreatingNew ? ThemeConfig.primaryColor : Colors.transparent,
                  ),
                  child: _isCreatingNew
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    size: 20,
                    color: ThemeConfig.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Créer un nouveau panier',
                    style: TextStyle(
                      color: ThemeConfig.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isCreatingNew) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _newCartNameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nom du panier',
                hintText: 'Ex: Panier Bureau',
                prefixIcon: const Icon(Icons.edit),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: ThemeConfig.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: ThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun panier',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre premier panier',
            style: TextStyle(
              fontSize: 14,
              color: ThemeConfig.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
