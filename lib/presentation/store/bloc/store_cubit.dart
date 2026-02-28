import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/store.dart';
import '../../../domain/repositories/store_repository.dart';
import '../../auth/bloc/auth_cubit.dart';

// -- State --

sealed class StoreState {
  const StoreState();
}

class StoreInitial extends StoreState {
  const StoreInitial();
}

class StoresLoading extends StoreState {
  const StoresLoading();
}

class StoresLoaded extends StoreState {
  final List<Store> stores;
  const StoresLoaded(this.stores);
}

class StoreSelected extends StoreState {
  final Store store;
  const StoreSelected(this.store);
}

class StoreError extends StoreState {
  final Failure failure;
  const StoreError(this.failure);
}

// -- Cubit --

@lazySingleton
class StoreCubit extends Cubit<StoreState> {
  final StoreRepository _storeRepository;
  late final StreamSubscription<AuthState> _authSubscription;

  StoreCubit(this._storeRepository, AuthCubit authCubit)
      : super(const StoreInitial()) {
    _authSubscription = authCubit.stream.listen((authState) {
      if (authState is Unauthenticated) clearSelection();
    });
  }

  bool get hasSelectedStore => state is StoreSelected;

  Future<void> loadStores() async {
    emit(const StoresLoading());
    final result = await _storeRepository.getStores();
    switch (result) {
      case Success(:final data):
        emit(StoresLoaded(data));
      case Fail(:final failure):
        emit(StoreError(failure));
    }
  }

  void selectStore(Store store) => emit(StoreSelected(store));

  void clearSelection() => emit(const StoreInitial());

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
