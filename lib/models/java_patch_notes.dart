import 'package:json_annotation/json_annotation.dart';

part 'java_patch_notes.g.dart';

@JsonSerializable()
class JavaPatchNotes {
  final int version;
  final List<JavaPatchNoteEntry> entries;

  JavaPatchNotes({
    required this.version,
    required this.entries,
  });

  factory JavaPatchNotes.fromJson(Map<String, dynamic> json) =>
      _$JavaPatchNotesFromJson(json);

  Map<String, dynamic> toJson() => _$JavaPatchNotesToJson(this);
}

@JsonSerializable()
class JavaPatchNoteEntry {
  final String? contentPath;

  JavaPatchNoteEntry({
    this.contentPath,
  });

  factory JavaPatchNoteEntry.fromJson(Map<String, dynamic> json) =>
      _$JavaPatchNoteEntryFromJson(json);

  Map<String, dynamic> toJson() => _$JavaPatchNoteEntryToJson(this);
}

@JsonSerializable()
class JavaPatchNoteContent {
  final String? title;
  final String? version;
  final String? body;
  final String? type;
  final String? id;
  final JavaPatchNoteImage? image;

  JavaPatchNoteContent({
    this.title,
    this.version,
    this.body,
    this.type,
    this.id,
    this.image,
  });

  factory JavaPatchNoteContent.fromJson(Map<String, dynamic> json) =>
      _$JavaPatchNoteContentFromJson(json);

  Map<String, dynamic> toJson() => _$JavaPatchNoteContentToJson(this);
}

@JsonSerializable()
class JavaPatchNoteImage {
  final String? url;
  final String? title;

  JavaPatchNoteImage({
    this.url,
    this.title,
  });

  factory JavaPatchNoteImage.fromJson(Map<String, dynamic> json) =>
      _$JavaPatchNoteImageFromJson(json);

  Map<String, dynamic> toJson() => _$JavaPatchNoteImageToJson(this);
}