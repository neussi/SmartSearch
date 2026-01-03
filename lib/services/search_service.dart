import 'dart:io';
import 'package:smartsearch/config/api_config.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/models/search_result.dart';
import 'package:smartsearch/services/api_service.dart';

/// Service pour la recherche de produits
class SearchService {
  final ApiService _apiService;

  SearchService({required ApiService apiService}) : _apiService = apiService;

  /// Recherche par texte
  Future<SearchResult> searchByText({
    required String query,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{
        'query': query,
        if (limit != null) 'limit': limit.toString(),
      };

      final response = await _apiService.get(
        ApiConfig.searchTextEndpoint,
        queryParameters: queryParams,
      );

      final productsData = response['products'] ?? response['results'] ?? [];
      final totalResults = response['total'] ?? response['totalResults'] ?? productsData.length;

      final products = (productsData as List<dynamic>)
          .map((json) => Product.fromJson(json))
          .toList();

      return SearchResult(
        products: products,
        searchType: SearchType.text,
        query: query,
        totalResults: totalResults,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Recherche par image
  Future<SearchResult> searchByImage({
    required File imageFile,
    int? limit,
  }) async {
    try {
      final additionalFields = <String, String>{};
      if (limit != null) {
        additionalFields['limit'] = limit.toString();
      }

      final response = await _apiService.uploadMultipart(
        ApiConfig.searchImageEndpoint,
        file: imageFile,
        fieldName: 'image',
        additionalFields: additionalFields,
      );

      final productsData = response['products'] ?? response['results'] ?? [];
      final totalResults = response['total'] ?? response['totalResults'] ?? productsData.length;

      final products = (productsData as List<dynamic>)
          .map((json) => Product.fromJson(json))
          .toList();

      return SearchResult(
        products: products,
        searchType: SearchType.image,
        totalResults: totalResults,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Recherche multimodale (texte + image)
  Future<SearchResult> searchMultimodal({
    required String textQuery,
    required File imageFile,
    double textWeight = 0.5,
    double imageWeight = 0.5,
    int? limit,
  }) async {
    try {
      final additionalFields = <String, String>{
        'query': textQuery,
        'textWeight': textWeight.toString(),
        'imageWeight': imageWeight.toString(),
        if (limit != null) 'limit': limit.toString(),
      };

      final response = await _apiService.uploadMultipart(
        ApiConfig.searchMultimodalEndpoint,
        file: imageFile,
        fieldName: 'image',
        additionalFields: additionalFields,
      );

      final productsData = response['products'] ?? response['results'] ?? [];
      final totalResults = response['total'] ?? response['totalResults'] ?? productsData.length;

      final products = (productsData as List<dynamic>)
          .map((json) => Product.fromJson(json))
          .toList();

      return SearchResult(
        products: products,
        searchType: SearchType.multimodal,
        query: textQuery,
        totalResults: totalResults,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
