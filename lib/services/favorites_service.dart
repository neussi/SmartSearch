import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer les favoris localement
class FavoritesService {
  static const String _favoritesKey = 'user_favorites';

  /// Récupérer la liste des IDs de produits favoris
  Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    
    if (favoritesJson == null) {
      return {};
    }
    
    try {
      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      return favoritesList.map((id) => id.toString()).toSet();
    } catch (e) {
      return {};
    }
  }

  /// Ajouter un produit aux favoris
  Future<void> addToFavorites(String productId) async {
    final favorites = await getFavorites();
    favorites.add(productId);
    await _saveFavorites(favorites);
  }

  /// Retirer un produit des favoris
  Future<void> removeFromFavorites(String productId) async {
    final favorites = await getFavorites();
    favorites.remove(productId);
    await _saveFavorites(favorites);
  }

  /// Vérifier si un produit est dans les favoris
  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.contains(productId);
  }

  /// Basculer l'état favori d'un produit
  Future<bool> toggleFavorite(String productId) async {
    final isFav = await isFavorite(productId);
    if (isFav) {
      await removeFromFavorites(productId);
      return false;
    } else {
      await addToFavorites(productId);
      return true;
    }
  }

  /// Effacer tous les favoris
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }

  /// Sauvegarder les favoris
  Future<void> _saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = favorites.toList();
    await prefs.setString(_favoritesKey, jsonEncode(favoritesList));
  }
}
