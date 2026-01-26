# Guide de Démarrage Rapide

Bienvenue dans le projet SmartSearch ! Ce guide vous aidera à démarrer rapidement.

## Prérequis

Avant de commencer, assurez-vous d'avoir :

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.0 ou supérieure)
- [Git](https://git-scm.com/downloads)
- Un IDE (VS Code, Android Studio, ou IntelliJ IDEA)
- Un compte GitHub

## Installation en 5 Minutes

### 1. Cloner le Projet

```bash
git clone https://github.com/neussi/SmartSearch.git
cd SmartSearch
```

### 2. Installer les Dépendances

```bash
flutter pub get
```

### 3. Vérifier l'Installation

```bash
flutter doctor
```

Assurez-vous que toutes les coches sont vertes (✓).

### 4. Lancer l'Application

```bash
# Connecter un émulateur ou un appareil
flutter devices

# Lancer l'app
flutter run
```

## Configuration de l'Environnement

### Configuration de l'API Backend

1. Ouvrir `lib/config/api_config.dart`
2. Modifier la `baseUrl` :

```dart
// Pour développement local (Android Emulator)
static const String baseUrl = 'http://10.0.2.2:8080/api';

// Pour développement local (iOS Simulator)
static const String baseUrl = 'http://localhost:8080/api';

// Pour développement local (Appareil réel sur le même réseau)
static const String baseUrl = 'http://VOTRE_IP_LOCALE:8080/api';
```

**Trouver votre IP locale :**

**Windows :**
```bash
ipconfig
```

**macOS/Linux :**
```bash
ifconfig | grep inet
```

### Extensions VS Code Recommandées

Installer les extensions suivantes :

1. **Flutter** (Dart-Code.flutter)
2. **Dart** (Dart-Code.dart-code)
3. **Prettier** (esbenp.prettier-vscode)
4. **GitLens** (eamodio.gitlens)
5. **Error Lens** (usernamehw.errorlens)

Configuration VS Code (`.vscode/settings.json`) :

```json
{
  "editor.formatOnSave": true,
  "dart.lineLength": 100,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [100],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

## Premier Développement

### Workflow Recommandé

1. **Créer une branche** :
```bash
git checkout -b feature/mon-premier-ecran
```

2. **Faire vos modifications** (par exemple, créer un écran)

3. **Tester** :
```bash
flutter analyze
flutter test
```

4. **Commit** :
```bash
git add .
git commit -m "feat: add my first screen"
```

5. **Push** :
```bash
git push origin feature/mon-premier-ecran
```

6. **Créer une Pull Request sur GitHub**

### Exemple : Créer un Premier Écran

Créons un écran simple de bienvenue.

**1. Créer le fichier** : `lib/screens/home/home_screen.dart`

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartSearch'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue sur SmartSearch!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigation vers la recherche
              },
              child: const Text('Commencer la recherche'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**2. Mettre à jour** `lib/config/routes.dart` :

```dart
case home:
  return MaterialPageRoute(
    builder: (_) => const HomeScreen(), // Remplacer Placeholder
  );
```

**3. Tester** :
```bash
flutter run
```

## Commandes Utiles

### Développement

```bash
# Hot reload (automatique en mode debug)
# Appuyez sur 'r' dans le terminal

# Hot restart
# Appuyez sur 'R' dans le terminal

# Ouvrir DevTools
# Appuyez sur 'v' dans le terminal
```

### Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (pour Play Store)
flutter build appbundle --release
```

### Tests

```bash
# Tous les tests
flutter test

# Un fichier spécifique
flutter test test/services/product_service_test.dart

# Avec coverage
flutter test --coverage
```

### Maintenance

```bash
# Nettoyer le projet
flutter clean

# Réinstaller les dépendances
flutter pub get

# Mettre à jour les dépendances
flutter pub upgrade

# Vérifier les packages obsolètes
flutter pub outdated
```

## Déboguer l'Application

### Méthode 1 : Print Statements

```dart
void loadProducts() async {
  print('Loading products...');
  final products = await service.getAllProducts();
  print('Loaded ${products.length} products');
}
```

### Méthode 2 : Breakpoints (VS Code)

1. Cliquer sur la marge gauche pour ajouter un breakpoint
2. Lancer en mode debug (F5)
3. L'exécution s'arrêtera au breakpoint

### Méthode 3 : Flutter DevTools

```bash
# Lancer l'app en mode debug
flutter run

# Dans le terminal, appuyer sur 'v' pour ouvrir DevTools
```

DevTools permet de :
- Inspecter le widget tree
- Analyser les performances
- Voir les logs réseau
- Profiler l'app

## Résolution de Problèmes Courants

### "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### "CocoaPods not installed" (iOS)

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### "Package not found"

```bash
flutter clean
flutter pub get
```

### "Hot reload ne fonctionne pas"

```bash
# Faire un hot restart
# Appuyer sur 'R' dans le terminal
```

### Erreur de version Flutter

```bash
flutter upgrade
flutter doctor
```

## Ressources Utiles

### Documentation du Projet
- [README.md](README.md) - Vue d'ensemble
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Architecture détaillée
- [docs/API_INTEGRATION.md](docs/API_INTEGRATION.md) - Intégration API
- [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) - Guide de contribution

### Documentation Flutter
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Provider Package](https://pub.dev/packages/provider)

### Tutoriels
- [Flutter Codelabs](https://flutter.dev/docs/codelabs)
- [Flutter YouTube Channel](https://www.youtube.com/flutterdev)

### Communauté
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow - Flutter Tag](https://stackoverflow.com/questions/tagged/flutter)

## Prochaines Étapes

Maintenant que vous êtes prêt, consultez :

1. **README.md** - Pour voir la répartition des tâches
2. **docs/ARCHITECTURE.md** - Pour comprendre l'architecture
3. **GitHub Issues** - Pour choisir une tâche à implémenter

## Besoin d'Aide ?

- Créer une issue sur GitHub avec le label `question`
- Contacter les mainteneurs :
  - neussi344@gmail.com
  - loicpauljunior@gmail.com
  - bellakanmo@gmail.com
  - tezloic@gmail.com

Bon développement ! 
