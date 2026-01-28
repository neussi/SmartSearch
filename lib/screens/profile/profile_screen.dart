import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/providers/auth_provider.dart';
import 'package:smartsearch/providers/cart_provider.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/config/routes.dart';

/// Page profil simple - Design blanc & orange
class ProfileScreenSimple extends StatefulWidget {
  const ProfileScreenSimple({super.key});

  @override
  State<ProfileScreenSimple> createState() => _ProfileScreenSimpleState();
}

class _ProfileScreenSimpleState extends State<ProfileScreenSimple>
    with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final user = authProvider.user;

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
          'Mon Profil',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: ThemeConfig.primaryColor),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar et infos
              Container(
                padding: const EdgeInsets.all(24),
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
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: ThemeConfig.primaryColor,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: ThemeConfig.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Utilisateur',
                      style: const TextStyle(
                        color: ThemeConfig.textPrimaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'email@example.com',
                      style: const TextStyle(
                        color: ThemeConfig.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistiques
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ThemeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistiques',
                      style: TextStyle(
                        color: ThemeConfig.textPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.shopping_bag_outlined,
                          value: '47',
                          label: 'Achats',
                        ),
                        _buildStatItem(
                          icon: Icons.favorite_outline,
                          value: '12',
                          label: 'Favoris',
                        ),
                        _buildStatItem(
                          icon: Icons.shopping_cart_outlined,
                          value: '${cartProvider.itemCount}',
                          label: 'Panier',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu
              Container(
                decoration: BoxDecoration(
                  color: ThemeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.favorite_outline,
                      title: 'Mes Favoris',
                      onTap: () {
                        Navigator.pushNamed(context, '/favorites');
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Mes Paniers',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.multiCart);
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.history,
                      title: 'Historique',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Déconnexion',
                      onTap: () => _showLogoutDialog(authProvider),
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: ThemeConfig.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: ThemeConfig.textSecondaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? ThemeConfig.errorColor.withValues(alpha: 0.1)
              : ThemeConfig.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? ThemeConfig.errorColor : ThemeConfig.primaryColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? ThemeConfig.errorColor : ThemeConfig.textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDestructive ? ThemeConfig.errorColor : ThemeConfig.textSecondaryColor,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: ThemeConfig.surfaceColor,
        title: const Text(
          'Déconnexion',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter?',
          style: TextStyle(
            color: ThemeConfig.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: ThemeConfig.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
