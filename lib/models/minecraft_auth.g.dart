// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minecraft_auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinecraftAuth _$MinecraftAuthFromJson(Map<String, dynamic> json) =>
    MinecraftAuth(
      clientId: json['clientId'] as String,
      authXuid: json['authXuid'] as String,
      userName: json['userName'] as String,
      uuid: json['uuid'] as String,
      accessToken: json['accessToken'] as String,
      userType: json['userType'] as String,
    );

Map<String, dynamic> _$MinecraftAuthToJson(MinecraftAuth instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'authXuid': instance.authXuid,
      'userName': instance.userName,
      'uuid': instance.uuid,
      'accessToken': instance.accessToken,
      'userType': instance.userType,
    };
