import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_model.dart';

class CurrencyService {
  static const String _url =
      'https://api.hgbrasil.com/finance?format=json-cors&key=fbfe6e34';

  Future<CurrencyModel> getCurrencies() async {
    try {
      print('🔍 Fazendo requisição para a API...');
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        print('📊 Dados recebidos!');
        final body = json.decode(response.body);
        return CurrencyModel.fromJson(body);
      } else {
        throw Exception('Erro na API... ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}
