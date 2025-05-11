import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/interfaces/vanilla_launcher_interface.dart';
import 'package:craft_launcher_core/java_arguments_builder.dart';
import 'package:craft_launcher_core/models/launcher_profiles.dart';
import 'package:craft_launcher_core/models/progress_callback.dart';
import 'package:flutter/material.dart';
import 'package:mcid_connect/data/auth/microsoft/microsoft_account.dart';
import 'package:mcid_connect/data/profile/minecraft_account_profile.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class VanillaLauncher implements VanillaLauncherInterface {
  final JavaArgumentsBuilder _javaArgumentsBuilder;
  String _gameDir;
  String _javaDir;
  Profile? _activeProfile;
  LauncherProfiles? _profiles;
  Process? _minecraftProcess;
  final MinecraftAccountProfile? _minecraftAccountProfile;
  final MicrosoftAccount? _microsoftAccount;
  final MinecraftAuth? _minecraftAuth;
  JavaExitCallback? onExit;

  final DownloadProgressCallback? _onDownloadProgress;
  final OperationProgressCallback? _onOperationProgress;
  final int _progressReportRate;

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
       _profiles = profiles,
       _activeProfile = activeProfile,
       _minecraftAccountProfile = minecraftAccountProfile,
       _microsoftAccount = microsoftAccount,
       _minecraftAuth = minecraftAuth,
       _onDownloadProgress = onDownloadProgress,
       _onOperationProgress = onOperationProgress,
       _progressReportRate = progressReportRate,
       _javaArgumentsBuilder = JavaArgumentsBuilder();

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

  String _getNativesDir(String versionId) {
    return _normalizePath(p.join(_gameDir, 'natives', versionId));
  }

  @override
  Future<void> downloadAssets() async {
    if (_activeProfile == null) {
      throw Exception('No active profile selected');
    }

    final versionId = _activeProfile!.lastVersionId;
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null || versionInfo.assetIndex == null) {
      throw Exception('Failed to get asset index info for $versionId');
    }

    final assetsDir = _getAssetsDir();
    final indexesDir = _normalizePath(p.join(assetsDir, 'indexes'));
    final objectsDir = _normalizePath(p.join(assetsDir, 'objects'));

    await _ensureDirectory(indexesDir);
    await _ensureDirectory(objectsDir);

    final assetIndexInfo = versionInfo.assetIndex;
    final indexId = assetIndexInfo!.id as String? ?? 'legacy';
    final indexUrl = assetIndexInfo.url;

    final indexPath = _normalizePath(p.join(indexesDir, '$indexId.json'));

    try {
      final operationName = 'Downloading assets';
      final indexFile = await _downloadFile(
        indexUrl,
        indexPath,
        resourceName: 'Asset Index ($indexId)',
      );
      final indexContent = await indexFile.readAsString();
      final indexJson = json.decode(indexContent);
      final objects = indexJson['objects'] as Map<String, dynamic>;
      final totalAssets = objects.length;

      if (_onOperationProgress != null) {
        _onOperationProgress(operationName, 0, totalAssets, 0);
      }

      int completedAssets = 0;
      int lastReportedPercentage = 0;

      for (final entry in objects.entries) {
        final assetName = entry.key;
        final object = entry.value as Map<String, dynamic>;
        final hash = object['hash'] as String;
        final hashPrefix = hash.substring(0, 2);
        final size = object['size'] as int;
        final objectPath = _normalizePath(p.join(objectsDir, hashPrefix, hash));
        final assetUrl =
            'https://resources.download.minecraft.net/$hashPrefix/$hash';

        try {
          await _downloadFile(
            assetUrl,
            objectPath,
            expectedSize: size,
            resourceName: assetName,
          );

          completedAssets++;

          // Report overall progress
          if (_onOperationProgress != null) {
            final percentage = (completedAssets / totalAssets) * 100;
            final reportPercentage =
                (percentage ~/ _progressReportRate) * _progressReportRate;

            if (reportPercentage > lastReportedPercentage) {
              lastReportedPercentage = reportPercentage;
              _onOperationProgress(
                operationName,
                completedAssets,
                totalAssets,
                max(0.0, min(percentage, 100.0)),
              );
            }
          }
        } catch (e) {
          debugPrint('Failed to download asset: $assetUrl - $e');
        }
      }

      if (_onOperationProgress != null) {
        _onOperationProgress(operationName, totalAssets, totalAssets, 100.0);
      }
    } catch (e) {
      debugPrint('Error processing asset index: $e');
      throw Exception('Failed to process asset index: $e');
    }
  }

  @override
  Future<void> downloadLibraries() async {
    if (_activeProfile == null) {
      throw Exception('No active profile selected');
    }

    final versionId = _activeProfile!.lastVersionId;
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null || versionInfo.libraries == null) {
      throw Exception('Failed to get libraries info for $versionId');
    }

    final librariesDir = _getLibrariesDir();
    await _ensureDirectory(librariesDir);

    final libraries = versionInfo.libraries!;
    final operationName = 'Downloading libraries';
    final totalLibraries = libraries.length;

    if (_onOperationProgress != null) {
      _onOperationProgress(operationName, 0, totalLibraries, 0);
    }

    int completedLibraries = 0;
    int lastReportedPercentage = 0;

    for (final library in libraries) {
      final downloads = library.downloads;
      if (downloads == null) {
        completedLibraries++;
        continue;
      }

      final artifact = downloads.artifact;
      if (artifact == null) {
        completedLibraries++;
        continue;
      }

      final path = artifact.path;
      final url = artifact.url;
      final size = artifact.size;

      if (path == null || url == null) {
        completedLibraries++;
        continue;
      }

      final libraryPath = _normalizePath(p.join(librariesDir, path));
      final libraryName = path.split('/').last;

      try {
        await _downloadFile(
          url,
          libraryPath,
          expectedSize: size,
          resourceName: libraryName,
        );
        debugPrint('Downloaded library: $path');

        completedLibraries++;

        // Report overall progress
        if (_onOperationProgress != null) {
          final percentage = (completedLibraries / totalLibraries) * 100;
          final reportPercentage =
              (percentage ~/ _progressReportRate) * _progressReportRate;

          if (reportPercentage > lastReportedPercentage) {
            lastReportedPercentage = reportPercentage;
            _onOperationProgress(
              operationName,
              completedLibraries,
              totalLibraries,
              max(0.0, min(percentage, 100.0)),
            );
          }
        }
      } catch (e) {
        debugPrint('Failed to download library: $url - $e');
        completedLibraries++;
      }
    }

    if (_onOperationProgress != null) {
      _onOperationProgress(
        operationName,
        totalLibraries,
        totalLibraries,
        100.0,
      );
    }
  }

  @override
  Future<void> extractNativeLibraries() async {
    if (_activeProfile == null) {
      throw Exception('No active profile selected');
    }

    final versionId = _activeProfile!.lastVersionId;
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null || versionInfo.libraries == null) {
      throw Exception('Failed to get libraries info for $versionId');
    }

    final libraries = versionInfo.libraries as List<dynamic>;
    final nativesDir = _getNativesDir(versionId);
    await _ensureDirectory(nativesDir);

    final librariesDir = _getLibrariesDir();

    for (final library in libraries) {
      if (library is! Library) continue;

      final downloads = library.downloads;
      if (downloads == null) continue;

      final classifiers = downloads.classifiers;
      if (classifiers == null) continue;

      String? nativeKey;
      if (Platform.isWindows) {
        if (classifiers.containsKey('natives-windows')) {
          nativeKey = 'natives-windows';
        }
      } else if (Platform.isMacOS) {
        if (classifiers.containsKey('natives-macos')) {
          nativeKey = 'natives-macos';
        } else if (classifiers.containsKey('natives-osx')) {
          nativeKey = 'natives-osx';
        }
      } else if (Platform.isLinux) {
        if (classifiers.containsKey('natives-linux')) {
          nativeKey = 'natives-linux';
        }
      }

      if (nativeKey == null) continue;

      final nativeArtifact = classifiers[nativeKey];
      if (nativeArtifact == null) continue;

      final path = nativeArtifact.path;
      if (path == null) continue;

      final nativeJar = _normalizePath(p.join(librariesDir, path));
      if (!await File(nativeJar).exists()) continue;

      try {
        final archive = await Process.run('jar', [
          'xf',
          nativeJar,
        ], workingDirectory: nativesDir);
        if (archive.exitCode != 0) {
          debugPrint(
            'Failed to extract natives from $nativeJar: ${archive.stderr}',
          );
        }
      } catch (e) {
        debugPrint('Error extracting natives: $e');
      }
    }

    final metaInfDir = p.join(nativesDir, 'META-INF');
    if (await Directory(metaInfDir).exists()) {
      await Directory(metaInfDir).delete(recursive: true);
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
    if (_activeProfile == null) {
      throw Exception('No active profile selected');
    }
    return _activeProfile!;
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
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }
    return _profiles!;
  }

  Future<VersionInfo?> _fetchVersionManifest(String versionId) async {
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

    return null;
  }

  @override
  Future<void> launch({
    JavaStderrCallback? onStderr,
    JavaStdoutCallback? onStdout,
    JavaExitCallback? onExit,
  }) async {
    if (_activeProfile == null) {
      throw Exception('No active profile selected');
    }

    await downloadAssets();
    await downloadLibraries();
    await extractNativeLibraries();

    final versionId = _activeProfile!.lastVersionId;
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null) {
      throw Exception('Failed to get version info for $versionId');
    }

    final nativesDir = _getNativesDir(versionId);
    await _ensureDirectory(nativesDir);

    debugPrint('Extracting native libraries to: $nativesDir');
    await extractNativeLibraries();

    final librariesDir = _getLibrariesDir();
    final clientJarPath = _getClientJarPath(versionId);
    final classpath = <String>[];

    if (!await File(clientJarPath).exists()) {
      debugPrint(
        'Client JAR file not found. Trying to download: $clientJarPath',
      );
      try {
        await downloadClientJar();
        if (!await File(clientJarPath).exists()) {
          throw Exception('Failed to download client JAR file: $clientJarPath');
        }
      } catch (e) {
        throw Exception('Failed to download Minecraft client files: $e');
      }
    }

    classpath.add(clientJarPath);
    debugPrint('Adding client jar to classpath: $clientJarPath');

    int missingLibraries = 0;
    final libraries = versionInfo.libraries ?? [];
    for (final library in libraries) {
      final rules = library.rules;
      if (rules != null) {
        bool allowed = false;

        for (final rule in rules) {
          final action = rule.action;
          final os = rule.os;

          bool osMatches = true;
          if (os != null) {
            final osName = os.name;
            if (osName != null) {
              if (Platform.isWindows && osName != 'windows') osMatches = false;
              if (Platform.isMacOS && osName != 'osx') osMatches = false;
              if (Platform.isLinux && osName != 'linux') osMatches = false;
            }
          }

          if (osMatches) {
            allowed = action == 'allow';
          }
        }

        if (!allowed) continue;
      }

      final downloads = library.downloads;
      if (downloads == null) continue;

      final artifact = downloads.artifact;
      if (artifact == null) continue;

      final path = artifact.path;
      if (path == null) continue;
      final libraryPath = _normalizePath(p.join(librariesDir, path));

      bool fileExists = await File(libraryPath).exists();
      if (fileExists) {
        classpath.add(libraryPath);
        debugPrint('Added library to classpath: $libraryPath');
      } else {
        missingLibraries++;
        debugPrint('Library not found: $libraryPath');
        try {
          await downloadLibraries();
          if (await File(libraryPath).exists()) {
            classpath.add(libraryPath);
            debugPrint(
              'Downloaded and added library to classpath: $libraryPath',
            );
          } else {
            debugPrint(
              'Library still not found after download attempt: $libraryPath',
            );
          }
        } catch (e) {
          debugPrint('Failed to download library: $e');
        }
      }
    }

    if (missingLibraries > 0) {
      debugPrint('Warning: $missingLibraries library files not found');
    }
    final mainClass = versionInfo.mainClass;
    if (mainClass == null) {
      throw Exception('Main class not found in version info');
    }
    debugPrint('Main class: $mainClass');
    debugPrint('Number of JAR files in classpath: ${classpath.length}');

    // Build Java arguments using JavaArgumentsBuilder
    _javaArgumentsBuilder
        .setGameDir(_normalizePath(_gameDir))
        .setVersion(versionInfo.id)
        .addClassPaths(classpath)
        .setNativesDir(nativesDir)
        .setClientJar(clientJarPath)
        .setMainClass(mainClass)
        .setAssetsIndexName(versionInfo.assetIndex?.id ?? versionInfo.id)
        .addGameArguments(versionInfo.arguments);

    // Set authentication information
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

    // Add Java arguments from profile
    if (_activeProfile!.javaArgs != null &&
        _activeProfile!.javaArgs!.isNotEmpty) {
      _javaArgumentsBuilder.addAdditionalArguments(_activeProfile!.javaArgs);
    }

    // Get built arguments
    final javaArgsString = _javaArgumentsBuilder.build();
    final javaArgs = javaArgsString.split(' ');

    final javaExe = _normalizePath(
      p.join(_javaDir, 'bin', Platform.isWindows ? 'javaw.exe' : 'java'),
    );
    debugPrint('Java executable: $javaExe');
    debugPrint('Java arguments:');
    debugPrint(javaArgs.join(' '));

    try {
      _minecraftProcess = await Process.start(
        javaExe,
        javaArgs,
        workingDirectory: _normalizePath(_gameDir),
      );

      if (onStdout != null) {
        _minecraftProcess!.stdout.listen((data) {
          final output = utf8.decode(data);
          debugPrint('Minecraft stdout: $output');
          onStdout(output);
        });
      } else {
        _minecraftProcess!.stdout.listen((data) {
          debugPrint('Minecraft stdout: ${utf8.decode(data)}');
        });
      }

      if (onStderr != null) {
        _minecraftProcess!.stderr.listen((data) {
          final output = utf8.decode(data);
          debugPrint('Minecraft stderr: $output');
          onStderr(output);
        });
      } else {
        _minecraftProcess!.stderr.listen((data) {
          debugPrint('Minecraft stderr: ${utf8.decode(data)}');
        });
      }

      _minecraftProcess!.exitCode.then((exitCode) {
        debugPrint('Minecraft process exited with code: $exitCode');
        if (onExit != null) {
          onExit(exitCode);
        }

        if (this.onExit != null) {
          this.onExit!(exitCode);
        }
      });

      debugPrint(
        'Minecraft process started with PID: ${_minecraftProcess!.pid}',
      );
    } catch (e) {
      debugPrint('Error launching Minecraft: $e');
      throw Exception('Failed to launch Minecraft: $e');
    }
  }

  @override
  void setActiveProfile(Profile profile) {
    _activeProfile = profile;
  }

  @override
  void setActiveProfileById(String profileId) {
    final profiles = _profiles?.profiles;
    if (profiles != null && profiles.containsKey(profileId)) {
      _activeProfile = profiles[profileId];
    }
  }

  @override
  void setGameDir(String gameDir) {
    _gameDir = gameDir;
  }

  @override
  void setJavaDir(String javaDir) {
    _javaDir = javaDir;
  }

  @override
  Future<void> loadProfiles() async {
    final launcherProfilesPath = p.join(_gameDir, 'launcher_profiles.json');
    final file = File(launcherProfilesPath);

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        _profiles = LauncherProfiles.fromJson(json);
      } catch (e) {
        debugPrint('Error loading launcher profiles: $e');
        throw Exception('Failed to load launcher profiles: $e');
      }
    } else {
      throw Exception('Launcher profiles file not found');
    }
  }

  @override
  void terminate() {
    if (_minecraftProcess != null) {
      _minecraftProcess!.kill();
    }
  }

  @override
  Future<void> downloadClientJar() async {
    if (_activeProfile == null) {
      throw Exception('No active profile selected');
    }

    final versionId = _activeProfile!.lastVersionId;
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null || versionInfo.downloads == null) {
      throw Exception('Failed to get downloads info for $versionId');
    }

    final downloads = versionInfo.downloads;
    final client = downloads!.client;

    if (client == null) {
      throw Exception('Client download info not found for $versionId');
    }

    final url = client.url as String?;
    final size = client.size;

    if (url == null) {
      throw Exception('Client download URL not found for $versionId');
    }

    final clientJarPath = _getClientJarPath(versionId);
    final operationName = 'Downloading Minecraft client';

    if (_onOperationProgress != null) {
      _onOperationProgress(operationName, 0, 1, 0);
    }

    try {
      await _downloadFile(
        url,
        clientJarPath,
        expectedSize: size,
        resourceName: 'Minecraft Client ($versionId)',
      );
      debugPrint('Downloaded client jar: $clientJarPath');

      if (_onOperationProgress != null) {
        _onOperationProgress(operationName, 1, 1, 100.0);
      }
    } catch (e) {
      debugPrint('Error downloading client jar: $e');
      throw Exception('Failed to download client jar: $e');
    }
  }
}
