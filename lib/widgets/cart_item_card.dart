import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartsearch/models/cart_item.dart';

/// Widget pour afficher un article dans le panier
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            _buildProductImage(),
            const SizedBox(width: 12),

            // Informations du produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductName(context),
                  const SizedBox(height: 4),
                  _buildProductPrice(context),
                  const SizedBox(height: 8),
                  _buildQuantityControls(context),
                ],
              ),
            ),

            // Bouton supprimer
            _buildDeleteButton(context),
          ],
        ),
      ),
    );
  }

  /// Image du produit avec gestion du cache
  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: item.product.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      ),
    );
  }

  /// Nom du produit
  Widget _buildProductName(BuildContext context) {
    return Text(
      item.product.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Prix du produit (avec réduction si applicable)
  Widget _buildProductPrice(BuildContext context) {
    final hasDiscount = item.product.discountPercentage > 0;

    return Row(
      children: [
        // Prix final
        Text(
          '${item.product.finalPrice.toStringAsFixed(0)} FCFA',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),

        // Prix original barré si réduction
        if (hasDiscount) ...[
          const SizedBox(width: 8),
          Text(
            '${item.product.price.toStringAsFixed(0)} FCFA',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
          ),
        ],
      ],
    );
  }

  /// Contrôles de quantité (-, nombre, +)
  Widget _buildQuantityControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton diminuer
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: item.quantity > 1
                ? () => onQuantityChanged(item.quantity - 1)
                : null,
          ),

          // Quantité actuelle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${item.quantity}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Bouton augmenter
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => onQuantityChanged(item.quantity + 1),
          ),
        ],
      ),
    );
  }

  /// Bouton de quantité (+ ou -)
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: onPressed != null ? Colors.black87 : Colors.grey,
        ),
      ),
    );
  }

  /// Bouton supprimer
  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      color: Colors.red[400],
      onPressed: () {
        // Afficher une confirmation avant de supprimer
        _showDeleteConfirmation(context);
      },
    );
  }

  /// Dialog de confirmation de suppression
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'article ?'),
        content: Text(
          'Voulez-vous vraiment retirer "${item.product.name}" du panier ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRemove();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}