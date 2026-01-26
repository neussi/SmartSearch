import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/providers/search_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/product_card.dart';
import 'package:smartsearch/config/theme_config.dart';

/// ImageSearchScreen compatible web et mobile
class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen>
    with TickerProviderStateMixin {
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
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
        _searchByImage();
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

  Future<void> _searchByImage() async {
    if (_selectedImageBytes != null && _selectedImageName != null) {
      await context.read<SearchProvider>().searchByImage(
            imageBytes: _selectedImageBytes!,
            fileName: _selectedImageName!,
          );
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
          'Recherche par Image',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          if (_selectedImageBytes != null)
            IconButton(
              icon: const Icon(Icons.clear, color: ThemeConfig.primaryColor),
              onPressed: () {
                setState(() {
                  _selectedImageBytes = null;
                  _selectedImageName = null;
                });
                searchProvider.clearResults();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _selectedImageBytes == null
              ? _buildImagePicker()
              : _buildSearchResults(searchProvider, cartProvider),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: ThemeConfig.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Recherchez avec une Image',
              style: TextStyle(
                color: ThemeConfig.textPrimaryColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Prenez une photo ou sélectionnez-en une depuis votre galerie',
              style: TextStyle(
                color: ThemeConfig.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            if (!kIsWeb)
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
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Prendre une Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            if (!kIsWeb) const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: Text(kIsWeb ? 'Choisir une Image' : 'Choisir depuis la Galerie'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeConfig.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(color: ThemeConfig.primaryColor, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    SearchProvider searchProvider,
    CartProvider cartProvider,
  ) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeConfig.surfaceColor,
            borderRadius: BorderRadius.circular(20),
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
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.memory(
                  _selectedImageBytes!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedImageBytes = null;
                          _selectedImageName = null;
                        });
                        searchProvider.clearResults();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Nouvelle Image'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeConfig.primaryColor,
                        side: const BorderSide(color: ThemeConfig.primaryColor),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ThemeConfig.primaryColor,
                            ThemeConfig.primaryLightColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _searchByImage,
                        icon: const Icon(Icons.search),
                        label: const Text('Rechercher'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (searchProvider.isLoading)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeConfig.primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Analyse de l\'image...',
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
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: ThemeConfig.textSecondaryColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun produit similaire trouvé',
                            style: TextStyle(
                              color: ThemeConfig.textPrimaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
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
                          '${searchProvider.lastSearchResult!.totalResults} produits similaires',
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
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 400 + (index * 100),
                              ),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(
                                    opacity: value,
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
                                            margin: const EdgeInsets.all(16),
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
                      ),
                    ],
                  ),
          ),
      ],
    );
  }
}
