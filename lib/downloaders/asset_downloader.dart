import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/downloaders/abstract_downloader.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class AssetDownloader extends AbstractDownloader {
  final Completer<void> _assetsCompleter = Completer<void>();
  final DownloadProgressCallback? _onDownloadProgress;
  final OperationProgressCallback? _onOperationProgress;
  final int _progressReportRate;

  AssetDownloader({
    required super.gameDir,
    DownloadProgressCallback? onDownloadProgress,
    OperationProgressCallback? onOperationProgress,
    int progressReportRate = 10,
  }) : _onDownloadProgress = onDownloadProgress,
       _onOperationProgress = onOperationProgress,
       _progressReportRate = progressReportRate;

  /// アセットのダウンロードを実行する
  Future<void> downloadAssets(VersionInfo versionInfo) async {
    if (versionInfo.assetIndex == null) {
      throw Exception('Failed to get asset index info');
    }

    final assetsDir = getAssetsDir();
    final indexesDir = normalizePath(p.join(assetsDir, 'indexes'));
    final objectsDir = normalizePath(p.join(assetsDir, 'objects'));

    await ensureDirectory(indexesDir);
    await ensureDirectory(objectsDir);

    final assetIndexInfo = versionInfo.assetIndex;
    final indexId = assetIndexInfo!.id as String? ?? 'legacy';
    final indexUrl = assetIndexInfo.url;

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

          // Report overall progress
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

  /// アセットのダウンロード完了を待機する
  Future<void> get completionFuture => _assetsCompleter.future;
}
