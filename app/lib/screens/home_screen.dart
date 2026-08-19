import 'package:flutter/material.dart';
import '../models/reframe_response.dart';
import '../services/mock_reframing_service.dart';
import '../services/reframing_service_interface.dart';
import '../theme/app_typography.dart';
import '../widgets/app_text_field.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/result_card.dart';

/// 📱 HomeScreen: Page layout component for entering concerns and displaying AI reframings.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  // Inject Reframing Service Interface (Currently using MockReframingService)
  final ReframingServiceInterface _service = MockReframingService();

  // Reactive state variables
  bool _isLoading = false;
  ReframeResponse? _response;

  Future<void> _processInput() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = null;
    });

    final result = await _service.reframeThought(text);

    setState(() {
      _isLoading = false;
      _response = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silver Lining AI'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Styled Glassmorphism Input Form Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("What's weighing on your mind?", style: AppTypography.subtitle),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _controller,
                    hintText: "Share what happened today, your concerns, or what feels tough...",
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Reframe Thought ✨',
                    isLoading: _isLoading,
                    onPressed: _processInput,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Render Result Card Widget
            if (_response != null) ResultCard(response: _response!),
          ],
        ),
      ),
    );
  }
}
