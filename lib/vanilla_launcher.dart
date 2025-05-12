import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/interfaces/vanilla_launcher_interface.dart';
import 'package:craft_launcher_core/java_arguments_builder.dart';
import 'package:craft_launcher_core/models/launcher_profiles.dart';
import 'package:flutter/material.dart';
import 'package:mcid_connect/data/auth/microsoft/microsoft_account.dart';
import 'package:mcid_connect/data/profile/minecraft_account_profile.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

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

  String _getNativesDir(String versionId, String libraryHash) {
    return _normalizePath(p.join(_gameDir, 'bin', libraryHash));
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

      _assetsCompleter!.complete();
    } catch (e) {
      debugPrint('Error processing asset index: $e');
      _assetsCompleter!.completeError(
        Exception('Failed to process asset index: $e'),
      );
      throw Exception('Failed to process asset index: $e');
    }
  }

  @override
  Future<void> downloadLibraries() async {
    _librariesCompleter = Completer<void>();
    _activeCompleters.add(_librariesCompleter!);

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

    _librariesCompleter!.complete();
  }

  @override
  Future<String> extractNativeLibraries() async {
    _nativeLibrariesCompleter = Completer<void>();
    _activeCompleters.add(_nativeLibrariesCompleter!);

    if (_activeProfile == null) {
      throw Exception('No active profile selected');
    }

    final versionId = _activeProfile!.lastVersionId;
    final versionInfo = await _fetchVersionManifest(versionId);
    String resultNativesDir = '';

    if (versionInfo == null || versionInfo.libraries == null) {
      throw Exception('Failed to get libraries info for $versionId');
    }

    final libraries = versionInfo.libraries!;
    final operationName = 'Extracting native libraries';
    List<String> nativeExtensions = [];
    if (Platform.isWindows) {
      nativeExtensions = ['.dll', '.dll.x86', '.dll.x64'];
    } else if (Platform.isMacOS) {
      nativeExtensions = ['.dylib', '.jnilib', '.so'];
    } else if (Platform.isLinux) {
      nativeExtensions = ['.so'];
    }

    int totalLibraries = 0;
    List<Library> nativeLibraries = [];

    // すべてのネイティブライブラリを取得
    for (final library in libraries) {
      final downloads = library.downloads;
      if (downloads == null) continue;

      final classifiers = downloads.classifiers;
      if (classifiers == null) continue;

      String? nativeKey;
      if (Platform.isWindows) {
        nativeKey = 'natives-windows';
      } else if (Platform.isMacOS) {
        nativeKey =
            classifiers.containsKey('natives-macos')
                ? 'natives-macos'
                : 'natives-osx';
      } else if (Platform.isLinux) {
        nativeKey = 'natives-linux';
      }

      if (nativeKey != null && classifiers.containsKey(nativeKey)) {
        nativeLibraries.add(library);
        totalLibraries++;
      }
    }

    if (_onOperationProgress != null) {
      _onOperationProgress(operationName, 0, totalLibraries, 0);
    }

    // 一時作業ディレクトリを作成
    final tempDir = await Directory.systemTemp.createTemp('mc_natives_');
    try {
      // 抽出されたネイティブファイルを保持
      List<File> allExtractedNativeFiles = [];
      int processedLibraries = 0;
      int lastReportedPercentage = 0;

      // 各ネイティブライブラリを処理
      for (final library in nativeLibraries) {
        final downloads = library.downloads!;
        final classifiers = downloads.classifiers!;

        String? nativeKey;
        if (Platform.isWindows) {
          nativeKey = 'natives-windows';
        } else if (Platform.isMacOS) {
          nativeKey =
              classifiers.containsKey('natives-macos')
                  ? 'natives-macos'
                  : 'natives-osx';
        } else if (Platform.isLinux) {
          nativeKey = 'natives-linux';
        }

        final nativeArtifact = classifiers[nativeKey];
        if (nativeArtifact == null) continue;

        final path = nativeArtifact.path;
        if (path == null) continue;

        final librariesDir = _getLibrariesDir();
        final nativeJar = _normalizePath(p.join(librariesDir, path));

        // JARファイルが存在しない場合はダウンロード
        if (!await File(nativeJar).exists()) {
          debugPrint(
            'Native JAR file not found, attempting to download: $nativeJar',
          );
          try {
            await downloadLibraries();
          } catch (e) {
            debugPrint('Error downloading libraries: $e');
          }

          // ダウンロード後も存在しない場合はURLから直接ダウンロード試行
          if (!await File(nativeJar).exists() && nativeArtifact.url != null) {
            debugPrint(
              'Attempting direct download of native library: ${nativeArtifact.url}',
            );
            try {
              await _downloadFile(
                nativeArtifact.url!,
                nativeJar,
                expectedSize: nativeArtifact.size,
                resourceName: p.basename(nativeJar),
              );
            } catch (e) {
              debugPrint('Direct download failed: $e');
            }
          }

          // それでも存在しない場合はスキップ
          if (!await File(nativeJar).exists()) {
            debugPrint('Failed to download native library, skipping: $path');
            processedLibraries++;
            continue;
          }
        }

        try {
          // JARファイルを読み込み
          final nativeJarFile = File(nativeJar);
          final jarBytes = await nativeJarFile.readAsBytes();
          final archive = ZipDecoder().decodeBytes(jarBytes);

          // プラットフォームに適したネイティブライブラリを抽出して一時フォルダに保存
          for (final file in archive) {
            if (file.isFile) {
              final fileName = p.basename(file.name);
              final fileExt = p.extension(fileName).toLowerCase();

              // 環境に適したファイルかチェック
              bool isValidForPlatform = false;
              if (Platform.isWindows) {
                isValidForPlatform = nativeExtensions.any(
                  (ext) => fileName.toLowerCase().endsWith(ext),
                );
              } else if (Platform.isMacOS) {
                isValidForPlatform = nativeExtensions.contains(fileExt);
              } else if (Platform.isLinux) {
                isValidForPlatform = fileExt == '.so';
              }

              if (isValidForPlatform) {
                final tempFilePath = p.join(
                  tempDir.path,
                  'extracted',
                  fileName,
                );
                final tempFileDir = Directory(p.dirname(tempFilePath));
                if (!await tempFileDir.exists()) {
                  await tempFileDir.create(recursive: true);
                }

                // ファイルの内容を一時ファイルに書き込む
                final data = file.content;
                final tempFile = await File(
                  tempFilePath,
                ).create(recursive: true);
                await tempFile.writeAsBytes(Uint8List.fromList(data));
                allExtractedNativeFiles.add(tempFile);
                debugPrint('Extracted native library: $fileName');
              }
            }
          }

          processedLibraries++;

          // 進捗状況の報告
          if (_onOperationProgress != null && totalLibraries > 0) {
            final percentage = (processedLibraries / totalLibraries) * 100;
            final reportPercentage =
                (percentage ~/ _progressReportRate) * _progressReportRate;

            if (reportPercentage > lastReportedPercentage) {
              lastReportedPercentage = reportPercentage;
              _onOperationProgress(
                operationName,
                processedLibraries,
                totalLibraries,
                max(0.0, min(percentage, 100.0)),
              );
            }
          }
        } catch (e) {
          debugPrint('Error extracting natives from $nativeJar: $e');
          processedLibraries++;
        }
      }

      // 全てのネイティブライブラリをZIPにまとめる
      if (allExtractedNativeFiles.isNotEmpty) {
        final collectionZipPath = p.join(
          tempDir.path,
          'natives_collection.zip',
        );
        final collectionZipEncoder = ZipFileEncoder();

        try {
          collectionZipEncoder.create(collectionZipPath);

          for (final file in allExtractedNativeFiles) {
            final fileName = p.basename(file.path);
            collectionZipEncoder.addFile(file, fileName);
            debugPrint('Added to collection ZIP: $fileName');
          }

          collectionZipEncoder.close();

          // ZIPファイルのハッシュを計算
          final zipHash = await _calculateSha1Hash(collectionZipPath);
          resultNativesDir = _getNativesDir(versionId, zipHash);

          // 既に同じハッシュのディレクトリがある場合は再利用
          if (await Directory(resultNativesDir).exists()) {
            debugPrint('Using existing natives directory with hash: $zipHash');
          } else {
            // 新しいディレクトリを作成して展開
            await _ensureDirectory(resultNativesDir);

            // 抽出したファイルを最終的な場所にコピー
            for (final file in allExtractedNativeFiles) {
              final fileName = p.basename(file.path);
              final targetPath = p.join(resultNativesDir, fileName);

              try {
                await file.copy(targetPath);
              } catch (e) {
                debugPrint('Failed to copy native library $fileName: $e');
                if (await File(targetPath).exists()) {
                  await File(targetPath).delete();
                  await file.copy(targetPath);
                }
              }
            }

            debugPrint('Created new natives directory: $resultNativesDir');
          }

          // 結果の検証
          final extractedFiles =
              await Directory(resultNativesDir).list().toList();
          debugPrint('Final native libraries count: ${extractedFiles.length}');
        } catch (e) {
          debugPrint('Error creating natives collection: $e');
        }
      }

      // ネイティブライブラリディレクトリが作成されなかった場合のフォールバック
      if (resultNativesDir.isEmpty) {
        debugPrint('No natives directory created, using default');
        resultNativesDir = _getNativesDir(versionId, 'default');
        await _ensureDirectory(resultNativesDir);
      }
    } finally {
      // 一時ディレクトリを削除
      try {
        await tempDir.delete(recursive: true);
        debugPrint('Temporary directory cleaned up');
      } catch (e) {
        debugPrint('Failed to clean up temporary directory: $e');
      }
    }

    // META-INFディレクトリを削除（必要な場合）
    final metaInfDir = p.join(resultNativesDir, 'META-INF');
    if (await Directory(metaInfDir).exists()) {
      try {
        await Directory(metaInfDir).delete(recursive: true);
        debugPrint('Removed META-INF directory from natives folder');
      } catch (e) {
        debugPrint('Failed to remove META-INF directory: $e');
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

    _nativeLibrariesCompleter!.complete();
    return resultNativesDir;
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

  Future<List<String>> _buildClasspath(
    VersionInfo versionInfo,
    String versionId,
  ) async {
    _classpathCompleter = Completer<void>();
    _activeCompleters.add(_classpathCompleter!);

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

    debugPrint('Number of JAR files in classpath: ${classpath.length}');
    _classpathCompleter!.complete();

    return classpath;
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

    _activeCompleters = [];

    await downloadAssets();
    await downloadLibraries();

    final versionId = _activeProfile!.lastVersionId;
    final versionInfo = await _fetchVersionManifest(versionId);

    if (versionInfo == null) {
      throw Exception('Failed to get version info for $versionId');
    }

    // ネイティブライブラリを展開し、使用するディレクトリパスを取得
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

    if (_activeProfile!.javaArgs != null &&
        _activeProfile!.javaArgs!.isNotEmpty) {
      _javaArgumentsBuilder.addAdditionalArguments(_activeProfile!.javaArgs);
    }

    final javaArgsString = _javaArgumentsBuilder.build();
    final javaArgs = javaArgsString.split(' ');

    final javaExe = _normalizePath(
      p.join(_javaDir, 'bin', Platform.isWindows ? 'javaw.exe' : 'java'),
    );
    debugPrint('Java executable: $javaExe');
    debugPrint('Java arguments:');
    debugPrint(javaArgs.join(' '));

    try {
      for (final completer in _activeCompleters) {
        await completer.future;
      }

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
