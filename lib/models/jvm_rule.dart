import 'package:json_annotation/json_annotation.dart';

part 'jvm_rule.g.dart';

@JsonSerializable()
class JvmRule {
  final List<JvmRuleCondition> rules;
  final dynamic value;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String>? values;

  JvmRule({required this.rules, required this.value, this.values});

  factory JvmRule.fromJson(Map<String, dynamic> json) {
    final rule = JvmRule(
      rules:
          (json['rules'] as List)
              .map(
                (rule) =>
                    JvmRuleCondition.fromJson(rule as Map<String, dynamic>),
              )
              .toList(),
      value: json['value'],
    );
    
    if (rule.value is List) {
      rule.values = (rule.value as List).map((v) => v.toString()).toList();
    }
    
    return rule;
  }

  Map<String, dynamic> toJson() => {
    'rules': rules.map((rule) => rule.toJson()).toList(),
    'value': value,
  };
}

@JsonSerializable()
class JvmRuleCondition {
  final String action;
  final JvmRuleOs? os;
  final Map<String, dynamic>? features;

  JvmRuleCondition({required this.action, this.os, this.features});

  factory JvmRuleCondition.fromJson(Map<String, dynamic> json) {
    return JvmRuleCondition(
      action: json['action'] as String,
      os:
          json['os'] != null
              ? JvmRuleOs.fromJson(json['os'] as Map<String, dynamic>)
              : null,
      features: json['features'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {'action': action};
    if (os != null) {
      result['os'] = os!.toJson();
    }
    if (features != null) {
      result['features'] = features;
    }
    return result;
  }
}

@JsonSerializable()
class JvmRuleOs {
  final String? name;
  final String? arch;
  final String? version;

  JvmRuleOs({this.name, this.arch, this.version});

  factory JvmRuleOs.fromJson(Map<String, dynamic> json) {
    return JvmRuleOs(
      name: json['name'] as String?,
      arch: json['arch'] as String?,
      version: json['version'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    if (name != null) result['name'] = name;
    if (arch != null) result['arch'] = arch;
    if (version != null) result['version'] = version;
    return result;
  }
}
