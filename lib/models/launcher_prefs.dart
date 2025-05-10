import 'package:json_annotation/json_annotation.dart';

part 'launcher_prefs.g.dart';

@JsonSerializable()
class LauncherPrefs {
  final int currentExperiencePointsPleaseDontHackThis;
  final int currentLauncherLevelPleaseDontHackThis;
  final List<String> enabledSkills;
  final int formatVersion;
  final int version;

  LauncherPrefs({
    required this.currentExperiencePointsPleaseDontHackThis,
    required this.currentLauncherLevelPleaseDontHackThis,
    required this.enabledSkills,
    required this.formatVersion,
    required this.version,
  });

  factory LauncherPrefs.fromJson(Map<String, dynamic> json) =>
      _$LauncherPrefsFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherPrefsToJson(this);
}