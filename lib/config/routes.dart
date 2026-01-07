import 'package:flutter/material.dart';
import 'package:smartsearch/screens/splash_screen.dart';
import 'package:smartsearch/screens/main/main_screen.dart';
import 'package:smartsearch/screens/auth/login_screen.dart';
import 'package:smartsearch/screens/auth/register_screen.dart';
import 'package:smartsearch/screens/search/text_search_screen.dart';
import 'package:smartsearch/screens/search/image_search_screen.dart';
import 'package:smartsearch/screens/search/combined_search_screen.dart';
import 'package:smartsearch/screens/product/product_detail_screen.dart';
import 'package:smartsearch/screens/product/product_list_screen.dart';
import 'package:smartsearch/screens/cart/cart_screen.dart';
import 'package:smartsearch/screens/profile/profile_screen.dart';
import 'package:smartsearch/screens/settings/professional_settings_screen.dart';
import 'package:smartsearch/screens/onboarding/onboarding_screen.dart';
import 'package:smartsearch/screens/favorites/favorites_screen.dart';
import 'package:smartsearch/widgets/app_tour_guide.dart';

/// Configuration des routes de navigation
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String textSearch = '/search/text';
  static const String imageSearch = '/search/image';
  static const String combinedSearch = '/search/combined';
  static const String productDetail = '/product/detail';
  static const String productList = '/product/list';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';
  static const String favorites = '/favorites';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const AppTourGuide(
            child: MainScreen(),
          ),
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

      case combinedSearch:
        return MaterialPageRoute(
          builder: (_) => const CombinedSearchScreen(),
        );

      case productDetail:
        final args = routeSettings.arguments as Map<String, dynamic>;
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

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreenSimple(),
        );

      case settings:
        return MaterialPageRoute(
          builder: (_) => const ProfessionalSettingsScreen(),
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case favorites:
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${routeSettings.name} non trouvée'),
            ),
          ),
        );
    }
  }
}
