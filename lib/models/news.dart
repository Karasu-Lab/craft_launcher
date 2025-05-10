import 'package:json_annotation/json_annotation.dart';

part 'news.g.dart';

@JsonSerializable()
class News {
  final int version;
  final List<LauncherNews> entries;

  News({required this.version, required this.entries});

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);
  Map<String, dynamic> toJson() => _$NewsToJson(this);
}

@JsonSerializable()
class LauncherNews {
  final String? title;
  final String? tag;
  final String? category;
  final String? date;
  final String? text;
  final PlayPageImage? playPageImage;
  final NewsPageImage? newsPageImage;
  final String? readMoreLink;
  final bool? cardBorder;
  final List<String>? newsType;
  final String id;

  LauncherNews({
    this.title,
    this.tag,
    this.category,
    this.date,
    this.text,
    this.playPageImage,
    this.newsPageImage,
    this.readMoreLink,
    this.cardBorder,
    this.newsType,
    required this.id,
  });

  factory LauncherNews.fromJson(Map<String, dynamic> json) =>
      _$LauncherNewsFromJson(json);
  Map<String, dynamic> toJson() => _$LauncherNewsToJson(this);
}

@JsonSerializable()
class PlayPageImage {
  final String? url;

  PlayPageImage({this.url});

  factory PlayPageImage.fromJson(Map<String, dynamic> json) =>
      _$PlayPageImageFromJson(json);
  Map<String, dynamic> toJson() => _$PlayPageImageToJson(this);
}

@JsonSerializable()
class NewsPageImage {
  NewsPageImage();

  factory NewsPageImage.fromJson(Map<String, dynamic> json) =>
      _$NewsPageImageFromJson(json);
  Map<String, dynamic> toJson() => _$NewsPageImageToJson(this);
}
