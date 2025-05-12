import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Abstract base class for downloading Minecraft game assets and libraries.
///
/// Provides common functionality for downloading files, managing directories,
/// and reporting progress during download operations.
abstract class AbstractDownloader {
  /// Root directory for storing game files.
  ///
  /// [_gameDir]
  /// The base directory where all game files will be stored.
  final String _gameDir;

  /// Callback for reporting download progress of individual files.
  ///
  /// [_onDownloadProgress]
  /// Optional callback that receives progress updates during file downloads.
  final DownloadProgressCallback? _onDownloadProgress;

  /// Callback for reporting progress of batch operations.
  ///
  /// [_onOperationProgress]
  /// Optional callback that receives progress updates for overall operations.
  final OperationProgressCallback? _onOperationProgress;

  /// Rate at which to report download progress.
  ///
  /// [_progressReportRate]
  /// Controls how frequently progress updates are sent, in percentage points.
  final int _progressReportRate;

  /// Creates a new downloader instance.
  ///
  /// [gameDir]
  /// The base directory where all game files will be stored.
  ///
  /// [onDownloadProgress]
  /// Optional callback for reporting file download progress.
  ///
  /// [onOperationProgress]
  /// Optional callback for reporting batch operation progress.
  ///
  /// [progressReportRate]
  /// How often to report progress, defaults to every 10%.
  AbstractDownloader({
    required String gameDir,
    DownloadProgressCallback? onDownloadProgress,
    OperationProgressCallback? onOperationProgress,
    int progressReportRate = 10,
  }) : _gameDir = gameDir,
       _onDownloadProgress = onDownloadProgress,
       _onOperationProgress = onOperationProgress,
       _progressReportRate = progressReportRate;

  /// Normalizes a file path to an absolute path with correct separators.
  ///
  /// Handles converting relative paths to absolute paths and normalizes
  /// the path format according to the current platform.
  ///
  /// [path]
  /// The path to normalize.
  ///
  /// Returns the normalized absolute path.
  String normalizePath(String path) {
    final normalized = p.normalize(path);
    return p.isAbsolute(normalized) ? normalized : p.absolute(normalized);
  }

  /// Ensures a directory exists, creating it if necessary.
  ///
  /// [path]
  /// The path to the directory that should exist.
  ///
  /// Returns a Directory object for the ensured directory.
  Future<Directory> ensureDirectory(String path) async {
    final normalizedPath = normalizePath(path);
    final dir = Directory(normalizedPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Reports progress of a batch operation.
  ///
  /// Calls the operation progress callback if one is set.
  ///
  /// [operationName]
  /// The name of the operation in progress.
  ///
  /// [completed]
  /// Number of items completed.
  ///
  /// [total]
  /// Total number of items to process.
  ///
  /// [percentage]
  /// Percentage completion from 0 to 100.
  void reportOperationProgress(
    String operationName,
    int completed,
    int total,
    double percentage,
  ) {
    if (_onOperationProgress != null) {
      _onOperationProgress(operationName, completed, total, percentage);
    }
  }

  /// Downloads a file from a URL to a specified path.
  ///
  /// If the file already exists and matches the expected size, download is skipped.
  /// Progress is reported via the download progress callback if one is set.
  ///
  /// [url]
  /// The URL to download the file from.
  ///
  /// [filePath]
  /// The local path where the file should be saved.
  ///
  /// [expectedSize]
  /// Optional expected file size for validation.
  ///
  /// [resourceName]
  /// Optional display name for the resource being downloaded.
  ///
  /// Returns the downloaded File object.
  Future<File> downloadFile(
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

    await ensureDirectory(p.dirname(filePath));

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

  /// Gets the base game directory.
  ///
  /// Returns the path to the game directory.
  String getGameDir() {
    return _gameDir;
  }

  /// Gets the directory for storing game libraries.
  ///
  /// Returns the normalized path to the libraries directory.
  String getLibrariesDir() {
    return normalizePath(p.join(_gameDir, 'libraries'));
  }

  /// Gets the directory for storing game assets.
  ///
  /// Returns the normalized path to the assets directory.
  String getAssetsDir() {
    return normalizePath(p.join(_gameDir, 'assets'));
  }
}
