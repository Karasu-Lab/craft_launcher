import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// 基底ダウンローダークラスの抽象クラス
abstract class AbstractDownloader {
  final String _gameDir;
  final DownloadProgressCallback? _onDownloadProgress;
  final OperationProgressCallback? _onOperationProgress;
  final int _progressReportRate;

  AbstractDownloader({
    required String gameDir,
    DownloadProgressCallback? onDownloadProgress,
    OperationProgressCallback? onOperationProgress,
    int progressReportRate = 10,
  }) : _gameDir = gameDir,
       _onDownloadProgress = onDownloadProgress,
       _onOperationProgress = onOperationProgress,
       _progressReportRate = progressReportRate;

  /// パスを正規化する
  String normalizePath(String path) {
    final normalized = p.normalize(path);
    return p.isAbsolute(normalized) ? normalized : p.absolute(normalized);
  }

  /// ディレクトリが存在することを確認し、存在しない場合は作成する
  Future<Directory> ensureDirectory(String path) async {
    final normalizedPath = normalizePath(path);
    final dir = Directory(normalizedPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 進捗報告
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

  /// ファイルをダウンロードする共通メソッド
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

  /// ゲームディレクトリのパスを取得する
  String getGameDir() {
    return _gameDir;
  }

  /// ライブラリディレクトリのパスを取得する
  String getLibrariesDir() {
    return normalizePath(p.join(_gameDir, 'libraries'));
  }

  /// アセットディレクトリのパスを取得する
  String getAssetsDir() {
    return normalizePath(p.join(_gameDir, 'assets'));
  }
}
