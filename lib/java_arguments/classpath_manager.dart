import 'dart:io';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/downloaders/library_downloader.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// クラスパスの管理と構築を行うクラス
class ClasspathManager {
  final String _gameDir;
  final String _librariesDir;
  final DownloadProgressCallback? _onDownloadProgress;
  final OperationProgressCallback? _onOperationProgress;
  final int _progressReportRate;

  ClasspathManager({
    required String gameDir,
    DownloadProgressCallback? onDownloadProgress,
    OperationProgressCallback? onOperationProgress,
    int progressReportRate = 10,
  }) : _gameDir = gameDir,
       _librariesDir = p.join(gameDir, 'libraries'),
       _onDownloadProgress = onDownloadProgress,
       _onOperationProgress = onOperationProgress,
       _progressReportRate = progressReportRate;

  String _normalizePath(String path) {
    final normalized = p.normalize(path);
    return p.isAbsolute(normalized) ? normalized : p.absolute(normalized);
  }

  String getClientJarPath(String versionId) {
    return _normalizePath(p.join(_gameDir, 'versions', versionId, '$versionId.jar'));
  }

  /// 指定されたバージョン情報とバージョンIDに基づいてクラスパスを構築する
  Future<List<String>> buildClasspath(
    VersionInfo versionInfo,
    String versionId,
  ) async {
    final clientJarPath = getClientJarPath(versionId);
    final classpath = <String>[];

    if (!await File(clientJarPath).exists()) {
      debugPrint(
        'Client JAR file not found. Trying to download: $clientJarPath',
      );
      try {
        await downloadClientJar(versionInfo, versionId);
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
      final libraryPath = _normalizePath(p.join(_librariesDir, path));

      bool fileExists = await File(libraryPath).exists();
      if (fileExists) {
        classpath.add(libraryPath);
        debugPrint('Added library to classpath: $libraryPath');
      } else {
        missingLibraries++;
        debugPrint('Library not found: $libraryPath');
        try {
          await downloadLibraries(versionInfo);
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
    return classpath;
  }

  /// クライアントJARファイルをダウンロードする
  Future<void> downloadClientJar(VersionInfo versionInfo, String versionId) async {
    try {
      final libraryDownloader = LibraryDownloader(
        gameDir: _gameDir,
        onDownloadProgress: _onDownloadProgress,
        onOperationProgress: _onOperationProgress,
        progressReportRate: _progressReportRate,
      );

      await libraryDownloader.downloadClientJar(versionInfo, versionId);
      debugPrint('Downloaded client jar for $versionId');
    } catch (e) {
      debugPrint('Error downloading client jar: $e');
      throw Exception('Failed to download client jar: $e');
    }
  }

  /// ライブラリをダウンロードする
  Future<void> downloadLibraries(VersionInfo versionInfo) async {
    try {
      final libraryDownloader = LibraryDownloader(
        gameDir: _gameDir,
        onDownloadProgress: _onDownloadProgress,
        onOperationProgress: _onOperationProgress,
        progressReportRate: _progressReportRate,
      );

      await libraryDownloader.downloadLibraries(versionInfo);
      await libraryDownloader.completionFuture;
    } catch (e) {
      debugPrint('Error downloading libraries: $e');
      throw Exception('Failed to download libraries: $e');
    }
  }
}
