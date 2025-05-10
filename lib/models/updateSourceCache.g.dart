// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updateSourceCache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateSourceCache _$UpdateSourceCacheFromJson(Map<String, dynamic> json) =>
    UpdateSourceCache(
      cacheMap: (json['cacheMap'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, CacheItem.fromJson(e as Map<String, dynamic>)),
      ),
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$UpdateSourceCacheToJson(UpdateSourceCache instance) =>
    <String, dynamic>{
      'cacheMap': instance.cacheMap,
      'version': instance.version,
    };

CacheItem _$CacheItemFromJson(Map<String, dynamic> json) => CacheItem(
  rawResponse: json['rawResponse'] as String,
  validUntil: json['validUntil'] as String,
);

Map<String, dynamic> _$CacheItemToJson(CacheItem instance) => <String, dynamic>{
  'rawResponse': instance.rawResponse,
  'validUntil': instance.validUntil,
};

BuildResult _$BuildResultFromJson(Map<String, dynamic> json) => BuildResult(
  result: BuildInfo.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BuildResultToJson(BuildResult instance) =>
    <String, dynamic>{'result': instance.result};

BuildInfo _$BuildInfoFromJson(Map<String, dynamic> json) => BuildInfo(
  buildName: json['buildName'] as String,
  downloadUrl: json['downloadUrl'] as String,
);

Map<String, dynamic> _$BuildInfoToJson(BuildInfo instance) => <String, dynamic>{
  'buildName': instance.buildName,
  'downloadUrl': instance.downloadUrl,
};
