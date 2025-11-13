import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:international_calc/shared/localization/translate_app.dart';

class SalaryCalculatorScreen extends StatefulWidget {
  final Map<String, dynamic> apiData;
  SalaryCalculatorScreen({required this.apiData});

  @override
  _SalaryCalculatorScreenState createState() => _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState extends State<SalaryCalculatorScreen> {
  final annualControlador = TextEditingController();
  final monthlyControlador = TextEditingController();
  final hourlyControlador = TextEditingController();

  final FocusNode annualFocus = FocusNode();
  final FocusNode monthlyFocus = FocusNode();
  final FocusNode hourlyFocus = FocusNode();

// Variáveis para os resultados
  double _annual = 0.0;
  double _monthly = 0.0;
  double _hourly = 0.0;

  // Cotações
  double dolar = 0.0;
  double euro = 0.0;
  double btc = 0.0;
  // Base de cálculo (pode ser ajustada)
  static const double _hoursPerMonth = 220.0;

  @override
  void initState() {
    super.initState();
    _parseApiData();
    // Adiciona listeners para os botões 'X'
    annualControlador.addListener(_onTextChanged);
    monthlyControlador.addListener(_onTextChanged);
    hourlyControlador.addListener(_onTextChanged);

    // Adiciona listeners para formatação ao perder o foco
    annualFocus.addListener(_onAnnualFocusChange);
    monthlyFocus.addListener(_onMonthlyFocusChange);
    hourlyFocus.addListener(_onHourlyFocusChange);
  }

void _parseApiData() {
    try {
      final results = widget.apiData["results"];
      final currencies = results["currencies"];
      final usd = currencies["USD"];
      final eur = currencies["EUR"];
      final btcCurrency = currencies["BTC"];

      dolar = (usd["sell"] ?? 0.0).toDouble();
      euro = (eur["sell"] ?? 0.0).toDouble();
      btc = (btcCurrency["sell"] ?? 0.0).toDouble();
    } catch (e) {
      print("Erro ao parsear dados da API no Salário: $e");
      dolar = 1.0; euro = 1.0; btc = 1.0;
    }
  }

  @override
  void dispose() {
    annualControlador.removeListener(_onTextChanged);
    monthlyControlador.removeListener(_onTextChanged);
    hourlyControlador.removeListener(_onTextChanged);

    annualFocus.removeListener(_onAnnualFocusChange);
    monthlyFocus.removeListener(_onMonthlyFocusChange);
    hourlyFocus.removeListener(_onHourlyFocusChange);

    annualControlador.dispose();
    monthlyControlador.dispose();
    hourlyControlador.dispose();

    annualFocus.dispose();
    monthlyFocus.dispose();
    hourlyFocus.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onAnnualFocusChange() {
    if (!annualFocus.hasFocus) _formatField(annualControlador);
  }

  void _onMonthlyFocusChange() {
    if (!monthlyFocus.hasFocus) _formatField(monthlyControlador);
  }

  void _onHourlyFocusChange() {
    if (!hourlyFocus.hasFocus) _formatField(hourlyControlador);
  }

  void _formatField(TextEditingController controller) {
    if (controller.text.isEmpty) return;
    final formatador = _getCurrencyFormat(context, 2);
    double value = _parseInput(controller.text);
    setState(() {
      controller.text = formatador.format(value);
    });
  }

  NumberFormat _getCurrencyFormat(BuildContext context, int decimalDigits) {
    final deviceLocale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.currency(
      locale: deviceLocale,
      symbol: '',
      decimalDigits: decimalDigits,
    );
  }

  void _clearFields() {
    annualControlador.clear();
    monthlyControlador.clear();
    hourlyControlador.clear();
    setState(() {
      _annual = 0.0;
      _monthly = 0.0;
      _hourly = 0.0;
    });
  }

  double _parseInput(String text) {
    final formatador = _getCurrencyFormat(context, 2);
    String cleanText = text.replaceAll(formatador.symbols.GROUP_SEP, '');
    cleanText = cleanText.replaceAll(formatador.symbols.DECIMAL_SEP, '.');
    try {
      return double.parse(cleanText);
    } catch (e) {
      return 0.0;
    }
  }

  void _annualTroca(String text) {
    if (!annualFocus.hasFocus) return;
    if (text.isEmpty) {
      _clearFields();
      return;
    }

    final formatador = _getCurrencyFormat(context, 2);
    
    double annual = _parseInput(text);
    double monthly = annual / 12;
    double hourly = monthly / _hoursPerMonth;

    monthlyControlador.text = formatador.format(monthly);
    hourlyControlador.text = formatador.format(hourly);

    setState(() {
      _annual = annual;
      _monthly = monthly;
      _hourly = hourly;
    });
  }

  void _monthlyTroca(String text) {
    if (!monthlyFocus.hasFocus) return;
    if (text.isEmpty) {
      _clearFields();
      return;
    }

    final formatador = _getCurrencyFormat(context, 2);
    double monthly = _parseInput(text);

    double annual = monthly * 12;
    double hourly = monthly / _hoursPerMonth;

    annualControlador.text = formatador.format(annual);
    hourlyControlador.text = formatador.format(hourly);
    
    setState(() {
      _annual = annual;
      _monthly = monthly;
      _hourly = hourly;
    });
  }

  void _hourlyTroca(String text) {
    if (!hourlyFocus.hasFocus) return;
    if (text.isEmpty) {
      _clearFields();
      return;
    }

    final formatador = _getCurrencyFormat(context, 2);

    double hourly = _parseInput(text);
    double monthly = hourly * _hoursPerMonth;
    double annual = monthly * 12;

    annualControlador.text = formatador.format(annual);
    monthlyControlador.text = formatador.format(monthly);

    setState(() {
      _annual = annual;
      _monthly = monthly;
      _hourly = hourly;
    });
  }

  @override
  Widget build(BuildContext context) {
    String hoursText = TranslateApp(context).text('salaryBased');
    hoursText = hoursText.replaceAll('{hours}', _hoursPerMonth.toStringAsFixed(0));

    // Formatadores para os resultados
    final formatBRL = _getCurrencyFormat(context, 2);
    final formatBTC = _getCurrencyFormat(context, 8); // BTC com mais casas

    // Esta tela retorna seu próprio 'SingleChildScrollView'
    return SingleChildScrollView(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pode colocar um ícone ou logo aqui
          Icon(Icons.calculate,
              size: 150.0, color: Theme.of(context).colorScheme.primary),
          Divider(),
          criaTextsFields(
            TranslateApp(context).text('salaryAnnual'),
            "R\$ ",
            annualControlador,
            annualFocus,
            _annualTroca,
          ),
          Divider(),
          criaTextsFields(
            TranslateApp(context).text('salaryMonthly'),
            "R\$ ",
            monthlyControlador,
            monthlyFocus,
            _monthlyTroca,
          ),
          Divider(),
          criaTextsFields(
            TranslateApp(context).text('salaryHourly'),
            "R\$ ",
            hourlyControlador,
            hourlyFocus,
            _hourlyTroca,
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Text(
              hoursText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // --- SEÇÃO DE RESULTADOS ---
          if (_annual > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  TranslateApp(context).text('salaryResults'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                // BRL
                _buildResultCard(
                  title: "BRL (R\$)",
                  annual: formatBRL.format(_annual),
                  monthly: formatBRL.format(_monthly),
                  hourly: formatBRL.format(_hourly),
                ),
                // USD
                _buildResultCard(
                  title: "USD (US\$)",
                  annual: formatBRL.format(_annual / dolar),
                  monthly: formatBRL.format(_monthly / dolar),
                  hourly: formatBRL.format(_hourly / dolar),
                ),
                // EUR
                _buildResultCard(
                  title: "EUR (€)",
                  annual: formatBRL.format(_annual / euro),
                  monthly: formatBRL.format(_monthly / euro),
                  hourly: formatBRL.format(_hourly / euro),
                ),
                // BTC
                _buildResultCard(
                  title: "BTC (₿)",
                  annual: formatBTC.format(_annual / btc),
                  monthly: formatBTC.format(_monthly / btc),
                  hourly: formatBTC.format(_hourly / btc),
                ),
              ],
            )
        ],
      ),
    );
  }

  // Card de Resultado
  Widget _buildResultCard({
    required String title,
    required String annual,
    required String monthly,
    required String hourly,
  }) {
    final titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary);
    final labelStyle = Theme.of(context).textTheme.bodyMedium;
    final valueStyle = labelStyle?.copyWith(fontWeight: FontWeight.bold);

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primary.withAlpha(20),
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            Divider(color: Theme.of(context).colorScheme.primary.withAlpha(50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TranslateApp(context).text('salaryAnnual'), style: labelStyle),
                Text(annual, style: valueStyle),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TranslateApp(context).text('salaryMonthly'), style: labelStyle),
                Text(monthly, style: valueStyle),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TranslateApp(context).text('salaryHourly'), style: labelStyle),
                Text(hourly, style: valueStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget criaTextsFields(
    String texto,
    String prefix,
    TextEditingController c,
    FocusNode focus,
    Function(String) f,
  ) {
    return TextField(
      controller: c,
      focusNode: focus,
      decoration: InputDecoration(
        labelText: texto,
        labelStyle:
            TextStyle(color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        prefixText: prefix,
        prefixStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary, fontSize: 25.0),
        suffixIcon: c.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.green[400]),
                onPressed: _clearFields,
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary.withAlpha(20),
      ),
      style: TextStyle(
          color: Theme.of(context).colorScheme.primary, fontSize: 25.0),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: f,
    );
  }
}