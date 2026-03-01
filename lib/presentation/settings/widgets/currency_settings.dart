import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../bloc/currency_settings_cubit.dart';

class CurrencySettings extends StatelessWidget {
  final String storeId;

  const CurrencySettings({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CurrencySettingsCubit, CurrencySettingsState>(
      listener: (context, state) {
        if (state is CurrencySettingsLoaded && state.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.currencySaved)),
          );
        } else if (state is CurrencySettingsLoaded && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        if (state is! CurrencySettingsLoaded) return const SizedBox.shrink();

        final cubit = context.read<CurrencySettingsCubit>();
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.currencySettings, style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),

              // Supported currencies toggles
              Text(AppStrings.supportedCurrencies, style: theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final code in CurrencySettingsCubit.allCurrencies)
                    FilterChip(
                      label: Text(code),
                      selected: state.supportedCurrencies.contains(code),
                      onSelected: code == 'USD'
                          ? null // USD always enabled
                          : (_) => cubit.toggleCurrency(code),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Default currency
              Text(AppStrings.defaultCurrency, style: theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              Semantics(
                label: AppStrings.defaultCurrency,
                child: DropdownButtonFormField<String>(
                  initialValue: state.supportedCurrencies.contains(state.defaultCurrencyCode)
                      ? state.defaultCurrencyCode
                      : state.supportedCurrencies.first,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [
                    for (final code in state.supportedCurrencies)
                      DropdownMenuItem(value: code, child: Text(code)),
                  ],
                  onChanged: (v) {
                    if (v != null) cubit.setDefaultCurrency(v);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Exchange rates
              Text(AppStrings.exchangeRates, style: theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              for (final code in state.supportedCurrencies.where((c) => c != 'USD'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 48, child: Text(code, style: theme.textTheme.bodyMedium)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Semantics(
                          label: '${AppStrings.rateLabel} $code',
                          child: TextFormField(
                            initialValue: state.rates[code]?.toStringAsFixed(2) ?? '1.00',
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              labelText: AppStrings.rateLabel,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')),
                            ],
                            onChanged: (v) {
                              final rate = double.tryParse(v);
                              if (rate != null && rate > 0) {
                                cubit.updateRate(code, rate);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => cubit.save(storeId),
                  child: const Text(AppStrings.save),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
