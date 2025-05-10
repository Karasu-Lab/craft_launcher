// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_prefs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherPrefs _$LauncherPrefsFromJson(Map<String, dynamic> json) =>
    LauncherPrefs(
      currentExperiencePointsPleaseDontHackThis:
          (json['currentExperiencePointsPleaseDontHackThis'] as num).toInt(),
      currentLauncherLevelPleaseDontHackThis:
          (json['currentLauncherLevelPleaseDontHackThis'] as num).toInt(),
      enabledSkills:
          (json['enabledSkills'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      formatVersion: (json['formatVersion'] as num).toInt(),
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$LauncherPrefsToJson(LauncherPrefs instance) =>
    <String, dynamic>{
      'currentExperiencePointsPleaseDontHackThis':
          instance.currentExperiencePointsPleaseDontHackThis,
      'currentLauncherLevelPleaseDontHackThis':
          instance.currentLauncherLevelPleaseDontHackThis,
      'enabledSkills': instance.enabledSkills,
      'formatVersion': instance.formatVersion,
      'version': instance.version,
    };
