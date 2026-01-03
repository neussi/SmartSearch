import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/providers/auth_provider.dart';
import 'package:smartsearch/providers/product_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/widgets/animated_gradient_background.dart';
import 'package:smartsearch/widgets/glassmorphic_card.dart';
import 'package:smartsearch/widgets/product_card.dart';
import 'package:smartsearch/widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<ProductProvider>().loadCategories();
      context.read<CartProvider>().loadCart();
    });
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: _scrollOffset > 50
                ? const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  )
                : null,
            boxShadow: _scrollOffset > 50
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SmartSearch',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                if (authProvider.user != null)
                  Text(
                    'Bonjour, ${authProvider.user!.name ?? "Utilisateur"}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.cart);
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cartProvider.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  if (authProvider.isAuthenticated) {
                    _showProfileBottomSheet(context);
                  } else {
                    Navigator.pushNamed(context, AppRoutes.login);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: AnimatedGradientBackground(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassmorphicCard(
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.textSearch);
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher un produit...',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.imageSearch);
                            },
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Catégories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (productProvider.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: productProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = productProvider.categories[index];
                      return _CategoryItem(
                        category: category.name,
                        icon: Icons.category,
                        index: index,
                        onTap: () {
                          productProvider.loadProducts(category: category.id);
                        },
                      );
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      'Produits Populaires',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.productList);
                      },
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (productProvider.isLoading)
              const SliverToBoxAdapter(
                child: LoadingWidget(message: 'Chargement des produits...'),
              )
            else if (productProvider.products.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'Aucun produit disponible',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = productProvider.products[index];
                      return ProductCard(
                        product: product,
                        onAddToCart: () {
                          cartProvider.addToCart(productId: product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} ajouté au panier'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF667eea),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: productProvider.products.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showProfileBottomSheet(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicCard(
        borderRadius: 30,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF667eea),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.user?.name ?? 'Utilisateur',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              authProvider.user?.email ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                authProvider.logout();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final String category;
  final IconData icon;
  final int index;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.icon,
    required this.index,
    required this.onTap,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
    ];

    final gradient = colors[widget.index % colors.length];

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(
                widget.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
