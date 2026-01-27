import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartsearch/config/theme_config.dart';
import 'package:smartsearch/config/routes.dart';
import 'package:smartsearch/models/search_history_item.dart';
import 'package:smartsearch/services/search_history_service.dart';

/// Écran d'historique de recherche
class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen>
    with SingleTickerProviderStateMixin {
  final SearchHistoryService _historyService = SearchHistoryService();
  List<SearchHistoryItem> _history = [];
  List<String> _popularQueries = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    final history = await _historyService.getHistory();
    final popularQueries = await _historyService.getPopularQueries();
    
    setState(() {
      _history = history;
      _popularQueries = popularQueries;
      _isLoading = false;
    });
    
    _animationController.forward();
  }

  Future<void> _deleteItem(String id) async {
    await _historyService.removeFromHistory(id);
    await _loadHistory();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Élément supprimé de l\'historique'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ThemeConfig.primaryColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Effacer l\'historique',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Voulez-vous vraiment effacer tout l\'historique de recherche ?',
          style: TextStyle(color: ThemeConfig.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      await _loadHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historique effacé'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ThemeConfig.primaryColor,
          ),
        );
      }
    }
  }

  void _repeatSearch(SearchHistoryItem item) {
    switch (item.type) {
      case SearchHistoryType.text:
        Navigator.pushNamed(
          context,
          AppRoutes.textSearch,
          arguments: {'query': item.query},
        );
        break;
      case SearchHistoryType.image:
        Navigator.pushNamed(context, AppRoutes.imageSearch);
        break;
      case SearchHistoryType.multimodal:
        Navigator.pushNamed(context, AppRoutes.combinedSearch);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeConfig.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: ThemeConfig.primaryColor,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historique de Recherche',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep,
                color: ThemeConfig.errorColor,
              ),
              onPressed: _clearAllHistory,
              tooltip: 'Effacer tout',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeConfig.primaryColor,
                ),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: _history.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              size: 80,
              color: ThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun historique',
            style: TextStyle(
              color: ThemeConfig.textPrimaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Vos recherches apparaîtront ici',
            style: TextStyle(
              color: ThemeConfig.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  ThemeConfig.primaryColor,
                  ThemeConfig.primaryLightColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.search),
              label: const Text('Commencer une recherche'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Recherches populaires
        if (_popularQueries.isNotEmpty) ...[
          const Text(
            'Recherches populaires',
            style: TextStyle(
              color: ThemeConfig.textPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularQueries.map((query) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.textSearch,
                      arguments: {'query': query},
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConfig.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 16,
                          color: ThemeConfig.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          query,
                          style: const TextStyle(
                            color: ThemeConfig.textPrimaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Historique complet
        const Text(
          'Historique',
          style: TextStyle(
            color: ThemeConfig.textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        ..._history.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildHistoryItem(item),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHistoryItem(SearchHistoryItem item) {
    final timeAgo = _getTimeAgo(item.timestamp);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _repeatSearch(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône du type de recherche
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(item.type),
                    color: ThemeConfig.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Détails
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: ThemeConfig.textPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: ThemeConfig.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              color: ThemeConfig.textSecondaryColor,
                              fontSize: 13,
                            ),
                          ),
                          if (item.resultsCount > 0) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: ThemeConfig.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.resultsCount} résultats',
                              style: const TextStyle(
                                color: ThemeConfig.textSecondaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Bouton supprimer
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: ThemeConfig.textSecondaryColor,
                    size: 20,
                  ),
                  onPressed: () => _deleteItem(item.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(SearchHistoryType type) {
    switch (type) {
      case SearchHistoryType.text:
        return Icons.text_fields;
      case SearchHistoryType.image:
        return Icons.camera_alt;
      case SearchHistoryType.multimodal:
        return Icons.auto_awesome;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }
}
