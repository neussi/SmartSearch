import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsearch/models/search_history_item.dart';

/// Service pour gérer l'historique de recherche
class SearchHistoryService {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 50;

  /// Ajouter une recherche à l'historique
  Future<void> addToHistory(SearchHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // Supprimer les doublons (même requête récente)
    history.removeWhere((h) => 
      h.type == item.type && 
      h.query == item.query &&
      DateTime.now().difference(h.timestamp).inMinutes < 5
    );

    // Ajouter en début de liste
    history.insert(0, item);

    // Limiter la taille
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    // Sauvegarder
    final jsonList = history.map((h) => h.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  /// Récupérer l'historique
  Future<List<SearchHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => SearchHistoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Supprimer un élément de l'historique
  Future<void> removeFromHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.removeWhere((h) => h.id == id);

    final jsonList = history.map((h) => h.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  /// Effacer tout l'historique
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Récupérer les recherches récentes (dernières 24h)
  Future<List<SearchHistoryItem>> getRecentSearches({int limit = 10}) async {
    final history = await getHistory();
    final now = DateTime.now();

    return history
        .where((h) => now.difference(h.timestamp).inHours < 24)
        .take(limit)
        .toList();
  }

  /// Récupérer les recherches populaires (les plus fréquentes)
  Future<List<String>> getPopularQueries({int limit = 5}) async {
    final history = await getHistory();
    
    // Compter les occurrences de chaque requête
    final queryCounts = <String, int>{};
    for (var item in history) {
      if (item.query != null && item.query!.isNotEmpty) {
        queryCounts[item.query!] = (queryCounts[item.query!] ?? 0) + 1;
      }
    }

    // Trier par fréquence
    final sortedQueries = queryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedQueries.take(limit).map((e) => e.key).toList();
  }
}
