import 'package:json_annotation/json_annotation.dart';

part 'launcher_entitlements.g.dart';

@JsonSerializable()
class LauncherEntitlements {
  @JsonKey(name: 'data')
  final Map<String, String> data;

  @JsonKey(name: 'formatVersion')
  final int formatVersion;

  const LauncherEntitlements({required this.data, required this.formatVersion});

  factory LauncherEntitlements.fromJson(Map<String, dynamic> json) =>
      _$LauncherEntitlementsFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherEntitlementsToJson(this);
}
