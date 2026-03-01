import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/payment_entry.dart';
import '../../../domain/entities/payment_method.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_role.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../store/bloc/store_cubit.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/checkout_cubit.dart';
import '../widgets/payment_line_widget.dart';
import '../widgets/summary_row.dart';

/// Shows the checkout dialog. Returns the [Transaction] on success, null on cancel.
Future<Transaction?> showCheckoutDialog(BuildContext context) async {
  final isMobile = MediaQuery.sizeOf(context).width < 600;
  final cartState = context.read<CartCubit>().state;
  if (cartState.isEmpty) return null;

  return showDialog<Transaction>(
    context: context,
    barrierDismissible: false,
    useSafeArea: !isMobile,
    builder: (_) => BlocProvider(
      create: (_) => getIt<CheckoutCubit>(),
      child: _CheckoutContent(
        items: cartState.items,
        subtotal: cartState.subtotal,
        fullscreen: isMobile,
      ),
    ),
  );
}

class _PaymentLine {
  PaymentMethod method = PaymentMethod.cash;
  String currencyCode;
  final TextEditingController controller;

  _PaymentLine({required this.currencyCode}) : controller = TextEditingController();

  double get amount => double.tryParse(controller.text) ?? 0;

  void dispose() => controller.dispose();
}

class _CheckoutContent extends StatefulWidget {
  final List<CartItem> items;
  final double subtotal;
  final bool fullscreen;

  const _CheckoutContent({
    required this.items,
    required this.subtotal,
    required this.fullscreen,
  });

  @override
  State<_CheckoutContent> createState() => _CheckoutContentState();
}

class _CheckoutContentState extends State<_CheckoutContent> {
  final _exchangeRate = getIt<ExchangeRateService>();
  late final double _taxAmount = widget.subtotal * CheckoutCubit.taxRate;
  late final double _totalUsd = widget.subtotal + _taxAmount;
  late final List<_PaymentLine> _lines = [_PaymentLine(currencyCode: _defaultCurrency)];

  String get _defaultCurrency {
    final storeState = context.read<StoreCubit>().state;
    return storeState is StoreSelected ? storeState.store.defaultCurrencyCode : 'USD';
  }

  List<String> get _supportedCurrencies {
    final storeState = context.read<StoreCubit>().state;
    return storeState is StoreSelected ? storeState.store.supportedCurrencies : ['USD'];
  }

  double _toDisplay(double usdAmount) =>
      _exchangeRate.convert(usdAmount, 'USD', _defaultCurrency) ?? usdAmount;

  double get _totalPaidUsd {
    var sum = 0.0;
    for (final line in _lines) {
      final rate = _exchangeRate.rateFor(line.currencyCode);
      if (rate != null && rate > 0) {
        sum += line.amount / rate;
      }
    }
    return sum;
  }

  double get _remainingUsd => _totalUsd - _totalPaidUsd;
  double get _changeUsd => _totalPaidUsd > _totalUsd ? _totalPaidUsd - _totalUsd : 0;
  bool get _canConfirm => _remainingUsd <= 0.005; // tolerance for floating point

  @override
  void initState() {
    super.initState();
    for (final line in _lines) {
      line.controller.addListener(_onAmountChanged);
    }
  }

  @override
  void dispose() {
    for (final line in _lines) {
      line.controller.removeListener(_onAmountChanged);
      line.dispose();
    }
    super.dispose();
  }

  void _onAmountChanged() => setState(() {});

  void _addLine() {
    setState(() {
      final line = _PaymentLine(currencyCode: _defaultCurrency);
      line.controller.addListener(_onAmountChanged);
      _lines.add(line);
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines[index].controller.removeListener(_onAmountChanged);
      _lines[index].dispose();
      _lines.removeAt(index);
    });
  }

  List<PaymentEntry> _buildPayments() {
    return _lines.where((l) => l.amount > 0).map((l) {
      final rate = _exchangeRate.rateFor(l.currencyCode) ?? 1.0;
      return PaymentEntry(
        method: l.method,
        currencyCode: l.currencyCode,
        amount: l.amount,
        amountInBaseCurrency: l.amount / rate,
        exchangeRate: rate,
      );
    }).toList();
  }

  void _confirm() {
    final authState = context.read<AuthCubit>().state;
    final storeState = context.read<StoreCubit>().state;

    final user = authState is Authenticated
        ? authState.user
        : const User(id: '', email: '', name: 'Unknown', role: UserRole.cashier);
    final storeId = storeState is StoreSelected ? storeState.store.id : '';

    context.read<CheckoutCubit>().processPayment(
      items: widget.items,
      payments: _buildPayments(),
      storeId: storeId,
      cashierId: user.id,
      cashierName: user.name,
      currencyCode: _defaultCurrency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeType = context.read<ThemeCubit>().state.themeType;

    final body = BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutComplete) {
          Navigator.of(context).pop(state.transaction);
        } else if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.error(themeType, state.failure.message))),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.checkout, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            SummaryRow(label: AppStrings.subtotal, value: _toDisplay(widget.subtotal), currencyCode: _defaultCurrency),
            const SizedBox(height: 8),
            SummaryRow(label: AppStrings.tax, value: _toDisplay(_taxAmount), currencyCode: _defaultCurrency),
            const Divider(height: 24),
            SummaryRow(label: AppStrings.total, value: _toDisplay(_totalUsd), currencyCode: _defaultCurrency, bold: true),
            const SizedBox(height: 24),

            // Payment lines
            for (var i = 0; i < _lines.length; i++)
              PaymentLineWidget(
                method: _lines[i].method,
                currencyCode: _lines[i].currencyCode,
                amountController: _lines[i].controller,
                availableCurrencies: _supportedCurrencies,
                onMethodChanged: (m) => setState(() => _lines[i].method = m),
                onCurrencyChanged: (c) => setState(() => _lines[i].currencyCode = c),
                onRemove: _lines.length > 1 ? () => _removeLine(i) : null,
              ),

            // Add payment button
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text(AppStrings.addPayment),
                onPressed: _addLine,
              ),
            ),
            const SizedBox(height: 8),

            // Remaining / Change
            SummaryRow(
              label: _remainingUsd > 0.005 ? AppStrings.remainingBalance : AppStrings.change,
              value: _remainingUsd > 0.005 ? _toDisplay(_remainingUsd) : _toDisplay(_changeUsd),
              currencyCode: _defaultCurrency,
              bold: true,
              color: _canConfirm ? null : theme.colorScheme.error,
            ),
            const SizedBox(height: 24),

            BlocBuilder<CheckoutCubit, CheckoutState>(
              builder: (context, state) {
                final isProcessing = state is CheckoutProcessing;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isProcessing ? null : () => Navigator.of(context).pop(),
                      child: const Text(AppStrings.cancel),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _canConfirm && !isProcessing ? _confirm : null,
                      child: isProcessing
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.confirmPayment),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );

    if (widget.fullscreen) {
      return Dialog.fullscreen(child: SingleChildScrollView(child: body));
    }
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(child: body),
      ),
    );
  }
}
