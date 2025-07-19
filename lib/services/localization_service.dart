import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('en');

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('kr'),
  ];

  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'kr': 'Kurdish Sorani',
  };

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  String get currentLanguageName =>
      languageNames[currentLanguageCode] ?? 'English';

  /// Check if current language is RTL
  bool get isRTL => currentLanguageCode == 'kr';

  /// Get text direction for current language
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Initialize the service and load saved language
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null &&
          supportedLocales
              .any((locale) => locale.languageCode == savedLanguage)) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }

  /// Change the current language
  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLocales
        .any((locale) => locale.languageCode == languageCode)) {
      debugPrint('Unsupported language code: $languageCode');
      return;
    }

    try {
      _currentLocale = Locale(languageCode);
      notifyListeners();

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  /// Get locale by language code
  Locale? getLocaleByCode(String languageCode) {
    try {
      return supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if a locale is supported
  bool isLocaleSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }
}
