import 'package:json_annotation/json_annotation.dart';

part 'version_manifest_v2.g.dart';

@JsonSerializable()
class VersionManifestV2 {
  final Latest latest;
  final List<Version> versions;

  VersionManifestV2({required this.latest, required this.versions});

  factory VersionManifestV2.fromJson(Map<String, dynamic> json) =>
      _$VersionManifestV2FromJson(json);

  Map<String, dynamic> toJson() => _$VersionManifestV2ToJson(this);
}

@JsonSerializable()
class Latest {
  final String release;
  final String snapshot;

  Latest({required this.release, required this.snapshot});

  factory Latest.fromJson(Map<String, dynamic> json) => _$LatestFromJson(json);

  Map<String, dynamic> toJson() => _$LatestToJson(this);
}

@JsonSerializable()
class Version {
  final int complianceLevel;

  Version({required this.complianceLevel});

  factory Version.fromJson(Map<String, dynamic> json) =>
      _$VersionFromJson(json);

  Map<String, dynamic> toJson() => _$VersionToJson(this);
}
