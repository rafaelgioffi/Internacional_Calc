import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/currency_model.dart';

class ConverterController {
  CurrencyModel? currencies;

  final realCtrl = TextEditingController();
  final dolarCtrl = TextEditingController();
  final euroCtrl = TextEditingController();
  final btcCtrl = TextEditingController();

  String _format(double value, String locale, {int decimalDigits = 2}) {
    final f = NumberFormat.currency(
        locale: locale, symbol: '', decimalDigits: decimalDigits);
    return f.format(value);
  }

  double _parse(String text) {
    String clean = text.replaceAll('.', '').replaceAll(',', '.');
    if (text.isEmpty) return 0.0;

    clean = text.replaceAll(RegExp(r'[^0-9.,]'), '');
    clean = clean.replaceAll(',', '.');

    return double.tryParse(clean) ?? 0.0;
  }

  void clearAll() {
    realCtrl.clear();
    dolarCtrl.clear();
    euroCtrl.clear();
    btcCtrl.clear();
  }

  void onRealChanged(String text, String locale) {
    if (text.isEmpty) {
      clearAll();
      return;
    }
    if (currencies == null) return;

    double real = _parse(text);
    dolarCtrl.text = _format(real / currencies!.usd, locale);
    euroCtrl.text = _format(real / currencies!.eur, locale);
    btcCtrl.text = (real / currencies!.btc).toStringAsFixed(8);
  }

  void onDolarChanged(String text, String locale) {
    if (text.isEmpty) {
      clearAll();
      return;
    }
    if (currencies == null) return;

    double dolar = _parse(text);
    realCtrl.text = _format(dolar * currencies!.usd, locale);
    euroCtrl.text =
        _format((dolar * currencies!.usd) / currencies!.eur, locale);
    btcCtrl.text =
        ((dolar * currencies!.usd) / currencies!.btc).toStringAsFixed(8);
  }

  void onEuroChanged(String text, String locale) {
    if (text.isEmpty) {
      clearAll();
      return;
    }
    if (currencies == null) return;

    double euro = _parse(text);
    realCtrl.text = _format(euro * currencies!.eur, locale);
    dolarCtrl.text =
        _format((euro * currencies!.eur) / currencies!.usd, locale);
    btcCtrl.text =
        ((euro * currencies!.eur) / currencies!.btc).toStringAsFixed(8);
  }

  void onBtcChanged(String text, String locale) {
    if (text.isEmpty) {
      clearAll();
      return;
    }
    if (currencies == null) return;

    double btc = _parse(text);
    realCtrl.text = _format(btc * currencies!.btc, locale);
    dolarCtrl.text = _format((btc * currencies!.btc) / currencies!.usd, locale);
    euroCtrl.text = _format((btc * currencies!.btc) / currencies!.eur, locale);
  }

  void dispose() {
    realCtrl.dispose();
    dolarCtrl.dispose();
    euroCtrl.dispose();
    btcCtrl.dispose();
  }
}
