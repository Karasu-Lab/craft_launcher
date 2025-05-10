import 'package:json_annotation/json_annotation.dart';

part 'alertMessaging.g.dart';

@JsonSerializable()
class AlertMessaging {
  final int version;
  final List<dynamic> entries;

  const AlertMessaging({
    required this.version,
    required this.entries,
  });

  factory AlertMessaging.fromJson(Map<String, dynamic> json) => 
      _$AlertMessagingFromJson(json);
  
  Map<String, dynamic> toJson() => _$AlertMessagingToJson(this);
}
