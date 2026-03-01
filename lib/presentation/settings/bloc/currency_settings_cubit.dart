import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../domain/entities/store.dart';
import '../../../domain/repositories/store_repository.dart';

// -- State --

sealed class CurrencySettingsState {
  const CurrencySettingsState();
}

class CurrencySettingsInitial extends CurrencySettingsState {
  const CurrencySettingsInitial();
}

class CurrencySettingsLoaded extends CurrencySettingsState {
  final List<String> supportedCurrencies;
  final String defaultCurrencyCode;
  final Map<String, double> rates;
  final bool saved;
  final String? error;

  const CurrencySettingsLoaded({
    required this.supportedCurrencies,
    required this.defaultCurrencyCode,
    required this.rates,
    this.saved = false,
    this.error,
  });
}

// -- Cubit --

class CurrencySettingsCubit extends Cubit<CurrencySettingsState> {
  final StoreRepository _storeRepository;

  CurrencySettingsCubit(this._storeRepository)
      : super(const CurrencySettingsInitial());

  /// All currencies that can be toggled on/off.
  static const allCurrencies = ['USD', 'ZWG', 'ZAR', 'BWP', 'EUR', 'GBP'];

  late List<String> _supported;
  late String _defaultCode;
  late Map<String, double> _rates;

  void load(Store store) {
    final exchange = getIt<ExchangeRateService>();
    _supported = List.of(store.supportedCurrencies);
    _defaultCode = store.defaultCurrencyCode;
    _rates = {
      for (final code in allCurrencies)
        code: exchange.rateFor(code) ?? 1.0,
    };
    _emit();
  }

  void toggleCurrency(String code) {
    if (code == 'USD') return;
    if (_supported.contains(code)) {
      _supported.remove(code);
      if (_defaultCode == code) _defaultCode = 'USD';
    } else {
      _supported.add(code);
    }
    _emit();
  }

  void setDefaultCurrency(String code) {
    if (!_supported.contains(code)) return;
    _defaultCode = code;
    _emit();
  }

  void updateRate(String code, double rate) {
    if (code == 'USD') return;
    _rates[code] = rate;
    _emit();
  }

  Future<void> save(String storeId) async {
    final exchange = getIt<ExchangeRateService>();
    for (final entry in _rates.entries) {
      exchange.setRate(entry.key, entry.value);
    }

    final result = await _storeRepository.updateStoreSettings(
      storeId,
      supportedCurrencies: _supported,
      defaultCurrencyCode: _defaultCode,
    );
    switch (result) {
      case Success():
        _emit(saved: true);
      case Fail(:final failure):
        _emit(error: failure.message);
    }
  }

  void _emit({bool saved = false, String? error}) {
    emit(CurrencySettingsLoaded(
      supportedCurrencies: List.unmodifiable(_supported),
      defaultCurrencyCode: _defaultCode,
      rates: Map.unmodifiable(_rates),
      saved: saved,
      error: error,
    ));
  }
}
