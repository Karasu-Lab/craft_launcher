import 'dart:async';

import 'package:craft_launcher_core/java_arguments_builder.dart';
import 'package:craft_launcher_core/models/launcher_profiles.dart';
import 'package:mcid_connect/data/auth/auth_models.dart';
import 'package:mcid_connect/data/profile/account_profile.dart';

typedef JavaStdoutCallback = void Function(String line);
typedef JavaStderrCallback = void Function(String line);
typedef JavaExitCallback = void Function(int exitCode);

/// An interface for the Vanilla Launcher.
abstract interface class VanillaLauncherInterface {
  /// A builder for Java arguments.
  JavaArgumentsBuilder getJavaArgumentsBuilder();

  /// Get asset index for a given version ID.
  Future<String> getAssetIndex(String versionId);

  /// Get an active profile.
  Profile getActiveProfile();

  /// Set the active profile by ID.
  void setActiveProfileById(String profileId);

  /// Set the active profile.
  void setActiveProfile(Profile profile);

  /// Load launcher profiles from launcher_profiles.json
  Future<void> loadProfiles();

  /// Get the launcher profiles.
  LauncherProfiles getProfiles();

  /// Get game directory.
  String getGameDir();

  /// Set game directory.
  void setGameDir(String gameDir);

  /// Get the Java executable file path.
  String getJavaDir();

  /// Set the Java executable file path.
  void setJavaDir(String javaDir);

  /// Get minecraft account profile.
  MinecraftAccountProfile? getAccountProfile();

  /// Get Microsoft account.
  MicrosoftAccount? getMicrosoftAccount();

  /// Extract native libraries.
  Future<void> extractNativeLibraries();

  /// Download assets from https://resources.download.minecraft.net.
  Future<void> downloadAssets();

  /// Download libraries from https://libraries.minecraft.net.
  Future<void> downloadLibraries();

  Future<void> downloadClientJar();

  /// Launch the game.
  Future<void> launch({
    JavaStderrCallback? onStderr,
    JavaStdoutCallback? onStdout,
    JavaExitCallback? onExit,
  });

  void terminate();
}
