// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_accounts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherAccounts _$LauncherAccountsFromJson(Map<String, dynamic> json) =>
    LauncherAccounts(
      accounts: (json['accounts'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Account.fromJson(e as Map<String, dynamic>)),
      ),
      activeAccountLocalId: json['activeAccountLocalId'] as String,
      mojangClientToken: json['mojangClientToken'] as String,
    );

Map<String, dynamic> _$LauncherAccountsToJson(LauncherAccounts instance) =>
    <String, dynamic>{
      'accounts': instance.accounts,
      'activeAccountLocalId': instance.activeAccountLocalId,
      'mojangClientToken': instance.mojangClientToken,
    };

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  accessToken: json['accessToken'] as String,
  accessTokenExpiresAt: json['accessTokenExpiresAt'] as String,
  avatar: json['avatar'] as String,
  eligibleForMigration: json['eligibleForMigration'] as bool,
  franchiseInventoryId: json['franchiseInventoryId'] as String,
  hasMultipleProfiles: json['hasMultipleProfiles'] as bool,
  inForcedMigration: json['inForcedMigration'] as bool,
  legacy: json['legacy'] as bool,
  licenseProductIds:
      (json['licenseProductIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  localId: json['localId'] as String,
  minecraftProfile: MinecraftProfile.fromJson(
    json['minecraftProfile'] as Map<String, dynamic>,
  ),
  persistent: json['persistent'] as bool,
  remoteId: json['remoteId'] as String,
  type: json['type'] as String,
  userProperites: json['userProperites'] as List<dynamic>,
  username: json['username'] as String,
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'accessTokenExpiresAt': instance.accessTokenExpiresAt,
  'avatar': instance.avatar,
  'eligibleForMigration': instance.eligibleForMigration,
  'franchiseInventoryId': instance.franchiseInventoryId,
  'hasMultipleProfiles': instance.hasMultipleProfiles,
  'inForcedMigration': instance.inForcedMigration,
  'legacy': instance.legacy,
  'licenseProductIds': instance.licenseProductIds,
  'localId': instance.localId,
  'minecraftProfile': instance.minecraftProfile,
  'persistent': instance.persistent,
  'remoteId': instance.remoteId,
  'type': instance.type,
  'userProperites': instance.userProperites,
  'username': instance.username,
};

MinecraftProfile _$MinecraftProfileFromJson(Map<String, dynamic> json) =>
    MinecraftProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      requiresProfileNameChange: json['requiresProfileNameChange'] as bool,
      requiresSkinChange: json['requiresSkinChange'] as bool,
    );

Map<String, dynamic> _$MinecraftProfileToJson(MinecraftProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'requiresProfileNameChange': instance.requiresProfileNameChange,
      'requiresSkinChange': instance.requiresSkinChange,
    };
