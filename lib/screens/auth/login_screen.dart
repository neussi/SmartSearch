import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/providers/auth_provider.dart';
import 'package:smartsearch/widgets/animated_gradient_background.dart';
import 'package:smartsearch/widgets/glassmorphic_card.dart';
import 'package:smartsearch/widgets/custom_text_field.dart';
import 'package:smartsearch/widgets/animated_button.dart';
import 'package:smartsearch/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else if (mounted && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedGradientBackground(
        colors: const [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFFf093fb),
          Color(0xFF4facfe),
        ],
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.shopping_bag,
                                size: 60,
                                color: Color(0xFF667eea),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Bienvenue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Connectez-vous pour continuer',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 50),
                      GlassmorphicCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'votreemail@example.com',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.email),
                                validator: Validators.validateEmail,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: _passwordController,
                                label: 'Mot de passe',
                                hint: '••••••••',
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: Validators.validatePassword,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Mot de passe oublié?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              AnimatedButton(
                                text: 'Se Connecter',
                                icon: Icons.login,
                                isLoading: authProvider.isLoading,
                                onPressed: _login,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Pas encore de compte?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                            child: const Text(
                              'S\'inscrire',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                        },
                        child: const Text(
                          'Continuer sans compte',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
