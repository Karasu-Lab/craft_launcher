import 'dart:convert';
import 'dart:io';
import 'package:craft_launcher_core/models/launcher_profiles.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// Manages Minecraft launcher profiles, including loading, saving, and manipulating profile data.
class ProfileManager {
  /// Directory where game files and launcher profiles are stored.
  String gameDir;

  /// Collection of launcher profiles.
  LauncherProfiles? _profiles;

  /// Currently selected profile.
  Profile? _activeProfile;

  /// Creates a new ProfileManager instance.
  ///
  /// [gameDir] - Directory where game files are stored
  /// [profiles] - Optional pre-loaded launcher profiles
  /// [activeProfile] - Optional pre-selected active profile
  ProfileManager({
    required this.gameDir,
    LauncherProfiles? profiles,
    Profile? activeProfile,
  }) : _profiles = profiles,
       _activeProfile = activeProfile;

  /// Gets the launcher profiles.
  ///
  /// Throws an exception if profiles have not been loaded.
  /// Returns the launcher profiles.
  LauncherProfiles get profiles {
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }
    return _profiles!;
  }

  /// Gets the active profile.
  ///
  /// Throws an exception if no active profile has been selected.
  /// Returns the active profile.
  Profile get activeProfile {
    if (_activeProfile == null) {
      throw Exception('No active profile selected');
    }
    return _activeProfile!;
  }

  /// Sets the active profile.
  ///
  /// [profile] - Profile to set as active
  set activeProfile(Profile profile) {
    _activeProfile = profile;
  }

  /// Sets the active profile by its ID.
  ///
  /// [profileId] - ID of the profile to set as active
  /// Throws an exception if profiles are not loaded or if the profile ID doesn't exist.
  void setActiveProfileById(String profileId) {
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }

    if (!_profiles!.profiles.containsKey(profileId)) {
      throw Exception('Profile with ID $profileId not found');
    }

    _activeProfile = _profiles!.profiles[profileId];
  }

  /// Loads launcher profiles from disk.
  ///
  /// Throws an exception if the launcher profiles file cannot be found or loaded.
  /// If no active profile is set, selects the most recently used profile.
  Future<void> loadProfiles() async {
    final launcherProfilesPath = p.join(gameDir, 'launcher_profiles.json');
    final profilesFile = File(launcherProfilesPath);

    if (!await profilesFile.exists()) {
      throw Exception(
        'Launcher profiles file not found at $launcherProfilesPath',
      );
    }

    try {
      final jsonString = await profilesFile.readAsString();
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      _profiles = LauncherProfiles.fromJson(jsonMap);

      if (_profiles!.profiles.isNotEmpty && _activeProfile == null) {
        Profile? mostRecentProfile;
        DateTime mostRecentTime = DateTime(1970);

        for (final profile in _profiles!.profiles.values) {
          if (profile.lastUsed != null) {
            final lastUsedTime = DateTime.parse(profile.lastUsed!);
            if (lastUsedTime.isAfter(mostRecentTime)) {
              mostRecentTime = lastUsedTime;
              mostRecentProfile = profile;
            }
          }
        }

        _activeProfile = mostRecentProfile ?? _profiles!.profiles.values.first;
      }
    } catch (e) {
      debugPrint('Error loading launcher profiles: $e');
      throw Exception('Failed to load launcher profiles: $e');
    }
  }

  /// Saves launcher profiles to disk.
  ///
  /// Throws an exception if profiles have not been loaded or if saving fails.
  Future<void> saveProfiles() async {
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }

    final launcherProfilesPath = p.join(gameDir, 'launcher_profiles.json');
    final profilesFile = File(launcherProfilesPath);

    try {
      final jsonString = json.encode(_profiles!.toJson());
      await profilesFile.writeAsString(jsonString, flush: true);
    } catch (e) {
      debugPrint('Error saving launcher profiles: $e');
      throw Exception('Failed to save launcher profiles: $e');
    }
  }

  /// Creates a new profile with the specified settings.
  ///
  /// [name] - Name of the profile
  /// [versionId] - Minecraft version ID
  /// [gameDir] - Optional custom game directory
  /// [javaDir] - Optional custom Java directory
  /// [javaArgs] - Optional custom Java arguments
  /// [icon] - Icon identifier for the profile
  /// [skipJreVersionCheck] - Whether to skip Java version checking
  /// [type] - Type of profile
  /// Returns the created profile.
  /// Throws an exception if profiles have not been loaded.
  Future<Profile> createProfile({
    required String name,
    required String versionId,
    String? gameDir,
    String? javaDir,
    String? javaArgs,
    String icon = 'Furnace',
    bool skipJreVersionCheck = false,
    String type = 'custom',
  }) async {
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }

    final now = DateTime.now().toIso8601String();

    final profile = Profile(
      created: now,
      gameDir: gameDir,
      icon: icon,
      javaDir: javaDir,
      lastUsed: now,
      lastVersionId: versionId,
      name: name,
      skipJreVersionCheck: skipJreVersionCheck,
      type: type,
      javaArgs: javaArgs,
    );

    final profileId = _generateProfileId();
    final updatedProfiles = Map<String, Profile>.from(_profiles!.profiles);
    updatedProfiles[profileId] = profile;

    _profiles = LauncherProfiles(
      profiles: updatedProfiles,
      settings: _profiles!.settings,
      version: _profiles!.version,
    );

    await saveProfiles();
    return profile;
  }

  /// Updates an existing profile with new settings.
  ///
  /// [profileId] - ID of the profile to update
  /// [updatedProfile] - Updated profile data
  /// Throws an exception if profiles have not been loaded or if the profile ID doesn't exist.
  Future<void> updateProfile(String profileId, Profile updatedProfile) async {
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }

    if (!_profiles!.profiles.containsKey(profileId)) {
      throw Exception('Profile with ID $profileId not found');
    }

    final updatedProfiles = Map<String, Profile>.from(_profiles!.profiles);
    updatedProfiles[profileId] = updatedProfile;

    _profiles = LauncherProfiles(
      profiles: updatedProfiles,
      settings: _profiles!.settings,
      version: _profiles!.version,
    );

    if (_activeProfile != null && _activeProfile!.name == updatedProfile.name) {
      _activeProfile = updatedProfile;
    }

    await saveProfiles();
  }

  /// Deletes a profile.
  ///
  /// [profileId] - ID of the profile to delete
  /// Throws an exception if profiles have not been loaded or if the profile ID doesn't exist.
  Future<void> deleteProfile(String profileId) async {
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }

    if (!_profiles!.profiles.containsKey(profileId)) {
      throw Exception('Profile with ID $profileId not found');
    }

    if (_activeProfile != null &&
        _activeProfile!.name == _profiles!.profiles[profileId]!.name) {
      _activeProfile = null;
    }

    final updatedProfiles = Map<String, Profile>.from(_profiles!.profiles);
    updatedProfiles.remove(profileId);

    _profiles = LauncherProfiles(
      profiles: updatedProfiles,
      settings: _profiles!.settings,
      version: _profiles!.version,
    );

    await saveProfiles();

    if (_activeProfile == null && updatedProfiles.isNotEmpty) {
      _activeProfile = updatedProfiles.values.first;
    }
  }

  /// Generates a unique profile ID.
  ///
  /// Returns a unique profile ID based on the current timestamp.
  String _generateProfileId() {
    return 'profile_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Finds a profile ID by profile name.
  ///
  /// [name] - Name of the profile to find
  /// Returns the profile ID if found, otherwise null.
  /// Throws an exception if profiles have not been loaded.
  String? findProfileIdByName(String name) {
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }

    for (final entry in _profiles!.profiles.entries) {
      if (entry.value.name == name) {
        return entry.key;
      }
    }

    return null;
  }
}
