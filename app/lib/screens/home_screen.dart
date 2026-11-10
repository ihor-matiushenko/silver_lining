import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../models/reframe_response.dart';
import '../services/auth_service.dart';
import '../services/dynamic_localization_service.dart';
import '../services/model_manager_service.dart';
import '../services/on_device_reframing_service.dart';
import '../services/reframing_service_interface.dart';
import '../services/storage_service.dart';
import '../widgets/app_bar/home_app_bar.dart';
import '../widgets/cards/ai_model_status_card.dart';
import '../widgets/footers/medical_disclaimer_footer.dart';
import '../widgets/forms/input_form_card.dart';
import '../widgets/result_card.dart';

/// 📱 HomeScreen: Page layout component for entering concerns and displaying AI reframings.
class HomeScreen extends StatefulWidget {
  final ReframingServiceInterface? service;

  const HomeScreen({super.key, this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  // Uses OnDeviceReframingService (100% offline Gemma 3 270M GGUF when ready, with seamless Cloud fallback)
  late final ReframingServiceInterface _service =
      widget.service ?? OnDeviceReframingService();

  // Reactive state variables
  bool _isLoading = false;
  ReframeResponse? _response;

  @override
  void initState() {
    super.initState();
    ModelManagerService.instance.checkAndAutoLoadCachedModel();
  }

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

    // Only save to local device storage if the user is a GUEST and the response is not an error!
    // (Authenticated users have their thoughts synced to PostgreSQL by the backend)
    if (!AuthService().isAuthenticated &&
        result.isSafe &&
        !result.isError &&
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
    } else if (AuthService().isAuthenticated &&
        result.isSafe &&
        !result.isError &&
        !result.crisisTriggered &&
        result.reframedText != null) {
      // ☁️ Signal history listeners that an authenticated cloud record has been persisted
      StorageService.historyRevision.value++;
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
            // 🧠 On-Device AI Status & One-Tap Model Downloader Card
            const AiModelStatusCard(),
            const SizedBox(height: 16),

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
            const MedicalDisclaimerFooter(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

