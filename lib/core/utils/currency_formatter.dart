// Currency formatting utilities.
// All display-currency formatting goes through these functions.
// Amounts in the DB are always USD; convert before calling formatCurrency.

const _symbols = <String, String>{
  'USD': '\$',
  'ZWG': 'ZWG ',
  'ZAR': 'R',
  'BWP': 'P',
  'EUR': '\u20AC',
  'GBP': '\u00A3',
};

/// Returns the display symbol/prefix for [code].
/// Falls back to the code itself with a trailing space.
String currencySymbol(String code) => _symbols[code] ?? '$code ';

/// Formats [amount] for display using the symbol for [currencyCode].
/// Example: `formatCurrency(12.5, 'USD')` → `$12.50`
/// Example: `formatCurrency(350, 'ZWG')` → `ZWG 350.00`
String formatCurrency(double amount, String currencyCode) =>
    '${currencySymbol(currencyCode)}${amount.toStringAsFixed(2)}';
