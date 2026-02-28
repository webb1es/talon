import 'package:injectable/injectable.dart';

/// Converts amounts between supported currencies.
/// Rates are relative to USD (base currency).
/// Hardcoded for now; swap implementation via DI when live rates are needed.
@lazySingleton
class ExchangeRateService {
  static const _rates = <String, double>{
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
}
