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
  final hoursControlador = TextEditingController();

  final FocusNode annualFocus = FocusNode();
  final FocusNode monthlyFocus = FocusNode();
  final FocusNode hourlyFocus = FocusNode();
  final FocusNode hoursFocus = FocusNode();

  String _selectedCurrency = "USD";
  double _selectedRate = 1.0;
  String _selectedPrefix = "US\$ ";
  List<bool> _isSelected = [false, true, false, false];

// Variáveis para os resultados
  double _annualBRL = 0.0;
  double _monthlyBRL = 0.0;
  double _hourlyBRL = 0.0;

  // Cotações
  double dolar = 0.0;
  double euro = 0.0;
  double btc = 0.0;
  // Base de cálculo (pode ser ajustada)
  double _hoursPerMonth = 160.0;

  @override
  void initState() {
    super.initState();
    _parseApiData();

    _selectedRate = dolar;
    hoursControlador.text = _hoursPerMonth.toStringAsFixed(0);

    // Adiciona listeners para os botões 'X'
    annualControlador.addListener(_onTextChanged);
    monthlyControlador.addListener(_onTextChanged);
    hourlyControlador.addListener(_onTextChanged);
    hoursControlador.addListener(_onHoursChanged);

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
      print("Erro ao parsear dados da API no Salário: $e...");
      dolar = 1.0;
      euro = 1.0;
      btc = 1.0;
    }
  }

  @override
  void dispose() {
    annualControlador.removeListener(_onTextChanged);
    monthlyControlador.removeListener(_onTextChanged);
    hourlyControlador.removeListener(_onTextChanged);
    hoursControlador.removeListener(_onHoursChanged);

    annualFocus.removeListener(_onAnnualFocusChange);
    monthlyFocus.removeListener(_onMonthlyFocusChange);
    hourlyFocus.removeListener(_onHourlyFocusChange);

    annualControlador.dispose();
    monthlyControlador.dispose();
    hourlyControlador.dispose();
    hoursControlador.dispose();

    annualFocus.dispose();
    monthlyFocus.dispose();
    hourlyFocus.dispose();
    hoursFocus.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onAnnualFocusChange() {
    if (!annualFocus.hasFocus) _formatField(annualControlador, 2);
  }

  void _onMonthlyFocusChange() {
    if (!monthlyFocus.hasFocus) _formatField(monthlyControlador, 2);
  }

  void _onHourlyFocusChange() {
    if (!hourlyFocus.hasFocus) _formatField(hourlyControlador, 2);
  }

  void _onHoursChanged() {
    double? newHours = double.tryParse(hoursControlador.text);
    if (newHours != null && newHours > 0 && newHours <= 300) {
      if (newHours != _hoursPerMonth) {
        setState(() {
          _hoursPerMonth = newHours;
        });
        if (annualControlador.text.isNotEmpty) {
          _annualTroca(annualControlador.text);
        } else if (monthlyControlador.text.isNotEmpty) {
          _monthlyTroca(monthlyControlador.text);
        } else if (hourlyControlador.text.isNotEmpty) {
          _hourlyTroca(hourlyControlador.text);
        }
      }
    }
  }

  void _formatField(TextEditingController controller, int digits) {
    if (controller.text.isEmpty) return;
    final formatador = _getCurrencyFormat(context, digits);
    double value = _parseInput(controller.text, digits);
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
      _annualBRL = 0.0;
      _monthlyBRL = 0.0;
      _hourlyBRL = 0.0;
    });
  }

  double _parseInput(String text, int digits) {
    final formatador = _getCurrencyFormat(context, digits);
    String cleanText = text.replaceAll(formatador.symbols.GROUP_SEP, '');
    cleanText = cleanText.replaceAll(formatador.symbols.DECIMAL_SEP, '.');
    try {
      return double.parse(cleanText);
    } catch (e) {
      return 0.0;
    }
  }

  void _updateTextFields({bool forceClear = false}) {
    if (forceClear || _annualBRL == 0.0) {
      if (!annualFocus.hasFocus) annualControlador.clear();
      if (!monthlyFocus.hasFocus) monthlyControlador.clear();
      if (!hourlyFocus.hasFocus) hourlyControlador.clear();
      return;
      // monthlyControlador.clear();
      // hourlyControlador.clear();
      // return;
    }
    final formatador = _getCurrencyFormat(context, 2);

    if (!annualFocus.hasFocus) {
      annualControlador.text = formatador.format(_annualBRL / _selectedRate);
    }
    if (!monthlyFocus.hasFocus) {
      monthlyControlador.text = formatador.format(_monthlyBRL / _selectedRate);
    }
    if (!hourlyFocus.hasFocus) {
      hourlyControlador.text = formatador.format(_hourlyBRL / _selectedRate);
    }
  }

  void _annualTroca(String text) {
    if (!annualFocus.hasFocus) return;
    if (text.isEmpty) {
      _clearFields();
      return;
    }

    double annualInput = _parseInput(text, 2);

    setState(() {
      _annualBRL = annualInput * _selectedRate;
      _monthlyBRL = _annualBRL / 12;
      _hourlyBRL = _monthlyBRL / _hoursPerMonth;
    });
    _updateTextFields();
  }

  void _monthlyTroca(String text) {
    if (!monthlyFocus.hasFocus) return;
    if (text.isEmpty) {
      _clearFields();
      return;
    }

    double monthlyInput = _parseInput(text, 2);

    setState(() {
      _monthlyBRL = monthlyInput * _selectedRate;
      _annualBRL = _monthlyBRL * 12;
      _hourlyBRL = _hourlyBRL / _hoursPerMonth;
    });
    _updateTextFields();
  }

  void _hourlyTroca(String text) {
    if (!hourlyFocus.hasFocus) return;
    if (text.isEmpty) {
      _clearFields();
      return;
    }

    // final formatador = _getCurrencyFormat(context, 2);

    double hourlyInput = _parseInput(text, 2);
    // double monthly = hourly * _hoursPerMonth;
    // double annual = monthly * 12;

    // annualControlador.text = formatador.format(annual);
    // monthlyControlador.text = formatador.format(monthly);

    setState(() {
      _hourlyBRL = hourlyInput * _selectedRate;
      _monthlyBRL = _hourlyBRL * _hoursPerMonth;
      _annualBRL = _monthlyBRL * 12;
    });
    _updateTextFields();
  }

  //Seletor de moedas
  Widget _buildCurrencySelector() {
    return ToggleButtons(
      children: [
        Text("BRL"),
        Text("USD"),
        Text("EUR"),
        Text("BTC"),
      ],
      isSelected: _isSelected,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _isSelected.length; i++) {
            _isSelected[i] = i == index;
          }
          switch (index) {
            case 0:
              _selectedCurrency = "BRL";
              _selectedRate = 1.0;
              _selectedPrefix = "R\$ ";
              break;
            case 1:
              _selectedCurrency = "USD";
              _selectedRate = dolar;
              _selectedPrefix = "US\$ ";
              break;
            case 2:
              _selectedCurrency = "EUR";
              _selectedRate = euro;
              _selectedPrefix = "€ ";
              break;
            case 3:
              _selectedCurrency = "BTC";
              _selectedRate = btc;
              _selectedPrefix = "₿ ";
              break;
          }

          if (annualControlador.text.isEmpty && monthlyControlador.text.isEmpty && hourlyControlador.text.isEmpty) {
            return;
          }

          // Atualiza os campos de texto com a nova moeda
          _updateTextFields();
        });
      },
      borderRadius: BorderRadius.circular(8.0),
      selectedColor: Theme.of(context).colorScheme.onPrimary,
      color: Theme.of(context).colorScheme.primary,
      fillColor: Theme.of(context).colorScheme.primary,
    );
  }

  //slider das horas por mês...
  Widget _buildHoursSlider() {
    String hoursText = TranslateApp(context).text('salaryBased');
    hoursText = hoursText.replaceAll('{hours}', _hoursPerMonth.toStringAsFixed(0));
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          child: Text(hoursText, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Slider(
                value: _hoursPerMonth,
                min: 1,
                max: 300,
                divisions: 299,
                label: _hoursPerMonth.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _hoursPerMonth = value.roundToDouble();
                    hoursControlador.text = _hoursPerMonth.toStringAsFixed(0);
                  });
                  // Recalcula
                  _onHoursChanged();
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: TextField(
                controller: hoursControlador,
                focusNode: hoursFocus,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                onChanged: (_) => _onHoursChanged(),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // String hoursText = TranslateApp(context).text('salaryBased');
    // hoursText =
    //     hoursText.replaceAll('{hours}', _hoursPerMonth.toStringAsFixed(0));

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
              size: 100.0, color: Theme.of(context).colorScheme.primary),
          //Seletor de moedas...
          Center(child: _buildCurrencySelector()),
          Divider(),
          criaTextsFields(
            TranslateApp(context).text('salaryAnnual'),
            // "R\$ ",
            _selectedPrefix,
            annualControlador,
            annualFocus,
            _annualTroca,
          ),
          Divider(),
          criaTextsFields(
            TranslateApp(context).text('salaryMonthly'),
            // "R\$ ",
            _selectedPrefix,
            monthlyControlador,
            monthlyFocus,
            _monthlyTroca,
          ),
          Divider(),
          criaTextsFields(
            TranslateApp(context).text('salaryHourly'),
            // "R\$ ",
            _selectedPrefix,
            hourlyControlador,
            hourlyFocus,
            _hourlyTroca,
          ),
          Divider(),
          _buildHoursSlider(),
          Divider(),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          //   child: Text(hoursText,
          //       textAlign: TextAlign.center,
          //       style: Theme.of(context).textTheme.bodySmall),
          // ),

          // --- SEÇÃO DE RESULTADOS ---
          if (_annualBRL > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  TranslateApp(context).text('salaryResults'),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                if (_selectedCurrency != "BRL")
                _buildResultCard(
                  title: "BRL (R\$)",
                  annual: formatBRL.format(_annualBRL),
                  monthly: formatBRL.format(_monthlyBRL),
                  hourly: formatBRL.format(_hourlyBRL),
                ),
                if (_selectedCurrency != "USD")
                _buildResultCard(
                  title: "USD (US\$)",
                  annual: formatBRL.format(_annualBRL / dolar),
                  monthly: formatBRL.format(_monthlyBRL / dolar),
                  hourly: formatBRL.format(_hourlyBRL / dolar),
                ),
                if (_selectedCurrency != "EUR")
                _buildResultCard(
                  title: "EUR (€)",
                  annual: formatBRL.format(_annualBRL / euro),
                  monthly: formatBRL.format(_monthlyBRL / euro),
                  hourly: formatBRL.format(_hourlyBRL / euro),
                ),
                if(_selectedCurrency != "BTC")
                _buildResultCard(
                  title: "BTC (₿)",
                  annual: formatBTC.format(_annualBRL / btc),
                  monthly: formatBTC.format(_monthlyBRL / btc),
                  hourly: formatBTC.format(_hourlyBRL / btc),
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
    final titleStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary);
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
                Text(TranslateApp(context).text('salaryAnnual'),
                    style: labelStyle),
                Text(annual, style: valueStyle),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TranslateApp(context).text('salaryMonthly'),
                    style: labelStyle),
                Text(monthly, style: valueStyle),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TranslateApp(context).text('salaryHourly'),
                    style: labelStyle),
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
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none),
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
