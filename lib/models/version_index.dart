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
  final VersionInfo info;
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
class VersionInfo {
  final String name;
  final String sha1;
  final String url;

  VersionInfo({required this.name, required this.sha1, required this.url});

  factory VersionInfo.fromJson(Map<String, dynamic> json) =>
      _$VersionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VersionInfoToJson(this);
}
