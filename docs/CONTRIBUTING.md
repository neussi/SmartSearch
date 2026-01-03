# Guide de Contribution

Merci de contribuer à SmartSearch ! Ce document fournit les guidelines pour contribuer efficacement au projet.

## Table des matières

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Workflow Git](#workflow-git)
- [Conventions de Code](#conventions-de-code)
- [Pull Requests](#pull-requests)
- [Code Review](#code-review)
- [Tests](#tests)
- [Documentation](#documentation)

## Code of Conduct

### Nos Engagements

- Respecter tous les contributeurs
- Être ouvert aux critiques constructives
- Focuser sur ce qui est mieux pour le projet
- Faire preuve d'empathie envers les autres

### Comportements Inacceptables

- Langage ou images offensantes
- Attaques personnelles
- Harcèlement public ou privé
- Publication d'informations privées sans permission

## Getting Started

### 1. Fork & Clone

```bash
# Fork le repo sur GitHub, puis :
git clone https://github.com/VOTRE_USERNAME/SmartSearch.git
cd SmartSearch

# Ajouter le repo upstream
git remote add upstream https://github.com/neussi/SmartSearch.git
```

### 2. Installation

```bash
flutter pub get
```

### 3. Créer une Branche

```bash
git checkout -b feature/ma-nouvelle-feature
```

## Workflow Git

### Branches

- `main` : Branche principale, toujours stable
- `develop` : Branche de développement (si utilisée)
- `feature/*` : Nouvelles fonctionnalités
- `fix/*` : Corrections de bugs
- `refactor/*` : Refactoring
- `docs/*` : Documentation

**Exemples** :
```bash
feature/search-by-image
fix/cart-total-calculation
refactor/api-service
docs/api-integration
```

### Commits

#### Convention : Conventional Commits

Format :
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types** :
- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `refactor` : Refactoring (pas de changement fonctionnel)
- `docs` : Documentation
- `style` : Formatage, points-virgules manquants, etc.
- `test` : Ajout ou modification de tests
- `chore` : Tâches de maintenance

**Exemples** :
```bash
feat(search): add image search functionality
fix(cart): correct total price calculation
refactor(api): improve error handling
docs(readme): update installation instructions
test(services): add unit tests for ProductService
```

### Synchronisation avec Upstream

```bash
# Récupérer les changements de upstream
git fetch upstream

# Merge dans votre branche locale
git checkout main
git merge upstream/main

# Rebase votre branche de feature
git checkout feature/ma-feature
git rebase main
```

## Conventions de Code

### Style Dart/Flutter

Suivre les [Effective Dart guidelines](https://dart.dev/guides/language/effective-dart).

#### Vérification

```bash
# Analyser le code
flutter analyze

# Formatter le code
dart format .
```

#### Règles Importantes

1. **Nommage** :
   ```dart
   // Classes : PascalCase
   class ProductCard extends StatelessWidget {}

   // Variables, fonctions : camelCase
   final String productName;
   void loadProducts() {}

   // Constantes : lowerCamelCase
   const String apiBaseUrl = '...';

   // Fichiers : snake_case
   product_card.dart
   api_service.dart
   ```

2. **Organisation des imports** :
   ```dart
   // 1. Dart core
   import 'dart:async';

   // 2. Packages Flutter
   import 'package:flutter/material.dart';

   // 3. Packages tiers
   import 'package:provider/provider.dart';

   // 4. Fichiers locaux
   import 'package:smartsearch/models/product.dart';
   ```

3. **Const Constructors** :
   ```dart
   // Utiliser const quand possible
   const Text('Hello');
   const SizedBox(height: 16);
   ```

4. **Trailing Commas** :
   ```dart
   // Ajouter une virgule après le dernier paramètre
   Widget build(BuildContext context) {
     return Container(
       child: Text('Hello'),
     ); // <- trailing comma
   }
   ```

### Architecture

#### Séparation des Responsabilités

```dart
// ❌ Mauvais : Logique dans le widget
class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final products = http.get('api/products'); // ❌
    return ListView(...);
  }
}

// ✅ Bon : Utiliser Provider et Service
class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return ListView(...);
      },
    );
  }
}
```

#### Widgets Stateless par Défaut

```dart
// Préférer StatelessWidget + Provider
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(...);
  }
}
```

#### Extraction de Widgets

```dart
// ❌ Mauvais : Widget trop complexe
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 50 lignes de code pour la AppBar
          // 100 lignes de code pour le body
          // 30 lignes de code pour le footer
        ],
      ),
    );
  }
}

// ✅ Bon : Extraire en widgets séparés
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: HomeBody(),
      bottomNavigationBar: HomeBottomBar(),
    );
  }
}
```

### Error Handling

```dart
// ❌ Mauvais
Future<void> loadData() async {
  try {
    final data = await api.get('/data');
  } catch (e) {
    print(e); // ❌
  }
}

// ✅ Bon
Future<void> loadData() async {
  _setLoading(true);
  _clearError();

  try {
    final data = await api.get('/data');
    _data = data;
  } on ApiException catch (e) {
    _setError(e.message);
  } catch (e) {
    _setError('Erreur inattendue');
  } finally {
    _setLoading(false);
  }
}
```

## Pull Requests

### Avant de Soumettre

1. **Tests** : Vérifier que tous les tests passent
   ```bash
   flutter test
   ```

2. **Analyse** : Pas d'erreurs d'analyse
   ```bash
   flutter analyze
   ```

3. **Format** : Code correctement formatté
   ```bash
   dart format .
   ```

4. **Build** : L'app compile sans erreur
   ```bash
   flutter build apk --debug
   ```

### Créer une Pull Request

1. **Push votre branche** :
   ```bash
   git push origin feature/ma-feature
   ```

2. **Ouvrir une PR sur GitHub** avec :
   - Titre clair et descriptif
   - Description détaillée des changements
   - Screenshots si changements UI
   - Référence aux issues (ex: "Closes #123")

### Template de PR

```markdown
## Description
Brève description des changements

## Type de changement
- [ ] Bug fix
- [ ] Nouvelle fonctionnalité
- [ ] Refactoring
- [ ] Documentation

## Checklist
- [ ] Code formatté (`dart format .`)
- [ ] Analyse OK (`flutter analyze`)
- [ ] Tests ajoutés/mis à jour
- [ ] Tests passent (`flutter test`)
- [ ] Documentation mise à jour
- [ ] Screenshots ajoutés (si UI)

## Screenshots (si applicable)
[Ajouter des screenshots]

## Tests effectués
- [ ] Sur émulateur Android
- [ ] Sur émulateur iOS
- [ ] Sur appareil réel

## Issues liées
Closes #123
```

## Code Review

### En tant que Reviewer

#### Checklist

- [ ] Le code suit les conventions du projet
- [ ] Le code est lisible et bien structuré
- [ ] Pas de code dupliqué
- [ ] Les erreurs sont gérées correctement
- [ ] Les tests sont présents et passent
- [ ] La documentation est à jour
- [ ] Pas de secrets (API keys) dans le code

#### Types de Commentaires

- **Nit** : Suggestion mineure, non bloquante
- **Question** : Demande de clarification
- **Issue** : Problème à corriger
- **Praise** : Bon code, encourager !

#### Exemple de Review

```dart
// ❓ Question: Pourquoi utiliser un StatefulWidget ici ?
// Un StatelessWidget avec Provider serait plus approprié

// 🔴 Issue: Cette logique devrait être dans un Provider, pas dans le Widget
final products = await http.get('/products');

// 💡 Nit: Utiliser const pour améliorer les performances
return Text('Hello'); // => return const Text('Hello');

// 🎉 Praise: Excellente gestion d'erreur !
```

### En tant qu'Auteur

- Être ouvert aux feedbacks
- Répondre à tous les commentaires
- Faire les modifications demandées
- Remercier les reviewers

## Tests

### Types de Tests

#### 1. Tests Unitaires

```dart
// test/services/product_service_test.dart
void main() {
  group('ProductService', () {
    late MockApiService mockApi;
    late ProductService service;

    setUp(() {
      mockApi = MockApiService();
      service = ProductService(apiService: mockApi);
    });

    test('getAllProducts returns list of products', () async {
      when(mockApi.get('/products')).thenAnswer(
        (_) async => {'products': [...]},
      );

      final products = await service.getAllProducts();

      expect(products, isA<List<Product>>());
      expect(products.length, greaterThan(0));
    });
  });
}
```

#### 2. Tests de Widgets

```dart
// test/widgets/product_card_test.dart
void main() {
  testWidgets('ProductCard displays product name', (tester) async {
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 1000,
      imageUrl: 'test.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(product: product),
        ),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
  });
}
```

### Exécution des Tests

```bash
# Tous les tests
flutter test

# Un fichier spécifique
flutter test test/services/product_service_test.dart

# Avec coverage
flutter test --coverage
```

### Coverage

Viser au moins **80% de coverage** pour :
- Services
- Providers
- Validators
- Helpers

## Documentation

### Code Documentation

```dart
/// Service pour la gestion des produits
///
/// Communique avec l'API backend pour récupérer, filtrer
/// et rechercher des produits.
class ProductService {
  final ApiService _apiService;

  ProductService({required ApiService apiService})
      : _apiService = apiService;

  /// Récupère tous les produits
  ///
  /// [limit] : Nombre maximum de produits à retourner
  /// [offset] : Offset pour la pagination
  /// [category] : Filtrer par catégorie (optionnel)
  ///
  /// Returns une liste de [Product]
  ///
  /// Throws [ApiException] si la requête échoue
  Future<List<Product>> getAllProducts({
    int? limit,
    int? offset,
    String? category,
  }) async {
    // Implementation
  }
}
```

### README et Docs

- Mettre à jour le README si nécessaire
- Ajouter/modifier la documentation dans `/docs`
- Inclure des exemples de code
- Ajouter des diagrammes si pertinent

## Questions ?

Si vous avez des questions :
- Ouvrir une issue avec le label `question`
- Contacter les mainteneurs :
  - neussi344@gmail.com
  - loicpauljunior@gmail.com
  - bellakanmo@gmail.com
  - tezloic@gmail.com

Merci de contribuer à SmartSearch ! 🚀
