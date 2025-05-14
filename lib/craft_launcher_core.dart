export './models/models.dart';
export './models/progress_callback.dart';
export './api/minecraft_meta.dart';
export './interfaces/minecraft_meta_interface.dart';
export './profilers/profile_manager.dart';

/// Hook called before extracting native libraries
/// Return true to proceed with extraction, false to skip
typedef BeforeExtractNativeLibrariesCallback = Future<bool> Function(
  String versionId,
);

/// Hook called after extracting native libraries
typedef AfterExtractNativeLibrariesCallback = Future<void> Function(
  String versionId,
  String nativesPath,
);

/// Get additional JAR files for native libraries extraction
typedef GetAdditionalNativeLibrariesCallback = Future<List<String>> Function(
  String versionId,
  String nativesPath,
);