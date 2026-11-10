import 'dart:async';
import '../models/reframe_response.dart';
import 'api_reframing_service.dart';
import 'auth_service.dart';
import 'local_safety_service.dart';
import 'model_manager_service.dart';
import 'reframing_service_interface.dart';

/// 🧠 OnDeviceReframingService: Pure 100% On-Device SLM Inference Engine (`llamadart` FFI)
///
/// Executes:
/// 1. `<1ms` Tier-1 (988 Crisis) & Tier-2 (Crime Regex) checks via `LocalSafetyService`.
/// 2. Local C++ `llama.cpp` inference on our MLX LoRA fine-tuned `Gemma 3 270M` GGUF
///    with empirically verified sampling (`parse_special=true`, `temp=0.0`, `penalty=1.0`).
/// 3. Output-level gray-area refusal detection (`**I cannot...` -> `PolicyRefusalCard`).
/// 4. Optional lightweight PostgreSQL Cloud History sync for authenticated users when online.
/// 5. Seamless fallback to `ApiReframingService` if the user has not yet downloaded the local model.
class OnDeviceReframingService implements ReframingServiceInterface {
  final ModelManagerService _modelManager;
  final ApiReframingService _cloudService;
  final bool fallbackToCloudWhenNotReady;

  OnDeviceReframingService({
    ModelManagerService? modelManager,
    ApiReframingService? cloudService,
    this.fallbackToCloudWhenNotReady = true,
  }) : _modelManager = modelManager ?? ModelManagerService.instance,
       _cloudService = cloudService ?? ApiReframingService();

  /// Builds the exact Gemma 3 instruction-tuned control prompt trained in Step 34.7b
  static String buildGemmaPrompt(
    String inputText, {
    String targetLanguage = 'auto',
  }) {
    final lang = targetLanguage.trim().isEmpty ? 'auto' : targetLanguage.trim();
    return '<start_of_turn>user\n'
        '[SilverLining | lang=$lang]\n'
        '${inputText.trim()}<end_of_turn>\n'
        '<start_of_turn>model\n';
  }

  @override
  Future<ReframeResponse> reframeThought(
    String inputText, {
    String targetLanguage = 'auto',
  }) async {
    final trimmed = inputText.trim();
    if (trimmed.isEmpty) {
      return const ReframeResponse(
        isSafe: true,
        safetyCategory: 'none',
        reframedText: '',
        crisisTriggered: false,
      );
    }

    // If the on-device `.gguf` brain is not loaded yet:
    if (!_modelManager.isModelReady) {
      if (fallbackToCloudWhenNotReady) {
        final cloudRes = await _cloudService.reframeThought(
          trimmed,
          targetLanguage: targetLanguage,
        );
        // If device is completely offline (network_error), still enforce <1ms local safety shield!
        if (cloudRes.isError && cloudRes.safetyCategory == 'network_error') {
          final offlineSafety = LocalSafetyService.evaluateInputSafety(trimmed);
          if (offlineSafety != null) return offlineSafety;
        }
        return cloudRes;
      } else {
        final safety = LocalSafetyService.evaluateInputSafety(trimmed);
        if (safety != null) return safety;
        return const ReframeResponse(
          isSafe: true,
          safetyCategory: 'model_not_ready',
          reframedText:
              'On-Device AI model is not downloaded yet. Please tap "Download Offline Brain" above.',
          crisisTriggered: false,
          isError: true,
        );
      }
    }

    // Step 1: <1ms Pure-Dart Tier-1 (Crisis 988) & Tier-2 (Crime Regex) Safety Evaluation
    final inputSafety = LocalSafetyService.evaluateInputSafety(trimmed);
    if (inputSafety != null) {
      return inputSafety;
    }

    // Step 2: Run 100% On-Device SLM Inference via llamadart (or debug generator in tests)
    try {
      final prompt = buildGemmaPrompt(trimmed, targetLanguage: targetLanguage);
      final rawOutput = await _modelManager.generateCompletion(prompt);
      final cleaned = rawOutput.replaceAll('<end_of_turn>', '').trim();

      // Step 3: Check if our fine-tuned Gemma 3 270M weights refused a gray-area prompt
      if (LocalSafetyService.isModelOutputRefusal(cleaned)) {
        return const ReframeResponse(
          isSafe: false,
          safetyCategory: 'crime_refusal',
          reframedText: null,
          crisisTriggered: false,
        );
      }

      // Step 4: If user is authenticated, sync the safe reframed thought to PostgreSQL Cloud History
      if (AuthService().isAuthenticated) {
        await _cloudService.saveCloudHistoryRecord(
          promptText: trimmed,
          reframedText: cleaned,
          language: targetLanguage,
        );
      }

      return ReframeResponse(
        isSafe: true,
        safetyCategory: 'none',
        reframedText: cleaned,
        crisisTriggered: false,
      );
    } catch (e) {
      return ReframeResponse(
        isSafe: true,
        safetyCategory: 'inference_error',
        reframedText: 'On-Device AI encountered an error: $e',
        crisisTriggered: false,
        isError: true,
      );
    }
  }
}
