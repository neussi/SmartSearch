import 'package:flutter/material.dart';
import 'package:smartsearch/config/theme_config.dart';

/// Modern Bottom Navigation Bar avec animations fluides
/// Design blanc & orange, super professionnel et dynamique
class ModernBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<ModernBottomNav> createState() => _ModernBottomNavState();
}

class _ModernBottomNavState extends State<ModernBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _slideAnimations;

  final List<NavItem> _items = [
    NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil'),
    NavItem(icon: Icons.search_outlined, activeIcon: Icons.search, label: 'Recherche'),
    NavItem(icon: Icons.favorite_border, activeIcon: Icons.favorite, label: 'Favoris'),
    NavItem(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag, label: 'Panier'),
    NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Paramètres'),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers
        .map((controller) => Tween<double>(begin: 1.0, end: 1.15).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ),)
        .toList();

    _slideAnimations = _controllers
        .map((controller) => Tween<double>(begin: 0.0, end: -4.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ),)
        .toList();

    _controllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(ModernBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == widget.currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBuilder(
                    animation: _controllers[index],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimations[index].value),
                        child: Transform.scale(
                          scale: _scaleAnimations[index].value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? ThemeConfig.primaryColor.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon avec animation
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isActive ? item.activeIcon : item.icon,
                                    key: ValueKey(isActive),
                                    color: isActive
                                        ? ThemeConfig.primaryColor
                                        : ThemeConfig.textSecondaryColor,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Label avec animation
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: isActive ? 12 : 11,
                                    fontWeight:
                                        isActive ? FontWeight.w700 : FontWeight.w500,
                                    color: isActive
                                        ? ThemeConfig.primaryColor
                                        : ThemeConfig.textSecondaryColor,
                                  ),
                                  child: Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Indicateur actif (point orange)
                                const SizedBox(height: 4),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 4,
                                  width: isActive ? 24 : 0,
                                  decoration: BoxDecoration(
                                    color: ThemeConfig.primaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
