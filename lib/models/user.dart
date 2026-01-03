import 'package:equatable/equatable.dart';

/// Modèle pour l'utilisateur
class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? profileImageUrl;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.profileImageUrl,
    this.createdAt,
  });

  /// Factory depuis JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Copier avec modifications
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, phone, profileImageUrl, createdAt];
}
