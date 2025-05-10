// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FAQ _$FAQFromJson(Map<String, dynamic> json) => FAQ(
  version: (json['version'] as num).toInt(),
  data:
      (json['data'] as List<dynamic>)
          .map((e) => FAQData.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$FAQToJson(FAQ instance) => <String, dynamic>{
  'version': instance.version,
  'data': instance.data,
};

FAQData _$FAQDataFromJson(Map<String, dynamic> json) => FAQData(
  context: json['context'] as String,
  description: json['description'] as String,
  qas:
      (json['qas'] as List<dynamic>)
          .map((e) => QA.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$FAQDataToJson(FAQData instance) => <String, dynamic>{
  'context': instance.context,
  'description': instance.description,
  'qas': instance.qas,
};

QA _$QAFromJson(Map<String, dynamic> json) =>
    QA(answer: json['answer'] as String);

Map<String, dynamic> _$QAToJson(QA instance) => <String, dynamic>{
  'answer': instance.answer,
};
