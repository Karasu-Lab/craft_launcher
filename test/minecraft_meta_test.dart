import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:craft_launcher_core/api/minecraft_meta.dart';
import 'package:craft_launcher_core/models/versions/version_manifest_v2.dart';
import 'package:craft_launcher_core/models/java_patch_notes.dart';
import 'package:craft_launcher_core/models/news.dart';
import 'package:craft_launcher_core/models/alert_messaging.dart';

void main() {
  late MinecraftMeta minecraftMeta;

  setUp(() {
    minecraftMeta = MinecraftMeta();
  });

  tearDown(() {
    minecraftMeta.dispose();
  });

  group('MinecraftMeta API Tests', () {
    test('getPistonVersionManifestV2 returns valid data', () async {
      final result = await minecraftMeta.getPistonVersionManifestV2();

      expect(result, isA<VersionManifestV2>());
      expect(result.latest, isNotNull);
      expect(result.versions, isNotEmpty);
      debugPrint('Successfully fetched Piston Version Manifest V2');
      debugPrint('Latest release: ${result.latest.release}');
      debugPrint('Latest snapshot: ${result.latest.snapshot}');
      debugPrint('Total versions: ${result.versions.length}');
    });

    test('getLauncherVersionManifestV2 returns valid data', () async {
      final result = await minecraftMeta.getLauncherVersionManifestV2();

      expect(result, isA<VersionManifestV2>());
      expect(result.latest, isNotNull);
      expect(result.versions, isNotEmpty);
      debugPrint('Successfully fetched Launcher Version Manifest V2');
      debugPrint('Total versions: ${result.versions.length}');
    });

    test('getJavaRuntime returns valid data', () async {
      final result = await minecraftMeta.getJavaRuntime();

      expect(result, isNotNull);
      debugPrint('Successfully fetched Java Runtime data');
    });

    test('getJavaPatchNotes returns valid data', () async {
      final result = await minecraftMeta.getJavaPatchNotes();

      expect(result, isA<JavaPatchNotes>());
      expect(result.entries, isNotEmpty);
      debugPrint('Successfully fetched Java Patch Notes');
      debugPrint('Total Java patch notes entries: ${result.entries.length}');
    });

    test('getNews returns valid data', () async {
      final result = await minecraftMeta.getNews();

      expect(result, isA<News>());
      expect(result.entries, isNotEmpty);
      debugPrint('Successfully fetched News');
      debugPrint('Total news entries: ${result.entries.length}');
    });

    test('getAlertMessaging returns valid data', () async {
      final result = await minecraftMeta.getAlertMessaging();

      expect(result, isA<AlertMessaging>());
      debugPrint('Successfully fetched Alert Messaging');
    });
  });

  group('Error handling tests', () {
    test('Invalid URL throws exception', () async {
      final invalidClient = MinecraftMeta();

      expect(
        () async => await invalidClient.getDungeonsMeta('invalid-platform'),
        throwsException,
      );

      invalidClient.dispose();
    });
  });
}
