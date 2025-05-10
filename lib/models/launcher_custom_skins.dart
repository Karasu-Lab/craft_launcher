import 'package:json_annotation/json_annotation.dart';

part 'launcher_custom_skins.g.dart';

@JsonSerializable()
class LauncherCustomSkins {
  final Map<String, SkinVariant> variants;
  final String activeSkinId;

  LauncherCustomSkins({
    required this.variants,
    required this.activeSkinId,
  });

  factory LauncherCustomSkins.fromJson(Map<String, dynamic> json) =>
      _$LauncherCustomSkinsFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherCustomSkinsToJson(this);
}

@JsonSerializable()
class SkinVariant {
  final String id;
  final String name;
  final String path;
  final SkinModel model;
  final bool isSlim;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  SkinVariant({
    required this.id,
    required this.name,
    required this.path,
    required this.model,
    required this.isSlim,
    required this.createdAt,
    this.updatedAt,
  });

  factory SkinVariant.fromJson(Map<String, dynamic> json) =>
      _$SkinVariantFromJson(json);

  Map<String, dynamic> toJson() => _$SkinVariantToJson(this);
}

enum SkinModel {
  @JsonValue('steve')
  steve,
  @JsonValue('alex')
  alex,
  @JsonValue('custom')
  custom,
}