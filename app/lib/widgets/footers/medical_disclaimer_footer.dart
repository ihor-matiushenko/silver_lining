import 'package:flutter/material.dart';
import '../dialogs/legal_info_dialog.dart';

/// 🩺 MedicalDisclaimerFooter: Clean, reusable banner linking to full medical & mental health disclaimer
class MedicalDisclaimerFooter extends StatelessWidget {
  const MedicalDisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}
