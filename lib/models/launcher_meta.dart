import 'package:json_annotation/json_annotation.dart';

part 'launcher_meta.g.dart';

@JsonSerializable()
class LauncherMetaAvailability {
  final int group;
  final int progress;

  LauncherMetaAvailability({
    required this.group,
    required this.progress,
  });

  factory LauncherMetaAvailability.fromJson(Map<String, dynamic> json) =>
      _$LauncherMetaAvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherMetaAvailabilityToJson(this);
}

@JsonSerializable()
class LauncherMetaManifest {
  final String sha1;
  final int size;
  final String url;

  LauncherMetaManifest({
    required this.sha1,
    required this.size,
    required this.url,
  });

  factory LauncherMetaManifest.fromJson(Map<String, dynamic> json) =>
      _$LauncherMetaManifestFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherMetaManifestToJson(this);
}

@JsonSerializable()
class LauncherMetaVersion {
  final String name;
  final String released;

  LauncherMetaVersion({
    required this.name,
    required this.released,
  });

  factory LauncherMetaVersion.fromJson(Map<String, dynamic> json) =>
      _$LauncherMetaVersionFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherMetaVersionToJson(this);
}

@JsonSerializable()
class LauncherMetaEntry {
  final LauncherMetaAvailability availability;
  final LauncherMetaManifest manifest;
  final LauncherMetaVersion version;

  LauncherMetaEntry({
    required this.availability,
    required this.manifest,
    required this.version,
  });

  factory LauncherMetaEntry.fromJson(Map<String, dynamic> json) =>
      _$LauncherMetaEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherMetaEntryToJson(this);
}

@JsonSerializable()
class LauncherMeta {
  @JsonKey(name: 'jre-x64')
  final List<LauncherMetaEntry> jreX64;
  
  @JsonKey(name: 'jre-x86')
  final List<LauncherMetaEntry> jreX86;
  
  @JsonKey(name: 'launcher-bootstrap')
  final List<LauncherMetaEntry> launcherBootstrap;
  
  @JsonKey(name: 'launcher-bootstrap-ado')
  final List<LauncherMetaEntry> launcherBootstrapAdo;
  
  @JsonKey(name: 'launcher-core')
  final List<LauncherMetaEntry> launcherCore;
  
  @JsonKey(name: 'launcher-core-ado')
  final List<LauncherMetaEntry> launcherCoreAdo;
  
  @JsonKey(name: 'launcher-core-v2')
  final List<LauncherMetaEntry> launcherCoreV2;
  
  @JsonKey(name: 'launcher-java')
  final List<LauncherMetaEntry> launcherJava;
  
  @JsonKey(name: 'launcher-msi-patch')
  final List<LauncherMetaEntry> launcherMsiPatch;

  LauncherMeta({
    required this.jreX64,
    required this.jreX86,
    required this.launcherBootstrap,
    required this.launcherBootstrapAdo,
    required this.launcherCore,
    required this.launcherCoreAdo,
    required this.launcherCoreV2,
    required this.launcherJava,
    required this.launcherMsiPatch,
  });

  factory LauncherMeta.fromJson(Map<String, dynamic> json) =>
      _$LauncherMetaFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherMetaToJson(this);
}

@JsonSerializable()
class WindowsLauncherMeta extends LauncherMeta {
  WindowsLauncherMeta({
    required super.jreX64,
    required super.jreX86,
    required super.launcherBootstrap,
    required super.launcherBootstrapAdo,
    required super.launcherCore,
    required super.launcherCoreAdo,
    required super.launcherCoreV2,
    required super.launcherJava,
    required super.launcherMsiPatch,
  });

  factory WindowsLauncherMeta.fromJson(Map<String, dynamic> json) =>
      _$WindowsLauncherMetaFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WindowsLauncherMetaToJson(this);
}

@JsonSerializable()
class MacOSLauncherMeta extends LauncherMeta {
  MacOSLauncherMeta({
    required super.jreX64,
    required super.jreX86,
    required super.launcherBootstrap,
    required super.launcherBootstrapAdo,
    required super.launcherCore,
    required super.launcherCoreAdo,
    required super.launcherCoreV2,
    required super.launcherJava,
    required super.launcherMsiPatch,
  });

  factory MacOSLauncherMeta.fromJson(Map<String, dynamic> json) =>
      _$MacOSLauncherMetaFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MacOSLauncherMetaToJson(this);
}

@JsonSerializable()
class LinuxLauncherMeta extends LauncherMeta {
  LinuxLauncherMeta({
    required super.jreX64,
    required super.jreX86,
    required super.launcherBootstrap,
    required super.launcherBootstrapAdo,
    required super.launcherCore,
    required super.launcherCoreAdo,
    required super.launcherCoreV2,
    required super.launcherJava,
    required super.launcherMsiPatch,
  });

  factory LinuxLauncherMeta.fromJson(Map<String, dynamic> json) =>
      _$LinuxLauncherMetaFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LinuxLauncherMetaToJson(this);
}