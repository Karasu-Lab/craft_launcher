// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherSettings _$LauncherSettingsFromJson(
  Map<String, dynamic> json,
) => LauncherSettings(
  autoPlayVideoDisabled: json['autoPlayVideoDisabled'] as bool,
  channel: json['channel'] as String,
  customChannels:
      (json['customChannels'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  deviceId: (json['deviceId'] as num).toInt(),
  formatVersion: (json['formatVersion'] as num).toInt(),
  locale: json['locale'] as String,
  productLibraryDir: json['productLibraryDir'] as String,
  quickPlayEnabled: json['quickPlayEnabled'] as bool,
  shutDownTimestampGamecore: (json['shutDownTimestampGamecore'] as num).toInt(),
  shutDownTimestampUnified: (json['shutDownTimestampUnified'] as num).toInt(),
  useArm64JreIfSupported: json['useArm64JreIfSupported'] as bool,
  useMagnifiedMode: json['useMagnifiedMode'] as bool,
  version: (json['version'] as num).toInt(),
);

Map<String, dynamic> _$LauncherSettingsToJson(LauncherSettings instance) =>
    <String, dynamic>{
      'autoPlayVideoDisabled': instance.autoPlayVideoDisabled,
      'channel': instance.channel,
      'customChannels': instance.customChannels,
      'deviceId': instance.deviceId,
      'formatVersion': instance.formatVersion,
      'locale': instance.locale,
      'productLibraryDir': instance.productLibraryDir,
      'quickPlayEnabled': instance.quickPlayEnabled,
      'shutDownTimestampGamecore': instance.shutDownTimestampGamecore,
      'shutDownTimestampUnified': instance.shutDownTimestampUnified,
      'useArm64JreIfSupported': instance.useArm64JreIfSupported,
      'useMagnifiedMode': instance.useMagnifiedMode,
      'version': instance.version,
    };
