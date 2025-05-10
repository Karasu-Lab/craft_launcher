// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_product_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherProductState _$LauncherProductStateFromJson(
  Map<String, dynamic> json,
) => LauncherProductState(
  products: (json['products'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, ProductState.fromJson(e as Map<String, dynamic>)),
  ),
  version: (json['version'] as num).toInt(),
);

Map<String, dynamic> _$LauncherProductStateToJson(
  LauncherProductState instance,
) => <String, dynamic>{
  'products': instance.products,
  'version': instance.version,
};

ProductState _$ProductStateFromJson(Map<String, dynamic> json) => ProductState(
  lastEpochTimeUpdateCheck: (json['lastEpochTimeUpdateCheck'] as num).toInt(),
);

Map<String, dynamic> _$ProductStateToJson(ProductState instance) =>
    <String, dynamic>{
      'lastEpochTimeUpdateCheck': instance.lastEpochTimeUpdateCheck,
    };
