import 'package:craft_launcher/models/alertMessaging.dart';
import 'package:craft_launcher/models/bedrock_patch_notes.dart';
import 'package:craft_launcher/models/dungeons_patch_notes.dart';
import 'package:craft_launcher/models/faq.dart';
import 'package:craft_launcher/models/java_patch_notes.dart';
import 'package:craft_launcher/models/launcherPatchNotes_v2.dart';
import 'package:craft_launcher/models/news.dart';
import 'package:craft_launcher/models/versions/jre_manifest.dart';
import 'package:craft_launcher/models/versions/version_manifest_v2.dart';

/// Abstract interface class for the Minecraft meta API.
abstract interface class MinecraftMetaInterface {
  /// Piston Meta - Minecraft Java Edition Versions
  Future<VersionManifestV2> getPistonVersionManifestV2();
  
  /// Piston Meta - Dungeons
  Future<Map<String, dynamic>> getDungeonsMeta(String platform);
  
  /// Launcher Meta - Minecraft Java Edition Versions
  Future<VersionManifestV2> getLauncherVersionManifestV2();
  
  /// Launcher Meta - Java Runtime
  Future<JavaRuntime> getJavaRuntime();
  
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