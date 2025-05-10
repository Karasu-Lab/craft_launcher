import 'package:json_annotation/json_annotation.dart';

part 'launcher_gamer_pics_microsoft_store.g.dart';

@JsonSerializable()
class LauncherGamerPicsMicrosoftStore {
  @JsonKey(name: 'data')
  final Map<String, String> data;

  @JsonKey(name: 'formatVersion')
  final int formatVersion;

  const LauncherGamerPicsMicrosoftStore({required this.data, required this.formatVersion});

  factory LauncherGamerPicsMicrosoftStore.fromJson(Map<String, dynamic> json) =>
      _$LauncherGamerPicsMicrosoftStoreFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherGamerPicsMicrosoftStoreToJson(this);
}
