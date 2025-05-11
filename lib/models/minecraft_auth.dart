import 'package:json_annotation/json_annotation.dart';

part 'minecraft_auth.g.dart';

@JsonSerializable()
class MinecraftAuth {
  final String clientId;
  final String authXuid;
  final String userName;
  final String uuid;
  final String accessToken;
  final String userType;

  MinecraftAuth({
    required this.clientId,
    required this.authXuid,
    required this.userName,
    required this.uuid,
    required this.accessToken,
    required this.userType,
  });

  factory MinecraftAuth.fromJson(Map<String, dynamic> json) =>
      _$MinecraftAuthFromJson(json);

  Map<String, dynamic> toJson() => _$MinecraftAuthToJson(this);
}
