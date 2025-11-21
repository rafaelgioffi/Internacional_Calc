import 'package:flutter/material.dart';
import '../models/currency_model.dart';
import '../controllers/converter_controller.dart';
import 'package:international_calc/shared/localization/translate_app.dart';

class CurrenciesConverter extends StatefulWidget {
  final CurrencyModel currencies;

  const CurrenciesConverter({Key? key, required this.currencies}) : super(key: key);

  @override
  _CurrenciesConverterState createState() => _CurrenciesConverterState();
}

class _CurrenciesConverterState extends State<CurrenciesConverter> {
  final ConverterController _controller = ConverterController();
  
  // Focus Nodes para evitar loops
  final FocusNode _realFocus = FocusNode();
  final FocusNode _dolarFocus = FocusNode();
  final FocusNode _euroFocus = FocusNode();
  final FocusNode _btcFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.currencies = widget.currencies;
  }

  @override
  void dispose() {
    _controller.dispose();
    _realFocus.dispose();
    _dolarFocus.dispose();
    _euroFocus.dispose();
    _btcFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.monetization_on,
                  size: 100.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                
                _buildTextField(
                  label: TranslateApp(context).text('real'),
                  prefix: "R\$ ",
                  controller: _controller.realCtrl,
                  focus: _realFocus,
                  onChanged: (text) {
                    if (_realFocus.hasFocus) {
                      _controller.onRealChanged(text, locale);
                    }
                  },
                ),
                const Divider(),
                _buildTextField(
                  label: TranslateApp(context).text('dolar'),
                  prefix: "US\$ ",
                  controller: _controller.dolarCtrl,
                  focus: _dolarFocus,
                  onChanged: (text) {
                    if (_dolarFocus.hasFocus) {
                      _controller.onDolarChanged(text, locale);
                    }
                  },
                ),
                const Divider(),
                _buildTextField(
                  label: TranslateApp(context).text('euro'),
                  prefix: "€ ",
                  controller: _controller.euroCtrl,
                  focus: _euroFocus,
                  onChanged: (text) {
                    if (_euroFocus.hasFocus) {
                      _controller.onEuroChanged(text, locale);
                    }
                  },
                ),
                const Divider(),
                _buildTextField(
                  label: "Bitcoin",
                  prefix: "BTC ",
                  controller: _controller.btcCtrl,
                  focus: _btcFocus,
                  onChanged: (text) {
                    if (_btcFocus.hasFocus) {
                      _controller.onBtcChanged(text, locale);
                    }
                  },
                ),
              ],
            ),
          ),
        ),        
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String prefix,
    required TextEditingController controller,
    required FocusNode focus,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focus,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        prefixText: prefix,
        prefixStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 20.0,
          fontWeight: FontWeight.bold
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _controller.clearAll();
                  setState(() {}); // Atualiza UI para limpar todos
                },
              )
            : null,
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 25.0,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}