// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jre_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JreManifest _$JreManifestFromJson(Map<String, dynamic> json) => JreManifest(
  manifest: ManifestData.fromJson(json['manifest'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JreManifestToJson(JreManifest instance) =>
    <String, dynamic>{'manifest': instance.manifest.toJson()};

ManifestData _$ManifestDataFromJson(Map<String, dynamic> json) => ManifestData(
  gamecore: PlatformJavaRuntimes.fromJson(
    json['gamecore'] as Map<String, dynamic>,
  ),
  linux: PlatformJavaRuntimes.fromJson(json['linux'] as Map<String, dynamic>),
  linuxI386: PlatformJavaRuntimes.fromJson(
    json['linux-i386'] as Map<String, dynamic>,
  ),
  macOs: PlatformJavaRuntimes.fromJson(json['mac-os'] as Map<String, dynamic>),
  macOsArm64: PlatformJavaRuntimes.fromJson(
    json['mac-os-arm64'] as Map<String, dynamic>,
  ),
  windowsArm64: PlatformJavaRuntimes.fromJson(
    json['windows-arm64'] as Map<String, dynamic>,
  ),
  windowsX64: PlatformJavaRuntimes.fromJson(
    json['windows-x64'] as Map<String, dynamic>,
  ),
  windowsX86: PlatformJavaRuntimes.fromJson(
    json['windows-x86'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ManifestDataToJson(ManifestData instance) =>
    <String, dynamic>{
      'gamecore': instance.gamecore.toJson(),
      'linux': instance.linux.toJson(),
      'linux-i386': instance.linuxI386.toJson(),
      'mac-os': instance.macOs.toJson(),
      'mac-os-arm64': instance.macOsArm64.toJson(),
      'windows-arm64': instance.windowsArm64.toJson(),
      'windows-x64': instance.windowsX64.toJson(),
      'windows-x86': instance.windowsX86.toJson(),
    };

PlatformJavaRuntimes _$PlatformJavaRuntimesFromJson(
  Map<String, dynamic> json,
) => PlatformJavaRuntimes(
  javaRuntimeAlpha:
      (json['java-runtime-alpha'] as List<dynamic>)
          .map((e) => JavaRuntime.fromJson(e as Map<String, dynamic>))
          .toList(),
  javaRuntimeBeta:
      (json['java-runtime-beta'] as List<dynamic>)
          .map((e) => JavaRuntime.fromJson(e as Map<String, dynamic>))
          .toList(),
  javaRuntimeDelta:
      (json['java-runtime-delta'] as List<dynamic>)
          .map((e) => JavaRuntime.fromJson(e as Map<String, dynamic>))
          .toList(),
  javaRuntimeGamma:
      (json['java-runtime-gamma'] as List<dynamic>)
          .map((e) => JavaRuntime.fromJson(e as Map<String, dynamic>))
          .toList(),
  javaRuntimeGammaSnapshot:
      (json['java-runtime-gamma-snapshot'] as List<dynamic>)
          .map((e) => JavaRuntime.fromJson(e as Map<String, dynamic>))
          .toList(),
  jreLegacy:
      (json['jre-legacy'] as List<dynamic>)
          .map((e) => JavaRuntime.fromJson(e as Map<String, dynamic>))
          .toList(),
  minecraftJavaExe:
      (json['minecraft-java-exe'] as List<dynamic>)
          .map((e) => JavaRuntime.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$PlatformJavaRuntimesToJson(
  PlatformJavaRuntimes instance,
) => <String, dynamic>{
  'java-runtime-alpha':
      instance.javaRuntimeAlpha.map((e) => e.toJson()).toList(),
  'java-runtime-beta': instance.javaRuntimeBeta.map((e) => e.toJson()).toList(),
  'java-runtime-delta':
      instance.javaRuntimeDelta.map((e) => e.toJson()).toList(),
  'java-runtime-gamma':
      instance.javaRuntimeGamma.map((e) => e.toJson()).toList(),
  'java-runtime-gamma-snapshot':
      instance.javaRuntimeGammaSnapshot.map((e) => e.toJson()).toList(),
  'jre-legacy': instance.jreLegacy.map((e) => e.toJson()).toList(),
  'minecraft-java-exe':
      instance.minecraftJavaExe.map((e) => e.toJson()).toList(),
};

JavaRuntime _$JavaRuntimeFromJson(Map<String, dynamic> json) => JavaRuntime(
  availability:
      json['availability'] == null
          ? null
          : Availability.fromJson(json['availability'] as Map<String, dynamic>),
  manifest:
      json['manifest'] == null
          ? null
          : ManifestFileInfo.fromJson(json['manifest'] as Map<String, dynamic>),
  version:
      json['version'] == null
          ? null
          : VersionInfo.fromJson(json['version'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JavaRuntimeToJson(JavaRuntime instance) =>
    <String, dynamic>{
      'availability': instance.availability?.toJson(),
      'manifest': instance.manifest?.toJson(),
      'version': instance.version?.toJson(),
    };

Availability _$AvailabilityFromJson(Map<String, dynamic> json) => Availability(
  group: (json['group'] as num).toInt(),
  progress: (json['progress'] as num).toInt(),
);

Map<String, dynamic> _$AvailabilityToJson(Availability instance) =>
    <String, dynamic>{'group': instance.group, 'progress': instance.progress};

ManifestFileInfo _$ManifestFileInfoFromJson(Map<String, dynamic> json) =>
    ManifestFileInfo(
      sha1: json['sha1'] as String,
      size: (json['size'] as num).toInt(),
      url: json['url'] as String,
    );

Map<String, dynamic> _$ManifestFileInfoToJson(ManifestFileInfo instance) =>
    <String, dynamic>{
      'sha1': instance.sha1,
      'size': instance.size,
      'url': instance.url,
    };

VersionInfo _$VersionInfoFromJson(Map<String, dynamic> json) => VersionInfo(
  name: json['name'] as String,
  released: json['released'] as String,
);

Map<String, dynamic> _$VersionInfoToJson(VersionInfo instance) =>
    <String, dynamic>{'name': instance.name, 'released': instance.released};
