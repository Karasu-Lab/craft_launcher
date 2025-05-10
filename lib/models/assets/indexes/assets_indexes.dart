import 'package:json_annotation/json_annotation.dart';

part 'assets_indexes.g.dart';

@JsonSerializable()
class AssetsIndexes {
  final bool? mapToResources;
  final Map<String, AssetObject> objects;

  AssetsIndexes({
    this.mapToResources,
    required this.objects,
  });

  factory AssetsIndexes.fromJson(Map<String, dynamic> json) =>
      _$AssetsIndexesFromJson(json);

  Map<String, dynamic> toJson() => _$AssetsIndexesToJson(this);
}

@JsonSerializable()
class AssetObject {
  final int size;

  AssetObject({
    required this.size,
  });

  factory AssetObject.fromJson(Map<String, dynamic> json) =>
      _$AssetObjectFromJson(json);

  Map<String, dynamic> toJson() => _$AssetObjectToJson(this);
}