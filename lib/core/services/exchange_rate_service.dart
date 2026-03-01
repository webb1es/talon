import 'package:injectable/injectable.dart';

/// Converts amounts between supported currencies.
/// Rates are relative to USD (base currency).
@lazySingleton
class ExchangeRateService {
  final Map<String, double> _rates = {
    'USD': 1.0,
    'ZWG': 28.0,
  };

  /// Converts [amount] from [from] currency to [to] currency.
  /// Returns null if either currency is unknown — caller should fall back to
  /// displaying the original amount in [from] currency.
  double? convert(double amount, String from, String to) {
    if (from == to) return amount;
    final fromRate = _rates[from];
    final toRate = _rates[to];
    if (fromRate == null || toRate == null) return null;
    return amount * (toRate / fromRate);
  }

  /// Returns the rate for [code] relative to USD, or null if unknown.
  double? rateFor(String code) => _rates[code];

  /// Sets the rate for a single currency.
  void setRate(String code, double rate) => _rates[code] = rate;

  /// Replaces all rates. USD is always pinned at 1.0.
  void setRates(Map<String, double> rates) {
    _rates
      ..clear()
      ..addAll(rates)
      ..['USD'] = 1.0;
  }

  /// All currency codes with known rates.
  List<String> get availableCurrencies => _rates.keys.toList();
}
