import 'package:international_calc/shared/localization/localization_app.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TranslateApp {
  final BuildContext context;

  TranslateApp(this.context);

  String text(String key) {
    try {
  return  LocalizationsApp.of(context).translate(key);
    } catch (e) {
      print("Erro ao traduzir a chave $key: $e");
      return key;
    }
  }
}