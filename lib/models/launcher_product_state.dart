import 'package:json_annotation/json_annotation.dart';

part 'launcher_product_state.g.dart';

@JsonSerializable()
class LauncherProductState {
  final Map<String, ProductState> products;
  final int version;

  LauncherProductState({
    required this.products,
    required this.version,
  });

  factory LauncherProductState.fromJson(Map<String, dynamic> json) =>
      _$LauncherProductStateFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherProductStateToJson(this);
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