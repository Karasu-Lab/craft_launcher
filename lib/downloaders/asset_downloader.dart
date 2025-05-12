import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/downloaders/abstract_downloader.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// Handles downloading of Minecraft game assets.
///
/// Downloads and manages game assets such as textures, sounds, and other resources
/// required for Minecraft to run properly.
class AssetDownloader extends AbstractDownloader {
  /// Completer that tracks the overall asset download operation completion.
  ///
  /// [_assetsCompleter]
  /// Completes when all assets have been downloaded successfully.
  final Completer<void> _assetsCompleter = Completer<void>();

  /// Callback for reporting download progress of individual files.
  ///
  /// [_onDownloadProgress]
  /// Optional callback that receives progress updates during asset downloads.
  final DownloadProgressCallback? _onDownloadProgress;

  /// Callback for reporting progress of the overall assets download operation.
  ///
  /// [_onOperationProgress]
  /// Optional callback that receives progress updates for the assets download operation.
  final OperationProgressCallback? _onOperationProgress;

  /// Rate at which to report download progress.
  ///
  /// [_progressReportRate]
  /// Controls how frequently progress updates are sent, in percentage points.
  final int _progressReportRate;

  /// Creates a new asset downloader.
  ///
  /// [gameDir]
  /// The base game directory where assets will be stored.
  ///
  /// [onDownloadProgress]
  /// Optional callback for reporting individual file download progress.
  ///
  /// [onOperationProgress]
  /// Optional callback for reporting overall operation progress.
  ///
  /// [progressReportRate]
  /// How often to report progress, defaults to every 10%.
  AssetDownloader({
    required super.gameDir,
    DownloadProgressCallback? onDownloadProgress,
    OperationProgressCallback? onOperationProgress,
    int progressReportRate = 10,
  }) : _onDownloadProgress = onDownloadProgress,
       _onOperationProgress = onOperationProgress,
       _progressReportRate = progressReportRate;

  /// Downloads all assets required for the specified Minecraft version.
  ///
  /// First downloads the asset index file, then iterates through all assets
  /// listed in the index and downloads them. Progress is reported via callbacks.
  ///
  /// [versionInfo]
  /// Information about the Minecraft version whose assets should be downloaded.
  ///
  /// [versionId]
  /// Optional ID of the version to download. If not provided, uses the ID from versionInfo.
  ///
  /// Throws an exception if the asset index is missing or if any part of the
  /// download process fails.
  Future<void> downloadAssets(
    VersionInfo versionInfo, {
    String? versionId,
  }) async {
    if (versionInfo.assetIndex == null) {
      throw Exception('Failed to get asset index info');
    }

    final assetsDir = getAssetsDir();
    final indexesDir = normalizePath(p.join(assetsDir, 'indexes'));
    final objectsDir = normalizePath(p.join(assetsDir, 'objects'));

    await ensureDirectory(indexesDir);
    await ensureDirectory(objectsDir);

    final assetIndexInfo = versionInfo.assetIndex;
    final indexId = versionId ?? assetIndexInfo!.id as String? ?? 'legacy';
    final indexUrl = assetIndexInfo!.url;

    final indexPath = normalizePath(p.join(indexesDir, '$indexId.json'));

    try {
      final operationName = 'Downloading assets';
      final indexFile = await downloadFile(
        indexUrl,
        indexPath,
        resourceName: 'Asset Index ($indexId)',
      );
      final indexContent = await indexFile.readAsString();
      final indexJson = json.decode(indexContent);
      final objects = indexJson['objects'] as Map<String, dynamic>;
      final totalAssets = objects.length;

      if (_onDownloadProgress != null) {
        _onDownloadProgress(operationName, 0, totalAssets, 0);
      }

      int completedAssets = 0;
      int lastReportedPercentage = 0;

      for (final entry in objects.entries) {
        final assetName = entry.key;
        final object = entry.value as Map<String, dynamic>;
        final hash = object['hash'] as String;
        final hashPrefix = hash.substring(0, 2);
        final size = object['size'] as int;
        final objectPath = normalizePath(p.join(objectsDir, hashPrefix, hash));
        final assetUrl =
            'https://resources.download.minecraft.net/$hashPrefix/$hash';

        try {
          await downloadFile(
            assetUrl,
            objectPath,
            expectedSize: size,
            resourceName: assetName,
          );

          completedAssets++;

          if (_onDownloadProgress != null) {
            final percentage = (completedAssets / totalAssets) * 100;
            final reportPercentage =
                (percentage ~/ _progressReportRate) * _progressReportRate;

            if (reportPercentage > lastReportedPercentage) {
              lastReportedPercentage = reportPercentage;
              _onOperationProgress!(
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

      _assetsCompleter.complete();
    } catch (e) {
      debugPrint('Error processing asset index: $e');
      _assetsCompleter.completeError(
        Exception('Failed to process asset index: $e'),
      );
      throw Exception('Failed to process asset index: $e');
    }
  }

  /// Returns a future that completes when all assets have been downloaded.
  ///
  /// Can be used to wait for the asset download operation to complete or to
  /// catch any errors that occurred during the download process.
  ///
  /// Returns a future that completes when the download operation is finished.
  Future<void> get completionFuture => _assetsCompleter.future;
}
