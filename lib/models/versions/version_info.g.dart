// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionInfo _$VersionInfoFromJson(Map<String, dynamic> json) => VersionInfo(
  id: json['id'] as String,
  inheritsFrom: json['inheritsFrom'] as String?,
  type: json['type'] as String?,
  mainClass: json['mainClass'] as String?,
  minecraftArguments: json['minecraftArguments'] as String?,
  arguments:
      json['arguments'] == null
          ? null
          : Arguments.fromJson(json['arguments'] as Map<String, dynamic>),
  assetIndex:
      json['assetIndex'] == null
          ? null
          : AssetIndex.fromJson(json['assetIndex'] as Map<String, dynamic>),
  assets: json['assets'] as String?,
  complianceLevel: (json['complianceLevel'] as num?)?.toInt(),
  downloads:
      json['downloads'] == null
          ? null
          : Downloads.fromJson(json['downloads'] as Map<String, dynamic>),
  javaVersion:
      json['javaVersion'] == null
          ? null
          : JavaVersion.fromJson(json['javaVersion'] as Map<String, dynamic>),
  libraries:
      (json['libraries'] as List<dynamic>?)
          ?.map((e) => Library.fromJson(e as Map<String, dynamic>))
          .toList(),
  logging:
      json['logging'] == null
          ? null
          : Logging.fromJson(json['logging'] as Map<String, dynamic>),
  minimumLauncherVersion: (json['minimumLauncherVersion'] as num?)?.toInt(),
  releaseTime: json['releaseTime'] as String?,
  time: json['time'] as String?,
);

Map<String, dynamic> _$VersionInfoToJson(VersionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.inheritsFrom case final value?) 'inheritsFrom': value,
      'type': instance.type,
      'mainClass': instance.mainClass,
      'minecraftArguments': instance.minecraftArguments,
      'arguments': instance.arguments,
      'assetIndex': instance.assetIndex,
      'assets': instance.assets,
      'complianceLevel': instance.complianceLevel,
      'downloads': instance.downloads,
      'javaVersion': instance.javaVersion,
      'libraries': instance.libraries,
      'logging': instance.logging,
      'minimumLauncherVersion': instance.minimumLauncherVersion,
      'releaseTime': instance.releaseTime,
      'time': instance.time,
    };

Arguments _$ArgumentsFromJson(Map<String, dynamic> json) => Arguments(
  game: json['game'] as List<dynamic>?,
  jvm: json['jvm'] as List<dynamic>?,
);

Map<String, dynamic> _$ArgumentsToJson(Arguments instance) => <String, dynamic>{
  'game': instance.game,
  'jvm': instance.jvm,
};

AssetIndex _$AssetIndexFromJson(Map<String, dynamic> json) => AssetIndex(
  id: json['id'] as String,
  sha1: json['sha1'] as String?,
  size: (json['size'] as num?)?.toInt(),
  totalSize: (json['totalSize'] as num?)?.toInt(),
  url: json['url'] as String,
);

Map<String, dynamic> _$AssetIndexToJson(AssetIndex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sha1': instance.sha1,
      'size': instance.size,
      'totalSize': instance.totalSize,
      'url': instance.url,
    };

Downloads _$DownloadsFromJson(Map<String, dynamic> json) => Downloads(
  client:
      json['client'] == null
          ? null
          : DownloadInfo.fromJson(json['client'] as Map<String, dynamic>),
  clientMappings:
      json['client_mappings'] == null
          ? null
          : DownloadInfo.fromJson(
            json['client_mappings'] as Map<String, dynamic>,
          ),
  server:
      json['server'] == null
          ? null
          : DownloadInfo.fromJson(json['server'] as Map<String, dynamic>),
  serverMappings:
      json['server_mappings'] == null
          ? null
          : DownloadInfo.fromJson(
            json['server_mappings'] as Map<String, dynamic>,
          ),
  windowsServer:
      json['windows_server'] == null
          ? null
          : DownloadInfo.fromJson(
            json['windows_server'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$DownloadsToJson(Downloads instance) => <String, dynamic>{
  'client': instance.client,
  'client_mappings': instance.clientMappings,
  'server': instance.server,
  'server_mappings': instance.serverMappings,
  'windows_server': instance.windowsServer,
};

DownloadInfo _$DownloadInfoFromJson(Map<String, dynamic> json) => DownloadInfo(
  sha1: json['sha1'] as String?,
  size: (json['size'] as num?)?.toInt(),
  url: json['url'] as String,
);

Map<String, dynamic> _$DownloadInfoToJson(DownloadInfo instance) =>
    <String, dynamic>{
      'sha1': instance.sha1,
      'size': instance.size,
      'url': instance.url,
    };

JavaVersion _$JavaVersionFromJson(Map<String, dynamic> json) => JavaVersion(
  component: json['component'] as String,
  majorVersion: (json['majorVersion'] as num).toInt(),
);

Map<String, dynamic> _$JavaVersionToJson(JavaVersion instance) =>
    <String, dynamic>{
      'component': instance.component,
      'majorVersion': instance.majorVersion,
    };

Library _$LibraryFromJson(Map<String, dynamic> json) => Library(
  name: json['name'] as String?,
  url: json['url'] as String?,
  downloads:
      json['downloads'] == null
          ? null
          : LibraryDownloads.fromJson(
            json['downloads'] as Map<String, dynamic>,
          ),
  natives: (json['natives'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  rules:
      (json['rules'] as List<dynamic>?)
          ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
          .toList(),
  extract:
      json['extract'] == null
          ? null
          : Extract.fromJson(json['extract'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LibraryToJson(Library instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
  'downloads': instance.downloads,
  'natives': instance.natives,
  'rules': instance.rules,
  'extract': instance.extract,
};

LibraryDownloads _$LibraryDownloadsFromJson(
  Map<String, dynamic> json,
) => LibraryDownloads(
  artifact:
      json['artifact'] == null
          ? null
          : DownloadArtifact.fromJson(json['artifact'] as Map<String, dynamic>),
  classifiers: (json['classifiers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, DownloadArtifact.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$LibraryDownloadsToJson(LibraryDownloads instance) =>
    <String, dynamic>{
      'artifact': instance.artifact,
      'classifiers': instance.classifiers,
    };

DownloadArtifact _$DownloadArtifactFromJson(Map<String, dynamic> json) =>
    DownloadArtifact(
      path: json['path'] as String?,
      sha1: json['sha1'] as String?,
      size: (json['size'] as num?)?.toInt(),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$DownloadArtifactToJson(DownloadArtifact instance) =>
    <String, dynamic>{
      'path': instance.path,
      'sha1': instance.sha1,
      'size': instance.size,
      'url': instance.url,
    };

Rule _$RuleFromJson(Map<String, dynamic> json) => Rule(
  action: json['action'] as String,
  os:
      json['os'] == null
          ? null
          : Os.fromJson(json['os'] as Map<String, dynamic>),
  features:
      json['features'] == null
          ? null
          : Features.fromJson(json['features'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
  'action': instance.action,
  'os': instance.os,
  'features': instance.features,
};

Features _$FeaturesFromJson(Map<String, dynamic> json) => Features(
  isDemoUser: json['is_demo_user'] as bool?,
  hasCustomResolution: json['has_custom_resolution'] as bool?,
  hasQuickPlaysSupport: json['has_quick_plays_support'] as bool?,
  isQuickPlaySingleplayer: json['is_quick_play_singleplayer'] as bool?,
  isQuickPlayMultiplayer: json['is_quick_play_multiplayer'] as bool?,
  isQuickPlayRealms: json['is_quick_play_realms'] as bool?,
);

Map<String, dynamic> _$FeaturesToJson(Features instance) => <String, dynamic>{
  'is_demo_user': instance.isDemoUser,
  'has_custom_resolution': instance.hasCustomResolution,
  'has_quick_plays_support': instance.hasQuickPlaysSupport,
  'is_quick_play_singleplayer': instance.isQuickPlaySingleplayer,
  'is_quick_play_multiplayer': instance.isQuickPlayMultiplayer,
  'is_quick_play_realms': instance.isQuickPlayRealms,
};

Os _$OsFromJson(Map<String, dynamic> json) =>
    Os(name: json['name'] as String?, version: json['version'] as String?);

Map<String, dynamic> _$OsToJson(Os instance) => <String, dynamic>{
  'name': instance.name,
  'version': instance.version,
};

Extract _$ExtractFromJson(Map<String, dynamic> json) => Extract(
  exclude:
      (json['exclude'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$ExtractToJson(Extract instance) => <String, dynamic>{
  'exclude': instance.exclude,
};

Logging _$LoggingFromJson(Map<String, dynamic> json) => Logging(
  client:
      json['client'] == null
          ? null
          : LoggingClient.fromJson(json['client'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoggingToJson(Logging instance) => <String, dynamic>{
  'client': instance.client,
};

LoggingClient _$LoggingClientFromJson(Map<String, dynamic> json) =>
    LoggingClient(
      argument: json['argument'] as String?,
      file:
          json['file'] == null
              ? null
              : LoggingFile.fromJson(json['file'] as Map<String, dynamic>),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$LoggingClientToJson(LoggingClient instance) =>
    <String, dynamic>{
      'argument': instance.argument,
      'file': instance.file,
      'type': instance.type,
    };

LoggingFile _$LoggingFileFromJson(Map<String, dynamic> json) => LoggingFile(
  id: json['id'] as String?,
  sha1: json['sha1'] as String?,
  size: (json['size'] as num?)?.toInt(),
  url: json['url'] as String?,
);

Map<String, dynamic> _$LoggingFileToJson(LoggingFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sha1': instance.sha1,
      'size': instance.size,
      'url': instance.url,
    };
