import 'package:flutter/material.dart';
import '../../services/model_manager_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../glass_card.dart';

/// 🧠 AiModelStatusCard: Reactive Glassmorphic Card displaying On-Device SLM
/// status, tier selection (`Compact 249 MB` vs `Pro 286 MB`), resumable download
/// progress bar, and active offline indicator.
class AiModelStatusCard extends StatelessWidget {
  final ModelManagerService? manager;

  const AiModelStatusCard({super.key, this.manager});

  @override
  Widget build(BuildContext context) {
    final modelManager = manager ?? ModelManagerService.instance;

    return ListenableBuilder(
      listenable: modelManager,
      builder: (context, _) {
        final state = modelManager.state;
        final tier = modelManager.selectedTier;

        if (state == OnDeviceModelState.ready) {
          return GlassCard(
            key: const ValueKey('ai_model_status_card'),
            borderColor: AppColors.success,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.memory_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'On-Device AI Active • 100% Offline (${tier.id == 'compact_q4_k_m' ? 'Gemma 3 270M Q4' : 'Gemma 3 270M Q8'})',
                    key: const ValueKey('on_device_active_badge'),
                    style: AppTypography.badgeText.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('unload_on_device_model_button'),
                  tooltip: 'Switch to Cloud Mode',
                  icon: const Icon(
                    Icons.cloud_sync_outlined,
                    size: 18,
                    color: Colors.white54,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => modelManager.unloadAndDeleteCache(),
                ),
              ],
            ),
          );
        }

        if (state == OnDeviceModelState.downloading ||
            state == OnDeviceModelState.loading) {
          final pct = (modelManager.downloadProgress * 100).clamp(0, 100).toInt();
          final recMb = (modelManager.receivedBytes / (1024 * 1024)).toStringAsFixed(1);
          final totMb = (modelManager.totalBytes / (1024 * 1024)).toStringAsFixed(1);

          return GlassCard(
            key: const ValueKey('ai_model_status_card'),
            borderColor: AppColors.primary,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state == OnDeviceModelState.loading
                            ? 'Initializing On-Device Brain in Metal/CPU...'
                            : 'Downloading ${tier.displayName} ($pct%)',
                        style: AppTypography.badgeText.copyWith(color: Colors.white),
                      ),
                    ),
                    if (state == OnDeviceModelState.downloading)
                      TextButton(
                        key: const ValueKey('cancel_model_download_button'),
                        onPressed: modelManager.cancelDownload,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: state == OnDeviceModelState.loading
                        ? null
                        : modelManager.downloadProgress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$recMb MB / $totMb MB • SHA-256 Verified CDN',
                  style: AppTypography.subtitle.copyWith(fontSize: 11),
                ),
              ],
            ),
          );
        }

        return GlassCard(
          key: const ValueKey('ai_model_status_card'),
          borderColor: AppColors.primary.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.offline_bolt_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '100% On-Device AI Available (${tier.sizeMb.toStringAsFixed(0)} MB)',
                      style: AppTypography.badgeText.copyWith(color: Colors.white),
                    ),
                  ),
                  PopupMenuButton<OnDeviceModelTier>(
                    key: const ValueKey('model_tier_selector_button'),
                    tooltip: 'Select Brain Size',
                    initialValue: tier,
                    onSelected: modelManager.selectTier,
                    itemBuilder: (context) => OnDeviceModelTier.values
                        .map(
                          (t) => PopupMenuItem(
                            value: t,
                            child: Text(t.displayName),
                          ),
                        )
                        .toList(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tier == OnDeviceModelTier.compact ? 'Q4 (249MB)' : 'Q8 (286MB)',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    key: const ValueKey('download_offline_brain_button'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => modelManager.downloadAndLoadModel(),
                    icon: const Icon(Icons.download_rounded, size: 14),
                    label: const Text('Download'),
                  ),
                ],
              ),
              if (state == OnDeviceModelState.error &&
                  modelManager.errorMessage != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Download interrupted. Tap Download to resume.',
                  style: TextStyle(
                    color: AppColors.warning.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
