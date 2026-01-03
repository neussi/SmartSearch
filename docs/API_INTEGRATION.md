# Guide d'Intégration API

Ce document décrit comment l'application mobile SmartSearch communique avec le backend.

## Configuration

### Base URL

Configurée dans `lib/config/api_config.dart` :

```dart
static const String baseUrl = 'http://localhost:8080/api';
```

**Environnements** :
- **Développement** : `http://localhost:8080/api` ou `http://YOUR_LOCAL_IP:8080/api`
- **Staging** : `https://staging.smartsearch.com/api`
- **Production** : `https://api.smartsearch.com/api`

### Timeouts

```dart
static const Duration connectionTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
```

## Authentification

### Format du Token

L'API utilise des **JWT (JSON Web Tokens)** pour l'authentification.

Header format :
```
Authorization: Bearer <token>
```

### Endpoints d'Authentification

#### 1. Inscription

**Endpoint** : `POST /auth/register`

**Request Body** :
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe",
  "phone": "+237600000000"
}
```

**Response** :
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user123",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+237600000000",
    "createdAt": "2025-01-03T10:00:00Z"
  }
}
```

**Utilisation** :
```dart
final user = await authService.register(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
  phone: '+237600000000',
);
```

#### 2. Connexion

**Endpoint** : `POST /auth/login`

**Request Body** :
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response** : (identique à l'inscription)

**Utilisation** :
```dart
final user = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);
```

## Recherche

### 1. Recherche par Texte

**Endpoint** : `GET /search/text`

**Query Parameters** :
- `query` (required) : Texte de recherche
- `limit` (optional) : Nombre maximum de résultats (default: 20)

**Example** :
```
GET /search/text?query=chaussures&limit=10
```

**Response** :
```json
{
  "products": [
    {
      "id": "prod123",
      "name": "Nike Air Max",
      "description": "Chaussures de sport confortables...",
      "price": 45000,
      "discount": 10,
      "imageUrl": "https://example.com/images/prod123.jpg",
      "category": "Chaussures",
      "subCategory": "Sport",
      "popularity": 4.5,
      "rating": 4.2,
      "similarityScore": 0.92
    }
  ],
  "total": 45,
  "query": "chaussures"
}
```

**Utilisation** :
```dart
final result = await searchService.searchByText(
  query: 'chaussures',
  limit: 10,
);
```

**Note** : Le score de similarité (`similarityScore`) est calculé par le backend en utilisant :
- Universal Sentence Encoder (USE) pour l'embedding textuel
- Similarité cosinus entre la requête et les descriptions des produits

### 2. Recherche par Image

**Endpoint** : `POST /search/image`

**Content-Type** : `multipart/form-data`

**Form Fields** :
- `image` (required) : Fichier image (JPEG, PNG)
- `limit` (optional) : Nombre maximum de résultats

**Example avec cURL** :
```bash
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -F "image=@/path/to/image.jpg" \
  -F "limit=10" \
  http://localhost:8080/api/search/image
```

**Response** : (même format que recherche par texte)

**Utilisation** :
```dart
final imageFile = File('/path/to/image.jpg');
final result = await searchService.searchByImage(
  imageFile: imageFile,
  limit: 10,
);
```

**Backend Processing** :
1. Réception de l'image
2. Extraction des features avec Xception (4096 dimensions)
3. Normalisation L2
4. Calcul de similarité avec FAISS index
5. Retour des produits les plus similaires

### 3. Recherche Multimodale

**Endpoint** : `POST /search/multimodal`

**Content-Type** : `multipart/form-data`

**Form Fields** :
- `image` (required) : Fichier image
- `query` (required) : Texte de recherche
- `textWeight` (optional) : Poids pour le score textuel (default: 0.5)
- `imageWeight` (optional) : Poids pour le score visuel (default: 0.5)
- `limit` (optional) : Nombre maximum de résultats

**Example** :
```bash
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -F "image=@/path/to/image.jpg" \
  -F "query=chaussures running" \
  -F "textWeight=0.6" \
  -F "imageWeight=0.4" \
  -F "limit=10" \
  http://localhost:8080/api/search/multimodal
```

**Response** : (même format que recherche par texte)

**Utilisation** :
```dart
final imageFile = File('/path/to/image.jpg');
final result = await searchService.searchMultimodal(
  textQuery: 'chaussures running',
  imageFile: imageFile,
  textWeight: 0.6,  // α
  imageWeight: 0.4, // β
  limit: 10,
);
```

**Formule de Scoring** :
```
FinalScore = α * TextScore + β * ImageScore
```
où α + β = 1

## Produits

### 1. Liste des Produits

**Endpoint** : `GET /products`

**Query Parameters** :
- `limit` (optional) : Nombre de produits par page
- `offset` (optional) : Offset pour pagination
- `category` (optional) : Filtrer par catégorie

**Example** :
```
GET /products?limit=20&offset=0&category=Chaussures
```

**Response** :
```json
{
  "products": [...],
  "total": 150
}
```

**Utilisation** :
```dart
final products = await productService.getAllProducts(
  limit: 20,
  offset: 0,
  category: 'Chaussures',
);
```

### 2. Détail d'un Produit

**Endpoint** : `GET /product/:id`

**Example** :
```
GET /product/prod123
```

**Response** :
```json
{
  "product": {
    "id": "prod123",
    "name": "Nike Air Max",
    "description": "Description complète...",
    "price": 45000,
    "discount": 10,
    "imageUrl": "https://example.com/images/prod123.jpg",
    "category": "Chaussures",
    "subCategory": "Sport",
    "popularity": 4.5,
    "rating": 4.2
  }
}
```

**Utilisation** :
```dart
final product = await productService.getProductById('prod123');
```

### 3. Catégories

**Endpoint** : `GET /categories`

**Response** :
```json
{
  "categories": [
    {
      "id": "cat1",
      "name": "Chaussures",
      "description": "Toutes les chaussures",
      "iconUrl": "https://example.com/icons/shoes.png",
      "productCount": 150
    }
  ]
}
```

**Utilisation** :
```dart
final categories = await productService.getCategories();
```

## Panier

### 1. Récupérer le Panier

**Endpoint** : `GET /cart/list`

**Response** :
```json
{
  "cart": [
    {
      "id": "cart_item_1",
      "product": {
        "id": "prod123",
        "name": "Nike Air Max",
        "price": 45000,
        "discount": 10,
        "imageUrl": "..."
      },
      "quantity": 2,
      "addedAt": "2025-01-03T10:00:00Z"
    }
  ]
}
```

**Utilisation** :
```dart
final cartItems = await cartService.getCart();
```

### 2. Ajouter au Panier

**Endpoint** : `POST /cart/add`

**Request Body** :
```json
{
  "productId": "prod123",
  "quantity": 2
}
```

**Response** :
```json
{
  "cartItem": {
    "id": "cart_item_1",
    "product": {...},
    "quantity": 2,
    "addedAt": "2025-01-03T10:00:00Z"
  }
}
```

**Utilisation** :
```dart
final cartItem = await cartService.addToCart(
  productId: 'prod123',
  quantity: 2,
);
```

### 3. Mettre à Jour la Quantité

**Endpoint** : `PUT /cart/update`

**Request Body** :
```json
{
  "cartItemId": "cart_item_1",
  "quantity": 3
}
```

**Response** : (cartItem mis à jour)

**Utilisation** :
```dart
final updatedItem = await cartService.updateCartItem(
  cartItemId: 'cart_item_1',
  quantity: 3,
);
```

### 4. Supprimer du Panier

**Endpoint** : `DELETE /cart/remove/:id`

**Example** :
```
DELETE /cart/remove/cart_item_1
```

**Response** :
```json
{
  "success": true
}
```

**Utilisation** :
```dart
await cartService.removeFromCart('cart_item_1');
```

### 5. Vider le Panier

**Endpoint** : `DELETE /cart`

**Response** :
```json
{
  "success": true
}
```

**Utilisation** :
```dart
await cartService.clearCart();
```

## Gestion des Erreurs

### Codes de Statut HTTP

| Code | Signification | Action Mobile |
|------|---------------|---------------|
| 200 | OK | Traiter la réponse normalement |
| 201 | Created | Ressource créée avec succès |
| 400 | Bad Request | Afficher le message d'erreur |
| 401 | Unauthorized | Rediriger vers login |
| 403 | Forbidden | Afficher "Accès refusé" |
| 404 | Not Found | Afficher "Ressource non trouvée" |
| 500 | Server Error | Afficher "Erreur serveur, réessayez" |

### Format des Erreurs

**Response d'Erreur** :
```json
{
  "error": "Invalid credentials",
  "message": "Email ou mot de passe incorrect",
  "statusCode": 401
}
```

### Gestion dans ApiService

```dart
if (response.statusCode >= 200 && response.statusCode < 300) {
  return jsonDecode(response.body);
} else {
  throw ApiException(
    statusCode: response.statusCode,
    message: extractErrorMessage(response),
  );
}
```

### Gestion dans les Providers

```dart
try {
  await _service.someMethod();
} on ApiException catch (e) {
  if (e.statusCode == 401) {
    // Token expiré, rediriger vers login
    authProvider.logout();
  } else {
    _setError(e.message);
  }
} catch (e) {
  _setError('Erreur inattendue');
}
```

## Optimisations

### Retry Logic

Pour les erreurs temporaires (timeout, 5xx), implémenter un retry :

```dart
Future<T> _retryRequest<T>(Future<T> Function() request, {int maxRetries = 3}) async {
  int retries = 0;
  while (true) {
    try {
      return await request();
    } catch (e) {
      if (retries >= maxRetries || !_shouldRetry(e)) {
        rethrow;
      }
      retries++;
      await Future.delayed(Duration(seconds: retries));
    }
  }
}
```

### Caching

Pour réduire les appels API :

```dart
class ProductService {
  final Map<String, Product> _cache = {};

  Future<Product> getProductById(String id) async {
    if (_cache.containsKey(id)) {
      return _cache[id]!;
    }

    final product = await _apiService.get('/product/$id');
    _cache[id] = product;
    return product;
  }
}
```

### Debouncing (Recherche)

Pour éviter trop d'appels lors de la saisie :

```dart
Timer? _debounceTimer;

void onSearchTextChanged(String text) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 500), () {
    searchProvider.searchByText(query: text);
  });
}
```

## Sécurité

### HTTPS

**Production** : Toujours utiliser HTTPS

```dart
static const String baseUrl = 'https://api.smartsearch.com';
```

### Certificate Pinning (Optionnel)

Pour une sécurité accrue :

```dart
import 'package:http/io_client.dart';

SecurityContext context = SecurityContext.defaultContext;
context.setTrustedCertificates('path/to/certificate.pem');

HttpClient httpClient = HttpClient(context: context);
IOClient client = IOClient(httpClient);
```

### Validation des Données

Toujours valider les données avant envoi :

```dart
if (Validators.validateEmail(email) != null) {
  throw Exception('Email invalide');
}
```

## Monitoring & Logging

### Logging des Requêtes

Pour le développement :

```dart
Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
  print('POST ${ApiConfig.baseUrl}$endpoint');
  print('Body: ${jsonEncode(body)}');

  final response = await _client.post(...);

  print('Response: ${response.statusCode}');
  print('Body: ${response.body}');

  return _handleResponse(response);
}
```

### Analytics

Tracker les erreurs API :

```dart
catch (e) {
  // Log to analytics service
  analytics.logEvent('api_error', parameters: {
    'endpoint': endpoint,
    'error': e.toString(),
  });
  rethrow;
}
```

## Testing

### Mock API Service

```dart
class MockApiService extends Mock implements ApiService {}

void main() {
  test('ProductService.getAllProducts', () async {
    final mockApi = MockApiService();
    final service = ProductService(apiService: mockApi);

    when(mockApi.get('/products')).thenAnswer(
      (_) async => {'products': [...]},
    );

    final products = await service.getAllProducts();
    expect(products.length, greaterThan(0));
  });
}
```

## Annexes

### Exemple Complet d'Intégration

```dart
// 1. Initialisation
final apiService = ApiService();
final authService = AuthService(apiService: apiService);
final searchService = SearchService(apiService: apiService);

// 2. Connexion
final user = await authService.login(
  email: 'user@example.com',
  password: 'password',
);

// 3. Recherche
final results = await searchService.searchByText(query: 'chaussures');

// 4. Affichage
results.products.forEach((product) {
  print('${product.name}: ${product.price} FCFA');
});
```

### Contrat API (OpenAPI/Swagger)

Pour une documentation complète de l'API backend, consultez :
- Swagger UI : `http://backend-url/swagger-ui`
- OpenAPI Spec : `http://backend-url/api-docs`
