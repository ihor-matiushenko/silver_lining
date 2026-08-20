import 'package:flutter/material.dart';
import '../models/reframe_response.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';

/// 📚 History & Favorites Item Model
class HistoryItem {
  final String id;
  final String dateString;
  final String promptText;
  final ReframeResponse response;
  bool isFavorite;

  HistoryItem({
    required this.id,
    required this.dateString,
    required this.promptText,
    required this.response,
    this.isFavorite = false,
  });
}

/// 📚 History & Favorites Screen Component
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showFavoritesOnly = false;

  // Sample Mock History Data
  final List<HistoryItem> _historyItems = [
    HistoryItem(
      id: '1',
      dateString: 'Today, 2:15 PM',
      promptText: 'Failed final round interview for lead role',
      isFavorite: true,
      response: const ReframeResponse(
        isSafe: true,
        safetyCategory: 'none',
        reframedText: 'Rejection is often redirection toward a better alignment. Experiencing this struggle demonstrates your courage to put yourself out there.',
        crisisTriggered: false,
      ),
    ),
    HistoryItem(
      id: '2',
      dateString: 'Yesterday, 8:40 PM',
      promptText: 'Struggling with work-life balance and burnout',
      isFavorite: false,
      response: const ReframeResponse(
        isSafe: true,
        safetyCategory: 'none',
        reframedText: 'Recognizing your limits is the first necessary step toward establishing healthier personal boundaries and long-term well-being.',
        crisisTriggered: false,
      ),
    ),
  ];

  void _toggleFavorite(HistoryItem item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
    });
  }

  void _deleteItem(HistoryItem item) {
    setState(() {
      _historyItems.removeWhere((i) => i.id == item.id);
    });
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
              child: displayedItems.isEmpty
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
