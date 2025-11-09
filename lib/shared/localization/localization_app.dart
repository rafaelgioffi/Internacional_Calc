import 'dart:convert';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'localization_app_delegate.dart';

class LocalizationsApp {
  final Locale locale;
  // Map<String, String> _localizationString;
  late Map<String, String> _localizationString;

  LocalizationsApp(this.locale);

  Future<bool> load() async {
    try {    
    String jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizationString = jsonMap.map((key, value) => MapEntry(key, value.toString()));

    return true;
  } catch (e) {
    print("Erro ao carregar localization: $e");
    _localizationString = {};
    return false;
  }
  }

  String translate(String key) {
    return _localizationString[key] ?? key;
  }

  static LocalizationsApp of(BuildContext context){
    return Localizations.of<LocalizationsApp>(context, LocalizationsApp)!;
  }

  static const LocalizationsAppDelegate delegate = LocalizationsAppDelegate();
}