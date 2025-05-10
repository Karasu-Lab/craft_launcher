// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realms_persistence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealmsPersistence _$RealmsPersistenceFromJson(Map<String, dynamic> json) =>
    RealmsPersistence(
      newsLink: json['newsLink'] as String,
      hasUnreadNews: json['hasUnreadNews'] as bool,
    );

Map<String, dynamic> _$RealmsPersistenceToJson(RealmsPersistence instance) =>
    <String, dynamic>{
      'newsLink': instance.newsLink,
      'hasUnreadNews': instance.hasUnreadNews,
    };
