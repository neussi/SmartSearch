import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/providers/search_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/product_card.dart';
import 'package:smartsearch/config/theme_config.dart';

/// CombinedSearchScreen - Recherche multimodale (texte + image)
class CombinedSearchScreen extends StatefulWidget {
  const CombinedSearchScreen({super.key});

  @override
  State<CombinedSearchScreen> createState() => _CombinedSearchScreenState();
}

class _CombinedSearchScreenState extends State<CombinedSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _textWeight = 0.6;
  double _imageWeight = 0.4;

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
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: ThemeConfig.errorColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    if (query.isEmpty && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un texte ou sélectionner une image'),
          backgroundColor: ThemeConfig.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedImageBytes != null && query.isNotEmpty) {
      // Recherche multimodale
      context.read<SearchProvider>().searchMultimodal(
            textQuery: query,
            imageBytes: _selectedImageBytes!,
            fileName: _selectedImageName!,
            textWeight: _textWeight,
            imageWeight: _imageWeight,
          );
    } else if (_selectedImageBytes != null) {
      // Recherche par image uniquement
      context.read<SearchProvider>().searchByImage(
            imageBytes: _selectedImageBytes!,
            fileName: _selectedImageName!,
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
          'Recherche Multimodale',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          if (_selectedImageBytes != null || _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: ThemeConfig.primaryColor),
              onPressed: () {
                setState(() {
                  _selectedImageBytes = null;
                  _selectedImageName = null;
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barre de recherche textuelle
                      Container(
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
                          decoration: InputDecoration(
                            hintText: 'Décrivez le produit recherché...',
                            hintStyle: const TextStyle(
                              color: ThemeConfig.textSecondaryColor,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: ThemeConfig.primaryColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: const TextStyle(
                            color: ThemeConfig.textPrimaryColor,
                            fontSize: 16,
                          ),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section image
                      const Text(
                        'Image de référence',
                        style: TextStyle(
                          color: ThemeConfig.textPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (_selectedImageBytes != null)
                        Container(
                          decoration: BoxDecoration(
                            color: ThemeConfig.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.memory(
                                  _selectedImageBytes!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedImageBytes = null;
                                          _selectedImageName = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Supprimer'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: ThemeConfig.errorColor,
                                        side: const BorderSide(
                                          color: ThemeConfig.errorColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            if (!kIsWeb)
                              OutlinedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Prendre une Photo'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ThemeConfig.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(
                                    color: ThemeConfig.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            if (!kIsWeb) const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: Text(
                                kIsWeb ? 'Choisir une Image' : 'Choisir depuis la Galerie',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ThemeConfig.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: ThemeConfig.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Poids de recherche (si les deux sont présents)
                      if (_selectedImageBytes != null && _searchController.text.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Pondération de la recherche',
                          style: TextStyle(
                            color: ThemeConfig.textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ThemeConfig.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Texte',
                                    style: TextStyle(
                                      color: ThemeConfig.textPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${(_textWeight * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: ThemeConfig.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _textWeight,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                activeColor: ThemeConfig.primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _textWeight = value;
                                    _imageWeight = 1.0 - value;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Image',
                                    style: TextStyle(
                                      color: ThemeConfig.textPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${(_imageWeight * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: ThemeConfig.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _imageWeight,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                activeColor: ThemeConfig.primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _imageWeight = value;
                                    _textWeight = 1.0 - value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Bouton de recherche
                      SizedBox(
                        width: double.infinity,
                        child: Container(
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
                          child: ElevatedButton.icon(
                            onPressed: searchProvider.isLoading ? null : _performSearch,
                            icon: searchProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.search),
                            label: Text(
                              searchProvider.isLoading ? 'Recherche...' : 'Rechercher',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Résultats
                      if (searchProvider.errorMessage != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: ThemeConfig.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ThemeConfig.errorColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: ThemeConfig.errorColor,
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  searchProvider.errorMessage!,
                                  style: const TextStyle(
                                    color: ThemeConfig.textPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (searchProvider.lastSearchResult != null &&
                          searchProvider.lastSearchResult!.products.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          '${searchProvider.lastSearchResult!.totalResults} résultats',
                          style: const TextStyle(
                            color: ThemeConfig.textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: searchProvider.lastSearchResult!.products.length,
                          itemBuilder: (context, index) {
                            final product =
                                searchProvider.lastSearchResult!.products[index];
                            return ProductCard(
                              product: product,
                              onAddToCart: () {
                                cartProvider.addToCart(productId: product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} ajouté au panier'),
                                    backgroundColor: ThemeConfig.primaryColor,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ],
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
