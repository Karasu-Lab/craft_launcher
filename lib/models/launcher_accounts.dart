import 'package:json_annotation/json_annotation.dart';

part 'launcher_accounts.g.dart';

@JsonSerializable()
class LauncherAccounts {
  final Map<String, Account> accounts;
  final String activeAccountLocalId;
  final String mojangClientToken;

  LauncherAccounts({
    required this.accounts,
    required this.activeAccountLocalId,
    required this.mojangClientToken,
  });

  factory LauncherAccounts.fromJson(Map<String, dynamic> json) =>
      _$LauncherAccountsFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherAccountsToJson(this);
}

@JsonSerializable()
class Account {
  final String accessToken;
  final String accessTokenExpiresAt;
  final String avatar;
  final bool eligibleForMigration;
  final String franchiseInventoryId;
  final bool hasMultipleProfiles;
  final bool inForcedMigration;
  final bool legacy;
  final List<String> licenseProductIds;
  final String localId;
  final MinecraftProfile minecraftProfile;
  final bool persistent;
  final String remoteId;
  final String type;
  final List<dynamic> userProperites;
  final String username;

  Account({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.avatar,
    required this.eligibleForMigration,
    required this.franchiseInventoryId,
    required this.hasMultipleProfiles,
    required this.inForcedMigration,
    required this.legacy,
    required this.licenseProductIds,
    required this.localId,
    required this.minecraftProfile,
    required this.persistent,
    required this.remoteId,
    required this.type,
    required this.userProperites,
    required this.username,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable()
class MinecraftProfile {
  final String id;
  final String name;
  final bool requiresProfileNameChange;
  final bool requiresSkinChange;

  MinecraftProfile({
    required this.id,
    required this.name,
    required this.requiresProfileNameChange,
    required this.requiresSkinChange,
  });

  factory MinecraftProfile.fromJson(Map<String, dynamic> json) =>
      _$MinecraftProfileFromJson(json);

  Map<String, dynamic> toJson() => _$MinecraftProfileToJson(this);
}
