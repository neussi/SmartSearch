import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/providers/product_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/animated_gradient_background.dart';
import 'package:smartsearch/widgets/glassmorphic_card.dart';
import 'package:smartsearch/widgets/product_card.dart';
import 'package:smartsearch/widgets/loading_widget.dart';

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
      builder: (context) => GlassmorphicCard(
        borderRadius: 30,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtres',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fourchette de Prix',
              style: TextStyle(
                color: Colors.white,
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
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.3),
              onChanged: (values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
            ),
            Text(
              '${_minPrice.toStringAsFixed(0)} - ${_maxPrice.toStringAsFixed(0)} FCFA',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text(
                'Produits en promotion uniquement',
                style: TextStyle(color: Colors.white),
              ),
              value: _showDiscountsOnly,
              activeColor: Colors.white,
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
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _minPrice = 0;
                        _maxPrice = 1000000;
                        _showDiscountsOnly = false;
                        _selectedCategory = null;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.3),
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
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Appliquer',
                      style: TextStyle(color: Color(0xFF667eea)),
                    ),
                  ),
                ),
              ],
            ),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tous les Produits',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        colors: const [
          Color(0xFF30cfd0),
          Color(0xFF330867),
          Color(0xFF667eea),
          Color(0xFF764ba2),
        ],
        child: SafeArea(
          child: Column(
            children: [
              if (productProvider.categories.isNotEmpty)
                Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
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
                    child: GlassmorphicCard(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 60,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun produit trouvé',
                            style: TextStyle(
                              color: Colors.white,
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
                                backgroundColor: const Color(0xFF30cfd0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Colors.white, Colors.white],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(isSelected ? 1.0 : 0.3),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF667eea) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
