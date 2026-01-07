import 'package:flutter/material.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Système de guidage au lancement de l'application
/// Tooltips et popups animés pour guider l'utilisateur
/// Design blanc & orange
class AppTourGuide extends StatefulWidget {
  final Widget child;

  const AppTourGuide({super.key, required this.child});

  @override
  State<AppTourGuide> createState() => _AppTourGuideState();
}

class _AppTourGuideState extends State<AppTourGuide> {
  bool _showTour = false;
  int _currentStep = 0;

  final List<TourStep> _steps = [
    TourStep(
      title: 'Bienvenue sur SmartSearch !',
      description:
          'Découvrez la recherche intelligente de produits avec texte et image.',
      icon: Icons.waving_hand,
    ),
    TourStep(
      title: 'Recherche Multimodale',
      description:
          'Recherchez des produits par texte ou prenez une photo pour trouver des articles similaires.',
      icon: Icons.camera_alt,
    ),
    TourStep(
      title: 'Panier et Favoris',
      description:
          'Ajoutez vos produits préférés au panier et sauvegardez-les dans vos favoris.',
      icon: Icons.favorite,
    ),
    TourStep(
      title: 'Commencez maintenant !',
      description:
          'Explorez notre catalogue et trouvez exactement ce que vous cherchez.',
      icon: Icons.rocket_launch,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTour = prefs.getBool('has_seen_tour') ?? false;

    if (!hasSeenTour) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _showTour = true;
        });
      }
    }
  }

  Future<void> _completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tour', true);
    setState(() {
      _showTour = false;
    });
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeTour();
    }
  }

  void _skipTour() {
    _completeTour();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showTour)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.75 * value),
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          builder: (context, scaleValue, child) {
                            return Transform.scale(
                              scale: scaleValue,
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: ThemeConfig.surfaceColor,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ThemeConfig.primaryColor
                                          .withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icon animé
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: ThemeConfig.primaryColor
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _steps[_currentStep].icon,
                                        size: 64,
                                        color: ThemeConfig.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Titre
                                    Text(
                                      _steps[_currentStep].title,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeConfig.textPrimaryColor,
                                        letterSpacing: -0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    // Description
                                    Text(
                                      _steps[_currentStep].description,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: ThemeConfig.textSecondaryColor,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32),
                                    // Indicateurs de progression
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        _steps.length,
                                        (index) => AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          width: index == _currentStep ? 32 : 8,
                                          height: 8,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: index == _currentStep
                                                ? ThemeConfig.primaryColor
                                                : ThemeConfig.textSecondaryColor
                                                    .withValues(alpha: 0.3),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    // Boutons
                                    Row(
                                      children: [
                                        if (_currentStep > 0)
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _skipTour,
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                side: BorderSide(
                                                  color: ThemeConfig
                                                      .textSecondaryColor
                                                      .withValues(alpha: 0.3),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Text(
                                                'Passer',
                                                style: TextStyle(
                                                  color: ThemeConfig
                                                      .textSecondaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (_currentStep > 0)
                                          const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _nextStep,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  ThemeConfig.primaryColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              _currentStep ==
                                                      _steps.length - 1
                                                  ? 'Commencer'
                                                  : 'Suivant',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class TourStep {
  final String title;
  final String description;
  final IconData icon;

  TourStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
