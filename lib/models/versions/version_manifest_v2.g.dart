// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_manifest_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionManifestV2 _$VersionManifestV2FromJson(Map<String, dynamic> json) =>
    VersionManifestV2(
      latest: Latest.fromJson(json['latest'] as Map<String, dynamic>),
      versions:
          (json['versions'] as List<dynamic>)
              .map((e) => Version.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$VersionManifestV2ToJson(VersionManifestV2 instance) =>
    <String, dynamic>{'latest': instance.latest, 'versions': instance.versions};

Latest _$LatestFromJson(Map<String, dynamic> json) => Latest(
  release: json['release'] as String,
  snapshot: json['snapshot'] as String,
);

Map<String, dynamic> _$LatestToJson(Latest instance) => <String, dynamic>{
  'release': instance.release,
  'snapshot': instance.snapshot,
};

Version _$VersionFromJson(Map<String, dynamic> json) =>
    Version(complianceLevel: (json['complianceLevel'] as num).toInt());

Map<String, dynamic> _$VersionToJson(Version instance) => <String, dynamic>{
  'complianceLevel': instance.complianceLevel,
};
