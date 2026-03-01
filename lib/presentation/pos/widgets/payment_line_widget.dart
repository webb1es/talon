import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/payment_method.dart';

class PaymentLineWidget extends StatelessWidget {
  final PaymentMethod method;
  final String currencyCode;
  final TextEditingController amountController;
  final List<String> availableCurrencies;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final ValueChanged<String> onCurrencyChanged;
  final VoidCallback? onRemove;

  const PaymentLineWidget({
    super.key,
    required this.method,
    required this.currencyCode,
    required this.amountController,
    required this.availableCurrencies,
    required this.onMethodChanged,
    required this.onCurrencyChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Payment method dropdown
          Expanded(
            flex: 3,
            child: Semantics(
              label: AppStrings.cashMethod,
              child: DropdownButtonFormField<PaymentMethod>(
                initialValue: method,
                isExpanded: true,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(
                    value: PaymentMethod.cash,
                    child: Text(AppStrings.cashMethod),
                  ),
                  DropdownMenuItem(
                    value: PaymentMethod.mobileMoney,
                    child: Text(AppStrings.mobileMoneyMethod),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) onMethodChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Currency dropdown
          Expanded(
            flex: 2,
            child: Semantics(
              label: AppStrings.currency,
              child: DropdownButtonFormField<String>(
                initialValue: currencyCode,
                isExpanded: true,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  for (final code in availableCurrencies)
                    DropdownMenuItem(value: code, child: Text(code)),
                ],
                onChanged: (v) {
                  if (v != null) onCurrencyChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Amount input
          Expanded(
            flex: 3,
            child: Semantics(
              label: AppStrings.paymentAmount,
              child: TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  prefixText: currencySymbol(currencyCode),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
            ),
          ),
          // Remove button
          if (onRemove != null)
            Semantics(
              label: AppStrings.removePayment,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onRemove,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}
