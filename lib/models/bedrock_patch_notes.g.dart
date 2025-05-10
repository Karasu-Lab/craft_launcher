// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bedrock_patch_notes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BedrockPatchNotes _$BedrockPatchNotesFromJson(
  Map<String, dynamic> json,
) => BedrockPatchNotes(
  version: (json['version'] as num).toInt(),
  entries:
      (json['entries'] as List<dynamic>)
          .map((e) => BedrockPatchNoteEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BedrockPatchNotesToJson(BedrockPatchNotes instance) =>
    <String, dynamic>{'version': instance.version, 'entries': instance.entries};

BedrockPatchNoteEntry _$BedrockPatchNoteEntryFromJson(
  Map<String, dynamic> json,
) => BedrockPatchNoteEntry(
  title: json['title'] as String?,
  version: json['version'] as String?,
  patchNoteType: json['patchNoteType'] as String?,
  date: json['date'] as String?,
  image:
      json['image'] == null
          ? null
          : BedrockPatchNoteImage.fromJson(
            json['image'] as Map<String, dynamic>,
          ),
  body: json['body'] as String?,
  id: json['id'] as String?,
  contentPath: json['contentPath'] as String,
);

Map<String, dynamic> _$BedrockPatchNoteEntryToJson(
  BedrockPatchNoteEntry instance,
) => <String, dynamic>{
  'title': instance.title,
  'version': instance.version,
  'patchNoteType': instance.patchNoteType,
  'date': instance.date,
  'image': instance.image,
  'body': instance.body,
  'id': instance.id,
  'contentPath': instance.contentPath,
};

BedrockPatchNoteImage _$BedrockPatchNoteImageFromJson(
  Map<String, dynamic> json,
) => BedrockPatchNoteImage(title: json['title'] as String?);

Map<String, dynamic> _$BedrockPatchNoteImageToJson(
  BedrockPatchNoteImage instance,
) => <String, dynamic>{'title': instance.title};
