// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jvm_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JvmRule _$JvmRuleFromJson(Map<String, dynamic> json) => JvmRule(
  rules:
      (json['rules'] as List<dynamic>)
          .map((e) => JvmRuleCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
  value: json['value'],
);

Map<String, dynamic> _$JvmRuleToJson(JvmRule instance) => <String, dynamic>{
  'rules': instance.rules,
  'value': instance.value,
};

JvmRuleCondition _$JvmRuleConditionFromJson(Map<String, dynamic> json) =>
    JvmRuleCondition(
      action: json['action'] as String,
      os:
          json['os'] == null
              ? null
              : JvmRuleOs.fromJson(json['os'] as Map<String, dynamic>),
      features: json['features'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$JvmRuleConditionToJson(JvmRuleCondition instance) =>
    <String, dynamic>{
      'action': instance.action,
      'os': instance.os,
      'features': instance.features,
    };

JvmRuleOs _$JvmRuleOsFromJson(Map<String, dynamic> json) => JvmRuleOs(
  name: json['name'] as String?,
  arch: json['arch'] as String?,
  version: json['version'] as String?,
);

Map<String, dynamic> _$JvmRuleOsToJson(JvmRuleOs instance) => <String, dynamic>{
  'name': instance.name,
  'arch': instance.arch,
  'version': instance.version,
};
