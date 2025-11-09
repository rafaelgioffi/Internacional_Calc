import 'package:calculadora_dev_internacional/shared/localization/localization_app.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LocalizationsAppDelegate extends LocalizationsDelegate<LocalizationsApp>{
  static List<String> supported = ['en', 'es', 'pt'];
  const LocalizationsAppDelegate();

  @override
  bool isSupported(Locale locale) {
    return supported.contains(locale.languageCode);
  }

  @override
  Future<LocalizationsApp> load(Locale locale) async {
    // var localizations = LocalizationsApp(locale);
    final localizations = LocalizationsApp(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<LocalizationsApp> old) => false;
}