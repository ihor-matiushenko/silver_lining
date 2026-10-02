import 'package:flutter/material.dart';
import '../dialogs/legal_info_dialog.dart';

/// ⚖️ LegalLinksRow: Clean, centered row linking to Terms of Service and Privacy Policy
class LegalLinksRow extends StatelessWidget {
  const LegalLinksRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => LegalInfoDialog.showTermsOfService(context),
          child: const Text(
            'Terms of Service',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const Text('  •  ', style: TextStyle(color: Colors.white24, fontSize: 11)),
        GestureDetector(
          onTap: () => LegalInfoDialog.showPrivacyPolicy(context),
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
