// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_custom_skins.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherCustomSkins _$LauncherCustomSkinsFromJson(Map<String, dynamic> json) =>
    LauncherCustomSkins(
      variants: (json['variants'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, SkinVariant.fromJson(e as Map<String, dynamic>)),
      ),
      activeSkinId: json['activeSkinId'] as String,
    );

Map<String, dynamic> _$LauncherCustomSkinsToJson(
  LauncherCustomSkins instance,
) => <String, dynamic>{
  'variants': instance.variants,
  'activeSkinId': instance.activeSkinId,
};

SkinVariant _$SkinVariantFromJson(Map<String, dynamic> json) => SkinVariant(
  id: json['id'] as String,
  name: json['name'] as String,
  path: json['path'] as String,
  model: $enumDecode(_$SkinModelEnumMap, json['model']),
  isSlim: json['isSlim'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SkinVariantToJson(SkinVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'model': _$SkinModelEnumMap[instance.model]!,
      'isSlim': instance.isSlim,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$SkinModelEnumMap = {
  SkinModel.steve: 'steve',
  SkinModel.alex: 'alex',
  SkinModel.custom: 'custom',
};
