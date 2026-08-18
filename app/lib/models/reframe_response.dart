/// 📦 Data Model representing the Reframing & Safety response from the backend.
class ReframeResponse {
  final bool isSafe;
  final String safetyCategory;
  final String? reframedText;
  final bool crisisTriggered;
  final String? emergencyHotline;

  const ReframeResponse({
    required this.isSafe,
    required this.safetyCategory,
    this.reframedText,
    required this.crisisTriggered,
    this.emergencyHotline,
  });

  /// Factory constructor to convert JSON map (from API or Mock) into strongly-typed Dart object.
  factory ReframeResponse.fromJson(Map<String, dynamic> json) {
    return ReframeResponse(
      isSafe: json['is_safe'] ?? true,
      safetyCategory: json['safety_category'] ?? 'none',
      reframedText: json['reframed_text'],
      crisisTriggered: json['crisis_triggered'] ?? false,
      emergencyHotline: json['emergency_hotline'],
    );
  }

  /// Converts Dart object back to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'is_safe': isSafe,
      'safety_category': safetyCategory,
      'reframed_text': reframedText,
      'crisis_triggered': crisisTriggered,
      'emergency_hotline': emergencyHotline,
    };
  }
}
