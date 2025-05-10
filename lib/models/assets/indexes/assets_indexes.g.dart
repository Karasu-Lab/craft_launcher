// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets_indexes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetsIndexes _$AssetsIndexesFromJson(Map<String, dynamic> json) =>
    AssetsIndexes(
      mapToResources: json['mapToResources'] as bool?,
      objects: (json['objects'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, AssetObject.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$AssetsIndexesToJson(AssetsIndexes instance) =>
    <String, dynamic>{
      'mapToResources': instance.mapToResources,
      'objects': instance.objects,
    };

AssetObject _$AssetObjectFromJson(Map<String, dynamic> json) =>
    AssetObject(size: (json['size'] as num).toInt());

Map<String, dynamic> _$AssetObjectToJson(AssetObject instance) =>
    <String, dynamic>{'size': instance.size};
