import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smartsearch/config/api_config.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/models/search_result.dart';
import 'package:smartsearch/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service pour la recherche de produits (compatible web et mobile)
class SearchService {
  final ApiService _apiService;

  SearchService({required ApiService apiService}) : _apiService = apiService;

  /// Recherche par texte
  Future<SearchResult> searchByText({
    required String query,
    int? limit,
  }) async {
    try {
      final body = <String, dynamic>{
        'query': query,
        if (limit != null) 'top_k': limit,
      };

      final response = await _apiService.post(
        ApiConfig.searchTextEndpoint,
        body: body,
      );

      final productsData = response['results'] ?? [];
      final totalResults = response['count'] ?? productsData.length;

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

  /// Recherche par image (compatible web et mobile)
  Future<SearchResult> searchByImage({
    required Uint8List imageBytes,
    required String fileName,
    int? limit,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.searchImageEndpoint}');
      
      var request = http.MultipartRequest('POST', url);
      
      // Ajouter l'image
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );
      
      // Ajouter topK si fourni
      if (limit != null) {
        request.fields['top_k'] = limit.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productsData = data['results'] ?? [];
        final totalResults = data['count'] ?? productsData.length;

        final products = (productsData as List<dynamic>)
            .map((json) => Product.fromJson(json))
            .toList();

        return SearchResult(
          products: products,
          searchType: SearchType.image,
          totalResults: totalResults,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('Erreur de recherche: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Recherche multimodale (texte + image, compatible web et mobile)
  Future<SearchResult> searchMultimodal({
    required String textQuery,
    required Uint8List imageBytes,
    required String fileName,
    double textWeight = 0.6,
    double imageWeight = 0.4,
    int? limit,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.searchMultimodalEndpoint}');
      
      var request = http.MultipartRequest('POST', url);
      
      // Ajouter l'image
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );
      
      // Ajouter les champs
      request.fields['text'] = textQuery;
      request.fields['alpha'] = textWeight.toString();
      request.fields['beta'] = imageWeight.toString();
      
      if (limit != null) {
        request.fields['top_k'] = limit.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productsData = data['results'] ?? [];
        final totalResults = data['count'] ?? productsData.length;

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
      } else {
        throw Exception('Erreur de recherche: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
