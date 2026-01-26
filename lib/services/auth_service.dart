import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartsearch/config/api_config.dart';
import 'package:smartsearch/models/user.dart';
import 'package:smartsearch/services/api_service.dart';

/// Service d'authentification
class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthService({
    required ApiService apiService,
    FlutterSecureStorage? secureStorage,
  })  : _apiService = apiService,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Connexion
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        body: {
          'email': email,
          'password': password,
        },
      );

      final token = response['access_token'] ?? response['token'];
      final userData = response['user'];

      if (token == null || userData == null) {
        throw const ApiException(
          statusCode: 400,
          message: 'Réponse d\'authentification invalide',
        );
      }

      // Sauvegarder le token
      await _saveToken(token);

      // Créer l'utilisateur
      final user = User.fromJson(userData);

      // Sauvegarder les données utilisateur
      await _saveUser(user);

      // Définir le token dans le service API
      _apiService.setAuthToken(token);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Inscription
  Future<User> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.registerEndpoint,
        body: {
          'email': email,
          'password': password,
          'name': name,
          if (phone != null) 'phone': phone,
        },
      );

      final token = response['access_token'] ?? response['token'];
      final userData = response['user'];

      if (token == null || userData == null) {
        throw const ApiException(
          statusCode: 400,
          message: 'Réponse d\'inscription invalide',
        );
      }

      // Sauvegarder le token
      await _saveToken(token);

      // Créer l'utilisateur
      final user = User.fromJson(userData);

      // Sauvegarder les données utilisateur
      await _saveUser(user);

      // Définir le token dans le service API
      _apiService.setAuthToken(token);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
    _apiService.setAuthToken(null);
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
      // Si l'ancienne méthode de sauvegarde était utilisée (toString), cela va échouer
      // On ignore l'erreur
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
