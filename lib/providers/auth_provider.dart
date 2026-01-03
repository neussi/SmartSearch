import 'package:flutter/foundation.dart';
import 'package:smartsearch/models/user.dart';
import 'package:smartsearch/services/auth_service.dart';

/// Provider pour l'authentification
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({required AuthService authService})
      : _authService = authService;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  /// Initialiser - Vérifier si l'utilisateur est déjà connecté
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final token = await _authService.getToken();
      if (token != null) {
        _user = await _authService.getUser();
        notifyListeners();
      }
    } catch (e) {
      _setError('Erreur d\'initialisation: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Connexion
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.login(
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur de connexion: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Inscription
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur d\'inscription: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Erreur de déconnexion: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
