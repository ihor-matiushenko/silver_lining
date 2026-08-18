import 'package:flutter/material.dart';
import 'models/reframe_response.dart';
import 'services/mock_reframing_service.dart';
import 'services/reframing_service_interface.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFFEC4899),
          surface: Color(0xFF1E293B),
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

    // Call service interface method
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
            // User Text Input
            TextField(
              controller: _controller,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "What is on your mind today?",
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button with Loading Indicator
            ElevatedButton(
              onPressed: _isLoading ? null : _processInput,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Reframe Thought ✨', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 24),

            // Render Output Views based on ReframeResponse
            if (_response != null) _buildResultCard(_response!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ReframeResponse res) {
    // Case 1: Safety Shield Activated (Self-Harm Crisis)
    if (res.crisisTriggered) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🚨 Safety Shield Activated', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('We hear you, and your life matters. Our AI will not reframe self-harm, but 24/7 support is available.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {}, // Trigger phone call
              icon: const Icon(Icons.phone, color: Colors.white),
              label: const Text('Call 988 Crisis Lifeline'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )
          ],
        ),
      );
    }

    // Case 2: Crime Policy Refusal
    if (!res.isSafe) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber),
        ),
        child: const Text('🛡️ Silver Lining AI cannot provide positive reframing or perspective on illegal activities.', style: TextStyle(color: Colors.white70)),
      );
    }

    // Case 3: Safe Reframed Perspective Output
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨ Silver Lining Perspective', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(res.reframedText ?? '', style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white)),
        ],
      ),
    );
  }
}
