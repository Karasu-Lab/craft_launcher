import 'dart:async';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/interfaces/vanilla_launcher_interface.dart';
import 'package:craft_launcher_core/java_arguments/java_arguments_builder.dart';
import 'package:craft_launcher_core/models/launcher_profiles.dart';
import 'package:craft_launcher_core/processes/process_manager.dart';
import 'package:mcid_connect/data/auth/microsoft/microsoft_account.dart';
import 'package:mcid_connect/data/profile/minecraft_account_profile.dart';

/// An abstract interface class that defines the contract for a launcher adapter.
/// This provides a base for creating custom launcher implementations that can override
/// specific behaviors while maintaining a consistent interface.
abstract interface class LauncherAdapter {
  /// Hook called after building classpath
  Future<void> afterBuildClasspath(
    VersionInfo versionInfo,
    String versionId,
    List<String> classpath,
  );

  /// Hook called after downloading assets
  Future<void> afterDownloadAssets(String versionId);

  /// Hook called after downloading client jar
  Future<void> afterDownloadClientJar(String versionId);

  /// Hook called after downloading libraries
  Future<void> afterDownloadLibraries(String versionId);

  /// Hook called after extracting native libraries
  Future<void> afterExtractNativeLibraries(
    String versionId,
    String nativesPath,
  );

  /// Hook called after fetching version manifest
  Future<T?> afterFetchVersionManifest<T extends VersionInfo>(
    String versionId,
    T? versionInfo,
  );

  /// Hook called after getting asset index
  Future<void> afterGetAssetIndex(String versionId, String assetIndex);

  /// Hook called after starting the Minecraft process
  Future<void> afterStartProcess(
    String versionId,
    MinecraftProcessInfo processInfo,
    MinecraftAuth? auth,
  );

  /// Hook called ae building classpath
  Future<List<String>> beforeBuildClasspath(
    VersionInfo versionInfo,
    String versionId,
  );

  /// Hook called before downloading assets
  /// Returns true if the download should proceed, false to skip
  Future<bool> beforeDownloadAssets(String versionId);

  /// Hook called before downloading client jar
  Future<bool> beforeDownloadClientJar(String versionId);

  /// Hook called before downloading libraries
  /// Returns true if the download should proceed, false to skip
  Future<bool> beforeDownloadLibraries(String versionId);
  /// Hook called before extracting native libraries
  /// Returns true if the extraction should proceed, false to skip
  Future<bool> beforeExtractNativeLibraries(String versionId);

  /// Hook called before fetching version manifest
  Future<void> beforeFetchVersionManifest(String versionId);

  /// Hook called before getting asset index
  /// Returns true if the asset index retrieval should be skipped
  Future<bool> beforeGetAssetIndex<T extends VersionInfo>(
    String versionId,
    T versionInfo,
  );

  /// Hook called before starting the Minecraft process
  Future<void> beforeStartProcess(
    String javaExe,
    List<String> javaArgs,
    String workingDirectory,
    Map<String, String> environment,
    String versionId,
    MinecraftAuth? auth,
  );

  /// Hook called before building Java arguments
  /// This allows customization of the JavaArgumentsBuilder before arguments are built
  ///
  /// [versionId] - Minecraft version ID
  /// [builder] - JavaArgumentsBuilder instance that can be customized
  /// [versionInfo] - VersionInfo instance containing version information
  Future<Arguments?> beforeBuildJavaArguments(
    String versionId,
    JavaArgumentsBuilder builder,
    VersionInfo versionInfo,
  );

  /// Hook called after building Java arguments
  ///
  /// [versionId] - Minecraft version ID
  /// [arguments] - The built Java arguments string
  Future<String> afterBuildJavaArguments(String versionId, String arguments);

  /// Download assets from https://resources.download.minecraft.net.
  Future<void> downloadAssets<T extends VersionInfo>(T versionInfo);

  /// Download client jar from Mojang servers
  Future<void> downloadClientJar();

  /// Download libraries from https://libraries.minecraft.net.
  Future<void> downloadLibraries();

  /// Extract native libraries
  Future<String> extractNativeLibraries();

  /// Get minecraft account profile
  MinecraftAccountProfile? getAccountProfile();

  /// Get an active profile
  Profile getActiveProfile();

  /// Get asset index for a given version ID
  Future<String> getAssetIndex(String versionId);

  /// Get game directory
  String getGameDir();

  /// A builder for Java arguments
  JavaArgumentsBuilder getJavaArgumentsBuilder();

  /// Get the Java executable file path
  String getJavaDir();

  /// Get Microsoft account
  MicrosoftAccount? getMicrosoftAccount();

  /// Get the launcher profiles
  LauncherProfiles getProfiles();

  /// Launch the game
  Future<void> launch({
    JavaStderrCallback? onStderr,
    JavaStdoutCallback? onStdout,
    JavaExitCallback? onExit,
  });

  /// Load launcher profiles from launcher_profiles.json
  Future<void> loadProfiles();

  /// Set the active profile
  void setActiveProfile(Profile profile);

  /// Set the active profile by ID
  void setActiveProfileById(String profileId);

  /// Set game directory
  void setGameDir(String gameDir);

  /// Set the Java executable file path
  void setJavaDir(String javaDir);

  /// Terminate the running Minecraft process
  void terminate();

  /// Get the launcher is modded
  bool isModded();
  /// Get custom asset index path to override default path
  /// Return null to use the default path
  String? getCustomAssetIndexPath(String versionId, String assetIndex);
  
  /// Get custom assets directory path to override default path
  /// Return null to use the default directory
  String? getCustomAssetsDirectory();

  /// Get additional native libraries to extract.
  /// These libraries will be added to the native libraries extracted from the version's libraries.
  /// 
  /// [versionId] - The version ID for which to get additional native libraries
  /// [nativesPath] - The path where native libraries will be extracted
  /// 
  /// Returns a list of paths to additional JAR files containing native libraries
  Future<List<String>> getAdditionalNativeLibraries(
    String versionId,
    String nativesPath,
  );
}
