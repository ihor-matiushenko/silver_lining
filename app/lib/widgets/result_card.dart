import 'package:flutter/material.dart';
import '../models/reframe_response.dart';
import 'cards/crisis_shield_card.dart';
import 'cards/error_feedback_card.dart';
import 'cards/policy_refusal_card.dart';
import 'cards/reframed_perspective_card.dart';

/// 🎯 Declarative Router Component that delegates to single-responsibility styled cards.
class ResultCard extends StatelessWidget {
  final ReframeResponse response;

  const ResultCard({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    if (response.crisisTriggered) {
      return CrisisShieldCard(
        hotlinePhone: response.emergencyHotline ?? '988',
      );
    }

    if (response.isError) {
      return ErrorFeedbackCard(response: response);
    }

    if (!response.isSafe) {
      return const PolicyRefusalCard();
    }

    return ReframedPerspectiveCard(
      text: response.reframedText ?? '',
    );
  }
}
