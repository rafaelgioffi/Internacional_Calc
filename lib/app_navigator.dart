import 'package:flutter/material.dart';
import 'package:international_calc/home_screen.dart';
import 'package:international_calc/salary_calculator_screen.dart';
import 'package:international_calc/shared/localization/translate_app.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

var chave = Uri.parse(
  'https://api.hgbrasil.com/finance?format=json-cors&key=fbfe6e34',
);

Future<Map<String, dynamic>> getData() async {
  try {
    print('🔍 Fazendo requisição para a API...');
    http.Response resposta = await http.get(chave);
    print('✅ Resposta recebida - Status: ${resposta.statusCode}');

    if (resposta.statusCode == 200) {
      var data = json.decode(resposta.body);
      print('📊 Dados recebidos: $data');
      return json.decode(resposta.body);
    } else {
      throw Exception('Failed to load data ${resposta.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
  // return json.decode(resposta.body);
}

class AppNavigator extends StatefulWidget {
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> _dadosMoeda;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _dadosMoeda = getData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dadosMoeda,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(TranslateApp(context).text('loading')),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!["results"] == null) {
          return Scaffold(
            body: Center(
              child: Text(TranslateApp(context).text('loadingerror')),
            ),
          );
        }

        // Se os dados carregaram, crie as telas e passe os dados
        final data = snapshot.data!;

        // Passa os dados brutos da API para as telas filhas
        _screens = [
          Home(apiData: data),
          SalaryCalculatorScreen(apiData: data),
        ];

        // Títulos (agora usam i18n)
        final List<String> _titles = [
          TranslateApp(context).text('converterTitle'),
          TranslateApp(context).text('salaryTitle')
        ];

        return Scaffold(
          appBar: AppBar(
            // O título muda dinamicamente
            title: Text(
              _titles[_selectedIndex],
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            centerTitle: true,
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.money),
                label: TranslateApp(context).text('converterTitle'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work),
                label: TranslateApp(context).text('salaryTitle'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor:
                Theme.of(context).colorScheme.primary, // Cor verde
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12.0,
            unselectedFontSize: 12.0,
          ),
        );
      },
    );
  }
}
