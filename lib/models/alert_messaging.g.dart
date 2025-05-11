// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_messaging.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertMessaging _$AlertMessagingFromJson(Map<String, dynamic> json) =>
    AlertMessaging(
      version: (json['version'] as num).toInt(),
      entries: json['entries'] as List<dynamic>,
    );

Map<String, dynamic> _$AlertMessagingToJson(AlertMessaging instance) =>
    <String, dynamic>{'version': instance.version, 'entries': instance.entries};
