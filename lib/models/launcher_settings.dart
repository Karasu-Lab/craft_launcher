import 'package:json_annotation/json_annotation.dart';

part 'launcher_settings.g.dart';

@JsonSerializable()
class LauncherSettings {
  @JsonKey(name: 'autoPlayVideoDisabled')
  final bool autoPlayVideoDisabled;

  @JsonKey(name: 'channel')
  final String channel;

  @JsonKey(name: 'customChannels')
  final List<String> customChannels;

  @JsonKey(name: 'deviceId')
  final int deviceId;

  @JsonKey(name: 'formatVersion')
  final int formatVersion;

  @JsonKey(name: 'locale')
  final String locale;

  @JsonKey(name: 'productLibraryDir')
  final String productLibraryDir;

  @JsonKey(name: 'quickPlayEnabled')
  final bool quickPlayEnabled;

  @JsonKey(name: 'shutDownTimestampGamecore')
  final int shutDownTimestampGamecore;

  @JsonKey(name: 'shutDownTimestampUnified')
  final int shutDownTimestampUnified;

  @JsonKey(name: 'useArm64JreIfSupported')
  final bool useArm64JreIfSupported;

  @JsonKey(name: 'useMagnifiedMode')
  final bool useMagnifiedMode;

  @JsonKey(name: 'version')
  final int version;

  LauncherSettings({
    required this.autoPlayVideoDisabled,
    required this.channel,
    required this.customChannels,
    required this.deviceId,
    required this.formatVersion,
    required this.locale,
    required this.productLibraryDir,
    required this.quickPlayEnabled,
    required this.shutDownTimestampGamecore,
    required this.shutDownTimestampUnified,
    required this.useArm64JreIfSupported,
    required this.useMagnifiedMode,
    required this.version,
  });

  factory LauncherSettings.fromJson(Map<String, dynamic> json) => 
      _$LauncherSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherSettingsToJson(this);
}