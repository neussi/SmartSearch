import 'package:smartsearch/config/api_config.dart';
import 'package:smartsearch/models/category.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/services/api_service.dart';

/// Service pour la gestion des produits
class ProductService {
  final ApiService _apiService;

  ProductService({required ApiService apiService}) : _apiService = apiService;

  /// Récupérer tous les produits
  Future<List<Product>> getAllProducts({
    int? limit,
    int? offset,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (category != null) queryParams['category'] = category;

      final response = await _apiService.get(
        ApiConfig.productsEndpoint,
        queryParameters: queryParams,
      );

      final productsData = response['products'] ?? response['data'] ?? [];

      return (productsData as List<dynamic>)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer un produit par ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await _apiService.get(
        ApiConfig.productDetailEndpoint(id),
      );

      final productData = response['product'] ?? response['data'];

      if (productData == null) {
        throw const ApiException(
          statusCode: 404,
          message: 'Produit non trouvé',
        );
      }

      return Product.fromJson(productData);
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les catégories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConfig.categoriesEndpoint);

      final categoriesData = response['categories'] ?? response['data'] ?? [];

      return (categoriesData as List<dynamic>)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les produits par catégorie
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      return await getAllProducts(category: categoryId);
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les produits en promotion
  Future<List<Product>> getDiscountedProducts() async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.where((product) => product.hasDiscount).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les produits populaires
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    try {
      final allProducts = await getAllProducts(limit: limit);
      allProducts.sort((a, b) {
        final aPopularity = a.popularity ?? 0;
        final bPopularity = b.popularity ?? 0;
        return bPopularity.compareTo(aPopularity);
      });
      return allProducts;
    } catch (e) {
      rethrow;
    }
  }
}
