import 'package:json_annotation/json_annotation.dart';

part 'usercache.g.dart';

@JsonSerializable()
class UserCacheEntry {
  final String name;
  final String uuid;
  final String expiresOn;

  UserCacheEntry({
    required this.name,
    required this.uuid,
    required this.expiresOn,
  });

  factory UserCacheEntry.fromJson(Map<String, dynamic> json) =>
      _$UserCacheEntryFromJson(json);

  Map<String, dynamic> toJson() => _$UserCacheEntryToJson(this);
}

@JsonSerializable()
class UserCache {
  final List<UserCacheEntry> entries;

  UserCache({required this.entries});

  factory UserCache.fromJson(List<dynamic> json) {
    final entries = json
        .map((e) => UserCacheEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return UserCache(entries: entries);
  }

  List<dynamic> toJson() => entries.map((e) => e.toJson()).toList();
}