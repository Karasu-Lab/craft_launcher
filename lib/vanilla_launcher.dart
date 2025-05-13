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

/// Implementation of the Vanilla Minecraft launcher that handles all aspects of
/// launching the game, including downloading assets, libraries, and configuring
/// Java arguments.
class VanillaLauncher implements VanillaLauncherInterface, LauncherAdapter {
  /// Builder for constructing Java arguments for Minecraft launch.
  final JavaArgumentsBuilder _javaArgumentsBuilder;

  /// Profile information for the Minecraft account.
  final MinecraftAccountProfile? _minecraftAccountProfile;

  /// Microsoft account information for authentication.
  final MicrosoftAccount? _microsoftAccount;

  /// Minecraft authentication details.
  final MinecraftAuth? _minecraftAuth;

  /// Manager for handling launcher profiles.
  final ProfileManager _profileManager;

  /// Manager for building classpath for Minecraft.
  final ClasspathManager _classpathManager;

  /// Downloader for game assets (textures, sounds, etc.).
  final AssetDownloader assetDownloader;

  /// Manager for handling archive extraction and native libraries.
  final ArchivesManager _archivesManager;

  /// Manager for handling Minecraft process.
  final ProcessManager _processManager = ProcessManager();

  /// Callback for reporting download progress.
  final DownloadProgressCallback? _onDownloadProgress;

  /// Callback for reporting operation progress.
  final OperationProgressCallback? _onOperationProgress;

  OperationProgressCallback? get onOperationProgress => _onOperationProgress;

  /// Rate at which progress updates are reported (in percentage points).
  final int _progressReportRate;

  /// Name of the launcher.
  final String _launcherName;

  /// Version of the launcher.
  final String _launcherVersion;

  /// Callback triggered when the Java process exits.
  JavaExitCallback? onExit;

  /// Directory where game files are stored.
  String _gameDir;

  /// A getter of gameDir;
  String get gameDir => _gameDir;

  /// Directory where Java is installed.
  String _javaDir;

  /// Information about the currently running Minecraft process.
  MinecraftProcessInfo? _minecraftProcessInfo;

  /// Completer for tracking native libraries extraction completion.
  Completer<void>? _nativeLibrariesCompleter;

  /// Completer for tracking classpath building completion.
  Completer<void>? _classpathCompleter;

  /// Completer for tracking assets download completion.
  Completer<void>? _assetsCompleter;

  /// Completer for tracking libraries download completion.
  Completer<void>? _librariesCompleter;

  /// List of active completers for tracking ongoing operations.
  List<Completer<void>> _activeCompleters = [];

  /// カスタムアセットインデックスパス
  String? _customAssetIndexPath;

  /// カスタムアセットディレクトリ
  String? _customAssetsDirectory;

  /// Creates a new VanillaLauncher instance.
  ///
  /// [gameDir] - Directory where the game files are stored
  /// [javaDir] - Directory where Java is installed
  /// [profiles] - Launcher profiles configuration
  /// [activeProfile] - Currently active profile
  /// [minecraftAccountProfile] - Optional Minecraft account profile information
  /// [microsoftAccount] - Optional Microsoft account for authentication
  /// [minecraftAuth] - Optional Minecraft authentication details
  /// [onDownloadProgress] - Optional callback for download progress reporting
  /// [onOperationProgress] - Optional callback for operation progress reporting
  /// [progressReportRate] - How often to report progress (in percentage points)
  /// [launcherName] - Name of the launcher
  /// [launcherVersion] - Version of the launcher
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
    String launcherName = 'CraftLauncher',
    String launcherVersion = '1.0.0',
  }) : _gameDir = gameDir,
       _javaDir = javaDir,
       _minecraftAccountProfile = minecraftAccountProfile,
       _microsoftAccount = microsoftAccount,
       _minecraftAuth = minecraftAuth,
       _onDownloadProgress = onDownloadProgress,
       _onOperationProgress = onOperationProgress,
       _progressReportRate = progressReportRate,
       _launcherName = launcherName,
       _launcherVersion = launcherVersion,
       _javaArgumentsBuilder = JavaArgumentsBuilder(
         launcherName: launcherName,
         launcherVersion: launcherVersion,
       ),
       _classpathManager = ClasspathManager(
         gameDir: gameDir,
         onDownloadProgress: onDownloadProgress,
         onOperationProgress: onOperationProgress,
         progressReportRate: progressReportRate,
       ),
       assetDownloader = AssetDownloader(
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

  /// Get the classpath manager
  ClasspathManager get classpathManager => _classpathManager;

  /// Normalizes a file path to an absolute path.
  ///
  /// [path] - Path to normalize
  /// Returns the normalized absolute path.
  String _normalizePath(String path) {
    final normalized = p.normalize(path);
    return p.isAbsolute(normalized) ? normalized : p.absolute(normalized);
  }

  /// Ensures that a directory exists, creating it if necessary.
  ///
  /// [path] - Path to the directory
  /// Returns the directory as a Directory object.
  Future<Directory> _ensureDirectory(String path) async {
    final normalizedPath = _normalizePath(path);
    final dir = Directory(normalizedPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Downloads a file from a URL to a local path.
  ///
  /// [url] - URL to download from
  /// [filePath] - Path where the file should be saved
  /// [expectedSize] - Optional expected file size for validation
  /// [resourceName] - Optional display name for progress reporting
  /// Returns the downloaded file.
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

  /// Calculates the SHA1 hash of a file.
  ///
  /// [filePath] - Path to the file
  /// Returns the SHA1 hash as a string.
  Future<String> _calculateSha1Hash(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  /// Downloads game assets (textures, sounds, etc.).
  @override
  Future<void> downloadAssets<T extends VersionInfo>(
    T versionInfo, {
    String? inheritsFrom,
  }) async {
    _assetsCompleter = Completer<void>();
    _activeCompleters.add(_assetsCompleter!);

    try {
      final shouldSkip = await beforeDownloadAssets(versionInfo.id);
      if (shouldSkip) {
        debugPrint(
          'Skipping asset download as requested by beforeDownloadAssets',
        );
        _assetsCompleter!.complete();
        await afterDownloadAssets(versionInfo.id);
        return;
      }

      await assetDownloader.downloadAssets(
        versionInfo,
        inheritsFrom:
            inheritsFrom != null
                ? await fetchVersionManifest(inheritsFrom)
                : null,
      );
      await assetDownloader.completionFuture;

      _assetsCompleter!.complete();
      await afterDownloadAssets(versionInfo.id);
    } catch (e) {
      debugPrint('Error downloading assets: $e');
      _assetsCompleter!.completeError(
        Exception('Failed to download assets: $e'),
      );
      throw Exception('Failed to download assets: $e');
    }
  }

  /// Downloads required libraries for Minecraft.
  @override
  Future<void> downloadLibraries() async {
    _librariesCompleter = Completer<void>();
    _activeCompleters.add(_librariesCompleter!);

    try {
      final versionId = _profileManager.activeProfile.lastVersionId;
      await beforeDownloadLibraries(versionId);
      final versionInfo = await fetchVersionManifest(versionId);

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

  /// Extracts native libraries required for Minecraft.
  ///
  /// Returns the path to the extracted native libraries.
  @override
  Future<String> extractNativeLibraries() async {
    _nativeLibrariesCompleter = Completer<void>();
    _activeCompleters.add(_nativeLibrariesCompleter!);

    final versionId = _profileManager.activeProfile.lastVersionId;
    await beforeExtractNativeLibraries(versionId);
    final versionInfo = await fetchVersionManifest(versionId);

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

  /// Gets the Minecraft account profile.
  ///
  /// Returns the Minecraft account profile if available, otherwise null.
  @override
  MinecraftAccountProfile? getAccountProfile() {
    return _minecraftAccountProfile;
  }

  /// Gets the Microsoft account.
  ///
  /// Returns the Microsoft account if available, otherwise null.
  @override
  MicrosoftAccount? getMicrosoftAccount() {
    return _microsoftAccount;
  }

  /// Gets the active profile.
  ///
  /// Returns the currently active profile.
  @override
  Profile getActiveProfile() {
    return _profileManager.activeProfile;
  }

  /// Gets the asset index for a specific version.
  ///
  /// [versionId] - Minecraft version ID
  /// Returns the asset index ID.
  @override
  Future<String> getAssetIndex(String versionId) async {
    final shouldSkip = await beforeGetAssetIndex(
      versionId,
      (await getVersionInfo(versionId)) ??
          (throw Exception('VersionInfo is null for versionId: $versionId')),
    );
    if (shouldSkip) {
      debugPrint('Asset index retrieval skipped for $versionId');
      final defaultAssetIndex = versionId;
      await afterGetAssetIndex(versionId, defaultAssetIndex);
      return defaultAssetIndex;
    }

    final versionInfo = await fetchVersionManifest(versionId);

    if (versionInfo == null || versionInfo.assetIndex == null) {
      throw Exception('Failed to get asset index info for $versionId');
    }

    final assetIndexInfo = versionInfo.assetIndex;
    final assetIndexId = assetIndexInfo!.id;

    await afterGetAssetIndex(versionId, assetIndexId);

    return assetIndexId;
  }

  /// Hook called before getting asset index
  /// Returns true if the asset index retrieval should be skipped
  @override
  Future<bool> beforeGetAssetIndex<T extends VersionInfo>(
    String versionId,
    T versionInfo,
  ) async {
    // Default implementation does nothing
    return false;
  }

  /// Hook called after getting asset index
  @override
  Future<void> afterGetAssetIndex(String versionId, String assetIndex) async {
    // Default implementation does nothing
  }

  /// Gets the game directory.
  ///
  /// Returns the path to the game directory.
  @override
  String getGameDir() {
    return _gameDir;
  }

  /// Gets the Java arguments builder.
  ///
  /// Returns the current Java arguments builder.
  @override
  JavaArgumentsBuilder getJavaArgumentsBuilder() {
    return _javaArgumentsBuilder;
  }

  /// Gets the Java directory.
  ///
  /// Returns the path to the Java directory.
  @override
  String getJavaDir() {
    return _javaDir;
  }

  /// Gets the launcher profiles.
  ///
  /// Returns the launcher profiles configuration.
  @override
  LauncherProfiles getProfiles() {
    return _profileManager.profiles;
  }

  /// Fetches the version manifest for a specific Minecraft version.
  ///
  /// [versionId] - Minecraft version ID
  /// [skipPatch] - Skip patch
  /// Returns the version information if available, otherwise null.
  Future<T?> fetchVersionManifest<T extends VersionInfo>(
    String versionId, {
    bool skipPatch = false,
  }) async {
    if (!skipPatch) {
      await beforeFetchVersionManifest(versionId);
    }

    final versionJsonPath = _getVersionJsonPath(versionId);
    final versionJsonFile = File(versionJsonPath);

    if (await versionJsonFile.exists()) {
      final content = await versionJsonFile.readAsString();
      final jsonData = json.decode(content);
      return _createVersionInfoInstance<T>(jsonData);
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
            final jsonData = json.decode(content);
            return _createVersionInfoInstance<T>(jsonData);
          } catch (e) {
            debugPrint('Error downloading version JSON: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching version info: $e');
    }

    T? result;
    if (await versionJsonFile.exists()) {
      final content = await versionJsonFile.readAsString();
      final jsonData = json.decode(content);
      result = _createVersionInfoInstance<T>(jsonData);
    }

    if (!skipPatch) {
      final resultModified = await afterFetchVersionManifest<T>(
        versionId,
        result,
      );

      if (resultModified != null) {
        return resultModified;
      }
    }

    return result;
  }

  /// Builds the classpath for launching Minecraft.
  ///
  /// [versionInfo] - Version information
  /// [versionId] - Minecraft version ID
  /// Returns a list of paths to include in the classpath.
  Future<List<String>> _buildClasspath(
    VersionInfo versionInfo,
    String versionId,
  ) async {
    _classpathCompleter = Completer<void>();
    _activeCompleters.add(_classpathCompleter!);

    try {
      final classpath = await beforeBuildClasspath(versionInfo, versionId);
      classpath.addAll(
        await _classpathManager.buildClasspath(versionInfo, versionId),
      );
      _classpathCompleter!.complete();
      await afterBuildClasspath(versionInfo, versionId, classpath);
      return classpath;
    } catch (e) {
      _classpathCompleter!.completeError(e);
      rethrow;
    }
  }

  /// Hook called before building Java arguments
  @override
  Future<Arguments?> beforeBuildJavaArguments(
    String versionId,
    JavaArgumentsBuilder builder,
    VersionInfo versionInfo,
  ) async {
    // Default implementation does nothing
    return null;
  }

  /// Hook called after building Java arguments
  @override
  Future<String> afterBuildJavaArguments(
    String versionId,
    String arguments,
  ) async {
    // Default implementation just returns the original arguments
    return arguments;
  }

  /// Launches Minecraft.
  ///
  /// [onStderr] - Optional callback for stderr output
  /// [onStdout] - Optional callback for stdout output
  /// [onExit] - Optional callback for when the process exits
  @override
  Future<void> launch({
    JavaStderrCallback? onStderr,
    JavaStdoutCallback? onStdout,
    JavaExitCallback? onExit,
  }) async {
    _activeCompleters = [];

    final versionId = _profileManager.activeProfile.lastVersionId;
    final versionInfo = await fetchVersionManifest(versionId);

    if (versionInfo == null) {
      throw Exception('Failed to get version info for $versionId');
    }

    await downloadAssets(versionInfo, inheritsFrom: versionInfo.inheritsFrom);
    await downloadLibraries();

    final nativesPath = await extractNativeLibraries();
    debugPrint('Using natives directory: $nativesPath');

    final classpath = await _buildClasspath(versionInfo, versionId);

    final mainClass = versionInfo.mainClass;
    if (mainClass == null) {
      throw Exception('Main class not found in version info');
    }
    debugPrint('Main class: $mainClass');

    final assetIndexName = await getAssetIndex(versionId);
    debugPrint('Using asset index: $assetIndexName');

    _javaArgumentsBuilder
        .setGameDir(_normalizePath(_gameDir))
        .setVersion(versionInfo.id)
        .addClassPaths(classpath)
        .setNativesDir(nativesPath)
        .setClientJar(_getClientJarPath(versionId))
        .setMainClass(mainClass)
        .setAssetsIndexName(assetIndexName)
        .setLauncherName(_launcherName)
        .setLauncherVersion(_launcherVersion)
        .addGameArguments(versionInfo.arguments);

    final customAssetIndexPath = getCustomAssetIndexPath(
      versionId,
      assetIndexName,
    );
    final customAssetsDirectory = getCustomAssetsDirectory();

    if (customAssetIndexPath != null) {
      _javaArgumentsBuilder.setCustomAssetIndexPath(customAssetIndexPath);
    }

    if (customAssetsDirectory != null) {
      _javaArgumentsBuilder.setCustomAssetsDirectory(customAssetsDirectory);
    }

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

    final customArguments = await beforeBuildJavaArguments(
      versionId,
      _javaArgumentsBuilder,
      versionInfo,
    );

    if (customArguments != null) {
      debugPrint(
        'Using custom arguments provided by beforeBuildJavaArguments hook',
      );
      _javaArgumentsBuilder.addGameArguments(customArguments);
    }

    String javaArgsString = _javaArgumentsBuilder.build();

    javaArgsString = await afterBuildJavaArguments(versionId, javaArgsString);

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

  /// Sets the active profile.
  ///
  /// [profile] - Profile to set as active
  @override
  void setActiveProfile(Profile profile) {
    _profileManager.activeProfile = profile;
  }

  /// Sets the active profile by its ID.
  ///
  /// [profileId] - ID of the profile to set as active
  @override
  void setActiveProfileById(String profileId) {
    _profileManager.setActiveProfileById(profileId);
  }

  /// Sets the game directory.
  ///
  /// [gameDir] - New game directory path
  @override
  void setGameDir(String gameDir) {
    _gameDir = gameDir;
    _profileManager.gameDir = gameDir;
  }

  /// Sets the Java directory.
  ///
  /// [javaDir] - New Java directory path
  @override
  void setJavaDir(String javaDir) {
    _javaDir = javaDir;
  }

  /// Loads launcher profiles from disk.
  @override
  Future<void> loadProfiles() async {
    await _profileManager.loadProfiles();
  }

  /// Terminates the running Minecraft process.
  @override
  void terminate() {
    if (_minecraftProcessInfo != null) {
      _processManager.terminateProcess(_minecraftProcessInfo!.pid);
      _minecraftProcessInfo = null;
    }
  }

  /// Downloads the Minecraft client JAR file.
  @override
  Future<void> downloadClientJar() async {
    final versionId = _profileManager.activeProfile.lastVersionId;

    // Run before download client jar hook
    final shouldProceed = await beforeDownloadClientJar(versionId);
    if (!shouldProceed) {
      debugPrint('Client JAR download was cancelled by a hook');
      return;
    }

    final versionInfo = await fetchVersionManifest(versionId);

    if (versionInfo == null) {
      throw Exception('Failed to get version info for $versionId');
    }

    await _classpathManager.downloadClientJar(versionInfo, versionId);

    // Run after download client jar hook
    await afterDownloadClientJar(versionId);
  }

  /// Gets the path to the version directory.
  ///
  /// [versionId] - Minecraft version ID
  /// Returns the path to the version directory.
  String _getVersionDir(String versionId) {
    return _normalizePath(p.join(_gameDir, 'versions', versionId));
  }

  /// Gets the path to the version JSON file.
  ///
  /// [versionId] - Minecraft version ID
  /// Returns the path to the version JSON file.
  String _getVersionJsonPath(String versionId) {
    return _normalizePath(p.join(_getVersionDir(versionId), '$versionId.json'));
  }

  /// Gets the path to the client JAR file.
  ///
  /// [versionId] - Minecraft version ID
  /// Returns the path to the client JAR file.
  String _getClientJarPath(String versionId) {
    return _normalizePath(p.join(_getVersionDir(versionId), '$versionId.jar'));
  }

  /// Gets the path to the libraries directory.
  ///
  /// Returns the path to the libraries directory.
  String _getLibrariesDir() {
    return _normalizePath(p.join(_gameDir, 'libraries'));
  }

  /// Gets the path to the assets directory.
  ///
  /// Returns the path to the assets directory.
  String _getAssetsDir() {
    final customDir = getCustomAssetsDirectory();
    if (customDir != null) {
      return _normalizePath(customDir);
    }
    return _normalizePath(p.join(_gameDir, 'assets'));
  }

  /// Gets the path to the natives directory.
  ///
  /// [versionId] - Minecraft version ID
  /// [libraryHash] - Hash of the library for which natives are needed
  /// Returns the path to the natives directory.
  String _getNativesDir(String versionId, String libraryHash) {
    return _normalizePath(p.join(_gameDir, 'bin', libraryHash));
  }

  /// Hook called before fetching the version manifest.
  ///
  /// [versionId] - Minecraft version ID
  @override
  Future<void> beforeFetchVersionManifest(String versionId) async {
    // Default implementation does nothing
  }

  /// Hook called after fetching the version manifest.
  ///
  /// [versionId] - Minecraft version ID
  /// [versionInfo] - The fetched version information
  /// Returns modified version info or null if no modifications needed.
  @override
  Future<T?> afterFetchVersionManifest<T extends VersionInfo>(
    String versionId,
    T? versionInfo,
  ) async {
    // Default implementation does nothing
    return null;
  }

  /// Hook called before building the classpath.
  ///
  /// [versionInfo] - Version information
  /// [versionId] - Minecraft version ID
  /// Returns initial classpath entries.
  @override
  Future<List<String>> beforeBuildClasspath(
    VersionInfo versionInfo,
    String versionId,
  ) async {
    // Default implementation does nothing
    return [];
  }

  /// Hook called after building the classpath.
  ///
  /// [versionInfo] - Version information
  /// [versionId] - Minecraft version ID
  /// [classpath] - The built classpath
  @override
  Future<void> afterBuildClasspath(
    VersionInfo versionInfo,
    String versionId,
    List<String> classpath,
  ) async {
    // Default implementation does nothing
  }

  /// Hook called before extracting native libraries.
  ///
  /// [versionId] - Minecraft version ID
  @override
  Future<bool> beforeExtractNativeLibraries(String versionId) async {
    // Default implementation does nothing
    return false;
  }

  /// Hook called after extracting native libraries.
  ///
  /// [versionId] - Minecraft version ID
  /// [nativesPath] - Path to the extracted native libraries
  @override
  Future<void> afterExtractNativeLibraries(
    String versionId,
    String nativesPath,
  ) async {
    // Default implementation does nothing
  }

  /// Hook called before downloading assets.
  ///
  /// [versionId] - Minecraft version ID
  @override
  Future<bool> beforeDownloadAssets(String versionId) async {
    // Default implementation does nothing
    return false;
  }

  /// Hook called after downloading assets.
  ///
  /// [versionId] - Minecraft version ID
  @override
  Future<void> afterDownloadAssets(String versionId) async {
    // Default implementation does nothing
  }

  /// Hook called before downloading libraries.
  ///
  /// [versionId] - Minecraft version ID
  @override
  Future<bool> beforeDownloadLibraries(String versionId) async {
    // Default implementation does nothing
    return false;
  }

  /// Hook called before downloading client jar.
  ///
  /// [versionId] - Minecraft version ID
  @override
  Future<bool> beforeDownloadClientJar(String versionId) async {
    // Default implementation always allows the download to proceed
    return true;
  }

  /// Hook called after downloading libraries.
  ///
  /// [versionId] - Minecraft version ID
  @override
  Future<void> afterDownloadLibraries(String versionId) async {
    // Default implementation does nothing
  }

  /// Hook called after downloading client jar.
  ///
  /// [versionId] - Minecraft version ID
  @override
  Future<void> afterDownloadClientJar(String versionId) async {
    // Default implementation does nothing
  }

  /// Hook called before starting the Minecraft process.
  ///
  /// [javaExe] - Path to the Java executable
  /// [javaArgs] - Java arguments for launching Minecraft
  /// [workingDirectory] - Working directory for the process
  /// [environment] - Environment variables for the process
  /// [versionId] - Minecraft version ID
  /// [auth] - Authentication information
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

  /// Hook called after starting the Minecraft process.
  ///
  /// [versionId] - Minecraft version ID
  /// [processInfo] - Information about the started process
  /// [auth] - Authentication information
  @override
  Future<void> afterStartProcess(
    String versionId,
    MinecraftProcessInfo processInfo,
    MinecraftAuth? auth,
  ) async {
    // Default implementation does nothing
  }

  @override
  bool isModded() {
    return false;
  }

  /// Retrieves basic version information for a Minecraft version.
  ///
  /// [versionId] - Minecraft version ID
  /// Returns the basic version information if available, otherwise null.
  @override
  Future<T?> getVersionInfo<T extends VersionInfo>(String versionId) async {
    return await fetchVersionManifest(versionId, skipPatch: true);
  }

  /// Create a versioninfo instance
  T? _createVersionInfoInstance<T extends VersionInfo>(
    Map<String, dynamic> json,
  ) {
    try {
      final baseInstance = VersionInfo.fromJson(json);

      if (T == VersionInfo) {
        return baseInstance as T;
      }

      return VersionInfo.fromJsonGeneric<T>(json, factory: null);
    } catch (e) {
      debugPrint('Error creating version info instance of type $T: $e');
      return null;
    }
  }

  /// Get custom asset index path to override default path
  /// Return null to use the default path
  @override
  String? getCustomAssetIndexPath(String versionId, String assetIndex) {
    return _customAssetIndexPath;
  }

  /// Get custom assets directory path to override default path
  /// Return null to use the default directory
  @override
  String? getCustomAssetsDirectory() {
    return _customAssetsDirectory;
  }

  /// Set custom asset index path to override default path
  void setCustomAssetIndexPath(String? path) {
    _customAssetIndexPath = path;
  }

  /// Set custom assets directory path to override default path
  void setCustomAssetsDirectory(String? directory) {
    _customAssetsDirectory = directory;
  }
}
