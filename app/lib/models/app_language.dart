/// Model representing language options for selection and display
class AppLanguage {
  final String code; // "system", "en", "uk", "es", "de", "fr", or any ISO code
  final String displayName;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.displayName,
    required this.nativeName,
    required this.flag,
  });

  /// Predefined core supported languages with clean native labeling
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'system',
      displayName: 'System Default',
      nativeName: 'Follow Device',
      flag: '📱',
    ),
    AppLanguage(
      code: 'en',
      displayName: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    AppLanguage(
      code: 'uk',
      displayName: 'Ukrainian',
      nativeName: 'Українська',
      flag: '🇺🇦',
    ),
    AppLanguage(
      code: 'es',
      displayName: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
    AppLanguage(
      code: 'de',
      displayName: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
    ),
    AppLanguage(
      code: 'fr',
      displayName: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
  ];

  factory AppLanguage.fromCode(String code) {
    final cleanCode = code.toLowerCase().trim();
    for (final lang in supportedLanguages) {
      if (lang.code == cleanCode) return lang;
    }
    if (cleanCode == 'auto') {
      return const AppLanguage(
        code: 'auto',
        displayName: 'Auto-Detect',
        nativeName: 'Auto',
        flag: '✨',
      );
    }
    return AppLanguage(
      code: cleanCode,
      displayName: cleanCode.toUpperCase(),
      nativeName: cleanCode.toUpperCase(),
      flag: '🌐',
    );
  }
}
