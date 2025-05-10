import 'package:json_annotation/json_annotation.dart';

part 'treatment_tags.g.dart';

@JsonSerializable()
class TreatmentTags {
  @JsonKey(name: 'entityTag')
  final String entityTag;
  
  @JsonKey(name: 'tags')
  final List<String> tags;
  
  @JsonKey(name: 'version')
  final int version;

  TreatmentTags({
    required this.entityTag,
    required this.tags,
    required this.version,
  });

  factory TreatmentTags.fromJson(Map<String, dynamic> json) => 
      _$TreatmentTagsFromJson(json);
  
  Map<String, dynamic> toJson() => _$TreatmentTagsToJson(this);
}