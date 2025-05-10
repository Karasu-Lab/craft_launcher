// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_ui_state_microsoft_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherUiStateMicrosoftStore _$LauncherUiStateMicrosoftStoreFromJson(
  Map<String, dynamic> json,
) => LauncherUiStateMicrosoftStore(
  data: LauncherUiStateData.fromJson(json['data'] as Map<String, dynamic>),
  formatVersion: (json['formatVersion'] as num).toInt(),
);

Map<String, dynamic> _$LauncherUiStateMicrosoftStoreToJson(
  LauncherUiStateMicrosoftStore instance,
) => <String, dynamic>{
  'data': instance.data,
  'formatVersion': instance.formatVersion,
};

LauncherUiStateData _$LauncherUiStateDataFromJson(Map<String, dynamic> json) =>
    LauncherUiStateData(uiSettings: json['UiSettings'] as String);

Map<String, dynamic> _$LauncherUiStateDataToJson(
  LauncherUiStateData instance,
) => <String, dynamic>{'UiSettings': instance.uiSettings};

UiSettings _$UiSettingsFromJson(Map<String, dynamic> json) => UiSettings(
  newsPageFilter: NewsPageFilter.fromJson(
    json['newsPageFilter'] as Map<String, dynamic>,
  ),
  homePageProductContentFilter: HomePageProductContentFilter.fromJson(
    json['homePageProductContentFilter'] as Map<String, dynamic>,
  ),
  homePageCategoryContentFilter: HomePageCategoryContentFilter.fromJson(
    json['homePageCategoryContentFilter'] as Map<String, dynamic>,
  ),
  dungeonsDLCFilter: DungeonsDLCFilter.fromJson(
    json['dungeonsDLCFilter'] as Map<String, dynamic>,
  ),
  javaConfigurationFilter: JavaConfigurationFilter.fromJson(
    json['javaConfigurationFilter'] as Map<String, dynamic>,
  ),
  lastVisitedPage: json['lastVisitedPage'] as String,
  animate: Animate.fromJson(json['animate'] as Map<String, dynamic>),
  hasClearedUpgradeDialog: json['hasClearedUpgradeDialog'] as bool,
  hasShownCloudyClimb: json['hasShownCloudyClimb'] as bool,
  hasShownWinterPromo: json['hasShownWinterPromo'] as bool,
  lastCoreVersion: json['lastCoreVersion'] as String,
  viewedReleaseNotes:
      (json['viewedReleaseNotes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  stopUpgradeDialog: json['stopUpgradeDialog'] as bool,
  javaPatchNotesFilter: JavaPatchNotesFilter.fromJson(
    json['javaPatchNotesFilter'] as Map<String, dynamic>,
  ),
  productsPatchNotesFilter: ProductsPatchNotesFilter.fromJson(
    json['productsPatchNotesFilter'] as Map<String, dynamic>,
  ),
  accountMismatchAcknowledgeDates:
      (json['accountMismatchAcknowledgeDates'] as List<dynamic>)
          .map(
            (e) => AccountMismatchAcknowledgeDate.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
  isSFXEnabled: json['isSFXEnabled'] as bool,
  isMusicEnabled: json['isMusicEnabled'] as bool,
  isAudioEnabled: json['isAudioEnabled'] as bool,
  isQuickPlayBarCollapsed: IsQuickPlayBarCollapsed.fromJson(
    json['isQuickPlayBarCollapsed'] as Map<String, dynamic>,
  ),
  javaLaunchAfterInstall: json['javaLaunchAfterInstall'] as bool,
  reviewIndicatorDate: json['reviewIndicatorDate'] as String,
  isSpecialEventEnabledSpring25: json['isSpecialEventEnabledSpring25'] as bool,
  isLauncherLevelingSystemEnabled:
      json['isLauncherLevelingSystemEnabled'] as bool,
  isSpecialEventEnabled: json['isSpecialEventEnabled'] as bool,
  lastVisitedGame: json['lastVisitedGame'] as String,
  viewedNews:
      (json['viewedNews'] as List<dynamic>).map((e) => e as String).toList(),
  viewedHighlights:
      (json['viewedHighlights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  firstLaunchDate: json['firstLaunchDate'] as String,
);

Map<String, dynamic> _$UiSettingsToJson(
  UiSettings instance,
) => <String, dynamic>{
  'newsPageFilter': instance.newsPageFilter,
  'homePageProductContentFilter': instance.homePageProductContentFilter,
  'homePageCategoryContentFilter': instance.homePageCategoryContentFilter,
  'dungeonsDLCFilter': instance.dungeonsDLCFilter,
  'javaConfigurationFilter': instance.javaConfigurationFilter,
  'lastVisitedPage': instance.lastVisitedPage,
  'animate': instance.animate,
  'hasClearedUpgradeDialog': instance.hasClearedUpgradeDialog,
  'hasShownCloudyClimb': instance.hasShownCloudyClimb,
  'hasShownWinterPromo': instance.hasShownWinterPromo,
  'lastCoreVersion': instance.lastCoreVersion,
  'viewedReleaseNotes': instance.viewedReleaseNotes,
  'stopUpgradeDialog': instance.stopUpgradeDialog,
  'javaPatchNotesFilter': instance.javaPatchNotesFilter,
  'productsPatchNotesFilter': instance.productsPatchNotesFilter,
  'accountMismatchAcknowledgeDates': instance.accountMismatchAcknowledgeDates,
  'isSFXEnabled': instance.isSFXEnabled,
  'isMusicEnabled': instance.isMusicEnabled,
  'isAudioEnabled': instance.isAudioEnabled,
  'isQuickPlayBarCollapsed': instance.isQuickPlayBarCollapsed,
  'javaLaunchAfterInstall': instance.javaLaunchAfterInstall,
  'reviewIndicatorDate': instance.reviewIndicatorDate,
  'isSpecialEventEnabledSpring25': instance.isSpecialEventEnabledSpring25,
  'isLauncherLevelingSystemEnabled': instance.isLauncherLevelingSystemEnabled,
  'isSpecialEventEnabled': instance.isSpecialEventEnabled,
  'lastVisitedGame': instance.lastVisitedGame,
  'viewedNews': instance.viewedNews,
  'viewedHighlights': instance.viewedHighlights,
  'firstLaunchDate': instance.firstLaunchDate,
};

NewsPageFilter _$NewsPageFilterFromJson(Map<String, dynamic> json) =>
    NewsPageFilter(
      dungeons: json['Dungeons'] as bool,
      java: json['Java'] as bool,
      bedrock: json['Bedrock'] as bool,
      mojang: json['Mojang'] as bool,
      legends: json['Legends'] as bool,
    );

Map<String, dynamic> _$NewsPageFilterToJson(NewsPageFilter instance) =>
    <String, dynamic>{
      'Dungeons': instance.dungeons,
      'Java': instance.java,
      'Bedrock': instance.bedrock,
      'Mojang': instance.mojang,
      'Legends': instance.legends,
    };

HomePageProductContentFilter _$HomePageProductContentFilterFromJson(
  Map<String, dynamic> json,
) => HomePageProductContentFilter(
  all: json['all'] as bool,
  java: json['java'] as bool,
  bedrock: json['bedrock'] as bool,
  javaAndBedrock: json['javaAndBedrock'] as bool,
  dungeons: json['dungeons'] as bool,
  legends: json['legends'] as bool,
);

Map<String, dynamic> _$HomePageProductContentFilterToJson(
  HomePageProductContentFilter instance,
) => <String, dynamic>{
  'all': instance.all,
  'java': instance.java,
  'bedrock': instance.bedrock,
  'javaAndBedrock': instance.javaAndBedrock,
  'dungeons': instance.dungeons,
  'legends': instance.legends,
};

HomePageCategoryContentFilter _$HomePageCategoryContentFilterFromJson(
  Map<String, dynamic> json,
) => HomePageCategoryContentFilter(
  all: json['all'] as bool,
  promo: json['promo'] as bool,
  patchNotes: json['patchNotes'] as bool,
  videos: json['videos'] as bool,
  blogs: json['blogs'] as bool,
  tutorials: json['tutorials'] as bool,
  marketplace: json['marketplace'] as bool,
  news: json['news'] as bool,
  community: json['community'] as bool,
  support: json['support'] as bool,
  sale: json['sale'] as bool,
);

Map<String, dynamic> _$HomePageCategoryContentFilterToJson(
  HomePageCategoryContentFilter instance,
) => <String, dynamic>{
  'all': instance.all,
  'promo': instance.promo,
  'patchNotes': instance.patchNotes,
  'videos': instance.videos,
  'blogs': instance.blogs,
  'tutorials': instance.tutorials,
  'marketplace': instance.marketplace,
  'news': instance.news,
  'community': instance.community,
  'support': instance.support,
  'sale': instance.sale,
};

DungeonsDLCFilter _$DungeonsDLCFilterFromJson(Map<String, dynamic> json) =>
    DungeonsDLCFilter(
      owned: json['Owned'] as bool,
      bundle: json['Bundle'] as bool,
      dlc: json['DLC'] as bool,
    );

Map<String, dynamic> _$DungeonsDLCFilterToJson(DungeonsDLCFilter instance) =>
    <String, dynamic>{
      'Owned': instance.owned,
      'Bundle': instance.bundle,
      'DLC': instance.dlc,
    };

JavaConfigurationFilter _$JavaConfigurationFilterFromJson(
  Map<String, dynamic> json,
) => JavaConfigurationFilter(
  historical: json['historical'] as bool,
  snapshot: json['snapshot'] as bool,
  release: json['release'] as bool,
  modded: json['modded'] as bool,
  sortBy: json['sortBy'] as String,
);

Map<String, dynamic> _$JavaConfigurationFilterToJson(
  JavaConfigurationFilter instance,
) => <String, dynamic>{
  'historical': instance.historical,
  'snapshot': instance.snapshot,
  'release': instance.release,
  'modded': instance.modded,
  'sortBy': instance.sortBy,
};

Animate _$AnimateFromJson(Map<String, dynamic> json) => Animate(
  transitions: json['transitions'] as bool,
  playButton: json['playButton'] as bool,
);

Map<String, dynamic> _$AnimateToJson(Animate instance) => <String, dynamic>{
  'transitions': instance.transitions,
  'playButton': instance.playButton,
};

JavaPatchNotesFilter _$JavaPatchNotesFilterFromJson(
  Map<String, dynamic> json,
) => JavaPatchNotesFilter(
  release: json['release'] as bool,
  snapshot: json['snapshot'] as bool,
);

Map<String, dynamic> _$JavaPatchNotesFilterToJson(
  JavaPatchNotesFilter instance,
) => <String, dynamic>{
  'release': instance.release,
  'snapshot': instance.snapshot,
};

ProductsPatchNotesFilter _$ProductsPatchNotesFilterFromJson(
  Map<String, dynamic> json,
) => ProductsPatchNotesFilter();

Map<String, dynamic> _$ProductsPatchNotesFilterToJson(
  ProductsPatchNotesFilter instance,
) => <String, dynamic>{};

AccountMismatchAcknowledgeDate _$AccountMismatchAcknowledgeDateFromJson(
  Map<String, dynamic> json,
) => AccountMismatchAcknowledgeDate(
  accountId: json['accountId'] as String,
  date: json['date'] as String,
);

Map<String, dynamic> _$AccountMismatchAcknowledgeDateToJson(
  AccountMismatchAcknowledgeDate instance,
) => <String, dynamic>{'accountId': instance.accountId, 'date': instance.date};

IsQuickPlayBarCollapsed _$IsQuickPlayBarCollapsedFromJson(
  Map<String, dynamic> json,
) => IsQuickPlayBarCollapsed(
  java: json['java'] as bool,
  bedrock: json['bedrock'] as bool,
);

Map<String, dynamic> _$IsQuickPlayBarCollapsedToJson(
  IsQuickPlayBarCollapsed instance,
) => <String, dynamic>{'java': instance.java, 'bedrock': instance.bedrock};
