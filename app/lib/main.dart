import 'package:flutter/material.dart';

/// 1. Entry point of every Dart/Flutter application
void main() {
  runApp(const SilverLiningApp());
}

/// 2. Root Application Widget (Configures global theme & initial home screen)
class SilverLiningApp extends StatelessWidget {
  const SilverLiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silver Lining AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

/// 3. Home Screen Widget (Immutable widget configuration)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// 4. Home Screen State (Holds mutable variables, input controller, and setState logic)
class _HomeScreenState extends State<HomeScreen> {
  // Input controller to read text from TextField
  final TextEditingController _controller = TextEditingController();

  // Reactive state variable holding reframed output text
  String _reframedText = "";

  // Function called when the user taps "Reframe" button
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Mutates state and triggers UI re-render
    setState(() {
      _reframedText = "Silver Lining Perspective:\n$text";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silver Lining AI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Text Input
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "What is on your mind today?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Reframe Thought'),
            ),
            const SizedBox(height: 24),

            // Reframed Output Result
            if (_reframedText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _reframedText,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
