import 'package:json_annotation/json_annotation.dart';

part 'launcher_ui_state_microsoft_store.g.dart';

@JsonSerializable()
class LauncherUiStateMicrosoftStore {
  final LauncherUiStateData data;
  final int formatVersion;

  LauncherUiStateMicrosoftStore({
    required this.data,
    required this.formatVersion,
  });

  factory LauncherUiStateMicrosoftStore.fromJson(Map<String, dynamic> json) =>
      _$LauncherUiStateMicrosoftStoreFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherUiStateMicrosoftStoreToJson(this);
}

@JsonSerializable()
class LauncherUiStateData {
  @JsonKey(name: 'UiSettings')
  final String uiSettings;

  LauncherUiStateData({required this.uiSettings});

  factory LauncherUiStateData.fromJson(Map<String, dynamic> json) =>
      _$LauncherUiStateDataFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherUiStateDataToJson(this);
}

@JsonSerializable()
class UiSettings {
  final NewsPageFilter newsPageFilter;
  final HomePageProductContentFilter homePageProductContentFilter;
  final HomePageCategoryContentFilter homePageCategoryContentFilter;
  final DungeonsDLCFilter dungeonsDLCFilter;
  final JavaConfigurationFilter javaConfigurationFilter;
  final String lastVisitedPage;
  final Animate animate;
  final bool hasClearedUpgradeDialog;
  final bool hasShownCloudyClimb;
  final bool hasShownWinterPromo;
  final String lastCoreVersion;
  final List<String> viewedReleaseNotes;
  final bool stopUpgradeDialog;
  final JavaPatchNotesFilter javaPatchNotesFilter;
  final ProductsPatchNotesFilter productsPatchNotesFilter;
  final List<AccountMismatchAcknowledgeDate> accountMismatchAcknowledgeDates;
  final bool isSFXEnabled;
  final bool isMusicEnabled;
  final bool isAudioEnabled;
  final IsQuickPlayBarCollapsed isQuickPlayBarCollapsed;
  final bool javaLaunchAfterInstall;
  final String reviewIndicatorDate;
  final bool isSpecialEventEnabledSpring25;
  final bool isLauncherLevelingSystemEnabled;
  final bool isSpecialEventEnabled;
  final String lastVisitedGame;
  final List<String> viewedNews;
  final List<String> viewedHighlights;
  final String firstLaunchDate;

  UiSettings({
    required this.newsPageFilter,
    required this.homePageProductContentFilter,
    required this.homePageCategoryContentFilter,
    required this.dungeonsDLCFilter,
    required this.javaConfigurationFilter,
    required this.lastVisitedPage,
    required this.animate,
    required this.hasClearedUpgradeDialog,
    required this.hasShownCloudyClimb,
    required this.hasShownWinterPromo,
    required this.lastCoreVersion,
    required this.viewedReleaseNotes,
    required this.stopUpgradeDialog,
    required this.javaPatchNotesFilter,
    required this.productsPatchNotesFilter,
    required this.accountMismatchAcknowledgeDates,
    required this.isSFXEnabled,
    required this.isMusicEnabled,
    required this.isAudioEnabled,
    required this.isQuickPlayBarCollapsed,
    required this.javaLaunchAfterInstall,
    required this.reviewIndicatorDate,
    required this.isSpecialEventEnabledSpring25,
    required this.isLauncherLevelingSystemEnabled,
    required this.isSpecialEventEnabled,
    required this.lastVisitedGame,
    required this.viewedNews,
    required this.viewedHighlights,
    required this.firstLaunchDate,
  });

  factory UiSettings.fromJson(Map<String, dynamic> json) =>
      _$UiSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$UiSettingsToJson(this);
}

@JsonSerializable()
class NewsPageFilter {
  @JsonKey(name: 'Dungeons')
  final bool dungeons;
  @JsonKey(name: 'Java')
  final bool java;
  @JsonKey(name: 'Bedrock')
  final bool bedrock;
  @JsonKey(name: 'Mojang')
  final bool mojang;
  @JsonKey(name: 'Legends')
  final bool legends;

  NewsPageFilter({
    required this.dungeons,
    required this.java,
    required this.bedrock,
    required this.mojang,
    required this.legends,
  });

  factory NewsPageFilter.fromJson(Map<String, dynamic> json) =>
      _$NewsPageFilterFromJson(json);

  Map<String, dynamic> toJson() => _$NewsPageFilterToJson(this);
}

@JsonSerializable()
class HomePageProductContentFilter {
  final bool all;
  final bool java;
  final bool bedrock;
  final bool javaAndBedrock;
  final bool dungeons;
  final bool legends;

  HomePageProductContentFilter({
    required this.all,
    required this.java,
    required this.bedrock,
    required this.javaAndBedrock,
    required this.dungeons,
    required this.legends,
  });

  factory HomePageProductContentFilter.fromJson(Map<String, dynamic> json) =>
      _$HomePageProductContentFilterFromJson(json);

  Map<String, dynamic> toJson() => _$HomePageProductContentFilterToJson(this);
}

@JsonSerializable()
class HomePageCategoryContentFilter {
  final bool all;
  final bool promo;
  final bool patchNotes;
  final bool videos;
  final bool blogs;
  final bool tutorials;
  final bool marketplace;
  final bool news;
  final bool community;
  final bool support;
  final bool sale;

  HomePageCategoryContentFilter({
    required this.all,
    required this.promo,
    required this.patchNotes,
    required this.videos,
    required this.blogs,
    required this.tutorials,
    required this.marketplace,
    required this.news,
    required this.community,
    required this.support,
    required this.sale,
  });

  factory HomePageCategoryContentFilter.fromJson(Map<String, dynamic> json) =>
      _$HomePageCategoryContentFilterFromJson(json);

  Map<String, dynamic> toJson() => _$HomePageCategoryContentFilterToJson(this);
}

@JsonSerializable()
class DungeonsDLCFilter {
  @JsonKey(name: 'Owned')
  final bool owned;
  @JsonKey(name: 'Bundle')
  final bool bundle;
  @JsonKey(name: 'DLC')
  final bool dlc;

  DungeonsDLCFilter({
    required this.owned,
    required this.bundle,
    required this.dlc,
  });

  factory DungeonsDLCFilter.fromJson(Map<String, dynamic> json) =>
      _$DungeonsDLCFilterFromJson(json);

  Map<String, dynamic> toJson() => _$DungeonsDLCFilterToJson(this);
}

@JsonSerializable()
class JavaConfigurationFilter {
  final bool historical;
  final bool snapshot;
  final bool release;
  final bool modded;
  final String sortBy;

  JavaConfigurationFilter({
    required this.historical,
    required this.snapshot,
    required this.release,
    required this.modded,
    required this.sortBy,
  });

  factory JavaConfigurationFilter.fromJson(Map<String, dynamic> json) =>
      _$JavaConfigurationFilterFromJson(json);

  Map<String, dynamic> toJson() => _$JavaConfigurationFilterToJson(this);
}

@JsonSerializable()
class Animate {
  final bool transitions;
  final bool playButton;

  Animate({required this.transitions, required this.playButton});

  factory Animate.fromJson(Map<String, dynamic> json) =>
      _$AnimateFromJson(json);

  Map<String, dynamic> toJson() => _$AnimateToJson(this);
}

@JsonSerializable()
class JavaPatchNotesFilter {
  final bool release;
  final bool snapshot;

  JavaPatchNotesFilter({required this.release, required this.snapshot});

  factory JavaPatchNotesFilter.fromJson(Map<String, dynamic> json) =>
      _$JavaPatchNotesFilterFromJson(json);

  Map<String, dynamic> toJson() => _$JavaPatchNotesFilterToJson(this);
}

@JsonSerializable()
class ProductsPatchNotesFilter {
  ProductsPatchNotesFilter();

  factory ProductsPatchNotesFilter.fromJson(Map<String, dynamic> json) =>
      _$ProductsPatchNotesFilterFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsPatchNotesFilterToJson(this);
}

@JsonSerializable()
class AccountMismatchAcknowledgeDate {
  final String accountId;
  final String date;

  AccountMismatchAcknowledgeDate({required this.accountId, required this.date});

  factory AccountMismatchAcknowledgeDate.fromJson(Map<String, dynamic> json) =>
      _$AccountMismatchAcknowledgeDateFromJson(json);

  Map<String, dynamic> toJson() => _$AccountMismatchAcknowledgeDateToJson(this);
}

@JsonSerializable()
class IsQuickPlayBarCollapsed {
  final bool java;
  final bool bedrock;

  IsQuickPlayBarCollapsed({required this.java, required this.bedrock});

  factory IsQuickPlayBarCollapsed.fromJson(Map<String, dynamic> json) =>
      _$IsQuickPlayBarCollapsedFromJson(json);

  Map<String, dynamic> toJson() => _$IsQuickPlayBarCollapsedToJson(this);
}
