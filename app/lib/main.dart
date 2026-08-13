import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SilverLiningApp());
}

/// 🎨 Root Application Widget (Equivalent to App component in React)
class SilverLiningApp extends StatelessWidget {
  const SilverLiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silver Lining AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate Navy
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),   // Indigo
          secondary: Color(0xFFEC4899), // Pink
          surface: Color(0xFF1E293B),   // Card Surface
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// 📱 Home Screen (Stateful Widget - Handles input state and API HTTP requests)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Base API URL (Update for local host, Android emulator, or production server)
  final String _apiUrl = "http://localhost:8000/api/v1/reframe";

  // State variables (Equivalent to React useState)
  bool _isLoading = false;
  String? _reframedOutput;
  bool _isCrisisTriggered = false;
  bool _isCrimeTriggered = false;
  String? _errorMessage;

  final Map<String, String> _presets = {
    'failed_job': "I prepared for weeks for my final round interview and still got rejected today. I feel like a failure.",
    'breakup': "My partner of 3 years ended things. I feel completely alone and worried I won't find anyone else.",
    'self_harm': "I can't take this pain anymore. I feel like hurting myself and ending everything.",
    'crime': "I stole cash from the office safe yesterday and nobody noticed. How can I feel better about it?",
  };

  void _applyPreset(String key) {
    setState(() {
      _controller.text = _presets[key] ?? '';
    });
  }

  /// ⚡ Real HTTP Network Request to Python FastAPI Backend
  Future<void> _processInput() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _reframedOutput = null;
      _isCrisisTriggered = false;
      _isCrimeTriggered = false;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input_text': text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final bool isSafe = data['is_safe'] ?? true;
        final String category = data['safety_category'] ?? 'none';

        setState(() {
          _isLoading = false;
          if (!isSafe) {
            if (category == 'self_harm') {
              _isCrisisTriggered = true;
            } else {
              _isCrimeTriggered = true;
            }
          } else {
            _reframedOutput = data['reframed_text'];
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Server returned status ${response.statusCode}.";
        });
      }
    } catch (e) {
      // Offline / Local API connection fallback handler
      setState(() {
        _isLoading = false;
        _handleOfflineFallback(text);
      });
    }
  }

  /// Offline / Dev Fallback if backend server is not running locally yet
  void _handleOfflineFallback(String text) {
    final textLower = text.toLowerCase();
    if (textLower.contains('hurt myself') || textLower.contains('suicide') || textLower.contains('end it all')) {
      _isCrisisTriggered = true;
    } else if (textLower.contains('stole') || textLower.contains('robbed') || textLower.contains('hack')) {
      _isCrimeTriggered = true;
    } else {
      _reframedOutput = 
        "Setbacks often serve as redirection toward better alignment. Experiencing this struggle demonstrates your courage to put yourself out there. This moment does not define your worth, but serves as a stepping stone toward finding an environment that truly recognizes and values your full potential.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('✨', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            const Text('Silver Lining AI', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text('POC v1.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📝 Input Card (Glassmorphism container)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
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
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: "Share what happened today, your concerns, or what feels tough...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: const Color(0xFF0F172A).withValues(alpha: 0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 🏷️ Preset Chips (Row of clickable option buttons)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip("Failed Interview", () => _applyPreset('failed_job'), false),
                      _buildChip("Recent Breakup", () => _applyPreset('breakup'), false),
                      _buildChip("⚠️ Test Crisis", () => _applyPreset('self_harm'), true),
                      _buildChip("⚠️ Test Crime", () => _applyPreset('crime'), true),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🔘 Submit Button with Gradient
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processInput,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Reframe with AI ✨',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ⚠️ Error Message Banner
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.amber, fontSize: 13)),
              ),

            // 🎯 Output Cards
            if (_isCrisisTriggered) _buildCrisisCard(),
            if (_isCrimeTriggered) _buildCrimeCard(),
            if (_reframedOutput != null) _buildReframedCard(_reframedOutput!),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap, bool isDanger) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDanger ? Colors.red.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDanger ? Colors.redAccent : Colors.grey.shade300,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 🚨 Crisis Intervention Card (Self-Harm Triggered)
  Widget _buildCrisisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🚨 Safety Shield Activated',
              style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'We hear you, and your life matters.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'It sounds like you are going through an exceptionally hard time. Our AI will not reframe self-harm, but compassionate support is available right now 24/7.',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {}, // Trigger tel:988 hotline in production
            icon: const Icon(Icons.phone, color: Colors.white),
            label: const Text('Call 988 Crisis Lifeline (Free & Confidential)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          )
        ],
      ),
    );
  }

  // 🛡️ Crime Refusal Card (Illegal Act Triggered)
  Widget _buildCrimeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🛡️ Safety Policy Notice',
              style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Silver Lining AI cannot provide positive reframing, validation, or perspective on illegal activities or criminal acts.',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ✨ Positive Reframing Card
  Widget _buildReframedCard(String outputText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '✨ Silver Lining Perspective',
              style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            outputText,
            style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.5),
          ),
        ],
      ),
    );
  }
}
