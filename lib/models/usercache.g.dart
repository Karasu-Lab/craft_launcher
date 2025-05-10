// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usercache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCacheEntry _$UserCacheEntryFromJson(Map<String, dynamic> json) =>
    UserCacheEntry(
      name: json['name'] as String,
      uuid: json['uuid'] as String,
      expiresOn: json['expiresOn'] as String,
    );

Map<String, dynamic> _$UserCacheEntryToJson(UserCacheEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'uuid': instance.uuid,
      'expiresOn': instance.expiresOn,
    };

UserCache _$UserCacheFromJson(Map<String, dynamic> json) => UserCache(
  entries:
      (json['entries'] as List<dynamic>)
          .map((e) => UserCacheEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UserCacheToJson(UserCache instance) => <String, dynamic>{
  'entries': instance.entries,
};
