import 'package:equatable/equatable.dart';

/// Modèle pour un panier d'achat
class Cart extends Equatable {
  final String id;
  final String name;
  final String? description;
  final Map<String, int> items; // productId -> quantity
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cart({
    required this.id,
    required this.name,
    this.description,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Créer un nouveau panier vide
  factory Cart.create({
    required String name,
    String? description,
  }) {
    final now = DateTime.now();
    return Cart(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      items: {},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Créer depuis JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      items: Map<String, int>.from(json['items'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Copier avec modifications
  Cart copyWith({
    String? name,
    String? description,
    Map<String, int>? items,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Nombre total d'articles
  int get totalItems {
    return items.values.fold(0, (sum, qty) => sum + qty);
  }

  /// Vérifier si le panier est vide
  bool get isEmpty => items.isEmpty;

  /// Vérifier si le panier contient un produit
  bool containsProduct(String productId) {
    return items.containsKey(productId);
  }

  /// Obtenir la quantité d'un produit
  int getQuantity(String productId) {
    return items[productId] ?? 0;
  }

  @override
  List<Object?> get props => [id, name, description, items, createdAt, updatedAt];
}
