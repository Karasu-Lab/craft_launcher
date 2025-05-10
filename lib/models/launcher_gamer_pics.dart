import 'package:json_annotation/json_annotation.dart';

part 'launcher_gamer_pics.g.dart';

@JsonSerializable()
class LauncherGamerPics {
  final Map<String, String> data;
  final int formatVersion;

  LauncherGamerPics({
    required this.data,
    required this.formatVersion,
  });

  factory LauncherGamerPics.fromJson(Map<String, dynamic> json) =>
      _$LauncherGamerPicsFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherGamerPicsToJson(this);
}
