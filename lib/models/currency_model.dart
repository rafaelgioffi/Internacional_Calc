class CurrencyModel {
  final double usd;
  final double eur;
  final double btc;

  CurrencyModel({
    required this.usd,
    required this.eur,
    required this.btc,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
   try {
    final currencies = json['results']['currencies'];
    return CurrencyModel(
      usd: (currencies['USD']['sell'] ?? 0.0).toDouble(),
      eur: (currencies['EUR']['sell'] ?? 0.0).toDouble(),
      btc: (currencies['BTC']['sell'] ?? 0.0).toDouble(),
    );
   } catch (e) {
    return CurrencyModel(usd: 1.0, eur: 1.0, btc: 1.0);
    }
  }
}