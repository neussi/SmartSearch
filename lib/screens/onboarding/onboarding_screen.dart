import 'package:flutter/material.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/widgets/animated_gradient_background.dart';
import 'package:smartsearch/widgets/animated_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Recherche Intelligente',
      description:
          'Trouvez vos produits préférés en utilisant du texte ou des images',
      icon: Icons.search,
      gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
    ),
    OnboardingPage(
      title: 'Recherche Visuelle',
      description:
          'Prenez une photo et découvrez des produits similaires instantanément',
      icon: Icons.camera_alt,
      gradientColors: [const Color(0xFFfa709a), const Color(0xFFfee140)],
    ),
    OnboardingPage(
      title: 'Recherche Multimodale',
      description:
          'Combinez texte et image pour des résultats ultra-précis',
      icon: Icons.auto_awesome,
      gradientColors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    ),
    OnboardingPage(
      title: 'Achats Rapides',
      description:
          'Ajoutez au panier en un clic et commandez en toute simplicité',
      icon: Icons.shopping_bag,
      gradientColors: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        colors: _pages[_currentPage].gradientColors,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text(
                      'Passer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),
              _buildPageIndicator(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _currentPage == _pages.length - 1
                    ? AnimatedButton(
                        text: 'Commencer',
                        icon: Icons.arrow_forward,
                        onPressed: _skipOnboarding,
                        gradientColors: const [
                          Colors.white,
                          Colors.white,
                        ],
                      )
                    : AnimatedButton(
                        text: 'Suivant',
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        gradientColors: const [
                          Colors.white,
                          Colors.white,
                        ],
                      ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Icon(
                      page.icon,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    page.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    page.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}
