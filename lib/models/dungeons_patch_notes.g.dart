// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dungeons_patch_notes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DungeonsPatchNotes _$DungeonsPatchNotesFromJson(Map<String, dynamic> json) =>
    DungeonsPatchNotes(
      version: (json['version'] as num).toInt(),
      entries:
          (json['entries'] as List<dynamic>)
              .map((e) => PatchNoteEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$DungeonsPatchNotesToJson(DungeonsPatchNotes instance) =>
    <String, dynamic>{'version': instance.version, 'entries': instance.entries};

PatchNoteEntry _$PatchNoteEntryFromJson(Map<String, dynamic> json) =>
    PatchNoteEntry(
      title: json['title'] as String?,
      version: json['version'] as String?,
      date: json['date'] as String?,
      image:
          json['image'] == null
              ? null
              : ImageInfo.fromJson(json['image'] as Map<String, dynamic>),
      body: json['body'] as String?,
      id: json['id'] as String?,
      contentPath: json['contentPath'] as String,
    );

Map<String, dynamic> _$PatchNoteEntryToJson(PatchNoteEntry instance) =>
    <String, dynamic>{
      'title': instance.title,
      'version': instance.version,
      'date': instance.date,
      'image': instance.image,
      'body': instance.body,
      'id': instance.id,
      'contentPath': instance.contentPath,
    };

ImageInfo _$ImageInfoFromJson(Map<String, dynamic> json) =>
    ImageInfo(title: json['title'] as String);

Map<String, dynamic> _$ImageInfoToJson(ImageInfo instance) => <String, dynamic>{
  'title': instance.title,
};
