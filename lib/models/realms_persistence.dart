import 'package:json_annotation/json_annotation.dart';

part 'realms_persistence.g.dart';

@JsonSerializable()
class RealmsPersistence {
  final String newsLink;
  final bool hasUnreadNews;

  RealmsPersistence({
    required this.newsLink,
    required this.hasUnreadNews,
  });

  factory RealmsPersistence.fromJson(Map<String, dynamic> json) =>
      _$RealmsPersistenceFromJson(json);

  Map<String, dynamic> toJson() => _$RealmsPersistenceToJson(this);
}