import 'reframe_response.dart';

/// 📚 History & Favorites Item Data Model
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_string': dateString,
      'prompt_text': promptText,
      'response': response.toJson(),
      'is_favorite': isFavorite,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      dateString: json['date_string'],
      promptText: json['prompt_text'],
      response: ReframeResponse.fromJson(Map<String, dynamic>.from(json['response'])),
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}
