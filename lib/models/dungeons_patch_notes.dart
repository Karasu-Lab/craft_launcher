import 'package:json_annotation/json_annotation.dart';

part 'dungeons_patch_notes.g.dart';

@JsonSerializable()
class DungeonsPatchNotes {
  final int version;
  final List<PatchNoteEntry> entries;

  DungeonsPatchNotes({
    required this.version,
    required this.entries,
  });

  factory DungeonsPatchNotes.fromJson(Map<String, dynamic> json) =>
      _$DungeonsPatchNotesFromJson(json);

  Map<String, dynamic> toJson() => _$DungeonsPatchNotesToJson(this);
}

@JsonSerializable()
class PatchNoteEntry {
  final String? title;
  final String? version;
  final String? date;
  final ImageInfo? image;
  final String? body;
  final String? id;
  final String contentPath;

  PatchNoteEntry({
    this.title,
    this.version,
    this.date,
    this.image,
    this.body,
    this.id,
    required this.contentPath,
  });

  factory PatchNoteEntry.fromJson(Map<String, dynamic> json) =>
      _$PatchNoteEntryFromJson(json);

  Map<String, dynamic> toJson() => _$PatchNoteEntryToJson(this);
}

@JsonSerializable()
class ImageInfo {
  final String title;

  ImageInfo({
    required this.title,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) =>
      _$ImageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ImageInfoToJson(this);
}