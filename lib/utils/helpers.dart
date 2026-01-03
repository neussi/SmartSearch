import 'package:intl/intl.dart';
import 'package:smartsearch/utils/constants.dart';

/// Fonctions utilitaires
class Helpers {
  /// Formater le prix
  static String formatPrice(double price) {
    final formatter = NumberFormat(AppConstants.currencyFormat, 'fr_FR');
    return '${formatter.format(price)} ${AppConstants.currencySymbol}';
  }

  /// Formater la date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }

  /// Formater la date et l'heure
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(dateTime);
  }

  /// Calculer le pourcentage de réduction
  static String formatDiscount(double discount) {
    return '-${discount.toStringAsFixed(0)}%';
  }

  /// Vérifier si une image est valide
  static bool isValidImageExtension(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return AppConstants.allowedImageExtensions.contains(extension);
  }

  /// Convertir les octets en MB
  static double bytesToMB(int bytes) {
    return bytes / (1024 * 1024);
  }

  /// Vérifier la taille de l'image
  static bool isImageSizeValid(int bytes) {
    final sizeMB = bytesToMB(bytes);
    return sizeMB <= AppConstants.maxImageSizeMB;
  }

  /// Raccourcir le texte
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Obtenir les initiales du nom
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Formater le nombre d'articles
  static String formatItemCount(int count) {
    if (count == 0) return 'Aucun article';
    if (count == 1) return '1 article';
    return '$count articles';
  }

  /// Débouncer pour la recherche
  static Future<void> debounce(
    Duration duration,
    Function() action,
  ) async {
    await Future.delayed(duration);
    action();
  }
}
