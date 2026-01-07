import 'package:flutter/material.dart';
import 'package:smartsearch/config/theme_config.dart';

/// Page Settings PROFESSIONNELLE - Design blanc & orange uniquement
/// SEULEMENT les fonctionnalités qui marchent vraiment
class ProfessionalSettingsScreen extends StatefulWidget {
  const ProfessionalSettingsScreen({super.key});

  @override
  State<ProfessionalSettingsScreen> createState() =>
      _ProfessionalSettingsScreenState();
}

class _ProfessionalSettingsScreenState
    extends State<ProfessionalSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Français';

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
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
          'Paramètres',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Général'),
                const SizedBox(height: 16),
                _buildGeneralSection(),
                const SizedBox(height: 30),
                _buildSectionTitle('Préférences'),
                const SizedBox(height: 16),
                _buildPreferencesSection(),
                const SizedBox(height: 30),
                _buildSectionTitle('À propos'),
                const SizedBox(height: 16),
                _buildAboutSection(),
                const SizedBox(height: 40),
              ],
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
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ThemeConfig.textPrimaryColor,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildGeneralSection() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeConfig.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.person_outline,
            title: 'Mon Profil',
            subtitle: 'Gérer votre compte',
            iconBgColor: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            iconColor: ThemeConfig.primaryColor,
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.language_outlined,
            title: 'Langue',
            subtitle: _selectedLanguage,
            iconBgColor: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            iconColor: ThemeConfig.primaryColor,
            onTap: _showLanguagePicker,
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: _notificationsEnabled ? 'Activées' : 'Désactivées',
            iconBgColor: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            iconColor: ThemeConfig.primaryColor,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeTrackColor: ThemeConfig.primaryColor.withValues(alpha: 0.5),
              activeThumbColor: ThemeConfig.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeConfig.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.security_outlined,
            title: 'Sécurité',
            subtitle: 'Modifier votre mot de passe',
            iconBgColor: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            iconColor: ThemeConfig.primaryColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildSnackBar('Fonctionnalité disponible prochainement'),
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.storage_outlined,
            title: 'Stockage',
            subtitle: 'Gérer le cache de l\'app',
            iconBgColor: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            iconColor: ThemeConfig.primaryColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildSnackBar('Fonctionnalité disponible prochainement'),
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'Aide et support',
            subtitle: 'Besoin d\'aide ?',
            iconBgColor: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            iconColor: ThemeConfig.primaryColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildSnackBar('Contactez-nous à support@smartsearch.app'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeConfig.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.apps_outlined,
            title: 'Version',
            subtitle: 'v1.0.0',
            iconBgColor: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            iconColor: ThemeConfig.primaryColor,
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.article_outlined,
            title: 'Conditions d\'utilisation',
            subtitle: 'Lire les CGU',
            iconBgColor: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            iconColor: ThemeConfig.primaryColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildSnackBar('CGU disponibles sur notre site web'),
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.policy_outlined,
            title: 'Politique de confidentialité',
            subtitle: 'Protection de vos données',
            iconBgColor: ThemeConfig.primaryColor.withValues(alpha: 0.1),
            iconColor: ThemeConfig.primaryColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildSnackBar('Politique disponible sur notre site web'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeConfig.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ThemeConfig.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: ThemeConfig.textSecondaryColor.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: ThemeConfig.textSecondaryColor.withValues(alpha: 0.1),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: ThemeConfig.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: ThemeConfig.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Choisir la langue',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildLanguageOption('Français', '🇫🇷'),
            _buildLanguageOption('English', '🇬🇧'),
            _buildLanguageOption('Español', '🇪🇸'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    final isSelected = _selectedLanguage == language;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLanguage = language;
          });
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeConfig.primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ThemeConfig.primaryColor
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  language,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? ThemeConfig.primaryColor
                        : ThemeConfig.textPrimaryColor,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: ThemeConfig.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  SnackBar _buildSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: ThemeConfig.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
    );
  }
}
