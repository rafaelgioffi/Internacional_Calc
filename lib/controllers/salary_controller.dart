class SalaryController {
  static const double defaultHoursPerMonth = 160.0;

  double calculateMonthlyFromAnnual(double annual) {
    return annual / 12;
  }

  double calculateHourlyFromMonthly(double monthly, double hoursPerMonth) {
    if (hoursPerMonth <= 0) return 0.0;
    return monthly / hoursPerMonth;
  }

  double calculateAnnualFromMonthly(double monthly) {
    return monthly * 12;
  }

  double calculateMonthlyFromHourly(double hourly, double hoursPerMonth) {
    return hourly * hoursPerMonth;
  }

  double convertCurrency(double amount, double rate) {
    if (rate == 0) return 0.0;
    return amount / rate;
  }

  double parseInput(String text) {
    if (text.isEmpty) return 0.0;

    String cleanText = text.replaceAll(',', '.');

    if (cleanText.contains('.')) {
      int lastDot = cleanText.lastIndexOf('.');
      String integerPart = cleanText.substring(0, lastDot).replaceAll('.', '');
      String decimalPart = cleanText.substring(lastDot);
      cleanText = integerPart + decimalPart;
    }

    try {
      return double.parse(cleanText);
    } catch (e) {
      return 0.0;
    }
  }
}
