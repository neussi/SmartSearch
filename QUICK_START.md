# Guide de Démarrage Rapide - SmartSearch

## Prérequis

- Flutter SDK 3.0+
- Android Studio ou VS Code
- Un émulateur Android/iOS ou un appareil physique

## Installation en 3 Étapes

### 1. Installer les Dépendances

```bash
cd SmartSearch
flutter pub get
```

### 2. Configurer l'URL du Backend

Ouvrir `lib/config/api_config.dart` et modifier :

```dart
static const String baseUrl = 'http://VOTRE_IP:8080/api';
```

**Pour trouver votre IP locale** :
- Windows : `ipconfig`
- Linux/Mac : `ifconfig | grep inet`

**URLs selon le contexte** :
- Émulateur Android : `http://10.0.2.2:8080/api`
- Émulateur iOS : `http://localhost:8080/api`
- Appareil réel : `http://VOTRE_IP_LOCALE:8080/api`

### 3. Lancer l'Application

```bash
flutter run
```

## Commandes Utiles

### Développement

```bash
# Lancer l'app
flutter run

# Lancer en mode debug avec hot reload
flutter run --debug

# Lancer en mode release (performances optimales)
flutter run --release

# Analyser le code
flutter analyze

# Formater le code
dart format .

# Nettoyer le projet
flutter clean
flutter pub get
```

### Build

```bash
# Build APK debug
flutter build apk --debug

# Build APK release
flutter build apk --release

# Build App Bundle (pour Play Store)
flutter build appbundle --release

# Build iOS (sur macOS uniquement)
flutter build ios --release
```

### Tests

```bash
# Lancer tous les tests
flutter test

# Tester avec coverage
flutter test --coverage

# Tester un fichier spécifique
flutter test test/widget_test.dart
```

## Résolution de Problèmes

### Problème : Gradle Build Failed

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Problème : Packages Non Trouvés

```bash
flutter clean
rm -rf .dart_tool/
rm pubspec.lock
flutter pub get
```

### Problème : Hot Reload Ne Fonctionne Pas

Appuyer sur `R` dans le terminal pour hot restart complet.

### Problème : Erreur de Version

```bash
flutter upgrade
flutter doctor
```

## Vérification de l'Installation

```bash
# Vérifier que Flutter est bien installé
flutter doctor

# Vérifier les appareils disponibles
flutter devices

# Vérifier la version
flutter --version
```

## Structure des Écrans

L'application contient ces écrans principaux :

1. **Splash** - Animation de démarrage
2. **Home** - Page d'accueil avec catégories et produits
3. **Recherche Texte** - Recherche par mots-clés
4. **Recherche Image** - Recherche par photo
5. **Détail Produit** - Informations complètes d'un produit
6. **Liste Produits** - Tous les produits avec filtres
7. **Panier** - Gestion du panier d'achat
8. **Connexion** - Authentification utilisateur
9. **Inscription** - Création de compte

## Fonctionnalités Principales

- Recherche multimodale (texte + image)
- Gestion du panier
- Authentification JWT
- Animations fluides partout
- Design glassmorphique moderne
- Gradients animés
- Transitions Hero
- Micro-interactions

## Navigation dans l'App

### Depuis l'Écran d'Accueil

- **Barre de recherche** → Recherche textuelle
- **Icône caméra** → Recherche par image
- **Catégories** → Filtrer par catégorie
- **Voir tout** → Liste complète des produits
- **Produit** → Détail du produit
- **Icône panier** → Voir le panier
- **Icône profil** → Profil/Connexion

### Raccourcis Clavier (en mode debug)

- `r` : Hot reload
- `R` : Hot restart
- `v` : Ouvrir Flutter DevTools
- `q` : Quitter l'app

## Personnalisation

### Changer les Couleurs

Modifier `lib/config/theme_config.dart` :

```dart
static const Color primaryColor = Color(0xFF6200EE); // Votre couleur
```

### Changer les Gradients

Dans chaque écran, modifier le widget `AnimatedGradientBackground` :

```dart
AnimatedGradientBackground(
  colors: const [
    Color(0xFFVotreCouleur1),
    Color(0xFFVotreCouleur2),
  ],
  child: ...
)
```

### Ajouter un Nouvel Écran

1. Créer le fichier dans `lib/screens/`
2. Ajouter la route dans `lib/config/routes.dart`
3. Utiliser `Navigator.pushNamed(context, '/votre-route')`

## Débogage

### Activer les Logs

Dans `lib/services/api_service.dart`, décommenter :

```dart
print('POST ${ApiConfig.baseUrl}$endpoint');
print('Response: ${response.statusCode}');
```

### Inspecter l'UI

```bash
flutter run
# Appuyer sur 'v' pour ouvrir DevTools
```

## Performance

L'application est optimisée pour :
- 60 FPS sur toutes les animations
- Chargement rapide des images avec cache
- Debounce sur la recherche
- Lazy loading des listes

## Base de Données

L'app utilise :
- **Flutter Secure Storage** : Pour les tokens JWT
- **Shared Preferences** : Pour les préférences
- **Cache** : Pour les images réseau

## Sécurité

- Tokens JWT sécurisés
- Validation des entrées
- HTTPS en production
- Pas de données sensibles en clair

## Support

Pour toute question :
1. Vérifier la documentation dans `docs/`
2. Consulter `APPLICATION_COMPLETE.md`
3. Voir le `README.md` principal

## Checklist Avant de Déployer

- [ ] Tester sur plusieurs appareils
- [ ] Vérifier tous les écrans
- [ ] Tester la recherche
- [ ] Tester le panier
- [ ] Tester l'authentification
- [ ] Vérifier les animations
- [ ] Analyser le code : `flutter analyze`
- [ ] Tester en mode release
- [ ] Vérifier les permissions
- [ ] Tester la connexion réseau

## Prochaines Étapes

1. Connecter au backend réel
2. Tester avec de vraies données
3. Ajuster les animations si besoin
4. Ajouter des fonctionnalités supplémentaires
5. Préparer pour le déploiement

Bonne chance avec SmartSearch!
