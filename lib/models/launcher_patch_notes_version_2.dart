import 'package:json_annotation/json_annotation.dart';

part 'launcher_patch_notes_version_2.g.dart';

@JsonSerializable()
class LauncherPatchNotesV2 {
  final int version;
  final List<LauncherPatchNotesV2PatchNoteEntry> entries;

  LauncherPatchNotesV2({required this.version, required this.entries});

  factory LauncherPatchNotesV2.fromJson(Map<String, dynamic> json) =>
      _$LauncherPatchNotesV2FromJson(json);

  Map<String, dynamic> toJson() => _$LauncherPatchNotesV2ToJson(this);
}

@JsonSerializable()
class LauncherPatchNotesV2PatchNoteEntry {
  final String id;
  final String? date;
  final String? body;
  @JsonKey(includeIfNull: false)
  final Map<String, dynamic>? versions;

  LauncherPatchNotesV2PatchNoteEntry({
    required this.id,
    this.date,
    this.body,
    this.versions,
  });

  factory LauncherPatchNotesV2PatchNoteEntry.fromJson(
    Map<String, dynamic> json,
  ) => _$LauncherPatchNotesV2PatchNoteEntryFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LauncherPatchNotesV2PatchNoteEntryToJson(this);
}
