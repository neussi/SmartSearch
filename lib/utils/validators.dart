import 'package:smartsearch/utils/constants.dart';

/// Validateurs de formulaires
class Validators {
  /// Valider l'email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }

    return null;
  }

  /// Valider le mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Le mot de passe doit contenir au moins ${AppConstants.minPasswordLength} caractères';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Le mot de passe est trop long';
    }

    return null;
  }

  /// Valider la confirmation de mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  /// Valider le nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }

    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }

    return null;
  }

  /// Valider le téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Numéro de téléphone invalide';
    }

    return null;
  }

  /// Valider la quantité
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La quantité est requise';
    }

    final quantity = int.tryParse(value);

    if (quantity == null || quantity < 1) {
      return 'La quantité doit être au moins 1';
    }

    if (quantity > AppConstants.maxCartItemQuantity) {
      return 'Quantité maximale: ${AppConstants.maxCartItemQuantity}';
    }

    return null;
  }

  /// Valider la recherche
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une recherche';
    }

    if (value.trim().length < AppConstants.minSearchQueryLength) {
      return 'La recherche doit contenir au moins ${AppConstants.minSearchQueryLength} caractères';
    }

    return null;
  }
}
