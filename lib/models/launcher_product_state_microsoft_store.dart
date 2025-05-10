import 'package:json_annotation/json_annotation.dart';

part 'launcher_product_state_microsoft_store.g.dart';

@JsonSerializable()
class LauncherProductStateMicrosoftStore {
  final Map<String, ProductState> products;
  final int version;

  LauncherProductStateMicrosoftStore({
    required this.products,
    required this.version,
  });

  factory LauncherProductStateMicrosoftStore.fromJson(Map<String, dynamic> json) =>
      _$LauncherProductStateMicrosoftStoreFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherProductStateMicrosoftStoreToJson(this);
}

@JsonSerializable()
class ProductState {
  final int lastEpochTimeUpdateCheck;

  ProductState({
    required this.lastEpochTimeUpdateCheck,
  });

  factory ProductState.fromJson(Map<String, dynamic> json) =>
      _$ProductStateFromJson(json);

  Map<String, dynamic> toJson() => _$ProductStateToJson(this);
}