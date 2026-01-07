import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/providers/search_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/product_card.dart';
import 'package:smartsearch/config/theme_config.dart';

class CombinedSearchScreen extends StatefulWidget {
  const CombinedSearchScreen({super.key});

  @override
  State<CombinedSearchScreen> createState() => _CombinedSearchScreenState();
}

class _CombinedSearchScreenState extends State<CombinedSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: ThemeConfig.errorColor,
          ),
        );
      }
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    if (query.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un texte ou sélectionner une image'),
          backgroundColor: ThemeConfig.warningColor,
        ),
      );
      return;
    }

    if (_selectedImage != null && query.isNotEmpty) {
      // Recherche combinée - TODO: Implémenter searchCombined dans SearchProvider
      // Pour l'instant, on fait une recherche par image
      context.read<SearchProvider>().searchByImage(
            imageFile: _selectedImage!,
          );
      // Note: La recherche combinée nécessite l'implémentation de la méthode
      // searchCombined(query: String, imageFile: File) dans SearchProvider
    } else if (_selectedImage != null) {
      // Recherche par image uniquement
      context.read<SearchProvider>().searchByImage(
            imageFile: _selectedImage!,
          );
    } else {
      // Recherche par texte uniquement
      context.read<SearchProvider>().searchByText(query: query);
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
          'Recherche Combinée',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          if (_selectedImage != null || _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: ThemeConfig.primaryColor),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _searchController.clear();
                });
                searchProvider.clearResults();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Champ de recherche texte
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              // Section image
              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: ThemeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: ThemeConfig.primaryColor,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Photo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ThemeConfig.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: ThemeConfig.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galerie'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ThemeConfig.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: ThemeConfig.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Bouton de recherche
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Rechercher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Résultats
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
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '${searchProvider.lastSearchResult!.totalResults} produits trouvés',
                                style: const TextStyle(
                                  color: ThemeConfig.textPrimaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: GridView.builder(
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
                                  return ProductCard(
                                    product: product,
                                    onAddToCart: () {
                                      cartProvider.addToCart(
                                        productId: product.id,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${product.name} ajouté au panier',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: ThemeConfig.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                )
              else
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(40),
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
                            Icons.manage_search,
                            size: 80,
                            color: ThemeConfig.primaryColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Recherche Combinée',
                            style: TextStyle(
                              color: ThemeConfig.textPrimaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Combinez texte et image pour des\nrésultats plus précis',
                            style: TextStyle(
                              color: ThemeConfig.textSecondaryColor,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
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
