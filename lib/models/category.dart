import 'package:equatable/equatable.dart';

/// Modèle pour une catégorie de produits
class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final int? productCount;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.productCount,
  });

  /// Factory depuis JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      iconUrl: json['iconUrl'] ?? json['icon_url'],
      productCount: json['productCount'] ?? json['product_count'],
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'productCount': productCount,
    };
  }

  /// Copier avec modifications
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    int? productCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  List<Object?> get props => [id, name, description, iconUrl, productCount];
}
