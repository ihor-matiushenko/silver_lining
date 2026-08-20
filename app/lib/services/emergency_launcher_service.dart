import 'package:url_launcher/url_launcher.dart';

/// 📞 Utility Service for triggering native emergency phone dialer & SMS lines.
class EmergencyLauncherService {
  /// Initiates a native OS phone call (e.g. 'tel:988' or '988')
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri url = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
