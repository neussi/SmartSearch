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
    // Helper pour parser le prix (ex: "150,000CFA" -> 150000.0)
    double parsePrice(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) {
        // Enlever tout sauf les chiffres
        String cleaned = val.replaceAll(RegExp(r'[^0-9]'), '');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    // Helper pour parser la réduction (ex: "-17%" -> 17.0)
    double parseDiscount(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) {
        String cleaned = val.replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    String imgUrl = '';
    if (json['images'] != null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      imgUrl = (json['images'] as List)[0];
    } else {
      imgUrl = json['imageUrl'] ?? json['image_url'] ?? '';
    }

    // Corriger l'URL si elle pointe vers localhost
    if (imgUrl.isNotEmpty) {
      imgUrl = imgUrl.replaceAll('localhost:8000', '185.198.27.20:9000');
      imgUrl = imgUrl.replaceAll('http://localhost:8000', 'http://185.198.27.20:9000');
      imgUrl = imgUrl.replaceAll('https://localhost:8000', 'http://185.198.27.20:9000');
    }

    return Product(
      id: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['nom'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsePrice(json['prix_apres'] ?? json['price']),
      discount: parseDiscount(json['reduction'] ?? json['discount']),
      imageUrl: imgUrl,
      category: json['categorie'] ?? json['category'],
      subCategory: json['sous_categorie'] ?? json['subCategory'] ?? json['sub_category'],
      popularity: json['popularity']?.toDouble(),
      rating: json['rating']?.toDouble(),
      similarityScore: json['similarity_score']?.toDouble() ?? json['similarityScore']?.toDouble(),
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
