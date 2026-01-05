import 'package:equatable/equatable.dart';

/// Modèle de données pour un produit
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discountPercentage; // Renommé pour correspondre aux tests et widgets
  final String imageUrl;
  final String? category;
  final String? subCategory;
  final double? popularity;
  final double? rating;
  final double? similarityScore;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPercentage = 0, // Valeur par défaut à 0
    required this.imageUrl,
    this.category,
    this.subCategory,
    this.popularity,
    this.rating,
    this.similarityScore,
  });

  /// Prix après réduction
  double get finalPrice {
    if (discountPercentage > 0) {
      return price * (1 - (discountPercentage / 100));
    }
    return price;
  }

  /// Montant de la réduction
  double get discountAmount {
    return price - finalPrice;
  }

  /// Vérifie si le produit a une réduction
  bool get hasDiscount {
    return discountPercentage > 0;
  }

  /// Factory pour créer un Product depuis JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      // Gère les deux noms possibles venant de l'API par sécurité
      discountPercentage: (json['discountPercentage'] ?? json['discount'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      category: json['category'],
      subCategory: json['subCategory'] ?? json['sub_category'],
      popularity: json['popularity']?.toDouble(),
      rating: json['rating']?.toDouble(),
      similarityScore: json['similarityScore']?.toDouble() ?? json['similarity_score']?.toDouble(),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPercentage': discountPercentage,
      'imageUrl': imageUrl,
      'category': category,
      'subCategory': subCategory,
      'popularity': popularity,
      'rating': rating,
      'similarityScore': similarityScore,
    };
  }

  /// Copier avec modifications
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPercentage,
    String? imageUrl,
    String? category,
    String? subCategory,
    double? popularity,
    double? rating,
    double? similarityScore,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      popularity: popularity ?? this.popularity,
      rating: rating ?? this.rating,
      similarityScore: similarityScore ?? this.similarityScore,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        discountPercentage,
        imageUrl,
        category,
        subCategory,
        popularity,
        rating,
        similarityScore,
      ];
}