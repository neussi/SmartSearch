/// Constantes de l'application
class AppConstants {
  // App Info
  static const String appName = 'SmartSearch';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxSearchResults = 50;

  // Timeouts
  static const int searchDebounceMs = 500;

  // Image
  static const double maxImageSizeMB = 5.0;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];

  // Cart
  static const int maxCartItemQuantity = 99;

  // Search
  static const int minSearchQueryLength = 2;
  static const int maxSearchHistoryItems = 20;

  // Price Format
  static const String currencySymbol = 'FCFA';
  static const String currencyFormat = '#,##0';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
}

/// Clés pour le stockage local
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userData = 'user_data';
  static const String searchHistory = 'search_history';
  static const String themeMode = 'theme_mode';
}

/// Messages d'erreur
class ErrorMessages {
  static const String networkError = 'Erreur de connexion. Vérifiez votre connexion internet.';
  static const String serverError = 'Erreur du serveur. Veuillez réessayer plus tard.';
  static const String unknownError = 'Une erreur inattendue s\'est produite.';
  static const String invalidCredentials = 'Email ou mot de passe incorrect.';
  static const String emailAlreadyExists = 'Cet email est déjà utilisé.';
  static const String invalidImage = 'Format d\'image invalide.';
  static const String imageTooLarge = 'L\'image est trop volumineuse (max 5MB).';
}

/// Messages de succès
class SuccessMessages {
  static const String loginSuccess = 'Connexion réussie!';
  static const String registerSuccess = 'Inscription réussie!';
  static const String addedToCart = 'Produit ajouté au panier';
  static const String removedFromCart = 'Produit retiré du panier';
  static const String cartCleared = 'Panier vidé';
}
