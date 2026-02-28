import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';

@freezed
abstract class Store with _$Store {
  const factory Store({
    required String id,
    required String name,
    required String address,
  }) = _Store;
}
