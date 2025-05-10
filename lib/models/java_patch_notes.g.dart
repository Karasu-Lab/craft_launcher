// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'java_patch_notes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JavaPatchNotes _$JavaPatchNotesFromJson(Map<String, dynamic> json) =>
    JavaPatchNotes(
      version: (json['version'] as num).toInt(),
      entries:
          (json['entries'] as List<dynamic>)
              .map(
                (e) => JavaPatchNoteEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$JavaPatchNotesToJson(JavaPatchNotes instance) =>
    <String, dynamic>{'version': instance.version, 'entries': instance.entries};

JavaPatchNoteEntry _$JavaPatchNoteEntryFromJson(Map<String, dynamic> json) =>
    JavaPatchNoteEntry(contentPath: json['contentPath'] as String?);

Map<String, dynamic> _$JavaPatchNoteEntryToJson(JavaPatchNoteEntry instance) =>
    <String, dynamic>{'contentPath': instance.contentPath};

JavaPatchNoteContent _$JavaPatchNoteContentFromJson(
  Map<String, dynamic> json,
) => JavaPatchNoteContent(
  title: json['title'] as String?,
  version: json['version'] as String?,
  body: json['body'] as String?,
  type: json['type'] as String?,
  id: json['id'] as String?,
  image:
      json['image'] == null
          ? null
          : JavaPatchNoteImage.fromJson(json['image'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JavaPatchNoteContentToJson(
  JavaPatchNoteContent instance,
) => <String, dynamic>{
  'title': instance.title,
  'version': instance.version,
  'body': instance.body,
  'type': instance.type,
  'id': instance.id,
  'image': instance.image,
};

JavaPatchNoteImage _$JavaPatchNoteImageFromJson(Map<String, dynamic> json) =>
    JavaPatchNoteImage(
      url: json['url'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$JavaPatchNoteImageToJson(JavaPatchNoteImage instance) =>
    <String, dynamic>{'url': instance.url, 'title': instance.title};
