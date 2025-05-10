import 'package:json_annotation/json_annotation.dart';

part 'version_info.g.dart';

@JsonSerializable()
class VersionInfo {
  final String id;
  @JsonKey(name: 'inheritsFrom', includeIfNull: false)
  final String? inheritsFrom;
  final String? type;
  final String? mainClass;
  @JsonKey(name: 'minecraftArguments')
  final String? minecraftArguments;
  final Arguments? arguments;
  final AssetIndex? assetIndex;
  final String? assets;
  final int? complianceLevel;
  final Downloads? downloads;
  @JsonKey(name: 'javaVersion')
  final JavaVersion? javaVersion;
  final List<Library>? libraries;
  final Logging? logging;
  final int? minimumLauncherVersion;
  final String? releaseTime;
  final String? time;

  VersionInfo({
    required this.id,
    this.inheritsFrom,
    this.type,
    this.mainClass,
    this.minecraftArguments,
    this.arguments,
    this.assetIndex,
    this.assets,
    this.complianceLevel,
    this.downloads,
    this.javaVersion,
    this.libraries,
    this.logging,
    this.minimumLauncherVersion,
    this.releaseTime,
    this.time,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) =>
      _$VersionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VersionInfoToJson(this);
}

@JsonSerializable()
class Arguments {
  final List<dynamic>? game;
  final List<dynamic>? jvm;

  Arguments({this.game, this.jvm});

  factory Arguments.fromJson(Map<String, dynamic> json) =>
      _$ArgumentsFromJson(json);
  Map<String, dynamic> toJson() => _$ArgumentsToJson(this);
}

@JsonSerializable()
class AssetIndex {
  final String id;
  final String? sha1;
  final int? size;
  @JsonKey(name: 'totalSize')
  final int? totalSize;
  final String url;

  AssetIndex({
    required this.id,
    this.sha1,
    this.size,
    this.totalSize,
    required this.url,
  });

  factory AssetIndex.fromJson(Map<String, dynamic> json) =>
      _$AssetIndexFromJson(json);
  Map<String, dynamic> toJson() => _$AssetIndexToJson(this);
}

@JsonSerializable()
class Downloads {
  final DownloadInfo? client;
  @JsonKey(name: 'client_mappings')
  final DownloadInfo? clientMappings;
  final DownloadInfo? server;
  @JsonKey(name: 'server_mappings')
  final DownloadInfo? serverMappings;
  @JsonKey(name: 'windows_server')
  final DownloadInfo? windowsServer;

  Downloads({
    this.client,
    this.clientMappings,
    this.server,
    this.serverMappings,
    this.windowsServer,
  });

  factory Downloads.fromJson(Map<String, dynamic> json) =>
      _$DownloadsFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadsToJson(this);
}

@JsonSerializable()
class DownloadInfo {
  final String? sha1;
  final int? size;
  final String url;

  DownloadInfo({this.sha1, this.size, required this.url});

  factory DownloadInfo.fromJson(Map<String, dynamic> json) =>
      _$DownloadInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadInfoToJson(this);
}

@JsonSerializable()
class JavaVersion {
  final String component;
  final int majorVersion;

  JavaVersion({required this.component, required this.majorVersion});

  factory JavaVersion.fromJson(Map<String, dynamic> json) =>
      _$JavaVersionFromJson(json);
  Map<String, dynamic> toJson() => _$JavaVersionToJson(this);
}

@JsonSerializable()
class Library {
  final String? name;
  final String? url;
  final Map<String, dynamic>? downloads;
  final Map<String, String>? natives;
  final List<Rule>? rules;
  final Extract? extract;

  Library({
    this.name,
    this.url,
    this.downloads,
    this.natives,
    this.rules,
    this.extract,
  });

  factory Library.fromJson(Map<String, dynamic> json) =>
      _$LibraryFromJson(json);
  Map<String, dynamic> toJson() => _$LibraryToJson(this);
}

@JsonSerializable()
class Rule {
  final String action;
  final Os? os;

  Rule({required this.action, this.os});

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);
  Map<String, dynamic> toJson() => _$RuleToJson(this);
}

@JsonSerializable()
class Os {
  final String? name;
  final String? version;

  Os({this.name, this.version});

  factory Os.fromJson(Map<String, dynamic> json) => _$OsFromJson(json);
  Map<String, dynamic> toJson() => _$OsToJson(this);
}

@JsonSerializable()
class Extract {
  final List<String>? exclude;

  Extract({this.exclude});

  factory Extract.fromJson(Map<String, dynamic> json) =>
      _$ExtractFromJson(json);
  Map<String, dynamic> toJson() => _$ExtractToJson(this);
}

@JsonSerializable()
class Logging {
  final LoggingClient? client;

  Logging({this.client});

  factory Logging.fromJson(Map<String, dynamic> json) =>
      _$LoggingFromJson(json);
  Map<String, dynamic> toJson() => _$LoggingToJson(this);
}

@JsonSerializable()
class LoggingClient {
  final String? argument;
  final LoggingFile? file;
  final String? type;

  LoggingClient({this.argument, this.file, this.type});

  factory LoggingClient.fromJson(Map<String, dynamic> json) =>
      _$LoggingClientFromJson(json);
  Map<String, dynamic> toJson() => _$LoggingClientToJson(this);
}

@JsonSerializable()
class LoggingFile {
  final String? id;
  final String? sha1;
  final int? size;
  final String? url;

  LoggingFile({this.id, this.sha1, this.size, this.url});

  factory LoggingFile.fromJson(Map<String, dynamic> json) =>
      _$LoggingFileFromJson(json);
  Map<String, dynamic> toJson() => _$LoggingFileToJson(this);
}
