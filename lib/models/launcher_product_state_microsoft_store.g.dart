// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_product_state_microsoft_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherProductStateMicrosoftStore _$LauncherProductStateMicrosoftStoreFromJson(
  Map<String, dynamic> json,
) => LauncherProductStateMicrosoftStore(
  products: (json['products'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, ProductState.fromJson(e as Map<String, dynamic>)),
  ),
  version: (json['version'] as num).toInt(),
);

Map<String, dynamic> _$LauncherProductStateMicrosoftStoreToJson(
  LauncherProductStateMicrosoftStore instance,
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
