import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../models/reframe_response.dart';
import '../services/api_reframing_service.dart';
import '../services/auth_service.dart';
import '../services/dynamic_localization_service.dart';
import '../services/reframing_service_interface.dart';
import '../services/storage_service.dart';
import '../widgets/app_bar/home_app_bar.dart';
import '../widgets/dialogs/legal_info_dialog.dart';
import '../widgets/forms/input_form_card.dart';
import '../widgets/result_card.dart';

/// 📱 HomeScreen: Page layout component for entering concerns and displaying AI reframings.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  // Inject Real Live API Reframing Service connecting Flutter to Python FastAPI & Ollama AI
  final ReframingServiceInterface _service = ApiReframingService();

  // Reactive state variables
  bool _isLoading = false;
  ReframeResponse? _response;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processInput() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = null;
    });

    final result = await _service.reframeThought(
      text,
      targetLanguage: DynamicLocalizationService.instance.currentLangCode,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _response = result;
    });

    // Only save to local device storage if the user is a GUEST!
    // (Authenticated users have their thoughts synced to PostgreSQL by the backend)
    if (!AuthService().isAuthenticated &&
        result.isSafe &&
        !result.crisisTriggered &&
        result.reframedText != null) {
      final now = DateTime.now();
      final dateStr = 'Today, ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

      final newItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateString: dateStr,
        promptText: text,
        response: result,
      );

      await StorageService.saveHistoryItem(newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Reusable Input Form Component
            InputFormCard(
              controller: _controller,
              isLoading: _isLoading,
              onSubmit: _processInput,
            ),
            const SizedBox(height: 24),

            // Declarative Result Card Router
            if (_response != null) ResultCard(response: _response!),

            const SizedBox(height: 32),

            // 🩺 Store Compliance Medical & Wellness Disclaimer Footer (Apple 1.4.1 & Google Play Health)
            GestureDetector(
              onTap: () => LegalInfoDialog.showMedicalDisclaimer(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, size: 16, color: Colors.white38),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Silver Lining is an AI self-reflection tool, not medical or mental health care. Tap to read full disclaimer.',
                        style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

