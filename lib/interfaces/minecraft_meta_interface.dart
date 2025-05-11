import 'package:craft_launcher_core/models/alert_messaging.dart';
import 'package:craft_launcher_core/models/bedrock_patch_notes.dart';
import 'package:craft_launcher_core/models/dungeons_patch_notes.dart';
import 'package:craft_launcher_core/models/faq.dart';
import 'package:craft_launcher_core/models/java_patch_notes.dart';
import 'package:craft_launcher_core/models/launcher_patch_notes_version_2.dart';
import 'package:craft_launcher_core/models/news.dart';
import 'package:craft_launcher_core/models/versions/jre_manifest.dart';
import 'package:craft_launcher_core/models/versions/version_manifest_v2.dart';

/// Abstract interface class for the Minecraft meta API.
abstract interface class MinecraftMetaInterface {
  /// Piston Meta - Minecraft Java Edition Versions
  Future<VersionManifestV2> getPistonVersionManifestV2();
  
  /// Piston Meta - Dungeons
  Future<Map<String, dynamic>> getDungeonsMeta(String platform);
  
  /// Launcher Meta - Minecraft Java Edition Versions
  Future<VersionManifestV2> getLauncherVersionManifestV2();
  
  /// Launcher Meta - Java Runtime
  Future<ManifestData> getJavaRuntime();
  
  /// Launcher Content - Patch Notes
  Future<JavaPatchNotes> getJavaPatchNotes({bool testing = false});
  Future<BedrockPatchNotes> getBedrockPatchNotes({bool testing = false});
  Future<DungeonsPatchNotes> getDungeonsPatchNotes({bool testing = false});
  Future<LauncherPatchNotesV2> getLauncherPatchNotesV2({bool testing = false});
  
  /// Launcher Content - News
  Future<News> getNews({bool testing = false});
  
  /// Launcher Content - FAQ
  Future<FAQ> getFAQ({bool testing = false});
  
  /// Launcher Content - Account Migration
  Future<Map<String, dynamic>> getAccountMigration({bool testing = false});
  
  /// Launcher Content - Dungeons DLCs
  Future<Map<String, dynamic>> getDungeonsDLC(String locale, {bool testing = false});
  
  /// Launcher Content - Alert Messaging
  Future<AlertMessaging> getAlertMessaging({bool testing = false});
}