import 'dart:io';
import 'package:flutter/material.dart';
import '../models/currency_model.dart';
import '../services/currency_service.dart';
import 'currencies_converter.dart';
import 'salary_calculator.dart';
import 'package:international_calc/shared/localization/translate_app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppNavigator extends StatefulWidget {
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _selectedIndex = 0;

  late Future<CurrencyModel> _currencyData;
  final CurrencyService _service = CurrencyService();

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  // InterstitialAd? _interstitialAd;
  // bool _adsInitialized = false;

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

  @override
  void initState() {
    super.initState();
    _currencyData = _service.getCurrencies();
    _loadBannerAd();
  }

  @override
  void dispose() {
  _bannerAd?.dispose();
    // _interstitialAd?.dispose();
    super.dispose();
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
    // if (!_isBannerAdReady) {
    if (_isBannerAdReady) {
      // return SizedBox.shrink();
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    
    return Container(height: AdSize.fullBanner.height.toDouble());    
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

@override
  Widget build(BuildContext context) {
    return FutureBuilder<CurrencyModel>(
      future: _currencyData,
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
            !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(TranslateApp(context).text('loadingerror')),
            ),
          );
        }

        // Se os dados carregaram, crie as telas e passe os dados
        final CurrencyModel data = snapshot.data!;

        List<Widget> _screens = [
          CurrenciesConverter(currencies: data),
          SalaryCalculator(currencies: data),
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

          // body: IndexedStack(
            // index: _selectedIndex,
            // children: _screens,
          body: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _screens,
                ),
          ),
          _buildBannerAdWidget()
            ],
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
