// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherMetaAvailability _$LauncherMetaAvailabilityFromJson(
  Map<String, dynamic> json,
) => LauncherMetaAvailability(
  group: (json['group'] as num).toInt(),
  progress: (json['progress'] as num).toInt(),
);

Map<String, dynamic> _$LauncherMetaAvailabilityToJson(
  LauncherMetaAvailability instance,
) => <String, dynamic>{'group': instance.group, 'progress': instance.progress};

LauncherMetaManifest _$LauncherMetaManifestFromJson(
  Map<String, dynamic> json,
) => LauncherMetaManifest(
  sha1: json['sha1'] as String,
  size: (json['size'] as num).toInt(),
  url: json['url'] as String,
);

Map<String, dynamic> _$LauncherMetaManifestToJson(
  LauncherMetaManifest instance,
) => <String, dynamic>{
  'sha1': instance.sha1,
  'size': instance.size,
  'url': instance.url,
};

LauncherMetaVersion _$LauncherMetaVersionFromJson(Map<String, dynamic> json) =>
    LauncherMetaVersion(
      name: json['name'] as String,
      released: json['released'] as String,
    );

Map<String, dynamic> _$LauncherMetaVersionToJson(
  LauncherMetaVersion instance,
) => <String, dynamic>{'name': instance.name, 'released': instance.released};

LauncherMetaEntry _$LauncherMetaEntryFromJson(Map<String, dynamic> json) =>
    LauncherMetaEntry(
      availability: LauncherMetaAvailability.fromJson(
        json['availability'] as Map<String, dynamic>,
      ),
      manifest: LauncherMetaManifest.fromJson(
        json['manifest'] as Map<String, dynamic>,
      ),
      version: LauncherMetaVersion.fromJson(
        json['version'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$LauncherMetaEntryToJson(LauncherMetaEntry instance) =>
    <String, dynamic>{
      'availability': instance.availability,
      'manifest': instance.manifest,
      'version': instance.version,
    };

LauncherMeta _$LauncherMetaFromJson(Map<String, dynamic> json) => LauncherMeta(
  jreX64:
      (json['jre-x64'] as List<dynamic>)
          .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
  jreX86:
      (json['jre-x86'] as List<dynamic>)
          .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
  launcherBootstrap:
      (json['launcher-bootstrap'] as List<dynamic>)
          .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
  launcherBootstrapAdo:
      (json['launcher-bootstrap-ado'] as List<dynamic>)
          .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
  launcherCore:
      (json['launcher-core'] as List<dynamic>)
          .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
  launcherCoreAdo:
      (json['launcher-core-ado'] as List<dynamic>)
          .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
  launcherCoreV2:
      (json['launcher-core-v2'] as List<dynamic>)
          .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
  launcherJava:
      (json['launcher-java'] as List<dynamic>)
          .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
  launcherMsiPatch:
      (json['launcher-msi-patch'] as List<dynamic>)
          .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$LauncherMetaToJson(LauncherMeta instance) =>
    <String, dynamic>{
      'jre-x64': instance.jreX64,
      'jre-x86': instance.jreX86,
      'launcher-bootstrap': instance.launcherBootstrap,
      'launcher-bootstrap-ado': instance.launcherBootstrapAdo,
      'launcher-core': instance.launcherCore,
      'launcher-core-ado': instance.launcherCoreAdo,
      'launcher-core-v2': instance.launcherCoreV2,
      'launcher-java': instance.launcherJava,
      'launcher-msi-patch': instance.launcherMsiPatch,
    };

WindowsLauncherMeta _$WindowsLauncherMetaFromJson(Map<String, dynamic> json) =>
    WindowsLauncherMeta(
      jreX64:
          (json['jre-x64'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      jreX86:
          (json['jre-x86'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherBootstrap:
          (json['launcher-bootstrap'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherBootstrapAdo:
          (json['launcher-bootstrap-ado'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherCore:
          (json['launcher-core'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherCoreAdo:
          (json['launcher-core-ado'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherCoreV2:
          (json['launcher-core-v2'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherJava:
          (json['launcher-java'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherMsiPatch:
          (json['launcher-msi-patch'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$WindowsLauncherMetaToJson(
  WindowsLauncherMeta instance,
) => <String, dynamic>{
  'jre-x64': instance.jreX64,
  'jre-x86': instance.jreX86,
  'launcher-bootstrap': instance.launcherBootstrap,
  'launcher-bootstrap-ado': instance.launcherBootstrapAdo,
  'launcher-core': instance.launcherCore,
  'launcher-core-ado': instance.launcherCoreAdo,
  'launcher-core-v2': instance.launcherCoreV2,
  'launcher-java': instance.launcherJava,
  'launcher-msi-patch': instance.launcherMsiPatch,
};

MacOSLauncherMeta _$MacOSLauncherMetaFromJson(Map<String, dynamic> json) =>
    MacOSLauncherMeta(
      jreX64:
          (json['jre-x64'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      jreX86:
          (json['jre-x86'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherBootstrap:
          (json['launcher-bootstrap'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherBootstrapAdo:
          (json['launcher-bootstrap-ado'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherCore:
          (json['launcher-core'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherCoreAdo:
          (json['launcher-core-ado'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherCoreV2:
          (json['launcher-core-v2'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherJava:
          (json['launcher-java'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherMsiPatch:
          (json['launcher-msi-patch'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$MacOSLauncherMetaToJson(MacOSLauncherMeta instance) =>
    <String, dynamic>{
      'jre-x64': instance.jreX64,
      'jre-x86': instance.jreX86,
      'launcher-bootstrap': instance.launcherBootstrap,
      'launcher-bootstrap-ado': instance.launcherBootstrapAdo,
      'launcher-core': instance.launcherCore,
      'launcher-core-ado': instance.launcherCoreAdo,
      'launcher-core-v2': instance.launcherCoreV2,
      'launcher-java': instance.launcherJava,
      'launcher-msi-patch': instance.launcherMsiPatch,
    };

LinuxLauncherMeta _$LinuxLauncherMetaFromJson(Map<String, dynamic> json) =>
    LinuxLauncherMeta(
      jreX64:
          (json['jre-x64'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      jreX86:
          (json['jre-x86'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherBootstrap:
          (json['launcher-bootstrap'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherBootstrapAdo:
          (json['launcher-bootstrap-ado'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherCore:
          (json['launcher-core'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherCoreAdo:
          (json['launcher-core-ado'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherCoreV2:
          (json['launcher-core-v2'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherJava:
          (json['launcher-java'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      launcherMsiPatch:
          (json['launcher-msi-patch'] as List<dynamic>)
              .map((e) => LauncherMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$LinuxLauncherMetaToJson(LinuxLauncherMeta instance) =>
    <String, dynamic>{
      'jre-x64': instance.jreX64,
      'jre-x86': instance.jreX86,
      'launcher-bootstrap': instance.launcherBootstrap,
      'launcher-bootstrap-ado': instance.launcherBootstrapAdo,
      'launcher-core': instance.launcherCore,
      'launcher-core-ado': instance.launcherCoreAdo,
      'launcher-core-v2': instance.launcherCoreV2,
      'launcher-java': instance.launcherJava,
      'launcher-msi-patch': instance.launcherMsiPatch,
    };
