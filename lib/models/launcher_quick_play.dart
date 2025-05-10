import 'package:json_annotation/json_annotation.dart';

part 'launcher_quick_play.g.dart';

@JsonSerializable()
class LauncherQuickPlay {
  @JsonKey(name: 'quickPlayData')
  final Map<String, List<QuickPlayEntry>> quickPlayData;
  final int version;

  LauncherQuickPlay({
    required this.quickPlayData,
    required this.version,
  });

  factory LauncherQuickPlay.fromJson(Map<String, dynamic> json) =>
      _$LauncherQuickPlayFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherQuickPlayToJson(this);
}

@JsonSerializable()
class QuickPlayEntry {
  @JsonKey(name: 'epochLastPlayedTimeMs')
  final int epochLastPlayedTimeMs;
  final String id;
  final String? name;
  final String source;
  @JsonKey(name: 'javaInstance')
  final JavaInstance? javaInstance;
  @JsonKey(name: 'bedrockInstance')
  final BedrockInstance? bedrockInstance;
  @JsonKey(name: 'productQuickPlay')
  final ProductQuickPlay? productQuickPlay;

  QuickPlayEntry({
    required this.epochLastPlayedTimeMs,
    required this.id,
    this.name,
    required this.source,
    this.javaInstance,
    this.bedrockInstance,
    this.productQuickPlay,
  });

  factory QuickPlayEntry.fromJson(Map<String, dynamic> json) =>
      _$QuickPlayEntryFromJson(json);

  Map<String, dynamic> toJson() => _$QuickPlayEntryToJson(this);
}

@JsonSerializable()
class JavaInstance {
  @JsonKey(name: 'configId')
  final String configId;
  final GameInfo? game;

  JavaInstance({
    required this.configId,
    this.game,
  });

  factory JavaInstance.fromJson(Map<String, dynamic> json) =>
      _$JavaInstanceFromJson(json);

  Map<String, dynamic> toJson() => _$JavaInstanceToJson(this);
}

@JsonSerializable()
class GameInfo {
  final String gamemode;
  final String type;

  GameInfo({
    required this.gamemode,
    required this.type,
  });

  factory GameInfo.fromJson(Map<String, dynamic> json) =>
      _$GameInfoFromJson(json);

  Map<String, dynamic> toJson() => _$GameInfoToJson(this);
}

@JsonSerializable()
class BedrockInstance {
  final String gamemode;
  final String type;
  final String versionId;
  final NetworkInfo? network;
  final LocalInfo? local;
  final RealmsInfo? realms;

  BedrockInstance({
    required this.gamemode,
    required this.type,
    required this.versionId,
    this.network,
    this.local,
    this.realms,
  });

  factory BedrockInstance.fromJson(Map<String, dynamic> json) =>
      _$BedrockInstanceFromJson(json);

  Map<String, dynamic> toJson() => _$BedrockInstanceToJson(this);
}

@JsonSerializable()
class NetworkInfo {
  final String address;
  final int port;

  NetworkInfo({
    required this.address,
    required this.port,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) =>
      _$NetworkInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkInfoToJson(this);
}

@JsonSerializable()
class LocalInfo {
  @JsonKey(name: 'levelId')
  final String levelId;
  final String name;

  LocalInfo({
    required this.levelId,
    required this.name,
  });

  factory LocalInfo.fromJson(Map<String, dynamic> json) =>
      _$LocalInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LocalInfoToJson(this);
}

@JsonSerializable()
class RealmsInfo {
  @JsonKey(name: 'realmId')
  final int realmId;

  RealmsInfo({
    required this.realmId,
  });

  factory RealmsInfo.fromJson(Map<String, dynamic> json) =>
      _$RealmsInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RealmsInfoToJson(this);
}

@JsonSerializable()
class ProductQuickPlay {
  @JsonKey(name: 'productId')
  final String productId;
  @JsonKey(name: 'versionId')
  final String versionId;

  ProductQuickPlay({
    required this.productId,
    required this.versionId,
  });

  factory ProductQuickPlay.fromJson(Map<String, dynamic> json) =>
      _$ProductQuickPlayFromJson(json);

  Map<String, dynamic> toJson() => _$ProductQuickPlayToJson(this);
}