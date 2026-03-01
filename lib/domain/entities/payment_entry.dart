import 'package:freezed_annotation/freezed_annotation.dart';

import 'payment_method.dart';

part 'payment_entry.freezed.dart';

@freezed
abstract class PaymentEntry with _$PaymentEntry {
  const factory PaymentEntry({
    required PaymentMethod method,
    required String currencyCode,
    required double amount,
    required double amountInBaseCurrency,
    required double exchangeRate,
  }) = _PaymentEntry;
}
