import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smartsearch/config/api_config.dart';
import 'package:smartsearch/models/product.dart';
import 'package:smartsearch/models/search_result.dart';
import 'package:smartsearch/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
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
      // Construire l'URL avec le paramètre top_k en query
      String endpoint = ApiConfig.searchImageEndpoint;
      if (limit != null) {
        endpoint += '?top_k=$limit';
      }
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      
      print('🔍 Image Search URL: $url');
      print('📸 Image size: ${imageBytes.length} bytes');
      
      var request = http.MultipartRequest('POST', url);
      
      // Ajouter l'image avec le bon content-type
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
          contentType: http_parser.MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body.substring(0, min(200, response.body.length))}');

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
        print('❌ Error response: ${response.body}');
        throw Exception('Erreur de recherche: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
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
      // Construire l'URL avec les paramètres en query
      String endpoint = ApiConfig.searchMultimodalEndpoint;
      endpoint += '?alpha=$textWeight&beta=$imageWeight';
      if (limit != null) {
        endpoint += '&top_k=$limit';
      }
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      
      var request = http.MultipartRequest('POST', url);
      
      // Ajouter l'image
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );
      
      // Ajouter le texte en form field
      request.fields['text'] = textQuery;

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
