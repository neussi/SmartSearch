import 'package:flutter/material.dart';

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
        // return MaterialPageRoute(builder: (_) => const SplashScreen());
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implement SplashScreen
        );

      case home:
        // return MaterialPageRoute(builder: (_) => const HomeScreen());
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implement HomeScreen
        );

      case login:
        // return MaterialPageRoute(builder: (_) => const LoginScreen());
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implement LoginScreen
        );

      case register:
        // return MaterialPageRoute(builder: (_) => const RegisterScreen());
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implement RegisterScreen
        );

      case textSearch:
        // return MaterialPageRoute(builder: (_) => const TextSearchScreen());
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implement TextSearchScreen
        );

      case imageSearch:
        // return MaterialPageRoute(builder: (_) => const ImageSearchScreen());
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implement ImageSearchScreen
        );

      case productDetail:
        // final args = settings.arguments as Map<String, dynamic>;
        // return MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: args['id']));
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implement ProductDetailScreen
        );

      case productList:
        // return MaterialPageRoute(builder: (_) => const ProductListScreen());
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implement ProductListScreen
        );

      case cart:
        // return MaterialPageRoute(builder: (_) => const CartScreen());
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implement CartScreen
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
