import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

/// Manages the extraction and handling of game archive files.
///
/// Responsible for extracting native libraries from JAR files and
/// organizing them for use by the Minecraft client.
class ArchivesManager {
  /// Callback for reporting progress of extraction operations.
  ///
  /// [_onOperationProgress]
  /// Optional callback that receives progress updates during extraction.
  final OperationProgressCallback? _onOperationProgress;

  /// Rate at which to report extraction progress.
  ///
  /// [_progressReportRate]
  /// Controls how frequently progress updates are sent, in percentage points.
  final int _progressReportRate;

  /// Creates a new archives manager instance.
  ///
  /// [onOperationProgress]
  /// Optional callback for reporting extraction progress.
  ///
  /// [progressReportRate]
  /// How often to report progress, defaults to every 10%.
  ArchivesManager({
    OperationProgressCallback? onOperationProgress,
    int progressReportRate = 10,
  }) : _onOperationProgress = onOperationProgress,
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
  String _normalizePath(String path) {
    final normalized = p.normalize(path);
    return p.isAbsolute(normalized) ? normalized : p.absolute(normalized);
  }

  /// Ensures a directory exists, creating it if necessary.
  ///
  /// [path]
  /// The path to the directory that should exist.
  ///
  /// Returns a Directory object for the ensured directory.
  Future<Directory> _ensureDirectory(String path) async {
    final normalizedPath = _normalizePath(path);
    final dir = Directory(normalizedPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Calculates SHA-1 hash of a file.
  ///
  /// Used to create unique identifiers for native library collections
  /// to manage caching and versioning.
  ///
  /// [filePath]
  /// Path to the file to hash.
  ///
  /// Returns the SHA-1 hash as a hexadecimal string.
  Future<String> calculateSha1Hash(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  /// Extracts platform-specific native libraries from JAR files.
  ///
  /// Identifies and extracts native libraries appropriate for the current platform
  /// from the game's library JAR files, placing them in a dedicated directory.
  ///
  /// [libraries]
  /// List of library definitions to process.
  ///
  /// [versionId]
  /// The Minecraft version identifier.
  ///
  /// [gameDir]
  /// Base game directory.
  ///
  /// [librariesDir]
  /// Directory containing downloaded library JAR files.
  ///
  /// [getNativesDir]
  /// Function that returns the path to the natives directory based on a hash.
  ///
  /// [downloadFile]
  /// Function to download a file if it doesn't exist locally.
  ///
  /// Returns the path to the directory containing extracted native libraries.
  Future<String> extractNativeLibraries({
    required List<Library> libraries,
    required String versionId,
    required String gameDir,
    required String librariesDir,
    required Function(String path) getNativesDir,
    required Function(
      String url,
      String path, {
      int? expectedSize,
      String? resourceName,
    })
    downloadFile,
    List<String>? additionalJars,
  }) async {
    String resultNativesDir = '';

    if (libraries.isEmpty) {
      throw Exception('No libraries provided for extraction');
    }

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

    final tempDir = await Directory.systemTemp.createTemp('mc_natives_');
    try {
      List<File> allExtractedNativeFiles = [];
      int processedLibraries = 0;
      int lastReportedPercentage = 0;

      // 追加のJARファイルがある場合、カウントを追加
      final additionalJarsCount = additionalJars?.length ?? 0;
      if (additionalJarsCount > 0) {
        totalLibraries += additionalJarsCount;
        debugPrint('Including $additionalJarsCount additional JAR files');
      }

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

        final nativeJar = _normalizePath(p.join(librariesDir, path));

        if (!await File(nativeJar).exists()) {
          debugPrint(
            'Native JAR file not found, attempting direct download: $nativeJar',
          );

          if (nativeArtifact.url != null) {
            try {
              await downloadFile(
                nativeArtifact.url!,
                nativeJar,
                expectedSize: nativeArtifact.size,
                resourceName: p.basename(nativeJar),
              );
            } catch (e) {
              debugPrint('Direct download failed: $e');
            }
          }

          if (!await File(nativeJar).exists()) {
            debugPrint('Failed to download native library, skipping: $path');
            processedLibraries++;
            continue;
          }
        }

        try {
          final nativeJarFile = File(nativeJar);
          final jarBytes = await nativeJarFile.readAsBytes();
          final archive = ZipDecoder().decodeBytes(jarBytes);

          for (final file in archive) {
            if (file.isFile) {
              final fileName = p.basename(file.name);
              final fileExt = p.extension(fileName).toLowerCase();

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
                percentage,
              );
            }
          }
        } catch (e) {
          debugPrint('Error extracting natives from $nativeJar: $e');
          processedLibraries++;
        }
      }

      // 追加のJARファイルからネイティブライブラリを抽出する
      if (additionalJars != null && additionalJars.isNotEmpty) {
        for (final additionalJar in additionalJars) {
          try {
            final jarFile = File(additionalJar);
            if (!await jarFile.exists()) {
              debugPrint(
                'Additional JAR file not found, skipping: $additionalJar',
              );
              processedLibraries++;
              continue;
            }

            debugPrint('Processing additional JAR file: $additionalJar');
            final jarBytes = await jarFile.readAsBytes();
            final archive = ZipDecoder().decodeBytes(jarBytes);

            for (final file in archive) {
              if (file.isFile) {
                final fileName = p.basename(file.name);
                final fileExt = p.extension(fileName).toLowerCase();

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

                  final data = file.content;
                  final tempFile = await File(
                    tempFilePath,
                  ).create(recursive: true);
                  await tempFile.writeAsBytes(Uint8List.fromList(data));
                  allExtractedNativeFiles.add(tempFile);
                  debugPrint(
                    'Extracted native library from additional JAR: $fileName',
                  );
                }
              }
            }

            processedLibraries++;

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
                  percentage,
                );
              }
            }
          } catch (e) {
            debugPrint(
              'Error extracting natives from additional JAR $additionalJar: $e',
            );
            processedLibraries++;
          }
        }
      }

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

          final zipHash = await calculateSha1Hash(collectionZipPath);
          resultNativesDir = getNativesDir(zipHash);

          if (await Directory(resultNativesDir).exists()) {
            debugPrint(
              'Deleting existing natives directory with hash: $zipHash',
            );
            try {
              await (Directory(resultNativesDir)).delete(recursive: true);
            } catch (e) {
              debugPrint(
                'Failed to delete the directory with recursive option: $e',
              );
            }
          }

          await _ensureDirectory(resultNativesDir);

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

          final extractedFiles =
              await Directory(resultNativesDir).list().toList();
          debugPrint('Final native libraries count: ${extractedFiles.length}');
        } catch (e) {
          debugPrint('Error creating natives collection: $e');
        }
      }

      if (resultNativesDir.isEmpty) {
        debugPrint('No natives directory created, using default');
        resultNativesDir = getNativesDir('default');
        await _ensureDirectory(resultNativesDir);
      }
    } finally {
      try {
        await tempDir.delete(recursive: true);
        debugPrint('Temporary directory cleaned up');
      } catch (e) {
        debugPrint('Failed to clean up temporary directory: $e');
      }
    }

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

    return resultNativesDir;
  }
}
