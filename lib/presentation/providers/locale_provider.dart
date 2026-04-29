import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  void toggleLocale() {
    if (_locale.languageCode == 'ar') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('ar');
    }
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }
}
