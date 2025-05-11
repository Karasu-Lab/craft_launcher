import 'package:json_annotation/json_annotation.dart';

part 'launcher_profiles.g.dart';

@JsonSerializable()
class LauncherProfiles {
  final Map<String, Profile> profiles;
  final Settings settings;
  final int version;

  LauncherProfiles({
    required this.profiles,
    required this.settings,
    required this.version,
  });

  factory LauncherProfiles.fromJson(Map<String, dynamic> json) =>
      _$LauncherProfilesFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherProfilesToJson(this);
}

@JsonSerializable()
class Profile {
  final String created;
  final String? gameDir;
  final String icon;
  final String? javaDir;
  final String lastUsed;
  final String lastVersionId;
  final String name;
  final bool? skipJreVersionCheck;
  final String type;
  final String? javaArgs;

  Profile({
    required this.created,
    this.gameDir,
    required this.icon,
    this.javaDir,
    required this.lastUsed,
    required this.lastVersionId,
    required this.name,
    this.skipJreVersionCheck,
    required this.type,
    this.javaArgs,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class Settings {
  final bool crashAssistance;
  final bool enableAdvanced;
  final bool enableAnalytics;
  final bool enableHistorical;
  final bool enableReleases;
  final bool enableSnapshots;
  final bool keepLauncherOpen;
  final String profileSorting;
  final bool showGameLog;
  final bool showMenu;
  final bool soundOn;

  Settings({
    required this.crashAssistance,
    required this.enableAdvanced,
    required this.enableAnalytics,
    required this.enableHistorical,
    required this.enableReleases,
    required this.enableSnapshots,
    required this.keepLauncherOpen,
    required this.profileSorting,
    required this.showGameLog,
    required this.showMenu,
    required this.soundOn,
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}

