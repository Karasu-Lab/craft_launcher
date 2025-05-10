import 'package:json_annotation/json_annotation.dart';

part 'launcher_ui_state.g.dart';

@JsonSerializable()
class LauncherUiState {
  @JsonKey(name: 'data')
  final LauncherUiStateData data;
  
  @JsonKey(name: 'formatVersion')
  final int formatVersion;

  LauncherUiState({
    required this.data,
    required this.formatVersion,
  });

  factory LauncherUiState.fromJson(Map<String, dynamic> json) =>
      _$LauncherUiStateFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherUiStateToJson(this);
}

@JsonSerializable()
class LauncherUiStateData {
  @JsonKey(name: 'UiEvents')
  final String uiEvents;
  
  @JsonKey(name: 'UiSettings')
  final String uiSettings;

  LauncherUiStateData({
    required this.uiEvents,
    required this.uiSettings,
  });

  factory LauncherUiStateData.fromJson(Map<String, dynamic> json) =>
      _$LauncherUiStateDataFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherUiStateDataToJson(this);
}