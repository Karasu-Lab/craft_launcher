// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
  version: (json['version'] as num).toInt(),
  entries:
      (json['entries'] as List<dynamic>)
          .map((e) => LauncherNews.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
  'version': instance.version,
  'entries': instance.entries,
};

LauncherNews _$LauncherNewsFromJson(Map<String, dynamic> json) => LauncherNews(
  title: json['title'] as String?,
  tag: json['tag'] as String?,
  category: json['category'] as String?,
  date: json['date'] as String?,
  text: json['text'] as String?,
  playPageImage:
      json['playPageImage'] == null
          ? null
          : PlayPageImage.fromJson(
            json['playPageImage'] as Map<String, dynamic>,
          ),
  newsPageImage:
      json['newsPageImage'] == null
          ? null
          : NewsPageImage.fromJson(
            json['newsPageImage'] as Map<String, dynamic>,
          ),
  readMoreLink: json['readMoreLink'] as String?,
  cardBorder: json['cardBorder'] as bool?,
  newsType:
      (json['newsType'] as List<dynamic>?)?.map((e) => e as String).toList(),
  id: json['id'] as String,
);

Map<String, dynamic> _$LauncherNewsToJson(LauncherNews instance) =>
    <String, dynamic>{
      'title': instance.title,
      'tag': instance.tag,
      'category': instance.category,
      'date': instance.date,
      'text': instance.text,
      'playPageImage': instance.playPageImage,
      'newsPageImage': instance.newsPageImage,
      'readMoreLink': instance.readMoreLink,
      'cardBorder': instance.cardBorder,
      'newsType': instance.newsType,
      'id': instance.id,
    };

PlayPageImage _$PlayPageImageFromJson(Map<String, dynamic> json) =>
    PlayPageImage(url: json['url'] as String?);

Map<String, dynamic> _$PlayPageImageToJson(PlayPageImage instance) =>
    <String, dynamic>{'url': instance.url};

NewsPageImage _$NewsPageImageFromJson(Map<String, dynamic> json) =>
    NewsPageImage();

Map<String, dynamic> _$NewsPageImageToJson(NewsPageImage instance) =>
    <String, dynamic>{};
