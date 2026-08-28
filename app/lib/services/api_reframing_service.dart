import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/reframe_response.dart';
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

  @override
  Future<ReframeResponse> reframeThought(String inputText) async {
    final uri = Uri.parse('$baseUrl/api/v1/reframe');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input_text': inputText,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ReframeResponse.fromJson(data);
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
}
