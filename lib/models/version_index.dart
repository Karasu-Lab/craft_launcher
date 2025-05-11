import 'package:json_annotation/json_annotation.dart';

part 'version_index.g.dart';

@JsonSerializable()
class VersionIndex {
  final List<VersionMetadata> metadata;

  VersionIndex({required this.metadata});

  factory VersionIndex.fromJson(Map<String, dynamic> json) =>
      _$VersionIndexFromJson(json);

  Map<String, dynamic> toJson() => _$VersionIndexToJson(this);
}

@JsonSerializable()
class VersionMetadata {
  final String name;
  @JsonKey(name: 'download_size')
  final int downloadSize;
  final VersionMetadata info;
  VersionMetadata({
    required this.name,
    required this.downloadSize,
    required this.info,
  });

  factory VersionMetadata.fromJson(Map<String, dynamic> json) =>
      _$VersionMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$VersionMetadataToJson(this);
}

@JsonSerializable()
class VersionMetadataVersionInfo {
  final String name;
  final String sha1;
  final String url;

  VersionMetadataVersionInfo({required this.name, required this.sha1, required this.url});

  factory VersionMetadataVersionInfo.fromJson(Map<String, dynamic> json) =>
      _$VersionMetadataVersionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VersionMetadataVersionInfoToJson(this);
}
