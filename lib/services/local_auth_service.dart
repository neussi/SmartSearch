import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:smartsearch/services/database_service.dart';
import 'package:smartsearch/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service d'authentification locale avec SQLite
class LocalAuthService {
  final DatabaseService _dbService = DatabaseService.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Hash un mot de passe avec SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Générer un token simple (UUID-like)
  String _generateToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return 'token_${timestamp}_$random';
  }

  /// Inscription d'un nouvel utilisateur
  Future<User> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final db = await _dbService.database;

    // Vérifier si l'email existe déjà
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (existing.isNotEmpty) {
      throw Exception('Cet email est déjà utilisé');
    }

    // Hash du mot de passe
    final passwordHash = _hashPassword(password);

    // Insérer le nouvel utilisateur
    final id = await db.insert('users', {
      'email': email.toLowerCase(),
      'password_hash': passwordHash,
      'name': name,
      'phone': phone,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Créer l'objet User
    final user = User(
      id: id.toString(),
      email: email.toLowerCase(),
      name: name,
      phone: phone,
      createdAt: DateTime.now(),
    );

    // Générer et sauvegarder le token
    final token = _generateToken();
    await _saveToken(token);
    await _saveUser(user);

    return user;
  }

  /// Connexion d'un utilisateur
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final db = await _dbService.database;

    // Hash du mot de passe
    final passwordHash = _hashPassword(password);

    // Rechercher l'utilisateur
    final results = await db.query(
      'users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email.toLowerCase(), passwordHash],
    );

    if (results.isEmpty) {
      throw Exception('Email ou mot de passe incorrect');
    }

    final userData = results.first;

    // Créer l'objet User
    final user = User(
      id: userData['id'].toString(),
      email: userData['email'] as String,
      name: userData['name'] as String,
      phone: userData['phone'] as String?,
      createdAt: DateTime.parse(userData['created_at'] as String),
    );

    // Générer et sauvegarder le token
    final token = _generateToken();
    await _saveToken(token);
    await _saveUser(user);

    return user;
  }

  /// Déconnexion
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  /// Récupérer le token sauvegardé
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Récupérer l'utilisateur sauvegardé
  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(userJson);
      return User.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  /// Sauvegarder le token
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Sauvegarder l'utilisateur
  Future<void> _saveUser(User user) async {
    await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }
}
