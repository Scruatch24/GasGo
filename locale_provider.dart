// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('ka'); // Default to Georgian

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

// A helper class for our supported locales
class L10n {
  static final all = [
    const Locale('ka'),
    const Locale('en'),
    const Locale('ru'),
  ];

  // Added helper method for language names
  static String getLanguageName(String code) {
    switch (code) {
      case 'ka':
        return 'ქართული';
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      default:
        return code;
    }
  }
}