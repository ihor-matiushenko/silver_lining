import '../models/reframe_response.dart';
import 'reframing_service_interface.dart';

/// 🎭 Mock implementation of the Reframing Service for Frontend-First UI testing.
class MockReframingService implements ReframingServiceInterface {
  @override
  Future<ReframeResponse> reframeThought(String inputText) async {
    // Simulate 600ms network latency
    await Future.delayed(const Duration(milliseconds: 600));

    final lower = inputText.toLowerCase().trim();

    // Safety Guardrail 1: Self-Harm / Crisis
    if (lower.contains('hurt myself') || 
        lower.contains('ending everything') || 
        lower.contains('suicide') || 
        lower.contains('end it all')) {
      return const ReframeResponse(
        isSafe: false,
        safetyCategory: 'self_harm',
        reframedText: null,
        crisisTriggered: true,
        emergencyHotline: 'tel:988',
      );
    }

    // Safety Guardrail 2: Crime / Illegal Acts
    if (lower.contains('stole') || 
        lower.contains('robbed') || 
        lower.contains('hack') || 
        lower.contains('drug deal')) {
      return const ReframeResponse(
        isSafe: false,
        safetyCategory: 'crime',
        reframedText: null,
        crisisTriggered: false,
        emergencyHotline: null,
      );
    }

    // Safe Input: Simulated AI Positive Reframing Perspective
    return const ReframeResponse(
      isSafe: true,
      safetyCategory: 'none',
      reframedText: 
        "Setbacks often serve as redirection toward better alignment. Experiencing this struggle demonstrates your courage to put yourself out there. This moment does not define your worth, but serves as a stepping stone toward finding an environment that truly recognizes and values your full potential.",
      crisisTriggered: false,
      emergencyHotline: null,
    );
  }
}
