import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/history_item.dart';
import '../models/reframe_response.dart';
import 'auth_service.dart';
import 'reframing_service_interface.dart';

/// 🌐 Real API Service implementation connecting Flutter to Python FastAPI Backend & AI Engine.
class ApiReframingService implements ReframingServiceInterface {
  final String baseUrl;

  ApiReframingService({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? _getDefaultBaseUrl();

  /// Automatically resolves the correct backend host URL based on platform
  static String _getDefaultBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    // For native Android emulator, localhost is 10.0.2.2; for macOS/iOS it is 127.0.0.1
    return 'http://127.0.0.1:8000';
  }

  /// Builds standard HTTP headers, automatically attaching JWT token if user is authenticated
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final token = AuthService().accessToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @override
  Future<ReframeResponse> reframeThought(String inputText) async {
    final uri = Uri.parse('$baseUrl/api/v1/reframe');

    try {
      final response = await http.post(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode({
          'input_text': inputText,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ReframeResponse.fromJson(data);
      } else if (response.statusCode == 429) {
        // Handle Rate Limiter HTTP 429 Too Many Requests
        final Map<String, dynamic> data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Guest daily limit reached. Sign up for unlimited reframings!';
        return ReframeResponse(
          isSafe: true,
          safetyCategory: 'none',
          reframedText: detail,
          crisisTriggered: false,
        );
      }

      // Handle non-200 HTTP error responses gracefully
      return const ReframeResponse(
        isSafe: true,
        safetyCategory: 'none',
        reframedText: 'Server returned an unexpected error. Please check your backend connection and try again.',
        crisisTriggered: false,
      );
    } catch (e) {
      // Fallback if backend server is unreachable or offline
      return const ReframeResponse(
        isSafe: true,
        safetyCategory: 'none',
        reframedText: 'Could not connect to Silver Lining Python Backend. Please ensure uvicorn server is running on http://127.0.0.1:8000.',
        crisisTriggered: false,
      );
    }
  }

  /// 📜 Fetches all saved Cloud History records from PostgreSQL for authenticated user
  Future<List<HistoryItem>> fetchCloudHistory() async {
    final token = AuthService().accessToken;
    if (token == null) return [];

    final uri = Uri.parse('$baseUrl/api/v1/history');
    try {
      final response = await http.get(uri, headers: _buildHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) {
          final id = json['id'] ?? DateTime.now().toIso8601String();
          final prompt = json['prompt_text'] ?? '';
          final reframed = json['reframed_text'] ?? '';
          final isSafe = json['is_safe'] ?? true;
          final category = json['safety_category'] ?? 'none';
          final isFavorite = json['is_favorite'] ?? false;
          final dateStr = json['created_at'] != null
              ? json['created_at'].toString().split('T')[0]
              : 'Today';

          return HistoryItem(
            id: id,
            dateString: dateStr,
            promptText: prompt,
            response: ReframeResponse(
              isSafe: isSafe,
              safetyCategory: category,
              reframedText: reframed,
              crisisTriggered: false,
            ),
            isFavorite: isFavorite,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching Cloud History: $e');
    }
    return [];
  }

  /// ❤️ Toggles is_favorite (True <-> False) on a record in PostgreSQL
  Future<bool> toggleCloudFavorite(String recordId) async {
    final uri = Uri.parse('$baseUrl/api/v1/history/$recordId/favorite');
    try {
      final response = await http.post(uri, headers: _buildHeaders());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ Error toggling cloud favorite: $e');
      return false;
    }
  }

  /// 🗑️ Deletes a saved reframing record from PostgreSQL
  Future<bool> deleteCloudRecord(String recordId) async {
    final uri = Uri.parse('$baseUrl/api/v1/history/$recordId');
    try {
      final response = await http.delete(uri, headers: _buildHeaders());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ Error deleting cloud record: $e');
      return false;
    }
  }
}
