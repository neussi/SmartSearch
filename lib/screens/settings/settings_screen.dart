import 'package:flutter/material.dart';
import 'package:smartsearch/widgets/animated_gradient_background.dart';
import 'package:smartsearch/widgets/glassmorphic_card.dart';
import 'package:smartsearch/widgets/animated_toggle.dart';
import 'package:smartsearch/widgets/neumorphic_card.dart';
import 'package:smartsearch/widgets/tilt_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
bool _notificationsEnabled = true;
bool _darkModeEnabled = false;
bool _biometricsEnabled = true;
bool _autoPlayVideos = false;
bool _dataSaverMode = false;
double _textSearchWeight = 0.5;
  double _imageSearchWeight = 0.5;
  String _selectedLanguage = 'Français';
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedGradientBackground(
        colors: const [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFF30cfd0),
          Color(0xFF330867),
        ],
        child: SafeArea(
          child: FadeTransition(
            opacity: _controller,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Général'),
                  const SizedBox(height: 16),
                  _buildGeneralSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Notifications'),
                  const SizedBox(height: 16),
                  _buildNotificationsSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Recherche'),
                  const SizedBox(height: 16),
                  _buildSearchSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Sécurité'),
                  const SizedBox(height: 16),
                  _buildSecuritySection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Apparence'),
                  const SizedBox(height: 16),
                  _buildAppearanceSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('À Propos'),
                  const SizedBox(height: 16),
                  _buildAboutSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGeneralSection() {
    return TiltCard(
      child: NeumorphicCard(
        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.language,
              title: 'Langue',
              subtitle: _selectedLanguage,
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () => _showLanguagePicker(),
            ),
            const Divider(color: Colors.white24),
            _buildSettingItem(
              icon: Icons.location_on,
              title: 'Localisation',
              subtitle: 'Cameroun',
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ),
            const Divider(color: Colors.white24),
            _buildSettingItem(
              icon: Icons.data_usage,
              title: 'Mode Économie de Données',
              subtitle: 'Réduire la consommation de données',
              trailing: AnimatedToggle(
                value: _dataSaverMode,
                onChanged: (value) {
                  setState(() {
                    _dataSaverMode = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return TiltCard(
      maxTilt: 0.03,
      child: NeumorphicCard(
        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.notifications_active,
              title: 'Notifications Push',
              subtitle: 'Recevoir les notifications',
              trailing: AnimatedToggle(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColors: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
              ),
            ),
            const Divider(color: Colors.white24),
            _buildSettingItem(
              icon: Icons.local_offer,
              title: 'Promotions',
              subtitle: 'Notifications des offres spéciales',
              trailing: AnimatedToggle(
                value: true,
                onChanged: (value) {},
                activeColors: const [Color(0xFFfa709a), Color(0xFFfee140)],
              ),
            ),
            const Divider(color: Colors.white24),
            _buildSettingItem(
              icon: Icons.email,
              title: 'Emails',
              subtitle: 'Recevoir les newsletters',
              trailing: AnimatedToggle(
                value: false,
                onChanged: (value) {},
                activeColors: const [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return TiltCard(
      maxTilt: 0.03,
      child: NeumorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text(
            'Pondération de la Recherche Multimodale',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajustez l\'importance du texte vs l\'image',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.text_fields, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Poids Texte',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          '${(_textSearchWeight * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 20,
                        ),
                      ),
                      child: Slider(
                        value: _textSearchWeight,
                        onChanged: (value) {
                          setState(() {
                            _textSearchWeight = value;
                            _imageSearchWeight = 1 - value;
                          });
                        },
                        activeColor: const Color(0xFF4facfe),
                        inactiveColor: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.image, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Poids Image',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          '${(_imageSearchWeight * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 20,
                        ),
                      ),
                      child: Slider(
                        value: _imageSearchWeight,
                        onChanged: (value) {
                          setState(() {
                            _imageSearchWeight = value;
                            _textSearchWeight = 1 - value;
                          });
                        },
                        activeColor: const Color(0xFFfa709a),
                        inactiveColor: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return TiltCard(
      maxTilt: 0.03,
      child: NeumorphicCard(
        child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.fingerprint,
            title: 'Authentification Biométrique',
            subtitle: 'Utiliser l\'empreinte ou Face ID',
            trailing: AnimatedToggle(
              value: _biometricsEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricsEnabled = value;
                });
              },
              activeColors: const [Color(0xFF43e97b), Color(0xFF38f9d7)],
            ),
          ),
          const Divider(color: Colors.white24),
          _buildSettingItem(
            icon: Icons.lock,
            title: 'Changer le Mot de Passe',
            subtitle: 'Mettre à jour votre mot de passe',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ),
          const Divider(color: Colors.white24),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Confidentialité',
            subtitle: 'Gérer vos données personnelles',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return TiltCard(
      maxTilt: 0.03,
      child: NeumorphicCard(
        child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.dark_mode,
            title: 'Mode Sombre',
            subtitle: 'Thème sombre pour l\'interface',
            trailing: AnimatedToggle(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
              activeColors: const [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
          const Divider(color: Colors.white24),
          _buildSettingItem(
            icon: Icons.video_library,
            title: 'Lecture Auto des Vidéos',
            subtitle: 'Lire les vidéos automatiquement',
            trailing: AnimatedToggle(
              value: _autoPlayVideos,
              onChanged: (value) {
                setState(() {
                  _autoPlayVideos = value;
                });
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return TiltCard(
      maxTilt: 0.03,
      child: NeumorphicCard(
        child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.info,
            title: 'Version',
            subtitle: '1.0.0',
            trailing: Container(),
          ),
          const Divider(color: Colors.white24),
          _buildSettingItem(
            icon: Icons.article,
            title: 'Conditions d\'Utilisation',
            subtitle: 'Lire les CGU',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ),
          const Divider(color: Colors.white24),
          _buildSettingItem(
            icon: Icons.policy,
            title: 'Politique de Confidentialité',
            subtitle: 'Comment nous utilisons vos données',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ),
          const Divider(color: Colors.white24),
          _buildSettingItem(
            icon: Icons.code,
            title: 'Licences Open Source',
            subtitle: 'Voir les dépendances',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3 * value),
                      Colors.white.withValues(alpha: 0.1 * value),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.2 * value),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              trailing: trailing,
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicCard(
        borderRadius: 30,
        margin: const EdgeInsets.only(top: 100),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir la Langue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildLanguageOption('Français', 'FR'),
            _buildLanguageOption('English', 'EN'),
            _buildLanguageOption('Español', 'ES'),
            _buildLanguageOption('Deutsch', 'DE'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String code) {
    final isSelected = _selectedLanguage == language;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF43e97b).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          code,
          style: TextStyle(
            color: isSelected ? const Color(0xFF43e97b) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        language,
        style: TextStyle(
          color: isSelected ? const Color(0xFF43e97b) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF43e97b))
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }
}
