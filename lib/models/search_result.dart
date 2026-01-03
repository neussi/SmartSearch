import 'package:equatable/equatable.dart';
import 'package:smartsearch/models/product.dart';

/// Type de recherche effectuée
enum SearchType {
  text,
  image,
  multimodal,
}

/// Modèle pour les résultats de recherche
class SearchResult extends Equatable {
  final List<Product> products;
  final SearchType searchType;
  final String? query;
  final int totalResults;
  final DateTime timestamp;

  const SearchResult({
    required this.products,
    required this.searchType,
    this.query,
    required this.totalResults,
    required this.timestamp,
  });

  /// Factory depuis JSON
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final searchTypeStr = json['searchType'] ?? json['search_type'] ?? 'text';
    SearchType type;

    switch (searchTypeStr) {
      case 'image':
        type = SearchType.image;
        break;
      case 'multimodal':
        type = SearchType.multimodal;
        break;
      default:
        type = SearchType.text;
    }

    return SearchResult(
      products: (json['products'] as List<dynamic>?)
              ?.map((p) => Product.fromJson(p))
              .toList() ??
          [],
      searchType: type,
      query: json['query'],
      totalResults: json['totalResults'] ?? json['total_results'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    String searchTypeStr;
    switch (searchType) {
      case SearchType.text:
        searchTypeStr = 'text';
        break;
      case SearchType.image:
        searchTypeStr = 'image';
        break;
      case SearchType.multimodal:
        searchTypeStr = 'multimodal';
        break;
    }

    return {
      'products': products.map((p) => p.toJson()).toList(),
      'searchType': searchTypeStr,
      'query': query,
      'totalResults': totalResults,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Copier avec modifications
  SearchResult copyWith({
    List<Product>? products,
    SearchType? searchType,
    String? query,
    int? totalResults,
    DateTime? timestamp,
  }) {
    return SearchResult(
      products: products ?? this.products,
      searchType: searchType ?? this.searchType,
      query: query ?? this.query,
      totalResults: totalResults ?? this.totalResults,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [products, searchType, query, totalResults, timestamp];
}
