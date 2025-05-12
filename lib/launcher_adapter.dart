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

  /// Hook called after downloading libraries
  Future<void> afterDownloadLibraries(String versionId);

  /// Hook called after extracting native libraries
  Future<void> afterExtractNativeLibraries(
    String versionId,
    String nativesPath,
  );

  /// Hook called after fetching version manifest
  Future<void> afterFetchVersionManifest(
    String versionId,
    VersionInfo versionInfo,
  );

  /// Hook called after starting the Minecraft process
  Future<void> afterStartProcess(
    String versionId,
    MinecraftProcessInfo processInfo,
    MinecraftAuth? auth,
  );

  /// Hook called before building classpath
  Future<void> beforeBuildClasspath(VersionInfo versionInfo, String versionId);

  /// Hook called before downloading assets
  Future<void> beforeDownloadAssets(String versionId);

  /// Hook called before downloading libraries
  Future<void> beforeDownloadLibraries(String versionId);

  /// Hook called before extracting native libraries
  Future<void> beforeExtractNativeLibraries(String versionId);

  /// Hook called before fetching version manifest
  Future<void> beforeFetchVersionManifest(String versionId);

  /// Hook called before starting the Minecraft process
  Future<void> beforeStartProcess(
    String javaExe,
    List<String> javaArgs,
    String workingDirectory,
    Map<String, String> environment,
    String versionId,
    MinecraftAuth? auth,
  );

  /// Download assets from https://resources.download.minecraft.net.
  Future<void> downloadAssets();

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
}
