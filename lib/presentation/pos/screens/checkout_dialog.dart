import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_role.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../store/bloc/store_cubit.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/checkout_cubit.dart';
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
  final _cashController = TextEditingController();
  final _exchangeRate = getIt<ExchangeRateService>();
  late final double _taxAmount = widget.subtotal * CheckoutCubit.taxRate;
  late final double _totalUsd = widget.subtotal + _taxAmount;
  double _cashEntered = 0;

  String get _currencyCode {
    final storeState = context.read<StoreCubit>().state;
    return storeState is StoreSelected ? storeState.store.currencyCode : 'USD';
  }

  double _toDisplay(double usdAmount) =>
      _exchangeRate.convert(usdAmount, 'USD', _currencyCode) ?? usdAmount;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(() {
      setState(() {
        _cashEntered = double.tryParse(_cashController.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  double get _displayTotal => _toDisplay(_totalUsd);
  bool get _canConfirm => _cashEntered >= _displayTotal;
  double get _change => _cashEntered - _displayTotal;

  void _confirm() {
    final authState = context.read<AuthCubit>().state;
    final storeState = context.read<StoreCubit>().state;

    final user = authState is Authenticated
        ? authState.user
        : const User(id: '', email: '', name: 'Unknown', role: UserRole.cashier);
    final storeId = storeState is StoreSelected ? storeState.store.id : '';

    // Convert display-currency tendered amount back to USD for storage
    final tenderedUsd =
        _exchangeRate.convert(_cashEntered, _currencyCode, 'USD') ?? _cashEntered;

    context.read<CheckoutCubit>().processPayment(
      items: widget.items,
      amountTendered: tenderedUsd,
      storeId: storeId,
      cashierId: user.id,
      cashierName: user.name,
      currencyCode: _currencyCode,
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
            SummaryRow(label: AppStrings.subtotal, value: _toDisplay(widget.subtotal), currencyCode: _currencyCode),
            const SizedBox(height: 8),
            SummaryRow(label: AppStrings.tax, value: _toDisplay(_taxAmount), currencyCode: _currencyCode),
            const Divider(height: 24),
            SummaryRow(label: AppStrings.total, value: _displayTotal, currencyCode: _currencyCode, bold: true),
            const SizedBox(height: 24),
            Semantics(
              label: AppStrings.cashTendered,
              child: TextFormField(
                controller: _cashController,
                decoration: InputDecoration(
                  labelText: AppStrings.cashTendered,
                  prefixText: currencySymbol(_currencyCode),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            if (_cashEntered > 0)
              SummaryRow(
                label: AppStrings.change,
                value: _change,
                currencyCode: _currencyCode,
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
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(child: body),
      ),
    );
  }
}

