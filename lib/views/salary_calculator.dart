import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:international_calc/shared/localization/translate_app.dart';
import '../models/currency_model.dart';
import '../controllers/salary_controller.dart';

class SalaryCalculator extends StatefulWidget {
  // Agora aceita o Objeto, não um Map
  final CurrencyModel currencies; 
  
  SalaryCalculator({required this.currencies});

  @override
  _SalaryCalculatorState createState() => _SalaryCalculatorState();
}

class _SalaryCalculatorState extends State<SalaryCalculator> {
  final SalaryController _controller = SalaryController();

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

  int _currentDecimalPlaces = 2;

  double _annualBRL = 0.0;
  double _monthlyBRL = 0.0;
  double _hourlyBRL = 0.0;

  late double dolar;
  late double euro;
  late double btc;
  
  double _hoursPerMonth = 160.0;

  @override
  void initState() {
    super.initState();
    
    dolar = widget.currencies.usd;
    euro = widget.currencies.eur;
    btc = widget.currencies.btc;
    
    // Configuração inicial
    _selectedRate = dolar; 
    _currentDecimalPlaces = 2; 
    hoursControlador.text = _hoursPerMonth.toStringAsFixed(0);

    // Listeners
    annualControlador.addListener(_onTextChanged);
    monthlyControlador.addListener(_onTextChanged);
    hourlyControlador.addListener(_onTextChanged);
    hoursControlador.addListener(_onHoursChanged); 

    annualFocus.addListener(_onAnnualFocusChange);
    monthlyFocus.addListener(_onMonthlyFocusChange);
    hourlyFocus.addListener(_onHourlyFocusChange);
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

  void _onTextChanged() { setState(() {}); }
  
  void _onAnnualFocusChange() { 
    if (!annualFocus.hasFocus) _formatField(annualControlador, _currentDecimalPlaces); 
    }
  void _onMonthlyFocusChange() { if (!monthlyFocus.hasFocus) _formatField(monthlyControlador, _currentDecimalPlaces); }
  void _onHourlyFocusChange() { if (!hourlyFocus.hasFocus) _formatField(hourlyControlador, _currentDecimalPlaces); }
  
  void _onHoursChanged() {
    double? newHours = double.tryParse(hoursControlador.text);
    if (newHours == null || newHours <= 0 || newHours > 300) return;

    if (newHours != _hoursPerMonth) {
      setState(() {
        _hoursPerMonth = newHours;
      });
      // Recalcula
      if (annualControlador.text.isNotEmpty) _annualTroca(annualControlador.text);
      else if (monthlyControlador.text.isNotEmpty) _monthlyTroca(monthlyControlador.text);
      else if (hourlyControlador.text.isNotEmpty) _hourlyTroca(hourlyControlador.text);
    }
  }

  void _formatField(TextEditingController controller, int digits) {
    if (controller.text.isEmpty) return;
    final formatador = _getCurrencyFormat(context, digits);
    double value = _controller.parseInput(controller.text); 
    setState(() { controller.text = formatador.format(value); });
  }

  NumberFormat _getCurrencyFormat(BuildContext context, int decimalDigits) {
    final deviceLocale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.currency(
      locale: deviceLocale, symbol: '', decimalDigits: decimalDigits);
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
  
  void _updateTextFields({bool forceClear = false}) {
    if (forceClear || _annualBRL == 0.0) {
      if (!annualFocus.hasFocus) annualControlador.clear();
      if (!monthlyFocus.hasFocus) monthlyControlador.clear();
      if (!hourlyFocus.hasFocus) hourlyControlador.clear();
      return;
    }
    final formatador = _getCurrencyFormat(context, _currentDecimalPlaces);
    
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
    if (text.isEmpty) { _clearFields(); return; }
    double annualInput = _controller.parseInput(text);
    setState(() {
      _annualBRL = annualInput * _selectedRate;
      // _monthlyBRL = _annualBRL / 12;
      _monthlyBRL = _controller.calculateMonthlyFromAnnual(_annualBRL);
      // _hourlyBRL = _monthlyBRL / _hoursPerMonth;
      _hourlyBRL = _controller.calculateHourlyFromMonthly(_monthlyBRL, _hoursPerMonth);
    });
    _updateTextFields();
  }

  void _monthlyTroca(String text) {
    if (!monthlyFocus.hasFocus) return;
    if (text.isEmpty) { _clearFields(); return; }
    double monthlyInput = _controller.parseInput(text);
    setState(() {
      _monthlyBRL = monthlyInput * _selectedRate;
      _annualBRL = _controller.calculateAnnualFromMonthly(_monthlyBRL);
      _hourlyBRL = _controller.calculateHourlyFromMonthly(_monthlyBRL, _hoursPerMonth); 
    });
    _updateTextFields();
  }

  void _hourlyTroca(String text) {
    if (!hourlyFocus.hasFocus) return;
    if (text.isEmpty) { _clearFields(); return; }
    double hourlyInput = _controller.parseInput(text);
    setState(() {
      _hourlyBRL = hourlyInput * _selectedRate;
      _monthlyBRL = _controller.calculateMonthlyFromHourly(_hourlyBRL, _hoursPerMonth);
      _annualBRL = _controller.calculateAnnualFromMonthly(_monthlyBRL);
    });
    _updateTextFields();
  }

  Widget _buildCurrencySelector() {
    return ToggleButtons(
      children: [ Text("BRL"), Text("USD"), Text("EUR"), Text("BTC") ],
      isSelected: _isSelected,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _isSelected.length; i++) {
            _isSelected[i] = i == index;
          }
          switch (index) {
            case 0: // BRL
              _selectedCurrency = "BRL"; _selectedRate = 1.0; _selectedPrefix = "R\$ ";
              _currentDecimalPlaces = 2; 
              break;
            case 1: // USD
              _selectedCurrency = "USD"; _selectedRate = dolar; _selectedPrefix = "US\$ ";
              _currentDecimalPlaces = 2;
              break;
            case 2: // EUR
              _selectedCurrency = "EUR"; _selectedRate = euro; _selectedPrefix = "€ ";
              _currentDecimalPlaces = 2;
              break;
            case 3: // BTC
              _selectedCurrency = "BTC"; _selectedRate = btc; _selectedPrefix = "₿ ";
              _currentDecimalPlaces = 8; 
              break;
          }
          if (annualControlador.text.isEmpty && 
              monthlyControlador.text.isEmpty && 
              hourlyControlador.text.isEmpty) {
            return;
          }
          _updateTextFields();
        });
      },
      borderRadius: BorderRadius.circular(8.0),
      selectedColor: Theme.of(context).colorScheme.onPrimary,
      color: Theme.of(context).colorScheme.primary,
      fillColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatBRL = _getCurrencyFormat(context, 2);
    final formatBTC = _getCurrencyFormat(context, 8);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.calculate,
              size: 100.0,
              color: Theme.of(context).colorScheme.primary),
          Center(child: _buildCurrencySelector()),
          Divider(),
          criaTextsFields(
            TranslateApp(context).text('salaryAnnual'),
            _selectedPrefix,
            annualControlador,
            annualFocus,
            _annualTroca,
          ),
          Divider(),
          criaTextsFields(
            TranslateApp(context).text('salaryMonthly'),
            _selectedPrefix,
            monthlyControlador,
            monthlyFocus,
            _monthlyTroca,
          ),
          Divider(),
          criaTextsFields(
            TranslateApp(context).text('salaryHourly'),
            _selectedPrefix,
            hourlyControlador,
            hourlyFocus,
            _hourlyTroca,
          ),
          Divider(),
          _buildHoursSlider(), 
          Divider(),

          if (_annualBRL > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  TranslateApp(context).text('salaryResults'),
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary
                  ),
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
                if (_selectedCurrency != "BTC")
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

  Widget _buildHoursSlider() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            TranslateApp(context).text('salaryHoursPerMonth'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary.withAlpha(220)
            ),
          ),
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

  Widget _buildResultCard({
    required String title,
    required String annual,
    required String monthly,
    required String hourly,
  }) {
    final titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary);
    final labelStyle = TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color);
    final valueStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary.withAlpha(220));

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
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TranslateApp(context).text('salaryMonthly'), style: labelStyle),
                Text(monthly, style: valueStyle),
              ],
            ),
            SizedBox(height: 6),
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

  Widget criaTextsFields(String texto, String prefix, TextEditingController c, FocusNode focus, Function(String) f) {
    return TextField(
      controller: c,
      focusNode: focus,
      decoration: InputDecoration(
        labelText: texto,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        prefixText: prefix,
        prefixStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 25.0),
        suffixIcon: c.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.green[400]),
                onPressed: _clearFields,
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary.withAlpha(20),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 25.0),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: f,
    );
  }
}