import 'package:equatable/equatable.dart';

/// Modèle de données pour un produit
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discount; // Réduction en pourcentage (0-100)
  final String imageUrl;
  final String? category;
  final String? subCategory;
  final double? popularity;
  final double? rating;
  final double? similarityScore; // Score de similarité pour les recherches

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discount = 0,
    required this.imageUrl,
    this.category,
    this.subCategory,
    this.popularity,
    this.rating,
    this.similarityScore,
  });

  /// Prix après réduction
  double get finalPrice {
    if (discount > 0) {
      return price * (1 - (discount / 100));
    }
    return price;
  }

  /// Montant de la réduction
  double get discountAmount {
    return price - finalPrice;
  }

  /// Vérifie si le produit a une réduction
  bool get hasDiscount {
    return discount > 0;
  }

  /// Factory pour créer un Product depuis JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
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
      'discount': discount,
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
    double? discount,
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
      discount: discount ?? this.discount,
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
        discount,
        imageUrl,
        category,
        subCategory,
        popularity,
        rating,
        similarityScore,
      ];
}
