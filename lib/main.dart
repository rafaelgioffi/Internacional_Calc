import 'dart:io';
import 'package:calculadora_dev_internacional/shared/localization/localization_app.dart';
import 'package:calculadora_dev_internacional/shared/localization/translate_app.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

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

void main() async {
  //admob parte 1...
  WidgetsFlutterBinding.ensureInitialized();
  //Admob.initialize();
  await MobileAds.instance.initialize();
  List<String> testDevice = ["B21373F543315FE0F022BB45B59CA1A2"];
  RequestConfiguration config = RequestConfiguration(testDeviceIds: testDevice);
  MobileAds.instance.updateRequestConfiguration(config);
  //fim parte 1...

  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        hintColor: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        // primaryColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        hintColor: Colors.green,
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      themeMode: ThemeMode.system,
      supportedLocales: [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
        Locale('es', 'ES'),
      ],
      localizationsDelegates: [
        LocalizationsApp.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //google ads parte3...
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdReady = false;
  bool _adsInitialized = false;

  final bannerAdIdAndroid = "ca-app-pub-9686860589009637/7987536502"; // Real
  // final bannerAdIdAndroid = "ca-app-pub-3940256099942544/6300978111";   // Teste

  final bannerAdIdIos = "ca-app-pub-9686860589009637/7987536502";

  // final intertstitialAdIdAndroid = "ca-app-pub-9686860589009637~1247061853";
  // final intertstitialAdIdAndroid = "ca-app-pub-3940256099942544/1033173712";  // Test

  // final intertstitialAdIdIos = "ca-app-pub-3940256099942544/4411468910";

  String get bannerAdUnitId =>
      Platform.isIOS ? bannerAdIdIos : bannerAdIdAndroid;
  // String get interstitialAdUnitId =>
  // Platform.isIOS ? intertstitialAdIdIos : intertstitialAdIdAndroid;

  final realControlador = TextEditingController();
  final dolarControlador = TextEditingController();
  final euroControlador = TextEditingController();
  final btcControlador = TextEditingController();

  final FocusNode realFocus = FocusNode();
  final FocusNode dolarFocus = FocusNode();
  final FocusNode euroFocus = FocusNode();
  final FocusNode btcFocus = FocusNode();

  late Future<Map<String, dynamic>> _dadosMoeda;

  double dolar = 0.0;
  double euro = 0.0;
  double btc = 0.0;

  @override
  void initState() {
    super.initState();

    _dadosMoeda = getData();
    // _dadosMoeda.then((data) {
    //   final results = data["results"];

    //   if (results == null)
    //     return;

    //   final currencies = results["currencies"];

    //   if (currencies == null)
    //     return;

    //   final usd = currencies["USD"];
    //   final eur = currencies["EUR"];
    //   final btcCurrency = currencies["BTC"];

    //   if (usd == null || eur == null || btcCurrency == null)
    //     return;

    //   dolar = (usd["sell"] ?? 0.0).toDouble();
    //   euro = (eur["sell"] ?? 0.0).toDouble();
    //   btc = (btcCurrency["sell"] ?? 0.0).toDouble();

    //   String dolar2 = dolar.toStringAsFixed(2);
    //   String euro2 = euro.toStringAsFixed(2);
    //   String btc2 = btc.toStringAsFixed(2);
    //   dolar = double.parse(dolar2);
    //   euro = double.parse(euro2);
    //   btc = double.parse(btc2);

    // --- Listeners para o Botão de Limpar (suffixIcon) ---
    // Faz o widget reconstruir para mostrar/esconder o 'X'
    realControlador.addListener(_onTextChanged);
    dolarControlador.addListener(_onTextChanged);
    euroControlador.addListener(_onTextChanged);
    btcControlador.addListener(_onTextChanged);

    // --- Listeners para Formatar o Campo Ativo (onFocusChange) ---
    realFocus.addListener(_onRealFocusChange);
    dolarFocus.addListener(_onDolarFocusChange);
    euroFocus.addListener(_onEuroFocusChange);

    // }).catchError((error) {
    //   print('Erro ao carregar dados: $error');
    // });

    // _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    // Limpa listeners
    realControlador.removeListener(_onTextChanged);
    dolarControlador.removeListener(_onTextChanged);
    euroControlador.removeListener(_onTextChanged);
    btcControlador.removeListener(_onTextChanged);

    realFocus.removeListener(_onRealFocusChange);
    dolarFocus.removeListener(_onDolarFocusChange);
    euroFocus.removeListener(_onEuroFocusChange);

    //solution deepseek 13/10/25
    realControlador.dispose();
    dolarControlador.dispose();
    euroControlador.dispose();
    btcControlador.dispose();
    //fim deepseek...

    // Limpa focus nodes
    realFocus.dispose();
    dolarFocus.dispose();
    euroFocus.dispose();
    btcFocus.dispose();

    super.dispose();
  }

// Reconstrói o widget para mostrar/esconder o botão 'X'
  void _onTextChanged() {
    setState(() {});
  }

  // Formata o campo de Real quando o usuário sai dele
  void _onRealFocusChange() {
    if (!realFocus.hasFocus) {
      _formatField(realControlador);
    }
  }

  // Formata o campo de Dólar quando o usuário sai dele
  void _onDolarFocusChange() {
    if (!dolarFocus.hasFocus) {
      _formatField(dolarControlador);
    }
  }

  // Formata o campo de Euro quando o usuário sai dele
  void _onEuroFocusChange() {
    if (!euroFocus.hasFocus) {
      _formatField(euroControlador);
    }
  }

  // --- Funções de Lógica ---

  // Função genérica para formatar o campo
  void _formatField(TextEditingController controller) {
    if (controller.text.isEmpty) return;
    final formatador = _getCurrencyFormat(context);
    double value = _parseInput(controller.text);

    // Usamos setState para garantir que o listener _onTextChanged
    // também seja notificado caso o texto mude.
    setState(() {
      controller.text = formatador.format(value);
    });
  }

  void _loadBannerAd() {
    print("Iniciando carregamento do Banner Ad...");
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.fullBanner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print("✅ Banner Ad Carregado com Sucesso!");
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  Widget _buildBannerAdWidget() {
    // 1. Se não estiver pronto, não ocupe espaço
    if (!_isBannerAdReady) {
      return SizedBox.shrink();
    }
    // if (_isBannerAdReady) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
  // return Container();
  // return SizedBox.shrink();
  // }

// String _formatNumber(valor, local) {
//     NumberFormat formatado = NumberFormat.simpleCurrency(locale: local);
//     return formatado.format(valor);
//   }

// Função helper para formatar saida...
  NumberFormat _getCurrencyFormat(BuildContext context) {
    final deviceLocale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.currency(
        locale: deviceLocale, symbol: '', decimalDigits: 2);
  }

  void _clearFields() {
    realControlador.clear();
    dolarControlador.clear();
    euroControlador.clear();
    btcControlador.clear();
  }

  // Helper para ler um número (ex: "1.234,56" ou "1234.56")
  double _parseInput(String text) {
    final formatador = _getCurrencyFormat(context);
    // Remove separadores de milhar (ex: 10.000 -> 10000)
    String cleanText = text.replaceAll(formatador.symbols.GROUP_SEP, '');
    // Troca separador decimal do locale por '.' (ex: 10,50 -> 10.50)
    cleanText = cleanText.replaceAll(formatador.symbols.DECIMAL_SEP, '.');

    try {
      return double.parse(cleanText);
    } catch (e) {
      return 0.0;
    }
  }

  // void _loadInterstitialAd() {
  //   InterstitialAd.load(
  //     adUnitId: interstitialAdUnitId,
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         _interstitialAd = ad;
  //         _setIntersticalCallback();
  //       },
  //       onAdFailedToLoad: (error) {
  //         print('InterstitialAd failed to load: $error');
  //         _interstitialAd = null;
  //       },
  //     ),
  //   );
  // }

  // void _setIntersticalCallback() {
  //   if (_interstitialAd == null) return;
  //   _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (ad) {
  //       print('InterstitialAd showed full screen content.');
  //       ad.dispose();
  //       _loadInterstitialAd(); // Load a new ad after the current one is shown
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       print('InterstitialAd failed to show full screen content: $error');
  //       ad.dispose();
  //       _loadInterstitialAd(); // Load a new ad after failure
  //     },
  //   );
  // }
  //fim google ads parte 3...

  // --- Funções de Conversão ---
  void _realTroca(String text) {
    // if (text.isEmpty) {
    if (!realFocus.hasFocus) return;

    if (text.isEmpty) {
      _clearFields();
      return;
    }

    final formatador = _getCurrencyFormat(context);
    double real = _parseInput(text);

    dolarControlador.text = formatador.format(real / dolar);
    euroControlador.text = formatador.format(real / euro);
    btcControlador.text = (real / btc).toStringAsFixed(10);
    // String parsableText = text.replaceAll(',', '.');
    // double real;
    // try {
    //   real = double.parse(parsableText);
    // }
    // catch (e) {
    //   real = 0.0;
    // }

    // double real = double.parse(text);
    // dolarControlador.text = (real / dolar).toStringAsFixed(2);
    // euroControlador.text = (real / euro).toStringAsFixed(2);

    // print(real);
  }

  void _dolarTroca(String text) {
    if (!dolarFocus.hasFocus) return;

    if (text.isEmpty) {
      _clearFields();
      return;
    }

    final formatador = _getCurrencyFormat(context);
    double dolarValue = _parseInput(text);
    // String parseableText = text.replaceAll(',', '.');
    // double dolarValue;
    // try {
    //   dolarValue = double.parse(parseableText);
    // } catch (e) {
    //   dolarValue = 0.0;
    // }

    // double dolar = double.parse(text);
    // realControlador.text = (dolar * this.dolar).toStringAsFixed(2);
    // euroControlador.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
    realControlador.text = formatador.format(dolarValue * this.dolar);
    euroControlador.text = formatador.format((dolarValue * this.dolar) / euro);
    btcControlador.text = ((dolar * this.dolar) / btc).toStringAsFixed(10);
  }

  void _euroTroca(String text) {
    if (!euroFocus.hasFocus) return;
    if (text.isEmpty) {
      _clearFields();
      return;
    }

    final formatador = _getCurrencyFormat(context);
    double euroValue = _parseInput(text);
    // String parseableText = text.replaceAll(',', '.');
    // double euroValue;
    // try {
    //   euroValue = double.parse(parseableText);
    // } catch (e) {
    //   euroValue = 0.0;
    // }
    // double euro = double.parse(text);
    // realControlador.text = (euro * this.euro).toStringAsFixed(2);
    // dolarControlador.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
    realControlador.text = formatador.format(euroValue * this.euro);
    dolarControlador.text = formatador.format((euroValue * this.euro) / dolar);
    btcControlador.text = ((euro * this.euro) / btc).toStringAsFixed(10);
  }

  void _btcTroca(String text) {
    if (!btcFocus.hasFocus) return;
    if (text.isEmpty) {
      // dolarControlador.text = "";
      // euroControlador.text = "";
      // realControlador.text = "";
      _clearFields();
      return;
    }
    // double btc = double.parse(text);
    // realControlador.text = (btc * this.btc).toStringAsFixed(2);
    // dolarControlador.text = ((btc * this.btc) / dolar).toStringAsFixed(2);
    // euroControlador.text = ((btc * this.btc) / euro).toStringAsFixed(2);
    String parseableText = text.replaceAll(',', '.');
    double btcValue;
    try {
      btcValue = double.parse(parseableText);
    } catch (e) {
      btcValue = 0.0;
    }

    final formatador = _getCurrencyFormat(context);
    realControlador.text = formatador.format(btcValue * this.btc);
    dolarControlador.text = formatador.format((btcValue * this.btc) / dolar);
    euroControlador.text = formatador.format((btcValue * this.btc) / euro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        title: Text(
          TranslateApp(context).text('titleapp'),
          // 'Conversor de Moedas',
          // style: TextStyle(color: Colors.green),
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
        ),
        ),
        centerTitle: true,
      ),
      // bottomNavigationBar: getBanner(AdmobBannerSize.FULL_BANNER),
      // bottomNavigationBar: _buildBannerAdWidget(),
      bottomNavigationBar: null,

      body: FutureBuilder<Map<String, dynamic>>(
        // future: getData(),
        future: _dadosMoeda,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  TranslateApp(context).text('loading'),
                  // 'Carregando...',
                  style: TextStyle(fontSize: 24.0, color: Colors.blueAccent),
                ),
              );

            default:
              // if (snapshot.hasError) {
              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: Text(TranslateApp(context).text('loadingerror')),
                  // child: Text('Erro ao carregar dados :('),
                );
                // } else if (snapshot.data == null) {
                // } else if (!snapshot.hasData || snapshot.data?["results"] == null) {
                // return Center(
                //   child: Text(TranslateApp(context).text('loadingerror')),
                //   // child: Text('Dados não disponíveis :('),
                // );
              } else {
                // ADICIONEI ESTE PRINT PARA TESTE
                print("✅ Future concluído. Construindo a UI principal...");

                final data = snapshot.data!;
                final results = data["results"];

                if (results == null) {
                  return Center(
                    child: Text(TranslateApp(context).text('loadingerror')),
                    // child: Text('Dados de câmbio indisponíveis :('),
                  );
                }

                final currencies = results["currencies"];
                if (currencies == null) {
                  return Center(
                    child: Text(TranslateApp(context).text('dataNotFound')),
                    // child: Text('Dados de câmbio indisponíveis :('),
                  );
                }

                final usd = currencies["USD"];
                final eur = currencies["EUR"];
                final btcCurrency = currencies["BTC"];

                if (usd == null || eur == null || btcCurrency == null) {
                  return Center(
                    child: Text(TranslateApp(context).text('dataNotFound')),
                    // child: Text('Dados de câmbio indisponíveis :('),
                  );
                }

                dolar = (usd["sell"] ?? 0.0).toDouble();
                euro = (eur["sell"] ?? 0.0).toDouble();
                btc = (btcCurrency["sell"] ?? 0.0).toDouble();

                // dolar = snapshot.data["results"]["currencies"]["USD"]["sell"];
                // euro = snapshot.data["results"]["currencies"]["EUR"]["sell"];
                // btc = snapshot.data["results"]["currencies"]["BTC"]["sell"];
                // print(dolar);
                // print(euro);
                // print(btc);
                // String dolar2 = dolar.toStringAsFixed(2);
                // String euro2 = euro.toStringAsFixed(2);
                // String btc2 = btc.toStringAsFixed(2);
                // dolar = double.parse(dolar2);
                // euro = double.parse(euro2);
                // btc = double.parse(btc2);
                // print(dolar);
                // print(euro);
                // print(btc);

                // CORREÇÃO DO ADMOB: Carrega o anúncio SÓ AGORA
                // if (snapshot.connectionState == ConnectionState.done &&
                //     !_adsInitialized) {
                if (!_adsInitialized) {
                  _adsInitialized = true;
                  // Adiciona um atraso para garantir que a UI dos TextFields
                  // seja renderizada antes de carregar o Ad (Platform View)
                  // Future.delayed(Duration(milliseconds: 500), () {
                  //   // 'mounted' verifica se o widget ainda está na tela
                  //   if (mounted) {
                  _loadBannerAd(); // Carrega o anúncio com segurança
                  // }
                  // });
                }

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(
                              Icons.monetization_on,
                              size: 150.0,
                              color: Colors.lightGreen,
                            ),
                            Divider(),
                            criaTextsFields(
                              TranslateApp(context).text('real'),
                              // 'Real',
                              "R\$",
                              realControlador,
                              realFocus,
                              _realTroca,
                            ),
                            Divider(),
                            criaTextsFields(
                              TranslateApp(context).text('dolar'),
                              // 'Dólar',
                              "US\$",
                              dolarControlador,
                              dolarFocus,
                              _dolarTroca,
                            ),
                            Divider(),
                            criaTextsFields(
                              TranslateApp(context).text('euro'),
                              // 'Euro',
                              "€",
                              euroControlador,
                              euroFocus,
                              _euroTroca,
                            ),
                            Divider(),
                            criaTextsFields(
                              "Bitcoin",
                              "BTC",
                              btcControlador,
                              btcFocus,
                              _btcTroca,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildBannerAdWidget(),
                  ],
                );
              }
          }
        },
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
        // labelStyle: TextStyle(color: Colors.green),
        labelStyle: GoogleFonts.lato(color: Theme.of(context).hintColor),
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        border: OutlineInputBorder(),
        prefixText: prefix,
        prefixStyle: TextStyle(
          // color: Colors.green, 
          color: Theme.of(context).colorScheme.primary,
          fontSize: 25.0),

        // ADICIONA O BOTÃO DE LIMPAR (X)
        suffixIcon: c.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.green[400]),
                onPressed: _clearFields,
              )
            : null, // Não mostra nada se o campo estiver vazio
      ),
      style: 
      TextStyle(
        // color: Colors.green, 
        color: Theme.of(context).colorScheme.primary,
        fontSize: 25.0),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: f,
    );
  }
}
