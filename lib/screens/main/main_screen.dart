import 'package:flutter/material.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/screens/home/home_screen.dart';
import 'package:smartsearch/screens/search/text_search_screen.dart';
import 'package:smartsearch/screens/favorites/favorites_screen.dart';
import 'package:smartsearch/screens/cart/cart_screen.dart';
import 'package:smartsearch/screens/settings/professional_settings_screen.dart';
import 'package:smartsearch/widgets/modern_bottom_nav.dart';

/// Écran principal avec Bottom Navigation Bar
/// Design blanc & orange, navigation fluide entre les pages
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TextSearchScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfessionalSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
