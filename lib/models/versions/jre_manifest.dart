import 'package:json_annotation/json_annotation.dart';

part 'jre_manifest.g.dart';

@JsonSerializable(explicitToJson: true)
class JreManifest {
  final ManifestData manifest;

  JreManifest({required this.manifest});

  factory JreManifest.fromJson(Map<String, dynamic> json) =>
      _$JreManifestFromJson(json);
  Map<String, dynamic> toJson() => _$JreManifestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ManifestData {
  final PlatformJavaRuntimes gamecore;
  final PlatformJavaRuntimes linux;
  @JsonKey(name: 'linux-i386')
  final PlatformJavaRuntimes linuxI386;
  @JsonKey(name: 'mac-os')
  final PlatformJavaRuntimes macOs;
  @JsonKey(name: 'mac-os-arm64')
  final PlatformJavaRuntimes macOsArm64;
  @JsonKey(name: 'windows-arm64')
  final PlatformJavaRuntimes windowsArm64;
  @JsonKey(name: 'windows-x64')
  final PlatformJavaRuntimes windowsX64;
  @JsonKey(name: 'windows-x86')
  final PlatformJavaRuntimes windowsX86;

  ManifestData({
    required this.gamecore,
    required this.linux,
    required this.linuxI386,
    required this.macOs,
    required this.macOsArm64,
    required this.windowsArm64,
    required this.windowsX64,
    required this.windowsX86,
  });

  factory ManifestData.fromJson(Map<String, dynamic> json) =>
      _$ManifestDataFromJson(json);
  Map<String, dynamic> toJson() => _$ManifestDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PlatformJavaRuntimes {
  @JsonKey(name: 'java-runtime-alpha')
  final List<JavaRuntime> javaRuntimeAlpha;
  @JsonKey(name: 'java-runtime-beta')
  final List<JavaRuntime> javaRuntimeBeta;
  @JsonKey(name: 'java-runtime-delta')
  final List<JavaRuntime> javaRuntimeDelta;
  @JsonKey(name: 'java-runtime-gamma')
  final List<JavaRuntime> javaRuntimeGamma;
  @JsonKey(name: 'java-runtime-gamma-snapshot')
  final List<JavaRuntime> javaRuntimeGammaSnapshot;
  @JsonKey(name: 'jre-legacy')
  final List<JavaRuntime> jreLegacy;
  @JsonKey(name: 'minecraft-java-exe')
  final List<JavaRuntime> minecraftJavaExe;

  PlatformJavaRuntimes({
    required this.javaRuntimeAlpha,
    required this.javaRuntimeBeta,
    required this.javaRuntimeDelta,
    required this.javaRuntimeGamma,
    required this.javaRuntimeGammaSnapshot,
    required this.jreLegacy,
    required this.minecraftJavaExe,
  });

  factory PlatformJavaRuntimes.fromJson(Map<String, dynamic> json) =>
      _$PlatformJavaRuntimesFromJson(json);
  Map<String, dynamic> toJson() => _$PlatformJavaRuntimesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JavaRuntime {
  final Availability? availability;
  final ManifestFileInfo? manifest;
  final VersionInfo? version;

  JavaRuntime({this.availability, this.manifest, this.version});

  factory JavaRuntime.fromJson(Map<String, dynamic> json) =>
      _$JavaRuntimeFromJson(json);
  Map<String, dynamic> toJson() => _$JavaRuntimeToJson(this);
}

@JsonSerializable()
class Availability {
  final int group;
  final int progress;

  Availability({required this.group, required this.progress});

  factory Availability.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilityToJson(this);
}

@JsonSerializable()
class ManifestFileInfo {
  final String sha1;
  final int size;
  final String url;

  ManifestFileInfo({required this.sha1, required this.size, required this.url});

  factory ManifestFileInfo.fromJson(Map<String, dynamic> json) =>
      _$ManifestFileInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ManifestFileInfoToJson(this);
}

@JsonSerializable()
class VersionInfo {
  final String name;
  final String released;

  VersionInfo({required this.name, required this.released});

  factory VersionInfo.fromJson(Map<String, dynamic> json) =>
      _$VersionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VersionInfoToJson(this);
}
