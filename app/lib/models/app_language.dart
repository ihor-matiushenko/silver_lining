/// Model representing any dynamic ISO language code requested by the client or device
class AppLanguage {
  final String code; // "auto" or any ISO code like "uk", "es", "de", "fr", "ja", etc.
  final String displayName;

  const AppLanguage({
    required this.code,
    required this.displayName,
  });

  factory AppLanguage.fromCode(String code) {
    final cleanCode = code.toLowerCase().trim();
    if (cleanCode == 'auto') {
      return const AppLanguage(code: 'auto', displayName: 'Auto-Detect');
    }
    return AppLanguage(code: cleanCode, displayName: cleanCode.toUpperCase());
  }
}
