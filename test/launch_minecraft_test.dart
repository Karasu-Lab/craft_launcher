import 'dart:io';
import 'dart:async';
import 'package:craft_launcher_core/env/env.dart';
import 'package:craft_launcher_core/models/models.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:craft_launcher_core/vanilla_launcher.dart';
import 'package:craft_launcher_core/models/launcher_profiles.dart';
import 'package:mcid_connect/mcid_connect.dart';
import 'package:path/path.dart' as p;

void main() {
  final String gameDir = p.join(Directory.current.path, 'test_minecraft_dir');

  final String javaDir =
      Platform.isWindows
          ? 'C:\\Program Files\\Java\\jdk-17.0.5\\'
          : '/usr/bin/java';

  final testProfile = Profile(
    icon: 'minecraft',
    name: 'TestProfile',
    type: 'latest-release',
    created: DateTime.now().toIso8601String(),
    lastUsed: DateTime.now().toIso8601String(),
    lastVersionId: '1.16.5',
  );

  final testProfiles = LauncherProfiles(
    profiles: {'test_profile': testProfile},
    settings: Settings(
      crashAssistance: true,
      enableAdvanced: true,
      enableAnalytics: true,
      enableHistorical: true,
      enableReleases: true,
      enableSnapshots: false,
      keepLauncherOpen: true,
      profileSorting: 'name',
      showGameLog: true,
      showMenu: true,
      soundOn: true,
    ),
    version: 3,
  );

  test('Initialize Vanilla Launcher', () {
    final launcher = VanillaLauncher(
      gameDir: gameDir,
      javaDir: javaDir,
      profiles: testProfiles,
      activeProfile: testProfile,
      minecraftAccountProfile: null,
    );

    expect(launcher.getGameDir(), equals(gameDir));
    expect(launcher.getJavaDir(), equals(javaDir));
    expect(launcher.getActiveProfile().name, equals('TestProfile'));
  });
  test('Launch Minecraft - Integration Test', () async {
    final gameDirectory = Directory(gameDir);
    if (!await gameDirectory.exists()) {
      await gameDirectory.create(recursive: true);
    }

    try {
      final clientId = Env.azureAppClientId;
      final authService = AuthService(
        clientId: clientId,
        redirectUri: 'http://localhost:3000',
        scopes: ['XboxLive.signin', 'offline_access'],
        onGetDeviceCode: (deviceCodeResponse) {
          debugPrint('Please visit: ${deviceCodeResponse.verificationUri}');
          debugPrint('And enter this code: ${deviceCodeResponse.userCode}');
        },
      );

      // await authService.startAuthenticationFlow();

      final launcher = VanillaLauncher(
        gameDir: gameDir,
        javaDir: javaDir,
        profiles: testProfiles,
        activeProfile: testProfile,
        onOperationProgress: (operation, completed, total, percentage) {
          debugPrint(
            'Operation: $operation, Completed: $completed, Total: $total, Percentage: $percentage',
          );
        },
        // minecraftAuth: MinecraftAuth(
        //   clientId: clientId,
        //   authXuid: authService.xstsUhs,
        //   userName: authService.minecraftProfile.name,
        //   uuid: authService.minecraftProfile.id,
        //   accessToken: authService.minecraftToken,
        //   userType: 'msa',
        // ),
      );

      final completer = Completer<void>();

      launcher.onExit = (int exitCode) {
        debugPrint('Minecraft process exited with code: $exitCode');
        completer.complete();
      };

      await launcher.launch();
      await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          debugPrint('Minecraft process timeout after 5 minutes');
          completer.complete();
        },
      );
    } catch (e) {
      fail('Failed to launch Minecraft: $e');
    }
  });
}
