// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_ui_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherUiState _$LauncherUiStateFromJson(Map<String, dynamic> json) =>
    LauncherUiState(
      data: LauncherUiStateData.fromJson(json['data'] as Map<String, dynamic>),
      formatVersion: (json['formatVersion'] as num).toInt(),
    );

Map<String, dynamic> _$LauncherUiStateToJson(LauncherUiState instance) =>
    <String, dynamic>{
      'data': instance.data,
      'formatVersion': instance.formatVersion,
    };

LauncherUiStateData _$LauncherUiStateDataFromJson(Map<String, dynamic> json) =>
    LauncherUiStateData(
      uiEvents: json['UiEvents'] as String,
      uiSettings: json['UiSettings'] as String,
    );

Map<String, dynamic> _$LauncherUiStateDataToJson(
  LauncherUiStateData instance,
) => <String, dynamic>{
  'UiEvents': instance.uiEvents,
  'UiSettings': instance.uiSettings,
};
