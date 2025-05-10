import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:craft_launcher/interfaces/minecraft_meta_interface.dart';
import 'package:craft_launcher/models/alertMessaging.dart';
import 'package:craft_launcher/models/bedrock_patch_notes.dart';
import 'package:craft_launcher/models/dungeons_patch_notes.dart';
import 'package:craft_launcher/models/faq.dart';
import 'package:craft_launcher/models/java_patch_notes.dart';
import 'package:craft_launcher/models/launcherPatchNotes_v2.dart';
import 'package:craft_launcher/models/news.dart';
import 'package:craft_launcher/models/versions/jre_manifest.dart';
import 'package:craft_launcher/models/versions/version_manifest_v2.dart';

class MinecraftMeta implements MinecraftMetaInterface {
  static const String _pistonMetaBaseUrl = 'https://piston-meta.mojang.com';
  static const String _launcherMetaBaseUrl = 'https://launchermeta.mojang.com';
  static const String _launcherContentBaseUrl =
      'https://launchercontent.mojang.com';

  final http.Client _client;

  MinecraftMeta({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data from $url: ${response.statusCode}');
    }
  }

  String _getLauncherContentUrl(String endpoint, {bool testing = false}) {
    return '$_launcherContentBaseUrl/${testing ? 'testing/' : ''}$endpoint';
  }

  @override
  Future<VersionManifestV2> getPistonVersionManifestV2() async {
    final jsonData = await _fetchJson(
      '$_pistonMetaBaseUrl/mc/game/version_manifest_v2.json',
    );
    return VersionManifestV2.fromJson(jsonData);
  }

  @override
  Future<Map<String, dynamic>> getDungeonsMeta(String platform) async {
    const String hash = 'f4c685912beb55eb2d5c9e0713fe1195164bba27';
    return _fetchJson(
      '$_pistonMetaBaseUrl/v1/products/dungeons/$hash/$platform.json',
    );
  }

  @override
  Future<VersionManifestV2> getLauncherVersionManifestV2() async {
    final jsonData = await _fetchJson(
      '$_launcherMetaBaseUrl/mc/game/version_manifest_v2.json',
    );
    return VersionManifestV2.fromJson(jsonData);
  }

  @override
  Future<JavaRuntime> getJavaRuntime() async {
    final jsonData = await _fetchJson(
      '$_launcherMetaBaseUrl/v1/products/java-runtime/2ec0cc96c44e5a76b9c8b7c39df7210883d12871/all.json',
    );
    return JavaRuntime.fromJson(jsonData);
  }

  @override
  Future<JavaPatchNotes> getJavaPatchNotes({bool testing = false}) async {
    final jsonData = await _fetchJson(
      _getLauncherContentUrl('javaPatchNotes.json', testing: testing),
    );
    return JavaPatchNotes.fromJson(jsonData);
  }

  @override
  Future<BedrockPatchNotes> getBedrockPatchNotes({bool testing = false}) async {
    final jsonData = await _fetchJson(
      _getLauncherContentUrl('bedrockPatchNotes.json', testing: testing),
    );
    return BedrockPatchNotes.fromJson(jsonData);
  }

  @override
  Future<DungeonsPatchNotes> getDungeonsPatchNotes({
    bool testing = false,
  }) async {
    final jsonData = await _fetchJson(
      _getLauncherContentUrl('dungeonsPatchNotes.json', testing: testing),
    );
    return DungeonsPatchNotes.fromJson(jsonData);
  }

  @override
  Future<LauncherPatchNotesV2> getLauncherPatchNotesV2({
    bool testing = false,
  }) async {
    final jsonData = await _fetchJson(
      _getLauncherContentUrl('launcherPatchNotes_v2.json', testing: testing),
    );
    return LauncherPatchNotesV2.fromJson(jsonData);
  }

  @override
  Future<News> getNews({bool testing = false}) async {
    final jsonData = await _fetchJson(
      _getLauncherContentUrl('news.json', testing: testing),
    );
    return News.fromJson(jsonData);
  }

  @override
  Future<FAQ> getFAQ({bool testing = false}) async {
    final jsonData = await _fetchJson(
      _getLauncherContentUrl('faq.json', testing: testing),
    );
    return FAQ.fromJson(jsonData);
  }

  @override
  Future<Map<String, dynamic>> getAccountMigration({
    bool testing = false,
  }) async {
    return _fetchJson(
      _getLauncherContentUrl('accountMigration.json', testing: testing),
    );
  }

  @override
  Future<Map<String, dynamic>> getDungeonsDLC(
    String locale, {
    bool testing = false,
  }) async {
    String url;
    if (testing) {
      url = '$_launcherContentBaseUrl/dungeonsDLC/testing/$locale.json';
    } else {
      url = '$_launcherContentBaseUrl/dungeonsDLC/$locale.json';
    }
    return _fetchJson(url);
  }

  @override
  Future<AlertMessaging> getAlertMessaging({bool testing = false}) async {
    final jsonData = await _fetchJson(
      _getLauncherContentUrl('alertMessaging.json', testing: testing),
    );
    return AlertMessaging.fromJson(jsonData);
  }

  void dispose() {
    _client.close();
  }
}
