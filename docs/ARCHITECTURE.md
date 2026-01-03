# Architecture de SmartSearch

## Vue d'ensemble

SmartSearch suit une architecture en couches avec séparation claire des responsabilités. L'application utilise le pattern **Provider** pour la gestion d'état, recommandé par l'équipe Flutter.

## Architecture en Couches

```
┌─────────────────────────────────────────────┐
│           Presentation Layer                │
│  (Screens, Widgets, UI Components)          │
└─────────────────────────────────────────────┘
                    ▼
┌─────────────────────────────────────────────┐
│         State Management Layer              │
│            (Providers)                      │
└─────────────────────────────────────────────┘
                    ▼
┌─────────────────────────────────────────────┐
│          Business Logic Layer               │
│             (Services)                      │
└─────────────────────────────────────────────┘
                    ▼
┌─────────────────────────────────────────────┐
│            Data Layer                       │
│    (Models, API Client, Storage)            │
└─────────────────────────────────────────────┘
```

## Détail des Couches

### 1. Presentation Layer (UI)

Responsabilités :
- Affichage de l'interface utilisateur
- Capture des interactions utilisateur
- Navigation entre écrans

Composants :
- **Screens** : Écrans complets de l'application
- **Widgets** : Composants UI réutilisables
- **Utils** : Helpers pour l'UI (formatters, validators)

Bonnes pratiques :
- Les widgets doivent être sans état (Stateless) autant que possible
- Utiliser `Consumer` pour écouter les changements de Provider
- Éviter toute logique métier dans les widgets
- Utiliser `const` pour les widgets immutables

Exemple :
```dart
class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produits')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return LoadingWidget();
          }
          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: provider.products[index]);
            },
          );
        },
      ),
    );
  }
}
```

### 2. State Management Layer (Providers)

Responsabilités :
- Gérer l'état de l'application
- Notifier les listeners des changements
- Orchestrer les appels aux services
- Gérer le loading et les erreurs

Composants :
- **AuthProvider** : État d'authentification
- **ProductProvider** : État des produits et catégories
- **SearchProvider** : État de la recherche
- **CartProvider** : État du panier

Cycle de vie d'une action :
```
User Action → Provider Method → Service Call → Update State → Notify Listeners → UI Update
```

Exemple :
```dart
class ProductProvider with ChangeNotifier {
  final ProductService _service;
  List<Product> _products = [];
  bool _isLoading = false;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _service.getAllProducts();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 3. Business Logic Layer (Services)

Responsabilités :
- Communication avec l'API
- Transformation des données
- Gestion des erreurs réseau
- Logique métier spécifique

Composants :
- **ApiService** : Service de base pour les appels HTTP
- **AuthService** : Authentification
- **ProductService** : Gestion des produits
- **SearchService** : Recherche multimodale
- **CartService** : Gestion du panier

Communication :
```
Provider → Service → ApiService → Backend API
```

Exemple :
```dart
class ProductService {
  final ApiService _apiService;

  Future<List<Product>> getAllProducts() async {
    final response = await _apiService.get('/products');
    final data = response['products'] as List;
    return data.map((json) => Product.fromJson(json)).toList();
  }
}
```

### 4. Data Layer (Models & Storage)

Responsabilités :
- Définition des modèles de données
- Sérialisation/désérialisation JSON
- Stockage local (cache, tokens)

Composants :
- **Models** : Classes de données (Product, User, CartItem, etc.)
- **Storage** : Flutter Secure Storage pour les données sensibles
- **Cache** : Shared Preferences pour les préférences utilisateur

Exemple de modèle :
```dart
class Product extends Equatable {
  final String id;
  final String name;
  final double price;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}
```

## Flux de Données

### Flux de Recherche par Texte

```
1. User entre du texte dans TextSearchScreen
2. TextSearchScreen appelle searchProvider.searchByText()
3. SearchProvider appelle searchService.searchByText()
4. SearchService fait un GET à /search/text via ApiService
5. Backend retourne les résultats avec scores de similarité
6. SearchService transforme la réponse en List<Product>
7. SearchProvider met à jour lastSearchResult
8. SearchProvider notifie les listeners
9. TextSearchScreen rebuild avec les nouveaux résultats
```

### Flux de Recherche par Image

```
1. User sélectionne une image (caméra/galerie)
2. ImageSearchScreen appelle searchProvider.searchByImage()
3. SearchProvider appelle searchService.searchByImage()
4. SearchService upload l'image via ApiService.uploadMultipart()
5. Backend :
   - Extrait les features avec Xception
   - Calcule la similarité avec FAISS
   - Retourne les produits similaires
6. SearchService transforme la réponse en List<Product>
7. SearchProvider met à jour lastSearchResult
8. SearchProvider notifie les listeners
9. ImageSearchScreen rebuild avec les résultats
```

### Flux d'Ajout au Panier

```
1. User clique sur "Ajouter au panier"
2. Widget appelle cartProvider.addToCart(productId)
3. CartProvider appelle cartService.addToCart()
4. CartService fait un POST à /cart/add via ApiService
5. Backend ajoute l'article et retourne le panier mis à jour
6. CartService transforme la réponse en CartItem
7. CartProvider met à jour la liste _items
8. CartProvider notifie les listeners
9. UI rebuild (badge panier, confirmation, etc.)
```

## Gestion des Erreurs

### Stratégie de Gestion des Erreurs

```
API Error → ApiException → Service (rethrow) → Provider (catch) → UI (display)
```

### Types d'Erreurs

1. **Erreurs Réseau** :
   - Pas de connexion internet
   - Timeout
   - Erreur serveur

2. **Erreurs API** :
   - 400 : Requête invalide
   - 401 : Non authentifié
   - 403 : Non autorisé
   - 404 : Ressource non trouvée
   - 500 : Erreur serveur

3. **Erreurs Métier** :
   - Produit en rupture de stock
   - Quantité invalide
   - Image trop volumineuse

### Gestion dans le Provider

```dart
Future<void> loadProducts() async {
  _setLoading(true);
  _clearError();

  try {
    _products = await _service.getAllProducts();
  } on ApiException catch (e) {
    if (e.statusCode == 401) {
      // Rediriger vers login
    } else {
      _setError(e.message);
    }
  } catch (e) {
    _setError('Erreur inattendue');
  } finally {
    _setLoading(false);
  }
}
```

### Affichage dans l'UI

```dart
Consumer<ProductProvider>(
  builder: (context, provider, child) {
    if (provider.errorMessage != null) {
      return ErrorWidget(message: provider.errorMessage);
    }
    if (provider.isLoading) {
      return LoadingWidget();
    }
    return ProductList(products: provider.products);
  },
)
```

## Navigation

### Stratégie de Navigation

- **Routes nommées** : Pour une navigation claire et maintenable
- **Arguments** : Passage de données via RouteSettings
- **Guards** : Vérification d'authentification avant certaines routes

### Configuration

Fichier `config/routes.dart` :

```dart
class AppRoutes {
  static const String home = '/home';
  static const String productDetail = '/product/detail';
  static const String cart = '/cart';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case productDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: args['id']),
        );
      // ...
    }
  }
}
```

### Navigation avec Arguments

```dart
// Naviguer vers le détail d'un produit
Navigator.pushNamed(
  context,
  AppRoutes.productDetail,
  arguments: {'id': product.id},
);
```

## Optimisations

### Performance

1. **Lazy Loading** :
   - Charger les images à la demande
   - Pagination pour les listes longues

2. **Caching** :
   - Cache des images avec `cached_network_image`
   - Cache des réponses API (à implémenter si nécessaire)

3. **Build Optimization** :
   - Utiliser `const` constructors
   - `Consumer` ciblé au lieu de `Consumer` global
   - `ListView.builder` au lieu de `ListView`

### Sécurité

1. **Authentification** :
   - Tokens JWT stockés dans Flutter Secure Storage
   - Refresh automatique des tokens (à implémenter)

2. **Validation** :
   - Validation côté client ET serveur
   - Sanitization des inputs

3. **HTTPS** :
   - Toutes les communications en HTTPS en production
   - Certificate pinning (optionnel)

## Tests

### Pyramide de Tests

```
    /\
   /  \      E2E Tests (peu, critiques)
  /────\
 /      \    Integration Tests (moyens)
/────────\
 Unit Tests  (nombreux, rapides)
```

### Tests Unitaires

- Tester les modèles (fromJson, toJson)
- Tester les validators
- Tester les helpers
- Tester la logique des services (avec mocks)

### Tests d'Intégration

- Tester les flows complets
- Tester l'interaction Provider ↔ Service
- Tester la navigation

### Tests E2E

- Parcours utilisateur critiques :
  - Recherche → Détail → Ajout panier → Commande
  - Inscription → Connexion → Recherche

## Évolutions Futures

### Court Terme
- Mode sombre
- Favoris/Wishlist
- Notifications push
- Filtres avancés

### Moyen Terme
- Recommandations personnalisées
- Historique des commandes
- Multi-langues (i18n)
- Tests A/B

### Long Terme
- Mode hors-ligne
- Réalité augmentée (AR) pour visualiser les produits
- Chatbot IA pour assistance
- Scan de code-barres

## Ressources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
