import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/providers/search_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/animated_gradient_background.dart';
import 'package:smartsearch/widgets/glassmorphic_card.dart';
import 'package:smartsearch/widgets/product_card.dart';
import 'package:smartsearch/widgets/custom_text_field.dart';
import 'package:smartsearch/widgets/loading_widget.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recherche Textuelle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedGradientBackground(
        colors: const [
          Color(0xFF4facfe),
          Color(0xFF00f2fe),
          Color(0xFF43e97b),
          Color(0xFF38f9d7),
        ],
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Hero(
                    tag: 'search_bar',
                    child: Material(
                      color: Colors.transparent,
                      child: CustomTextField(
                        controller: _searchController,
                        hint: 'Rechercher des produits...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  searchProvider.clearResults();
                                },
                              )
                            : null,
                        onChanged: _onSearchChanged,
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
                                color: Colors.white,
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
                                style: TextStyle(color: Colors.white70),
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
                  const Expanded(
                    child: LoadingWidget(message: 'Recherche en cours...'),
                  )
                else if (searchProvider.errorMessage != null)
                  Expanded(
                    child: Center(
                      child: GlassmorphicCard(
                        margin: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchProvider.errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
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
                            child: GlassmorphicCard(
                              margin: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aucun résultat trouvé',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Essayez une autre recherche',
                                    style: TextStyle(
                                      color: Colors.white70,
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
                                              backgroundColor:
                                                  const Color(0xFF4facfe),
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
                      child: GlassmorphicCard(
                        margin: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Recherchez des produits',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Entrez au moins 2 caractères',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              query,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
