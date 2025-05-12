import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Manages environment variables and paths for Minecraft game execution.
///
/// Provides utilities for configuring the environment, resolving Java paths,
/// and normalizing file paths across different operating systems.
class EnvironmentManager {
  /// Configures environment variables to include native library directories.
  ///
  /// Sets up the appropriate environment variables based on the operating system
  /// to ensure native libraries can be found at runtime.
  ///
  /// [nativesPath]
  /// Path to the directory containing native libraries.
  ///
  /// [environment]
  /// Optional existing environment variables map to extend. If not provided,
  /// the current platform environment will be used.
  ///
  /// Returns a map of environment variables with the natives path properly configured.
  static Map<String, String> configureEnvironment({
    required String nativesPath,
    Map<String, String>? environment,
  }) {
    final envVars = Map<String, String>.from(
      environment ?? Platform.environment,
    );

    if (Platform.isWindows) {
      final String currentPath = envVars['PATH'] ?? '';
      envVars['PATH'] = '$nativesPath;$currentPath';

      debugPrint('Added natives directory to PATH: $nativesPath');
      debugPrint('Java library path: -Djava.library.path=$nativesPath');
    } else {
      final String currentLdLibraryPath = envVars['LD_LIBRARY_PATH'] ?? '';
      envVars['LD_LIBRARY_PATH'] = '$nativesPath:$currentLdLibraryPath';

      if (Platform.isMacOS) {
        final String currentDyldLibraryPath =
            envVars['DYLD_LIBRARY_PATH'] ?? '';
        envVars['DYLD_LIBRARY_PATH'] = '$nativesPath:$currentDyldLibraryPath';
      }

      debugPrint('Added natives directory to LD_LIBRARY_PATH: $nativesPath');
    }

    return envVars;
  }

  /// Returns the path to the Java executable based on the provided Java directory.
  ///
  /// Creates the appropriate path to the Java executable based on the operating system.
  /// On Windows, it will point to 'javaw.exe', on other platforms to 'java'.
  ///
  /// [javaDir]
  /// Base directory where Java is installed.
  ///
  /// Returns the full path to the Java executable.
  static String getJavaExecutablePath(String javaDir) {
    return p.normalize(
      p.join(javaDir, 'bin', Platform.isWindows ? 'javaw.exe' : 'java'),
    );
  }

  /// Normalizes a file path according to the platform conventions.
  ///
  /// Converts a path to its canonical form, resolving '..' and '.' segments
  /// and ensuring proper path separators for the current platform.
  ///
  /// [path]
  /// The file path to normalize.
  ///
  /// Returns the normalized path.
  static String normalizePath(String path) {
    return p.normalize(path);
  }
}
