import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/providers/auth_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/providers/multi_cart_provider.dart';
import 'package:smartsearch/providers/product_provider.dart';
import 'package:smartsearch/providers/search_provider.dart';
import 'package:smartsearch/providers/favorites_provider.dart';
import 'package:smartsearch/services/api_service.dart';
import 'package:smartsearch/services/local_auth_service.dart';
import 'package:smartsearch/services/local_cart_service.dart';
import 'package:smartsearch/services/multi_cart_service.dart';
import 'package:smartsearch/services/product_service.dart';
import 'package:smartsearch/services/search_service.dart';
import 'package:smartsearch/services/favorites_service.dart';

void main() {
  runApp(const SmartSearchApp());
}

class SmartSearchApp extends StatelessWidget {
  const SmartSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialisation des services
    final apiService = ApiService();
    final localAuthService = LocalAuthService();
    final localCartService = LocalCartService();
    final multiCartService = MultiCartService();
    final favoritesService = FavoritesService();
    final productService = ProductService(apiService: apiService);
    final searchService = SearchService(apiService: apiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: localAuthService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productService: productService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(searchService: searchService),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(
            cartService: localCartService,
            productService: productService,
          )..loadCart(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(
            favoritesService: favoritesService,
            productService: productService,
          )..loadFavorites(),
        ),
        ChangeNotifierProvider(
          create: (_) => MultiCartProvider(
            cartService: multiCartService,
            productService: productService,
          )..loadCarts(),
        ),
      ],
      child: MaterialApp(
        title: 'SmartSearch',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
