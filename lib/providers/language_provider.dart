import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('ar', 'SA');

  Locale get currentLocale => _currentLocale;

  bool get isArabic => _currentLocale.languageCode == 'ar';

  void setLanguage(String languageCode) {
    if (languageCode == 'ar') {
      _currentLocale = const Locale('ar', 'SA');
    } else {
      _currentLocale = const Locale('en', 'US');
    }
    notifyListeners();
  }

  void toggleLanguage() {
    if (isArabic) {
      setLanguage('en');
    } else {
      setLanguage('ar');
    }
  }
}
