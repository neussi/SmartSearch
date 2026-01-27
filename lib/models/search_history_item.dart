import 'package:equatable/equatable.dart';

/// Type de recherche dans l'historique
enum SearchHistoryType {
  text,
  image,
  multimodal,
}

/// Élément de l'historique de recherche
class SearchHistoryItem extends Equatable {
  final String id;
  final SearchHistoryType type;
  final String? query;
  final String? imagePath;
  final DateTime timestamp;
  final int resultsCount;

  const SearchHistoryItem({
    required this.id,
    required this.type,
    this.query,
    this.imagePath,
    required this.timestamp,
    this.resultsCount = 0,
  });

  /// Créer depuis JSON
  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      id: json['id'] as String,
      type: SearchHistoryType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SearchHistoryType.text,
      ),
      query: json['query'] as String?,
      imagePath: json['imagePath'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      resultsCount: json['resultsCount'] as int? ?? 0,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'query': query,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'resultsCount': resultsCount,
    };
  }

  /// Obtenir une description lisible
  String get description {
    switch (type) {
      case SearchHistoryType.text:
        return query ?? 'Recherche textuelle';
      case SearchHistoryType.image:
        return 'Recherche par image';
      case SearchHistoryType.multimodal:
        return query ?? 'Recherche multimodale';
    }
  }

  /// Obtenir l'icône correspondante
  String get iconName {
    switch (type) {
      case SearchHistoryType.text:
        return 'text_fields';
      case SearchHistoryType.image:
        return 'camera_alt';
      case SearchHistoryType.multimodal:
        return 'auto_awesome';
    }
  }

  @override
  List<Object?> get props => [id, type, query, imagePath, timestamp, resultsCount];
}
