import 'package:flutter/material.dart';
import 'models/reframe_response.dart';
import 'services/mock_reframing_service.dart';
import 'services/reframing_service_interface.dart';
import 'theme/app_colors.dart';
import 'widgets/glass_card.dart';
import 'widgets/status_badge.dart';

void main() {
  runApp(const SilverLiningApp());
}

/// 🎨 Root Application Widget
class SilverLiningApp extends StatelessWidget {
  const SilverLiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silver Lining AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// 📱 Home Screen
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
            // Styled Glassmorphism Input Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What's weighing on your mind?",
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Share what happened today, your concerns, or what feels tough...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: AppColors.background.withValues(alpha: 0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processInput,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Reframe Thought ✨', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Render Output Views based on ReframeResponse
            if (_response != null) _buildResultCard(_response!),
          ],
        ),
      ),
    );
  }

  /// 🎯 Helper method returning reusable Styled Components
  Widget _buildResultCard(ReframeResponse res) {
    // Case 1: Safety Shield Activated (Self-Harm Crisis)
    if (res.crisisTriggered) {
      return GlassCard(
        borderColor: AppColors.danger,
        backgroundColor: AppColors.danger.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusBadge(label: '🚨 Safety Shield Activated', color: AppColors.danger),
            const SizedBox(height: 10),
            const Text(
              'We hear you, and your life matters. Our AI will not reframe self-harm, but 24/7 support is available.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {}, // Will trigger 988 phone call
              icon: const Icon(Icons.phone, color: Colors.white),
              label: const Text('Call 988 Crisis Lifeline'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      );
    }

    // Case 2: Crime Policy Refusal
    if (!res.isSafe) {
      return GlassCard(
        borderColor: AppColors.warning,
        backgroundColor: AppColors.warning.withValues(alpha: 0.1),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(label: '🛡️ Safety Policy Notice', color: AppColors.warning),
            SizedBox(height: 10),
            Text(
              'Silver Lining AI cannot provide positive reframing or perspective on illegal activities.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          ],
        ),
      );
    }

    // Case 3: Safe Positive Perspective
    return GlassCard(
      borderColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusBadge(label: '✨ Silver Lining Perspective', color: AppColors.success),
          const SizedBox(height: 12),
          Text(
            res.reframedText ?? '',
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
