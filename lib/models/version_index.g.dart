// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionIndex _$VersionIndexFromJson(Map<String, dynamic> json) => VersionIndex(
  metadata:
      (json['metadata'] as List<dynamic>)
          .map((e) => VersionMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$VersionIndexToJson(VersionIndex instance) =>
    <String, dynamic>{'metadata': instance.metadata};

VersionMetadata _$VersionMetadataFromJson(Map<String, dynamic> json) =>
    VersionMetadata(
      name: json['name'] as String,
      downloadSize: (json['download_size'] as num).toInt(),
      info: VersionInfo.fromJson(json['info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VersionMetadataToJson(VersionMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'download_size': instance.downloadSize,
      'info': instance.info,
    };

VersionInfo _$VersionInfoFromJson(Map<String, dynamic> json) => VersionInfo(
  name: json['name'] as String,
  sha1: json['sha1'] as String,
  url: json['url'] as String,
);

Map<String, dynamic> _$VersionInfoToJson(VersionInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sha1': instance.sha1,
      'url': instance.url,
    };
