import 'package:json_annotation/json_annotation.dart';

part 'faq.g.dart';

@JsonSerializable()
class FAQ {
  final int version;
  final List<FAQData> data;

  FAQ({
    required this.version,
    required this.data,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) => _$FAQFromJson(json);
  Map<String, dynamic> toJson() => _$FAQToJson(this);
}

@JsonSerializable()
class FAQData {
  final String context;
  final String description;
  final List<QA> qas;

  FAQData({
    required this.context,
    required this.description,
    required this.qas,
  });

  factory FAQData.fromJson(Map<String, dynamic> json) => _$FAQDataFromJson(json);
  Map<String, dynamic> toJson() => _$FAQDataToJson(this);
}

@JsonSerializable()
class QA {
  final String answer;

  QA({
    required this.answer,
  });

  factory QA.fromJson(Map<String, dynamic> json) => _$QAFromJson(json);
  Map<String, dynamic> toJson() => _$QAToJson(this);
}