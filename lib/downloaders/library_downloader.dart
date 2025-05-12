import 'dart:async';
import 'dart:math';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/downloaders/abstract_downloader.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// Handles downloading of Minecraft library files.
///
/// Downloads and manages Java libraries required for Minecraft to run,
/// including the client JAR file itself.
class LibraryDownloader extends AbstractDownloader {
  /// Completer that tracks the overall library download operation completion.
  ///
  /// [_librariesCompleter]
  /// Completes when all libraries have been downloaded successfully.
  final Completer<void> _librariesCompleter = Completer<void>();

  /// Callback for reporting download progress of individual files.
  ///
  /// [onDownloadProgress]
  /// Optional callback that receives progress updates during library downloads.
  final DownloadProgressCallback? onDownloadProgress;

  /// Callback for reporting progress of the overall libraries download operation.
  ///
  /// [onOperationProgress]
  /// Optional callback that receives progress updates for the libraries download operation.
  final OperationProgressCallback? onOperationProgress;

  /// Rate at which to report download progress.
  ///
  /// [progressReportRate]
  /// Controls how frequently progress updates are sent, in percentage points.
  final int progressReportRate;

  /// Creates a new library downloader.
  ///
  /// [gameDir]
  /// The base game directory where libraries will be stored.
  ///
  /// [onDownloadProgress]
  /// Optional callback for reporting individual file download progress.
  ///
  /// [onOperationProgress]
  /// Optional callback for reporting overall operation progress.
  ///
  /// [progressReportRate]
  /// How often to report progress, defaults to every 10%.
  LibraryDownloader({
    required super.gameDir,
    super.onDownloadProgress,
    super.onOperationProgress,
    super.progressReportRate,
  }) : onDownloadProgress = null,
       onOperationProgress = null,
       progressReportRate = 10;

  /// Downloads all libraries required for the specified Minecraft version.
  ///
  /// Iterates through the version's library list and downloads each one,
  /// reporting progress via callbacks.
  ///
  /// [versionInfo]
  /// Information about the Minecraft version whose libraries should be downloaded.
  ///
  /// Throws an exception if the library information is missing.
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

  /// Downloads the main Minecraft client JAR file.
  ///
  /// This is the core game executable that requires the supporting libraries.
  ///
  /// [versionInfo]
  /// Information about the Minecraft version to download.
  ///
  /// [versionId]
  /// The version identifier string.
  ///
  /// Throws an exception if the client download information is missing or
  /// if the download fails.
  Future<void> downloadClientJar(
    VersionInfo versionInfo,
    String versionId,
  ) async {
    if (versionInfo.downloads == null) {
      debugPrint('Client jar downloads not found. Skipping it.');
      return;
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

  /// Gets the path where the Minecraft client JAR file should be stored.
  ///
  /// [versionId]
  /// The version identifier string.
  ///
  /// Returns the normalized absolute path to the client JAR file.
  String getClientJarPath(String versionId) {
    return normalizePath(p.join(getVersionDir(versionId), '$versionId.jar'));
  }

  /// Gets the directory where version-specific files should be stored.
  ///
  /// [versionId]
  /// The version identifier string.
  ///
  /// Returns the normalized absolute path to the version directory.
  String getVersionDir(String versionId) {
    return normalizePath(p.join(getGameDir(), 'versions', versionId));
  }

  /// Returns a future that completes when all libraries have been downloaded.
  ///
  /// Can be used to wait for the library download operation to complete or to
  /// catch any errors that occurred during the download process.
  ///
  /// Returns a future that completes when the download operation is finished.
  Future<void> get completionFuture => _librariesCompleter.future;
}
