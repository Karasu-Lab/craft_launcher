import 'dart:async';
import 'dart:math';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/downloaders/abstract_downloader.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class LibraryDownloader extends AbstractDownloader {
  final Completer<void> _librariesCompleter = Completer<void>();

  final DownloadProgressCallback? onDownloadProgress;
  final OperationProgressCallback? onOperationProgress;
  final int progressReportRate;

  LibraryDownloader({
    required super.gameDir,
    super.onDownloadProgress,
    super.onOperationProgress,
    super.progressReportRate,
  }) : onDownloadProgress = null,
       onOperationProgress = null,
       progressReportRate = 10;

  /// ライブラリのダウンロードを実行する
  Future<void> downloadLibraries(VersionInfo versionInfo) async {
    if (versionInfo.libraries == null) {
      throw Exception('Failed to get libraries info');
    }

    final librariesDir = getLibrariesDir();
    await ensureDirectory(librariesDir);

    final libraries = versionInfo.libraries!;
    final operationName = 'Downloading libraries';
    final totalLibraries = libraries.length;

    if (onOperationProgress != null) {
      onOperationProgress!(operationName, 0, totalLibraries, 0);
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

      final libraryPath = normalizePath(p.join(librariesDir, path));
      final libraryName = path.split('/').last;

      try {
        await downloadFile(
          url,
          libraryPath,
          expectedSize: size,
          resourceName: libraryName,
        );
        debugPrint('Downloaded library: $path');

        completedLibraries++;

        // Report overall progress
        if (onOperationProgress != null) {
          final percentage = (completedLibraries / totalLibraries) * 100;
          final reportPercentage =
              (percentage ~/ progressReportRate) * progressReportRate;

          if (reportPercentage > lastReportedPercentage) {
            lastReportedPercentage = reportPercentage;
            onOperationProgress!(
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

    if (onOperationProgress != null) {
      onOperationProgress!(
        operationName,
        totalLibraries,
        totalLibraries,
        100.0,
      );
    }

    _librariesCompleter.complete();
  }

  /// クライアントJARをダウンロードする
  Future<void> downloadClientJar(
    VersionInfo versionInfo,
    String versionId,
  ) async {
    if (versionInfo.downloads == null) {
      throw Exception('Failed to get downloads info');
    }

    final downloads = versionInfo.downloads;
    final client = downloads!.client;

    if (client == null) {
      throw Exception('Client download info not found');
    }

    final url = client.url as String?;
    final size = client.size;

    if (url == null) {
      throw Exception('Client download URL not found');
    }

    final clientJarPath = getClientJarPath(versionId);
    final operationName = 'Downloading Minecraft client';

    if (onOperationProgress != null) {
      onOperationProgress!(operationName, 0, 1, 0);
    }

    try {
      await downloadFile(
        url,
        clientJarPath,
        expectedSize: size,
        resourceName: 'Minecraft Client ($versionId)',
      );
      debugPrint('Downloaded client jar: $clientJarPath');

      if (onOperationProgress != null) {
        onOperationProgress!(operationName, 1, 1, 100.0);
      }
    } catch (e) {
      debugPrint('Error downloading client jar: $e');
      throw Exception('Failed to download client jar: $e');
    }
  }

  /// クライアントJARのパスを取得する
  String getClientJarPath(String versionId) {
    return normalizePath(p.join(getVersionDir(versionId), '$versionId.jar'));
  }

  /// バージョンディレクトリのパスを取得する
  String getVersionDir(String versionId) {
    return normalizePath(p.join(getGameDir(), 'versions', versionId));
  }

  /// ライブラリのダウンロード完了を待機する
  Future<void> get completionFuture => _librariesCompleter.future;
}
