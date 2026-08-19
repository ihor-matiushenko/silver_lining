import 'package:flutter/material.dart';
import '../models/reframe_response.dart';
import '../services/mock_reframing_service.dart';
import '../services/reframing_service_interface.dart';
import '../widgets/app_bar/home_app_bar.dart';
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

  // Inject Reframing Service Interface (Currently using MockReframingService)
  final ReframingServiceInterface _service = MockReframingService();

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

    final result = await _service.reframeThought(text);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _response = result;
    });
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
          ],
        ),
      ),
    );
  }
}
