import 'package:flutter/material.dart';
import '../../services/api_reframing_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../glass_card.dart';

/// 🚩 ReportContentModal: User-facing GenAI content reporting modal (Apple Guideline 1.2 & Google GenAI Policy)
class ReportContentModal extends StatefulWidget {
  final String contentSnippet;
  final String? reframeId;

  const ReportContentModal({
    super.key,
    required this.contentSnippet,
    this.reframeId,
  });

  static Future<void> show(
    BuildContext context, {
    required String contentSnippet,
    String? reframeId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportContentModal(
        contentSnippet: contentSnippet,
        reframeId: reframeId,
      ),
    );
  }

  @override
  State<ReportContentModal> createState() => _ReportContentModalState();
}

class _ReportContentModalState extends State<ReportContentModal> {
  final _detailsController = TextEditingController();
  String _selectedReason = 'inappropriate';
  bool _isSubmitting = false;

  final Map<String, String> _reasons = const {
    'inappropriate': '⚠️ Offensive or Inappropriate',
    'harmful': '🚨 Harmful or Dangerous Advice',
    'inaccurate': '❓ Inaccurate or Low Quality',
    'other': '💬 Other Issue',
  };

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    final success = await ApiReframingService().submitReport(
      contentSnippet: widget.contentSnippet,
      reason: _selectedReason,
      details: _detailsController.text.trim(),
      reframeId: widget.reframeId,
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.surface : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              color: success ? AppColors.success : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                success
                    ? 'Report submitted. Our safety team will review this response.'
                    : 'Failed to submit report. Please check your connection.',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modal Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: const [
                  Icon(Icons.flag_rounded, color: AppColors.warning, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Report AI Response',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Help us keep Silver Lining safe and helpful. Tell us what went wrong with this response.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Snippet Preview
              GlassCard(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '"${widget.contentSnippet}"',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reason Selector
              const Text(
                'Reason for Report',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ..._reasons.entries.map((entry) {
                final isSelected = _selectedReason == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedReason = entry.key),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Optional details textfield
              TextField(
                controller: _detailsController,
                maxLines: 2,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'Additional details (optional)...',
                  hintStyle: AppTypography.bodyMuted,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: Text(_isSubmitting ? 'Submitting...' : 'Submit Report'),
                      onPressed: _isSubmitting ? null : _handleSubmit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
