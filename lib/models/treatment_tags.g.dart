// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment_tags.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TreatmentTags _$TreatmentTagsFromJson(Map<String, dynamic> json) =>
    TreatmentTags(
      entityTag: json['entityTag'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$TreatmentTagsToJson(TreatmentTags instance) =>
    <String, dynamic>{
      'entityTag': instance.entityTag,
      'tags': instance.tags,
      'version': instance.version,
    };
