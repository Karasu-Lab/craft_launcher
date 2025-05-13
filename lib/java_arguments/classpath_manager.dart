import 'dart:io';
import 'dart:math';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/downloaders/library_downloader.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// Manages the Java classpath for Minecraft game execution.
///
/// Responsible for building the classpath required to run the Minecraft client,
/// including the main client JAR and all required libraries.
class ClasspathManager {
  /// The root directory for the Minecraft game files.
  ///
  /// [_gameDir]
  /// Path to the main Minecraft directory.
  final String _gameDir;

  /// The directory containing all library files.
  ///
  /// [_librariesDir]
  /// Path to the libraries directory within the game directory.
  final String _librariesDir;

  /// Callback for reporting download progress of individual files.
  ///
  /// [_onDownloadProgress]
  /// Optional callback that receives progress updates during file downloads.
  final DownloadProgressCallback? _onDownloadProgress;

  /// Callback for reporting progress of the overall download operation.
  ///
  /// [_onOperationProgress]
  /// Optional callback that receives progress updates for the overall operation.
  final OperationProgressCallback? _onOperationProgress;

  /// Rate at which to report download progress.
  ///
  /// [_progressReportRate]
  /// Controls how frequently progress updates are sent, in percentage points.
  final int _progressReportRate;

  /// Creates a new classpath manager.
  ///
  /// [gameDir]
  /// The root directory for Minecraft game files.
  ///
  /// [onDownloadProgress]
  /// Optional callback for reporting file download progress.
  ///
  /// [onOperationProgress]
  /// Optional callback for reporting overall operation progress.
  ///
  /// [progressReportRate]
  /// How often to report progress, defaults to every 10%.
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

  /// Normalizes a file path to an absolute path with correct separators.
  ///
  /// [path]
  /// The path to normalize.
  ///
  /// Returns the normalized absolute path.
  String _normalizePath(String path) {
    final normalized = p.normalize(path);
    return p.isAbsolute(normalized) ? normalized : p.absolute(normalized);
  }

  /// Gets the path to the Minecraft client JAR file for a specific version.
  ///
  /// [versionId]
  /// The Minecraft version identifier.
  ///
  /// Returns the absolute path to the client JAR file.
  String getClientJarPath(String versionId) {
    return _normalizePath(
      p.join(_gameDir, 'versions', versionId, '$versionId.jar'),
    );
  }

  /// Builds the full Java classpath for the specified Minecraft version.
  ///
  /// Collects all required JAR files, including the client JAR and all
  /// libraries required by the version. Downloads any missing files as needed.
  ///
  /// [versionInfo]
  /// The version information containing library dependencies.
  ///
  /// [versionId]
  /// The Minecraft version identifier.
  ///
  /// Returns a list of paths to be included in the Java classpath.
  /// Throws an exception if critical files cannot be downloaded.
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
        debugPrint('Failed to download Minecraft client files skipping it: $e');
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

  /// Downloads the Minecraft client JAR file for the specified version.
  ///
  /// [versionInfo]
  /// The version information containing download URLs.
  ///
  /// [versionId]
  /// The Minecraft version identifier.
  ///
  /// Throws an exception if the download fails.
  Future<void> downloadClientJar(
    VersionInfo versionInfo,
    String versionId,
  ) async {
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

  /// Downloads all required library files for the specified Minecraft version.
  ///
  /// [versionInfo]
  /// The version information containing library dependencies and download URLs.
  ///
  /// Throws an exception if the download process fails.
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

  /// Removes duplicate libraries from the classpath, keeping only the newest version.
  ///
  /// When multiple versions of the same JAR file are found in the classpath,
  /// this function keeps the newest version and removes older versions.
  ///
  /// [classpath]
  /// The list of classpath entries to optimize
  ///
  /// Returns an optimized classpath list with duplicates removed
  List<String> removeDuplicateLibraries(List<String> classpath) {
    RegExp versionPattern = RegExp(r'-([\d.]+(?:-[\w.]+)?)\.jar$');
    final Map<String, String> libraryPaths = {};
    final Map<String, String> libraryVersions = {};
    
    for (final path in classpath) {
      final fileName = p.basename(path);
      final match = versionPattern.firstMatch(fileName);
      
      if (match != null) {
        final version = match.group(1)!;
        final baseName = fileName.substring(0, fileName.indexOf("-$version.jar"));
        
        if (libraryVersions.containsKey(baseName)) {
          final existingVersion = libraryVersions[baseName]!;
          
          if (_compareVersions(version, existingVersion) > 0) {
            debugPrint('Replacing $baseName $existingVersion with $version');
            libraryVersions[baseName] = version;
            libraryPaths[baseName] = path;
          }
        } else {
          libraryVersions[baseName] = version;
          libraryPaths[baseName] = path;
        }
      } else {
        libraryPaths[fileName] = path;
      }
    }
    
    final optimizedClasspath = libraryPaths.values.toList();
    
    if (classpath.length != optimizedClasspath.length) {
      debugPrint('Optimized classpath: removed ${classpath.length - optimizedClasspath.length} duplicate libraries');
    }
    
    return optimizedClasspath;
  }
  
  /// Compares two version strings to determine which is newer.
  ///
  /// [version1]
  /// First version string to compare
  ///
  /// [version2]
  /// Second version string to compare
  ///
  /// Returns a positive value if version1 is newer, 
  /// 0 if they are the same, or a negative value if version1 is older
  int _compareVersions(String version1, String version2) {
    final parts1 = version1.split('.');
    final parts2 = version2.split('.');
    
    final length = min(parts1.length, parts2.length);
    
    for (int i = 0; i < length; i++) {
      final numPart1 = int.tryParse(parts1[i].split('-')[0]) ?? 0;
      final numPart2 = int.tryParse(parts2[i].split('-')[0]) ?? 0;
      
      if (numPart1 != numPart2) {
        return numPart1 - numPart2;
      }
    }
    
    return parts1.length - parts2.length;
  }
}
