import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:craft_launcher_core/archives/archives_manager.dart';
import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/downloaders/asset_downloader.dart';
import 'package:craft_launcher_core/interfaces/vanilla_launcher_interface.dart';
import 'package:craft_launcher_core/java_arguments/classpath_manager.dart';
import 'package:craft_launcher_core/java_arguments/java_arguments_builder.dart';
import 'package:craft_launcher_core/launcher_adapter.dart';
import 'package:craft_launcher_core/models/launcher_profiles.dart';
import 'package:craft_launcher_core/processes/process_manager.dart';
import 'package:flutter/material.dart';
import 'package:mcid_connect/data/auth/microsoft/microsoft_account.dart';
import 'package:mcid_connect/data/profile/minecraft_account_profile.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:craft_launcher_core/environments/environment_manager.dart';

class VanillaLauncher implements VanillaLauncherInterface, LauncherAdapter {
  final JavaArgumentsBuilder _javaArgumentsBuilder;

  final MinecraftAccountProfile? _minecraftAccountProfile;
  final MicrosoftAccount? _microsoftAccount;
  final MinecraftAuth? _minecraftAuth;

  final ProfileManager _profileManager;
  final ClasspathManager _classpathManager;
  final ArchivesManager _archivesManager;
  final ProcessManager _processManager = ProcessManager();

  final DownloadProgressCallback? _onDownloadProgress;
  final OperationProgressCallback? _onOperationProgress;
  final int _progressReportRate;

  JavaExitCallback? onExit;
  String _gameDir;
  String _javaDir;
  MinecraftProcessInfo? _minecraftProcessInfo;

  Completer<void>? _nativeLibrariesCompleter;
  Completer<void>? _classpathCompleter;
  Completer<void>? _assetsCompleter;
  Completer<void>? _librariesCompleter;
  List<Completer<void>> _activeCompleters = [];

  VanillaLauncher({
    required String gameDir,
    required String javaDir,
    required LauncherProfiles profiles,
    required Profile activeProfile,
    MinecraftAccountProfile? minecraftAccountProfile,
    MicrosoftAccount? microsoftAccount,
    MinecraftAuth? minecraftAuth,
    DownloadProgressCallback? onDownloadProgress,
    OperationProgressCallback? onOperationProgress,
    int progressReportRate = 10,
  }) : _gameDir = gameDir,
       _javaDir = javaDir,
       _minecraftAccountProfile = minecraftAccountProfile,
       _microsoftAccount = microsoftAccount,
       _minecraftAuth = minecraftAuth,
       _onDownloadProgress = onDownloadProgress,
       _onOperationProgress = onOperationProgress,
       _progressReportRate = progressReportRate,
       _javaArgumentsBuilder = JavaArgumentsBuilder(),
       _classpathManager = ClasspathManager(
         gameDir: gameDir,
         onDownloadProgress: onDownloadProgress,
         onOperationProgress: onOperationProgress,
         progressReportRate: progressReportRate,
       ),
       _archivesManager = ArchivesManager(
         onOperationProgress: onOperationProgress,
         progressReportRate: progressReportRate,
       ),
       _profileManager = ProfileManager(
         gameDir: gameDir,
         profiles: profiles,
         activeProfile: activeProfile,
       );

  String _normalizePath(String path) {
    final normalized = p.normalize(path);
    return p.isAbsolute(normalized) ? normalized : p.absolute(normalized);
  }

  Future<Directory> _ensureDirectory(String path) async {
    final normalizedPath = _normalizePath(path);
    final dir = Directory(normalizedPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _downloadFile(
    String url,
    String filePath, {
    int? expectedSize,
    String? resourceName,
  }) async {
    final file = File(filePath);
    final displayName = resourceName ?? p.basename(filePath);

    if (await file.exists() && expectedSize != null) {
      final fileSize = await file.length();
      if (fileSize == expectedSize) {
        if (_onDownloadProgress != null) {
          _onDownloadProgress(displayName, expectedSize, expectedSize, 100.0);
        }
        return file;
      }
    }

    await _ensureDirectory(p.dirname(filePath));

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? -1;
        final sink = file.openWrite();
        int received = 0;
        int lastReportedPercentage = 0;

        await response.stream.listen((data) {
          sink.add(data);
          received += data.length;

          if (_onDownloadProgress != null && contentLength > 0) {
            final percentage = (received / contentLength) * 100;
            final reportPercentage =
                (percentage ~/ _progressReportRate) * _progressReportRate;

            if (reportPercentage > lastReportedPercentage) {
              lastReportedPercentage = reportPercentage;
              final clampedPercentage = max(0.0, min(percentage, 100.0));
              _onDownloadProgress(
                displayName,
                received,
                contentLength,
                clampedPercentage,
              );
            }
          }
        }).asFuture<void>();

        await sink.close();
        client.close();

        if (_onDownloadProgress != null && contentLength > 0) {
          _onDownloadProgress(displayName, contentLength, contentLength, 100.0);
        }

        return file;
      } else {
        client.close();
        throw Exception('Failed to download file: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading file from $url: $e');
      rethrow;
    }
  }

  Future<String> _calculateSha1Hash(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  @override
  Future<void> downloadAssets() async {
    _assetsCompleter = Completer<void>();
    _activeCompleters.add(_assetsCompleter!);

    try {
      final versionId = _profileManager.activeProfile.lastVersionId;
      await beforeDownloadAssets(versionId);
      final versionInfo = await _fetchVersionManifest(versionId);

      if (versionInfo == null) {
        throw Exception('Failed to get version info for $versionId');
      }

      final assetDownloader = AssetDownloader(
        gameDir: _gameDir,
        onDownloadProgress: _onDownloadProgress,
        onOperationProgress: _onOperationProgress,
        progressReportRate: _progressReportRate,
      );

      await assetDownloader.downloadAssets(versionInfo);
      await assetDownloader.completionFuture;

      _assetsCompleter!.complete();
      await afterDownloadAssets(versionId);
    } catch (e) {
      debugPrint('Error downloading assets: $e');
      _assetsCompleter!.completeError(
        Exception('Failed to download assets: $e'),
      );
      throw Exception('Failed to download assets: $e');
    }
  }

  @override
  Future<void> downloadLibraries() async {
    _librariesCompleter = Completer<void>();
    _activeCompleters.add(_librariesCompleter!);

    try {
      final versionId = _profileManager.activeProfile.lastVersionId;
      await beforeDownloadLibraries(versionId);
      final versionInfo = await _fetchVersionManifest(versionId);

      if (versionInfo == null) {
        throw Exception('Failed to get version info for $versionId');
      }

      await _classpathManager.downloadLibraries(versionInfo);
      _librariesCompleter!.complete();
      await afterDownloadLibraries(versionId);
    } catch (e) {
      debugPrint('Error downloading libraries: $e');
      _librariesCompleter!.completeError(
        Exception('Failed to download libraries: $e'),
      );
      throw Exception('Failed to download libraries: $e');
    }
  }

  @override
  Future<String> extractNativeLibraries() async {
    _nativeLibrariesCompleter = Completer<void>();
    _activeCompleters.add(_nativeLibrariesCompleter!);

    final versionId = _profileManager.activeProfile.lastVersionId;
    await beforeExtractNativeLibraries(versionId);
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null || versionInfo.libraries == null) {
      throw Exception('Failed to get libraries info for $versionId');
    }

    try {
      final resultNativesDir = await _archivesManager.extractNativeLibraries(
        libraries: versionInfo.libraries!,
        versionId: versionId,
        gameDir: _gameDir,
        librariesDir: _getLibrariesDir(),
        getNativesDir: (libraryHash) => _getNativesDir(versionId, libraryHash),
        downloadFile: _downloadFile,
      );

      _nativeLibrariesCompleter!.complete();
      await afterExtractNativeLibraries(versionId, resultNativesDir);
      return resultNativesDir;
    } catch (e) {
      _nativeLibrariesCompleter!.completeError(e);
      throw Exception('Failed to extract native libraries: $e');
    }
  }

  @override
  MinecraftAccountProfile? getAccountProfile() {
    return _minecraftAccountProfile;
  }

  @override
  MicrosoftAccount? getMicrosoftAccount() {
    return _microsoftAccount;
  }

  @override
  Profile getActiveProfile() {
    return _profileManager.activeProfile;
  }

  @override
  Future<String> getAssetIndex(String versionId) async {
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null || versionInfo.assetIndex == null) {
      throw Exception('Failed to get asset index info for $versionId');
    }

    final assetIndexInfo = versionInfo.assetIndex;
    return assetIndexInfo!.id;
  }

  @override
  String getGameDir() {
    return _gameDir;
  }

  @override
  JavaArgumentsBuilder getJavaArgumentsBuilder() {
    return _javaArgumentsBuilder;
  }

  @override
  String getJavaDir() {
    return _javaDir;
  }

  @override
  LauncherProfiles getProfiles() {
    return _profileManager.profiles;
  }

  Future<VersionInfo?> _fetchVersionManifest(String versionId) async {
    await beforeFetchVersionManifest(versionId);

    final versionJsonPath = _getVersionJsonPath(versionId);
    final versionJsonFile = File(versionJsonPath);

    if (await versionJsonFile.exists()) {
      final content = await versionJsonFile.readAsString();
      return VersionInfo.fromJson(json.decode(content));
    }

    try {
      final manifestUrl =
          'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';
      final manifestResponse = await http.get(Uri.parse(manifestUrl));

      if (manifestResponse.statusCode != 200) {
        throw Exception('Failed to download version manifest');
      }
      final manifestJson = json.decode(manifestResponse.body);
      final versions = manifestJson['versions'] as List;

      for (final version in versions) {
        if (version['id'] == versionId) {
          final versionUrl = version['url'] as String;
          await _ensureDirectory(p.dirname(versionJsonPath));

          try {
            final versionFile = await _downloadFile(
              versionUrl,
              versionJsonPath,
            );
            final content = await versionFile.readAsString();
            return VersionInfo.fromJson(json.decode(content));
          } catch (e) {
            debugPrint('Error downloading version JSON: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching version info: $e');
    }

    final result =
        await versionJsonFile.exists()
            ? VersionInfo.fromJson(
              json.decode(await versionJsonFile.readAsString()),
            )
            : null;

    await afterFetchVersionManifest(versionId, result);
    return result;
  }

  Future<List<String>> _buildClasspath(
    VersionInfo versionInfo,
    String versionId,
  ) async {
    _classpathCompleter = Completer<void>();
    _activeCompleters.add(_classpathCompleter!);

    try {
      await beforeBuildClasspath(versionInfo, versionId);
      final classpath = await _classpathManager.buildClasspath(
        versionInfo,
        versionId,
      );
      _classpathCompleter!.complete();
      await afterBuildClasspath(versionInfo, versionId, classpath);
      return classpath;
    } catch (e) {
      _classpathCompleter!.completeError(e);
      rethrow;
    }
  }

  @override
  Future<void> launch({
    JavaStderrCallback? onStderr,
    JavaStdoutCallback? onStdout,
    JavaExitCallback? onExit,
  }) async {
    _activeCompleters = [];

    await downloadAssets();
    await downloadLibraries();

    final versionId = _profileManager.activeProfile.lastVersionId;
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null) {
      throw Exception('Failed to get version info for $versionId');
    }

    final nativesPath = await extractNativeLibraries();
    debugPrint('Using natives directory: $nativesPath');

    final classpath = await _buildClasspath(versionInfo, versionId);

    final mainClass = versionInfo.mainClass;
    if (mainClass == null) {
      throw Exception('Main class not found in version info');
    }
    debugPrint('Main class: $mainClass');

    _javaArgumentsBuilder
        .setGameDir(_normalizePath(_gameDir))
        .setVersion(versionInfo.id)
        .addClassPaths(classpath)
        .setNativesDir(nativesPath)
        .setClientJar(_getClientJarPath(versionId))
        .setMainClass(mainClass)
        .setAssetsIndexName(versionInfo.assetIndex?.id ?? versionInfo.id)
        .addGameArguments(versionInfo.arguments);

    if (versionInfo.minecraftArguments != null) {
      _javaArgumentsBuilder.setMinecraftArguments(
        versionInfo.minecraftArguments!,
      );
    }

    if (_minecraftAuth != null) {
      debugPrint('Using authenticated account: ${_minecraftAuth.userName}');
      _javaArgumentsBuilder
          .setAuthPlayerName(_minecraftAuth.userName)
          .setAuthUuid(_minecraftAuth.uuid)
          .setAuthAccessToken(_minecraftAuth.accessToken)
          .setClientId(_minecraftAuth.clientId)
          .setAuthXuid(_minecraftAuth.authXuid)
          .setUserType(_minecraftAuth.userType);
    } else {
      debugPrint('Using offline mode: Player');
      _javaArgumentsBuilder
          .setDemoUser(true)
          .setAuthPlayerName('Player')
          .setAuthUuid('00000000-0000-0000-0000-000000000000')
          .setAuthAccessToken('00000000-0000-0000-0000-000000000000')
          .setClientId('00000000-0000-0000-0000-000000000000')
          .setAuthXuid('00000000-0000-0000-0000-000000000000')
          .setUserType('msa');
    }

    final activeProfile = _profileManager.activeProfile;
    if (activeProfile.javaArgs != null && activeProfile.javaArgs!.isNotEmpty) {
      _javaArgumentsBuilder.addAdditionalArguments(activeProfile.javaArgs);
    }

    final javaArgsString = _javaArgumentsBuilder.build();
    final javaArgs = javaArgsString.split(' ');

    try {
      for (final completer in _activeCompleters) {
        await completer.future;
      }

      final Map<String, String> environment =
          EnvironmentManager.configureEnvironment(nativesPath: nativesPath);

      final javaExe = EnvironmentManager.getJavaExecutablePath(_javaDir);
      debugPrint('Java executable: $javaExe');
      debugPrint('Java arguments:');
      debugPrint(javaArgs.join(' '));

      await beforeStartProcess(
        javaExe,
        javaArgs,
        EnvironmentManager.normalizePath(_gameDir),
        environment,
        versionId,
        _minecraftAuth,
      );

      _minecraftProcessInfo = await _processManager.startProcess(
        javaExe: javaExe,
        javaArgs: javaArgs,
        workingDirectory: EnvironmentManager.normalizePath(_gameDir),
        environment: environment,
        versionId: versionId,
        auth: _minecraftAuth,
        onStdout: onStdout,
        onStderr: onStderr,
        onExit: (exitCode) {
          if (onExit != null) {
            onExit(exitCode);
          }
          if (this.onExit != null) {
            this.onExit!(exitCode);
          }
          _minecraftProcessInfo = null;
        },
      );

      await afterStartProcess(
        versionId,
        _minecraftProcessInfo!,
        _minecraftAuth,
      );

      debugPrint(
        'Minecraft process started with PID: ${_minecraftProcessInfo!.pid}, User: ${_minecraftAuth?.userName ?? "anonymous"}',
      );
    } catch (e) {
      debugPrint('Error launching Minecraft: $e');
      throw Exception('Failed to launch Minecraft: $e');
    }
  }

  @override
  void setActiveProfile(Profile profile) {
    _profileManager.activeProfile = profile;
  }

  @override
  void setActiveProfileById(String profileId) {
    _profileManager.setActiveProfileById(profileId);
  }

  @override
  void setGameDir(String gameDir) {
    _gameDir = gameDir;
    _profileManager.gameDir = gameDir;
  }

  @override
  void setJavaDir(String javaDir) {
    _javaDir = javaDir;
  }

  @override
  Future<void> loadProfiles() async {
    await _profileManager.loadProfiles();
  }

  @override
  void terminate() {
    if (_minecraftProcessInfo != null) {
      _processManager.terminateProcess(_minecraftProcessInfo!.pid);
      _minecraftProcessInfo = null;
    }
  }

  @override
  Future<void> downloadClientJar() async {
    final versionId = _profileManager.activeProfile.lastVersionId;
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null) {
      throw Exception('Failed to get version info for $versionId');
    }

    await _classpathManager.downloadClientJar(versionInfo, versionId);
  }

  String _getVersionDir(String versionId) {
    return _normalizePath(p.join(_gameDir, 'versions', versionId));
  }

  String _getVersionJsonPath(String versionId) {
    return _normalizePath(p.join(_getVersionDir(versionId), '$versionId.json'));
  }

  String _getClientJarPath(String versionId) {
    return _normalizePath(p.join(_getVersionDir(versionId), '$versionId.jar'));
  }

  String _getLibrariesDir() {
    return _normalizePath(p.join(_gameDir, 'libraries'));
  }

  String _getAssetsDir() {
    return _normalizePath(p.join(_gameDir, 'assets'));
  }

  String _getNativesDir(String versionId, String libraryHash) {
    return _normalizePath(p.join(_gameDir, 'bin', libraryHash));
  }

  @override
  Future<void> beforeFetchVersionManifest(String versionId) async {
    // Default implementation does nothing
  }

  @override
  Future<void> afterFetchVersionManifest(
    String versionId,
    VersionInfo? versionInfo,
  ) async {
    // Default implementation does nothing
  }

  @override
  Future<void> beforeBuildClasspath(
    dynamic versionInfo,
    String versionId,
  ) async {
    // Default implementation does nothing
  }

  @override
  Future<void> afterBuildClasspath(
    VersionInfo versionInfo,
    String versionId,
    List<String> classpath,
  ) async {
    // Default implementation does nothing
  }

  @override
  Future<void> beforeExtractNativeLibraries(String versionId) async {
    // Default implementation does nothing
  }

  @override
  Future<void> afterExtractNativeLibraries(
    String versionId,
    String nativesPath,
  ) async {
    // Default implementation does nothing
  }

  @override
  Future<void> beforeDownloadAssets(String versionId) async {
    // Default implementation does nothing
  }

  @override
  Future<void> afterDownloadAssets(String versionId) async {
    // Default implementation does nothing
  }

  @override
  Future<void> beforeDownloadLibraries(String versionId) async {
    // Default implementation does nothing
  }

  @override
  Future<void> afterDownloadLibraries(String versionId) async {
    // Default implementation does nothing
  }

  @override
  Future<void> beforeStartProcess(
    String javaExe,
    List<String> javaArgs,
    String workingDirectory,
    Map<String, String> environment,
    String versionId,
    MinecraftAuth? auth,
  ) async {
    // Default implementation does nothing
  }

  @override
  Future<void> afterStartProcess(
    String versionId,
    MinecraftProcessInfo processInfo,
    MinecraftAuth? auth,
  ) async {
    // Default implementation does nothing
  }
}
