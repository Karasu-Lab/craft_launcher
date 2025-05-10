import 'package:json_annotation/json_annotation.dart';

part 'updateSourceCache.g.dart';

@JsonSerializable()
class UpdateSourceCache {
  final Map<String, CacheItem> cacheMap;
  final int version;

  UpdateSourceCache({
    required this.cacheMap,
    required this.version,
  });

  factory UpdateSourceCache.fromJson(Map<String, dynamic> json) =>
      _$UpdateSourceCacheFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSourceCacheToJson(this);
}

@JsonSerializable()
class CacheItem {
  final String rawResponse;
  final String validUntil;

  CacheItem({
    required this.rawResponse,
    required this.validUntil,
  });

  factory CacheItem.fromJson(Map<String, dynamic> json) =>
      _$CacheItemFromJson(json);

  Map<String, dynamic> toJson() => _$CacheItemToJson(this);
}

@JsonSerializable()
class BuildResult {
  final BuildInfo result;

  BuildResult({
    required this.result,
  });

  factory BuildResult.fromJson(Map<String, dynamic> json) =>
      _$BuildResultFromJson(json);

  Map<String, dynamic> toJson() => _$BuildResultToJson(this);
}

@JsonSerializable()
class BuildInfo {
  final String buildName;
  final String downloadUrl;

  BuildInfo({
    required this.buildName,
    required this.downloadUrl,
  });

  factory BuildInfo.fromJson(Map<String, dynamic> json) =>
      _$BuildInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BuildInfoToJson(this);
}