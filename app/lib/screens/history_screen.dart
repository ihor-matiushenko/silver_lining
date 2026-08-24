import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';

/// 📚 History & Favorites Screen Component (Connected to StorageService)
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showFavoritesOnly = false;
  bool _isLoading = true;
  List<HistoryItem> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final items = await StorageService.loadHistoryItems();
    if (!mounted) return;
    setState(() {
      _historyItems = items;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(HistoryItem item) async {
    setState(() {
      item.isFavorite = !item.isFavorite;
    });
    await StorageService.toggleFavorite(item.id);
  }

  Future<void> _deleteItem(HistoryItem item) async {
    setState(() {
      _historyItems.removeWhere((i) => i.id == item.id);
    });
    await StorageService.deleteHistoryItem(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final displayedItems = _showFavoritesOnly 
        ? _historyItems.where((i) => i.isFavorite).toList()
        : _historyItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Silver Linings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            // Filter Chips (All Saved vs Favorites)
            Row(
              children: [
                ChoiceChip(
                  label: Text('All Saved (${_historyItems.length})'),
                  selected: !_showFavoritesOnly,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => setState(() => _showFavoritesOnly = false),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: Text('♥ Favorites (${_historyItems.where((i) => i.isFavorite).length})'),
                  selected: _showFavoritesOnly,
                  selectedColor: AppColors.secondary,
                  onSelected: (_) => setState(() => _showFavoritesOnly = true),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // History Cards List View
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : displayedItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No saved silver linings yet.',
                            style: AppTypography.subtitle,
                          ),
                        )
                      : ListView.separated(
                          itemCount: displayedItems.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = displayedItems[index];
                            return GlassCard(
                              borderColor: item.isFavorite ? AppColors.secondary : AppColors.primary,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.dateString, style: AppTypography.subtitle),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: item.isFavorite ? AppColors.secondary : Colors.grey,
                                              size: 20,
                                            ),
                                            onPressed: () => _toggleFavorite(item),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                            onPressed: () => _deleteItem(item),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Text('"${item.promptText}"', style: AppTypography.titleBold),
                                  const SizedBox(height: 8),
                                  Text(item.response.reframedText ?? '', style: AppTypography.bodyMuted),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
