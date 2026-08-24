import 'dart:async';
import 'package:flutter/material.dart';

/// ✍️ Animated Typewriter Text Component (Reveals text character-by-character)
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration characterDelay;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.characterDelay = const Duration(milliseconds: 25),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  int _characterIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _characterIndex = 0;
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();
    if (widget.text.isEmpty) return;

    _timer = Timer.periodic(widget.characterDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_characterIndex < widget.text.length) {
        setState(() {
          _characterIndex++;
        });
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedText = widget.text.substring(0, _characterIndex);

    return Text(
      displayedText,
      style: widget.style,
    );
  }
}
