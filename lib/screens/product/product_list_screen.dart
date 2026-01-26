import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/providers/product_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/product_card.dart';
import 'package:smartsearch/widgets/loading_widget.dart';

/// ProductListScreen avec design blanc & orange cohérent
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  double _minPrice = 0;
  double _maxPrice = 1000000;
  bool _showDiscountsOnly = false;
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
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: ThemeConfig.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: ThemeConfig.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Filtres',
              style: TextStyle(
                color: ThemeConfig.textPrimaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fourchette de Prix',
              style: TextStyle(
                color: ThemeConfig.textPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 1000000,
              divisions: 100,
              activeColor: ThemeConfig.primaryColor,
              inactiveColor: ThemeConfig.primaryColor.withValues(alpha: 0.3),
              onChanged: (values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
            ),
            Text(
              '${_minPrice.toStringAsFixed(0)} - ${_maxPrice.toStringAsFixed(0)} FCFA',
              style: const TextStyle(color: ThemeConfig.textSecondaryColor),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text(
                'Produits en promotion uniquement',
                style: TextStyle(color: ThemeConfig.textPrimaryColor),
              ),
              value: _showDiscountsOnly,
              activeColor: ThemeConfig.primaryColor,
              onChanged: (value) {
                setState(() {
                  _showDiscountsOnly = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _minPrice = 0;
                        _maxPrice = 1000000;
                        _showDiscountsOnly = false;
                        _selectedCategory = null;
                      });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeConfig.primaryColor,
                      side: const BorderSide(color: ThemeConfig.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    final productProvider = context.read<ProductProvider>();
    productProvider.loadProducts(category: _selectedCategory);
  }

  List _getFilteredProducts(List products) {
    return products.where((product) {
      final priceInRange =
          product.finalPrice >= _minPrice && product.finalPrice <= _maxPrice;
      final discountCondition = !_showDiscountsOnly || product.hasDiscount;
      return priceInRange && discountCondition;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final filteredProducts = _getFilteredProducts(productProvider.products);

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
          'Tous les Produits',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
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
                Icons.filter_list,
                color: ThemeConfig.primaryColor,
                size: 20,
              ),
            ),
            onPressed: _showFilterBottomSheet,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            if (productProvider.categories.isNotEmpty)
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: productProvider.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _CategoryChip(
                        label: 'Tous',
                        isSelected: _selectedCategory == null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = null;
                          });
                          _applyFilters();
                        },
                      );
                    }
                    final category = productProvider.categories[index - 1];
                    return _CategoryChip(
                      label: category.name,
                      isSelected: _selectedCategory == category.id,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category.id;
                        });
                        _applyFilters();
                      },
                    );
                  },
                ),
              ),
            if (productProvider.isLoading)
              const Expanded(
                child: LoadingWidget(message: 'Chargement des produits...'),
              )
            else if (filteredProducts.isEmpty)
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: ThemeConfig.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: ThemeConfig.textSecondaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun produit trouvé',
                          style: TextStyle(
                            color: ThemeConfig.textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(
                            (index * 0.05).clamp(0.0, 1.0),
                            ((index + 1) * 0.05).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                      child: ProductCard(
                        product: product,
                        onAddToCart: () {
                          cartProvider.addToCart(productId: product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} ajouté au panier'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: ThemeConfig.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeConfig.primaryColor
              : ThemeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ThemeConfig.primaryColor,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : ThemeConfig.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
