// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_quick_play.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherQuickPlay _$LauncherQuickPlayFromJson(Map<String, dynamic> json) =>
    LauncherQuickPlay(
      quickPlayData: (json['quickPlayData'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => QuickPlayEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$LauncherQuickPlayToJson(LauncherQuickPlay instance) =>
    <String, dynamic>{
      'quickPlayData': instance.quickPlayData,
      'version': instance.version,
    };

QuickPlayEntry _$QuickPlayEntryFromJson(Map<String, dynamic> json) =>
    QuickPlayEntry(
      epochLastPlayedTimeMs: (json['epochLastPlayedTimeMs'] as num).toInt(),
      id: json['id'] as String,
      name: json['name'] as String?,
      source: json['source'] as String,
      javaInstance:
          json['javaInstance'] == null
              ? null
              : JavaInstance.fromJson(
                json['javaInstance'] as Map<String, dynamic>,
              ),
      bedrockInstance:
          json['bedrockInstance'] == null
              ? null
              : BedrockInstance.fromJson(
                json['bedrockInstance'] as Map<String, dynamic>,
              ),
      productQuickPlay:
          json['productQuickPlay'] == null
              ? null
              : ProductQuickPlay.fromJson(
                json['productQuickPlay'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$QuickPlayEntryToJson(QuickPlayEntry instance) =>
    <String, dynamic>{
      'epochLastPlayedTimeMs': instance.epochLastPlayedTimeMs,
      'id': instance.id,
      'name': instance.name,
      'source': instance.source,
      'javaInstance': instance.javaInstance,
      'bedrockInstance': instance.bedrockInstance,
      'productQuickPlay': instance.productQuickPlay,
    };

JavaInstance _$JavaInstanceFromJson(Map<String, dynamic> json) => JavaInstance(
  configId: json['configId'] as String,
  game:
      json['game'] == null
          ? null
          : GameInfo.fromJson(json['game'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JavaInstanceToJson(JavaInstance instance) =>
    <String, dynamic>{'configId': instance.configId, 'game': instance.game};

GameInfo _$GameInfoFromJson(Map<String, dynamic> json) => GameInfo(
  gamemode: json['gamemode'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$GameInfoToJson(GameInfo instance) => <String, dynamic>{
  'gamemode': instance.gamemode,
  'type': instance.type,
};

BedrockInstance _$BedrockInstanceFromJson(Map<String, dynamic> json) =>
    BedrockInstance(
      gamemode: json['gamemode'] as String,
      type: json['type'] as String,
      versionId: json['versionId'] as String,
      network:
          json['network'] == null
              ? null
              : NetworkInfo.fromJson(json['network'] as Map<String, dynamic>),
      local:
          json['local'] == null
              ? null
              : LocalInfo.fromJson(json['local'] as Map<String, dynamic>),
      realms:
          json['realms'] == null
              ? null
              : RealmsInfo.fromJson(json['realms'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BedrockInstanceToJson(BedrockInstance instance) =>
    <String, dynamic>{
      'gamemode': instance.gamemode,
      'type': instance.type,
      'versionId': instance.versionId,
      'network': instance.network,
      'local': instance.local,
      'realms': instance.realms,
    };

NetworkInfo _$NetworkInfoFromJson(Map<String, dynamic> json) => NetworkInfo(
  address: json['address'] as String,
  port: (json['port'] as num).toInt(),
);

Map<String, dynamic> _$NetworkInfoToJson(NetworkInfo instance) =>
    <String, dynamic>{'address': instance.address, 'port': instance.port};

LocalInfo _$LocalInfoFromJson(Map<String, dynamic> json) =>
    LocalInfo(levelId: json['levelId'] as String, name: json['name'] as String);

Map<String, dynamic> _$LocalInfoToJson(LocalInfo instance) => <String, dynamic>{
  'levelId': instance.levelId,
  'name': instance.name,
};

RealmsInfo _$RealmsInfoFromJson(Map<String, dynamic> json) =>
    RealmsInfo(realmId: (json['realmId'] as num).toInt());

Map<String, dynamic> _$RealmsInfoToJson(RealmsInfo instance) =>
    <String, dynamic>{'realmId': instance.realmId};

ProductQuickPlay _$ProductQuickPlayFromJson(Map<String, dynamic> json) =>
    ProductQuickPlay(
      productId: json['productId'] as String,
      versionId: json['versionId'] as String,
    );

Map<String, dynamic> _$ProductQuickPlayToJson(ProductQuickPlay instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'versionId': instance.versionId,
    };
