import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/providers/search_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/product_card.dart';
import 'package:smartsearch/config/theme_config.dart';

class TextSearchScreen extends StatefulWidget {
  const TextSearchScreen({super.key});

  @override
  State<TextSearchScreen> createState() => _TextSearchScreenState();
}

class _TextSearchScreenState extends State<TextSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        context.read<SearchProvider>().searchByText(query: query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
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
          'Recherche Textuelle',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ThemeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      color: ThemeConfig.textPrimaryColor,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher des produits...',
                      hintStyle: TextStyle(
                        color: ThemeConfig.textSecondaryColor.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: ThemeConfig.primaryColor,
                        size: 24,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: ThemeConfig.textSecondaryColor,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                searchProvider.clearResults();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                if (searchProvider.searchHistory.isNotEmpty &&
                    searchProvider.lastSearchResult == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recherches récentes',
                              style: TextStyle(
                                color: ThemeConfig.textPrimaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                searchProvider.clearHistory();
                              },
                              child: const Text(
                                'Effacer',
                                style: TextStyle(color: ThemeConfig.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: searchProvider.searchHistory
                              .take(5)
                              .where((result) => result.query != null)
                              .map((result) => _HistoryChip(
                                    query: result.query!,
                                    onTap: () {
                                      _searchController.text = result.query!;
                                      _onSearchChanged(result.query!);
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (searchProvider.isLoading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeConfig.primaryColor,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Recherche en cours...',
                            style: TextStyle(
                              color: ThemeConfig.textSecondaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (searchProvider.errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: ThemeConfig.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ThemeConfig.errorColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: ThemeConfig.errorColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchProvider.errorMessage!,
                              style: const TextStyle(
                                color: ThemeConfig.textPrimaryColor,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (searchProvider.lastSearchResult != null)
                  Expanded(
                    child: searchProvider.lastSearchResult!.products.isEmpty
                        ? Center(
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
                                    Icons.search_off,
                                    size: 60,
                                    color: ThemeConfig.textSecondaryColor,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aucun résultat trouvé',
                                    style: TextStyle(
                                      color: ThemeConfig.textPrimaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Essayez une autre recherche',
                                    style: TextStyle(
                                      color: ThemeConfig.textSecondaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount:
                                searchProvider.lastSearchResult!.products.length,
                            itemBuilder: (context, index) {
                              final product =
                                  searchProvider.lastSearchResult!.products[index];
                              return AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  final animation = Tween<double>(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _animationController,
                                      curve: Interval(
                                        (index * 0.1).clamp(0.0, 1.0),
                                        ((index + 1) * 0.1).clamp(0.0, 1.0),
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                  );

                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.3),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: ProductCard(
                                        product: product,
                                        onAddToCart: () {
                                          cartProvider.addToCart(
                                            productId: product.id,
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${product.name} ajouté au panier',
                                              ),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: ThemeConfig.primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(24),
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
                              Icons.search,
                              size: 60,
                              color: ThemeConfig.primaryColor,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Recherchez des produits',
                              style: TextStyle(
                                color: ThemeConfig.textPrimaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Entrez au moins 2 caractères',
                              style: TextStyle(
                                color: ThemeConfig.textSecondaryColor,
                                fontSize: 13,
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
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const _HistoryChip({
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history,
              size: 16,
              color: ThemeConfig.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              query,
              style: const TextStyle(
                color: ThemeConfig.textPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
