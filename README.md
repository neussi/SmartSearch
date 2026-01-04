# SmartSearch - Application Mobile de Recherche Multimodale

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Application mobile intelligente de recherche de produits utilisant du texte et des images, connectée à une plateforme de e-commerce. Projet développé dans le cadre du Projet de l'UE **Réseaux de Neurones et Deep Learning II** (AIA4 2025-2026).

## Table des matières

- [Aperçu du Projet](#aperçu-du-projet)
- [Fonctionnalités](#fonctionnalités)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [Structure du Projet](#structure-du-projet)
- [Équipe et Répartition des Tâches](#équipe-et-répartition-des-tâches)
- [Technologies Utilisées](#technologies-utilisées)
- [Guide de Développement](#guide-de-développement)
- [Tests](#tests)
- [Déploiement](#déploiement)
- [Contributeurs](#contributeurs)

## Aperçu du Projet

SmartSearch est une application mobile cross-platform développée avec Flutter qui permet aux utilisateurs de rechercher des produits de manière innovante en utilisant :
- **Recherche textuelle** : Recherche classique par mots-clés
- **Recherche par image** : Upload ou capture photo pour trouver des produits similaires
- **Recherche multimodale** : Combinaison de texte et d'image avec pondération personnalisable

Le système utilise des modèles de Deep Learning pour l'extraction de features (USE pour le texte, Xception pour les images) et un moteur de scoring basé sur la similarité cosinus.

## Fonctionnalités

### Recherche Intelligente
- Recherche par texte avec auto-complétion
- Recherche par image (caméra ou galerie)
- Recherche multimodale avec ajustement des poids (α pour texte, β pour image)
- Historique des recherches

### Catalogue Produits
- Affichage des produits par catégorie
- Filtrage par prix et réduction
- Détails complets des produits (nom, description, prix, réduction, rating)
- Images haute qualité avec mise en cache

### Panier d'Achat
- Ajout/suppression de produits
- Modification des quantités
- Calcul automatique du total
- Sauvegarde du panier

### Authentification
- Inscription utilisateur
- Connexion sécurisée avec JWT
- Stockage sécurisé des tokens

### Interface Utilisateur
- Design Material Design moderne
- Interface intuitive et responsive
- Support Android et iOS
- Mode clair (mode sombre prévu pour extension)

## Architecture

### Architecture Globale du Système

```
┌─────────────────────────────────────────────────────────┐
│                   Application Mobile                     │
│                      (Flutter)                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Recherche  │  │   Produits   │  │    Panier    │  │
│  │   Textuelle  │  │  & Catégories│  │  & Commande  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ▼
                    ┌─────────────┐
                    │   API REST  │
                    │  (Backend)  │
                    └─────────────┘
                           ▼
         ┌─────────────────────────────────────┐
         │      Moteur de Scoring Multimodal    │
         │  α * TextScore + β * ImageScore      │
         └─────────────────────────────────────┘
                           ▼
    ┌──────────────────────────────────────────────┐
    │          Feature Extraction                   │
    │  ┌─────────────────┐  ┌─────────────────┐   │
    │  │  Text Embedding │  │ Image Embedding │   │
    │  │      (USE)      │  │   (Xception)    │   │
    │  │   512 dims      │  │   4096 dims     │   │
    │  └─────────────────┘  └─────────────────┘   │
    └──────────────────────────────────────────────┘
                           ▼
                 ┌──────────────────┐
                 │  Base de Données │
                 │   + FAISS Index  │
                 └──────────────────┘
```

### Architecture Mobile (Flutter)

L'application suit une architecture **Provider** avec séparation des responsabilités :

```
lib/
├── config/          # Configuration (API, thème, routes)
├── models/          # Modèles de données
├── services/        # Couche de communication API
├── providers/       # Gestion d'état (Provider)
├── screens/         # Écrans de l'application
├── widgets/         # Composants réutilisables
└── utils/           # Utilitaires et helpers
```

## Installation

### Prérequis

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio ou Xcode
- Un émulateur Android/iOS ou un appareil physique

### Étapes d'Installation

1. **Cloner le repository**
```bash
git clone https://github.com/neussi/SmartSearch.git
cd SmartSearch
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer l'API Backend**

Modifier le fichier `lib/config/api_config.dart` :
```dart
static const String baseUrl = 'http://VOTRE_IP:8080/api';
```

4. **Lancer l'application**
```bash
# Sur émulateur/appareil connecté
flutter run

# En mode release
flutter run --release
```

## Configuration

### Configuration API

Fichier : `lib/config/api_config.dart`

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api';
  // ... autres configurations
}
```

### Configuration Thème

Fichier : `lib/config/theme_config.dart`

Personnalisez les couleurs et styles de l'application.

### Variables d'Environnement

Pour la production, créez un fichier `lib/config/secrets.dart` (ignoré par Git) :

```dart
class Secrets {
  static const String apiBaseUrl = 'https://api.smartsearch.com';
  static const String apiKey = 'YOUR_API_KEY';
}
```

## Structure du Projet

```
SmartSearch/
├── lib/
│   ├── config/
│   │   ├── api_config.dart          # Configuration API
│   │   ├── theme_config.dart        # Configuration thème
│   │   └── routes.dart              # Configuration routes
│   ├── models/
│   │   ├── product.dart             # Modèle produit
│   │   ├── cart_item.dart           # Modèle panier
│   │   ├── category.dart            # Modèle catégorie
│   │   ├── search_result.dart       # Modèle résultat recherche
│   │   └── user.dart                # Modèle utilisateur
│   ├── services/
│   │   ├── api_service.dart         # Service API de base
│   │   ├── auth_service.dart        # Service authentification
│   │   ├── product_service.dart     # Service produits
│   │   ├── search_service.dart      # Service recherche
│   │   └── cart_service.dart        # Service panier
│   ├── providers/
│   │   ├── auth_provider.dart       # Provider authentification
│   │   ├── cart_provider.dart       # Provider panier
│   │   ├── product_provider.dart    # Provider produits
│   │   └── search_provider.dart     # Provider recherche
│   ├── screens/
│   │   ├── home/                    # Écran d'accueil
│   │   ├── search/                  # Écrans de recherche
│   │   ├── product/                 # Écrans produits
│   │   ├── cart/                    # Écran panier
│   │   └── auth/                    # Écrans authentification
│   ├── widgets/
│   │   ├── custom_button.dart       # Bouton personnalisé
│   │   ├── loading_widget.dart      # Widget chargement
│   │   ├── product_card.dart        # Carte produit (TODO)
│   │   └── custom_text_field.dart   # Champ texte (TODO)
│   ├── utils/
│   │   ├── constants.dart           # Constantes
│   │   ├── validators.dart          # Validateurs
│   │   └── helpers.dart             # Fonctions utilitaires
│   └── main.dart                    # Point d'entrée
├── assets/
│   ├── images/                      # Images de l'app
│   ├── icons/                       # Icônes
│   └── fonts/                       # Polices personnalisées
├── test/                            # Tests unitaires
├── docs/                            # Documentation
├── pubspec.yaml                     # Dépendances Flutter
└── README.md                        # Ce fichier
```

## Équipe et Répartition des Tâches

### Contributeurs

- **neussi344@gmail.com** - Lead Developer & Architecture
- **loicpauljunior@gmail.com** - UI/UX & Frontend Development
- **bellakanmo@gmail.com** - Backend Integration & Testing
- **tezloic@gmail.com** - Features & Quality Assurance

### Répartition des Tâches

#### Phase 1 : Mise en Place (Semaine 1)
- **Tous** : Review de l'architecture et familiarisation avec le code
- **neussi344** : Setup du projet, configuration CI/CD
- **loicpauljunior** : Design des maquettes UI/UX sur Figma

#### Phase 2 : Développement des Écrans (Semaines 2-3)

**neussi344@gmail.com** :
- [ ] Écran d'accueil (HomeScreen)
  - Affichage des catégories
  - Produits populaires
  - Produits en promotion
  - Barre de recherche rapide
- [ ] Écran de recherche par texte (TextSearchScreen)
  - Champ de recherche avec validation
  - Affichage des résultats
  - Historique de recherche

**loicpauljunior@gmail.com** :
- [ ] Écran de recherche par image (ImageSearchScreen)
  - Interface de sélection d'image (caméra/galerie)
  - Prévisualisation de l'image
  - Affichage des résultats
- [ ] Écran de recherche multimodale
  - Combinaison texte + image
  - Sliders pour ajuster les poids α et β
  - Affichage des résultats

**bellakanmo@gmail.com** :
- [ ] Écran de détail produit (ProductDetailScreen)
  - Affichage complet des informations
  - Galerie d'images
  - Bouton d'ajout au panier
  - Produits similaires
- [ ] Écran liste de produits (ProductListScreen)
  - Affichage par catégorie
  - Filtres (prix, réduction)
  - Tri (popularité, prix)

**tezloic@gmail.com** :
- [ ] Écran du panier (CartScreen)
  - Liste des articles
  - Modification des quantités
  - Calcul du total
  - Bouton de commande
- [ ] Écrans d'authentification (LoginScreen, RegisterScreen)
  - Formulaires de connexion/inscription
  - Validation des champs
  - Gestion des erreurs

#### Phase 3 : Widgets Réutilisables (Semaine 3)

**neussi344@gmail.com** :
- [ ] ProductCard widget
  - Affichage compact du produit
  - Badge de réduction
  - Rating
  - Bouton ajout rapide au panier

**loicpauljunior@gmail.com** :
- [ ] CustomTextField widget
  - Champ de texte stylisé
  - Validation intégrée
  - Icônes et suffixes
- [ ] SearchBar widget
  - Barre de recherche avec auto-complétion
  - Historique dropdown

**bellakanmo@gmail.com** :
- [ ] CategoryCard widget
  - Carte de catégorie avec icône
  - Nombre de produits
- [ ] FilterSheet widget
  - Bottom sheet de filtres
  - Sliders de prix
  - Checkboxes de catégories

**tezloic@gmail.com** :
- [ ] CartItemCard widget
  - Affichage d'un article du panier
  - Contrôles de quantité
  - Bouton de suppression
- [ ] EmptyState widget
  - États vides (panier vide, aucun résultat, etc.)

#### Phase 4 : Intégration Backend (Semaine 4)

**Tous** :
- [ ] Tests d'intégration avec l'API backend
- [ ] Gestion des erreurs réseau
- [ ] Optimisation des requêtes
- [ ] Mise en cache des images

**neussi344@gmail.com** :
- Coordination des tests d'intégration
- Résolution des bugs critiques

**bellakanmo@gmail.com** :
- Tests des endpoints API
- Documentation des erreurs
- Validation des réponses

#### Phase 5 : Tests et Optimisation (Semaine 5)

**tezloic@gmail.com** :
- [ ] Tests unitaires des services
- [ ] Tests des providers
- [ ] Tests des validateurs

**Tous** :
- [ ] Tests de l'application complète
- [ ] Optimisation des performances
- [ ] Correction des bugs
- [ ] Documentation finale

#### Phase 6 : Déploiement (Semaine 6)

**neussi344@gmail.com** :
- [ ] Build Android (APK/AAB)
- [ ] Configuration Play Store
- [ ] CI/CD avec GitHub Actions

**loicpauljunior@gmail.com** :
- [ ] Build iOS (si applicable)
- [ ] Configuration App Store
- [ ] Screenshots et descriptions

### Suivi des Tâches

Le suivi se fait via :
- **GitHub Issues** : Création d'issues pour chaque tâche
- **GitHub Projects** : Tableau Kanban (To Do, In Progress, Done)
- **Pull Requests** : Review de code obligatoire avant merge

### Workflow Git

```bash
# Créer une branche pour chaque feature
git checkout -b feature/nom-de-la-feature

# Faire vos modifications et commits
git add .
git commit -m "feat: description de la feature"

# Pousser et créer une Pull Request
git push origin feature/nom-de-la-feature
```

**Convention de nommage des branches** :
- `feature/` : Nouvelles fonctionnalités
- `fix/` : Corrections de bugs
- `refactor/` : Refactoring
- `docs/` : Documentation

**Convention de commit** (Conventional Commits) :
- `feat:` : Nouvelle fonctionnalité
- `fix:` : Correction de bug
- `refactor:` : Refactoring
- `docs:` : Documentation
- `test:` : Tests
- `style:` : Formatage

## Technologies Utilisées

### Frontend Mobile
- **Flutter** 3.0+ : Framework cross-platform
- **Dart** : Langage de programmation
- **Provider** : Gestion d'état
- **HTTP/Dio** : Requêtes réseau
- **Image Picker** : Sélection d'images
- **Cached Network Image** : Mise en cache d'images
- **Flutter Secure Storage** : Stockage sécurisé
- **JWT Decoder** : Décodage des tokens JWT

### Backend (Référence)
- **Spring Boot** ou **FastAPI** : API REST
- **Universal Sentence Encoder (USE)** : Embedding textuel
- **Xception** : Extraction de features visuelles
- **FAISS** : Index de similarité
- **MongoDB** ou **PostgreSQL** : Base de données

## Guide de Développement

### Bonnes Pratiques

1. **Code Clean** :
   - Suivre les conventions Dart/Flutter
   - Utiliser `flutter analyze` avant chaque commit
   - Formatter le code avec `dart format .`

2. **Architecture** :
   - Respecter la séparation des couches (UI, Provider, Service, Model)
   - Éviter la logique métier dans les widgets
   - Utiliser les providers pour la gestion d'état

3. **Sécurité** :
   - Ne jamais commiter de secrets ou tokens
   - Utiliser Flutter Secure Storage pour les données sensibles
   - Valider toutes les entrées utilisateur

4. **Performance** :
   - Utiliser `const` pour les widgets statiques
   - Mettre en cache les images
   - Optimiser les rebuilds avec `Consumer` ciblés

### Commandes Utiles

```bash
# Vérifier le code
flutter analyze

# Formatter le code
dart format .

# Lancer les tests
flutter test

# Générer le code (si nécessaire)
flutter pub run build_runner build

# Nettoyer le projet
flutter clean && flutter pub get

# Build pour Android
flutter build apk --release
flutter build appbundle --release

# Build pour iOS
flutter build ios --release
```

### Debugging

- Utiliser `print()` ou `debugPrint()` pour le logging
- Utiliser Flutter DevTools pour l'inspection
- Activer les logs réseau dans `api_service.dart`

## Tests

### Tests Unitaires

```bash
flutter test
```

### Tests d'Intégration

```bash
flutter test integration_test/
```

### Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Déploiement

### Android

1. Configurer `android/app/build.gradle`
2. Créer la clé de signature
3. Build l'APK ou l'AAB :
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

1. Configurer Xcode
2. Configurer les certificats
3. Build :
```bash
flutter build ios --release
```

## Documentation

Documentation complète disponible dans le dossier `docs/` :
- [Architecture détaillée](docs/ARCHITECTURE.md)
- [Intégration API](docs/API_INTEGRATION.md)
- [Guide de contribution](docs/CONTRIBUTING.md)

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## Contact & Support

Pour toute question ou problème :
- Créer une issue sur GitHub
- Contacter l'équipe via les emails listés ci-dessus

---

**Projet AIA4 - 2025**
Réseaux de Neurones et Deep Learning II
