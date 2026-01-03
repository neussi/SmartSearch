import 'package:flutter/material.dart';
import 'package:smartsearch/screens/splash_screen.dart';
import 'package:smartsearch/screens/home/home_screen.dart';
import 'package:smartsearch/screens/auth/login_screen.dart';
import 'package:smartsearch/screens/auth/register_screen.dart';
import 'package:smartsearch/screens/search/text_search_screen.dart';
import 'package:smartsearch/screens/search/image_search_screen.dart';
import 'package:smartsearch/screens/product/product_detail_screen.dart';
import 'package:smartsearch/screens/product/product_list_screen.dart';
import 'package:smartsearch/screens/cart/cart_screen.dart';

/// Configuration des routes de navigation
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String textSearch = '/search/text';
  static const String imageSearch = '/search/image';
  static const String productDetail = '/product/detail';
  static const String productList = '/product/list';
  static const String cart = '/cart';
  static const String profile = '/profile';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case textSearch:
        return MaterialPageRoute(
          builder: (_) => const TextSearchScreen(),
        );

      case imageSearch:
        return MaterialPageRoute(
          builder: (_) => const ImageSearchScreen(),
        );

      case productDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: args['id']),
        );

      case productList:
        return MaterialPageRoute(
          builder: (_) => const ProductListScreen(),
        );

      case cart:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} non trouvée'),
            ),
          ),
        );
    }
  }
}
