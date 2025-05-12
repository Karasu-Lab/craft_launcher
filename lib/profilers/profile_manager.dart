import 'dart:convert';
import 'dart:io';
import 'package:craft_launcher_core/models/launcher_profiles.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class ProfileManager {
  String gameDir;
  LauncherProfiles? _profiles;
  Profile? _activeProfile;

  ProfileManager({
    required this.gameDir,
    LauncherProfiles? profiles,
    Profile? activeProfile,
  }) : _profiles = profiles,
       _activeProfile = activeProfile;

  LauncherProfiles get profiles {
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }
    return _profiles!;
  }

  Profile get activeProfile {
    if (_activeProfile == null) {
      throw Exception('No active profile selected');
    }
    return _activeProfile!;
  }

  set activeProfile(Profile profile) {
    _activeProfile = profile;
  }

  void setActiveProfileById(String profileId) {
    if (_profiles == null) {
      throw Exception('Launcher profiles not loaded');
    }

    if (!_profiles!.profiles.containsKey(profileId)) {
      throw Exception('Profile with ID $profileId not found');
    }

    _activeProfile = _profiles!.profiles[profileId];
  }

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
          final lastUsedTime = DateTime.parse(profile.lastUsed);
          if (lastUsedTime.isAfter(mostRecentTime)) {
            mostRecentTime = lastUsedTime;
            mostRecentProfile = profile;
          }
        }

        _activeProfile = mostRecentProfile ?? _profiles!.profiles.values.first;
      }
    } catch (e) {
      debugPrint('Error loading launcher profiles: $e');
      throw Exception('Failed to load launcher profiles: $e');
    }
  }

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

  String _generateProfileId() {
    return 'profile_${DateTime.now().millisecondsSinceEpoch}';
  }

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
