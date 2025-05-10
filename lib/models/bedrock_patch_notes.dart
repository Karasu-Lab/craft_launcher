import 'package:json_annotation/json_annotation.dart';

part 'bedrock_patch_notes.g.dart';

@JsonSerializable()
class BedrockPatchNotes {
  final int version;
  final List<BedrockPatchNoteEntry> entries;

  BedrockPatchNotes({
    required this.version,
    required this.entries,
  });

  factory BedrockPatchNotes.fromJson(Map<String, dynamic> json) =>
      _$BedrockPatchNotesFromJson(json);

  Map<String, dynamic> toJson() => _$BedrockPatchNotesToJson(this);
}

@JsonSerializable()
class BedrockPatchNoteEntry {
  final String? title;
  final String? version;
  final String? patchNoteType;
  final String? date;
  final BedrockPatchNoteImage? image;
  final String? body;
  final String? id;
  final String contentPath;

  BedrockPatchNoteEntry({
    this.title,
    this.version,
    this.patchNoteType,
    this.date,
    this.image,
    this.body,
    this.id,
    required this.contentPath,
  });

  factory BedrockPatchNoteEntry.fromJson(Map<String, dynamic> json) =>
      _$BedrockPatchNoteEntryFromJson(json);

  Map<String, dynamic> toJson() => _$BedrockPatchNoteEntryToJson(this);
}

@JsonSerializable()
class BedrockPatchNoteImage {
  final String? title;

  BedrockPatchNoteImage({
    this.title,
  });

  factory BedrockPatchNoteImage.fromJson(Map<String, dynamic> json) =>
      _$BedrockPatchNoteImageFromJson(json);

  Map<String, dynamic> toJson() => _$BedrockPatchNoteImageToJson(this);
}