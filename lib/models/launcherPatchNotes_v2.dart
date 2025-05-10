import 'package:json_annotation/json_annotation.dart';

part 'launcherPatchNotes_v2.g.dart';

@JsonSerializable()
class LauncherPatchNotesV2 {
  final int version;
  final List<PatchNoteEntry> entries;

  LauncherPatchNotesV2({
    required this.version,
    required this.entries,
  });

  factory LauncherPatchNotesV2.fromJson(Map<String, dynamic> json) =>
      _$LauncherPatchNotesV2FromJson(json);

  Map<String, dynamic> toJson() => _$LauncherPatchNotesV2ToJson(this);
}

@JsonSerializable()
class PatchNoteEntry {
  final String id;
  final String? date;
  final String? body;
  @JsonKey(includeIfNull: false)
  final Map<String, dynamic>? versions;

  PatchNoteEntry({
    required this.id,
    this.date,
    this.body,
    this.versions,
  });

  factory PatchNoteEntry.fromJson(Map<String, dynamic> json) =>
      _$PatchNoteEntryFromJson(json);

  Map<String, dynamic> toJson() => _$PatchNoteEntryToJson(this);
}