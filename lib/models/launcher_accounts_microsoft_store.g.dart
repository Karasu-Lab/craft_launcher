// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_accounts_microsoft_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherAccountsMicrosoftStore _$LauncherAccountsMicrosoftStoreFromJson(
  Map<String, dynamic> json,
) => LauncherAccountsMicrosoftStore(
  accounts: (json['accounts'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, AccountMicrosoftStore.fromJson(e as Map<String, dynamic>)),
  ),
  activeAccountLocalId: json['activeAccountLocalId'] as String,
  mojangClientToken: json['mojangClientToken'] as String,
);

Map<String, dynamic> _$LauncherAccountsMicrosoftStoreToJson(
  LauncherAccountsMicrosoftStore instance,
) => <String, dynamic>{
  'accounts': instance.accounts,
  'activeAccountLocalId': instance.activeAccountLocalId,
  'mojangClientToken': instance.mojangClientToken,
};

AccountMicrosoftStore _$AccountMicrosoftStoreFromJson(
  Map<String, dynamic> json,
) => AccountMicrosoftStore(
  accessToken: json['accessToken'] as String,
  accessTokenExpiresAt: json['accessTokenExpiresAt'] as String,
  avatar: json['avatar'] as String,
  azureToken: json['azureToken'] as String,
  eligibleForMigration: json['eligibleForMigration'] as bool,
  franchiseInventoryId: json['franchiseInventoryId'] as String,
  hasMultipleProfiles: json['hasMultipleProfiles'] as bool,
  inForcedMigration: json['inForcedMigration'] as bool,
  legacy: json['legacy'] as bool,
  licenseProductIds:
      (json['licenseProductIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  licenseRequestId: json['licenseRequestId'] as String,
  localId: json['localId'] as String,
  minecraftProfile: MinecraftProfileMicrosoftStore.fromJson(
    json['minecraftProfile'] as Map<String, dynamic>,
  ),
  persistent: json['persistent'] as bool,
  remoteId: json['remoteId'] as String,
  type: json['type'] as String,
  userProperites: json['userProperites'] as List<dynamic>,
  username: json['username'] as String,
);

Map<String, dynamic> _$AccountMicrosoftStoreToJson(
  AccountMicrosoftStore instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'accessTokenExpiresAt': instance.accessTokenExpiresAt,
  'avatar': instance.avatar,
  'azureToken': instance.azureToken,
  'eligibleForMigration': instance.eligibleForMigration,
  'franchiseInventoryId': instance.franchiseInventoryId,
  'hasMultipleProfiles': instance.hasMultipleProfiles,
  'inForcedMigration': instance.inForcedMigration,
  'legacy': instance.legacy,
  'licenseProductIds': instance.licenseProductIds,
  'licenseRequestId': instance.licenseRequestId,
  'localId': instance.localId,
  'minecraftProfile': instance.minecraftProfile,
  'persistent': instance.persistent,
  'remoteId': instance.remoteId,
  'type': instance.type,
  'userProperites': instance.userProperites,
  'username': instance.username,
};

MinecraftProfileMicrosoftStore _$MinecraftProfileMicrosoftStoreFromJson(
  Map<String, dynamic> json,
) => MinecraftProfileMicrosoftStore(
  id: json['id'] as String,
  name: json['name'] as String,
  requiresProfileNameChange: json['requiresProfileNameChange'] as bool,
  requiresSkinChange: json['requiresSkinChange'] as bool,
);

Map<String, dynamic> _$MinecraftProfileMicrosoftStoreToJson(
  MinecraftProfileMicrosoftStore instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'requiresProfileNameChange': instance.requiresProfileNameChange,
  'requiresSkinChange': instance.requiresSkinChange,
};
