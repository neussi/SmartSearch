import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/providers/auth_provider.dart';
import 'package:smartsearch/widgets/animated_gradient_background.dart';
import 'package:smartsearch/widgets/glassmorphic_card.dart';
import 'package:smartsearch/widgets/custom_text_field.dart';
import 'package:smartsearch/widgets/animated_button.dart';
import 'package:smartsearch/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
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

    return Scaffold(
      body: AnimatedGradientBackground(
        colors: const [
          Color(0xFF4facfe),
          Color(0xFF00f2fe),
          Color(0xFF43e97b),
          Color(0xFF38f9d7),
        ],
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
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
                                    padding: const EdgeInsets.all(20),
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
                                      Icons.person_add,
                                      size: 50,
                                      color: Color(0xFF4facfe),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Créer un Compte',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Rejoignez SmartSearch aujourd\'hui',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 40),
                            GlassmorphicCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: _nameController,
                                      label: 'Nom complet',
                                      hint: 'John Doe',
                                      prefixIcon: const Icon(Icons.person),
                                      validator: Validators.validateName,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      hint: 'votreemail@example.com',
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: const Icon(Icons.email),
                                      validator: Validators.validateEmail,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _phoneController,
                                      label: 'Téléphone (optionnel)',
                                      hint: '+237 6XX XXX XXX',
                                      keyboardType: TextInputType.phone,
                                      prefixIcon: const Icon(Icons.phone),
                                      validator: Validators.validatePhone,
                                    ),
                                    const SizedBox(height: 16),
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
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _confirmPasswordController,
                                      label: 'Confirmer le mot de passe',
                                      hint: '••••••••',
                                      obscureText: _obscureConfirmPassword,
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      validator: (value) =>
                                          Validators.validateConfirmPassword(
                                        value,
                                        _passwordController.text,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    AnimatedButton(
                                      text: 'S\'inscrire',
                                      icon: Icons.arrow_forward,
                                      isLoading: authProvider.isLoading,
                                      onPressed: _register,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Déjà un compte?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Se Connecter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
