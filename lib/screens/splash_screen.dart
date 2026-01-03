import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/providers/auth_provider.dart';
import 'package:smartsearch/widgets/animated_gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimations();
    _navigateToHome();
  }

  void _startAnimations() {
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
    _rotateController.repeat();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize();

      if (mounted) {
        if (authProvider.isAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: RotationTransition(
                    turns: _rotateAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        size: 80,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: const [
                      Text(
                        'SmartSearch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Recherche Intelligente',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
