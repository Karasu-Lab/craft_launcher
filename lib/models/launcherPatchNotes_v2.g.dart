// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcherPatchNotes_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherPatchNotesV2 _$LauncherPatchNotesV2FromJson(
  Map<String, dynamic> json,
) => LauncherPatchNotesV2(
  version: (json['version'] as num).toInt(),
  entries:
      (json['entries'] as List<dynamic>)
          .map((e) => PatchNoteEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$LauncherPatchNotesV2ToJson(
  LauncherPatchNotesV2 instance,
) => <String, dynamic>{
  'version': instance.version,
  'entries': instance.entries,
};

PatchNoteEntry _$PatchNoteEntryFromJson(Map<String, dynamic> json) =>
    PatchNoteEntry(
      id: json['id'] as String,
      date: json['date'] as String?,
      body: json['body'] as String?,
      versions: json['versions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PatchNoteEntryToJson(PatchNoteEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'body': instance.body,
      if (instance.versions case final value?) 'versions': value,
    };
