import 'package:json_annotation/json_annotation.dart';

part 'launcher_accounts_microsoft_store.g.dart';

@JsonSerializable()
class LauncherAccountsMicrosoftStore {
  final Map<String, AccountMicrosoftStore> accounts;
  final String activeAccountLocalId;
  final String mojangClientToken;

  LauncherAccountsMicrosoftStore({
    required this.accounts,
    required this.activeAccountLocalId,
    required this.mojangClientToken,
  });

  factory LauncherAccountsMicrosoftStore.fromJson(Map<String, dynamic> json) =>
      _$LauncherAccountsMicrosoftStoreFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherAccountsMicrosoftStoreToJson(this);
}

@JsonSerializable()
class AccountMicrosoftStore {
  final String accessToken;
  final String accessTokenExpiresAt;
  final String avatar;
  final String azureToken;
  final bool eligibleForMigration;
  final String franchiseInventoryId;
  final bool hasMultipleProfiles;
  final bool inForcedMigration;
  final bool legacy;
  final List<String> licenseProductIds;
  final String licenseRequestId;
  final String localId;
  final MinecraftProfileMicrosoftStore minecraftProfile;
  final bool persistent;
  final String remoteId;
  final String type;
  final List<dynamic> userProperites;
  final String username;

  AccountMicrosoftStore({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.avatar,
    required this.azureToken,
    required this.eligibleForMigration,
    required this.franchiseInventoryId,
    required this.hasMultipleProfiles,
    required this.inForcedMigration,
    required this.legacy,
    required this.licenseProductIds,
    required this.licenseRequestId,
    required this.localId,
    required this.minecraftProfile,
    required this.persistent,
    required this.remoteId,
    required this.type,
    required this.userProperites,
    required this.username,
  });

  factory AccountMicrosoftStore.fromJson(Map<String, dynamic> json) =>
      _$AccountMicrosoftStoreFromJson(json);

  Map<String, dynamic> toJson() => _$AccountMicrosoftStoreToJson(this);
}

@JsonSerializable()
class MinecraftProfileMicrosoftStore {
  final String id;
  final String name;
  final bool requiresProfileNameChange;
  final bool requiresSkinChange;

  MinecraftProfileMicrosoftStore({
    required this.id,
    required this.name,
    required this.requiresProfileNameChange,
    required this.requiresSkinChange,
  });

  factory MinecraftProfileMicrosoftStore.fromJson(Map<String, dynamic> json) =>
      _$MinecraftProfileMicrosoftStoreFromJson(json);

  Map<String, dynamic> toJson() => _$MinecraftProfileMicrosoftStoreToJson(this);
}
