# Craft Launcher Core

A Dart package for launching Minecraft Java Edition. This library simplifies the process of managing launcher profiles, downloading game assets, and starting Minecraft instances.

## Features

- Minecraft version management
- Game assets and libraries downloading
- Java runtime detection and management 
- Profile configuration and customization
- Launch with Microsoft authentication support
- Extensible launcher adapter system
- Customizable launcher branding

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  craft_launcher_core: ^0.0.3
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Launcher Setup

```dart
import 'package:craft_launcher_core/vanilla_launcher.dart';
import 'package:craft_launcher_core/models/launcher_profiles.dart';

// Create a profile
final myProfile = Profile(
  icon: 'minecraft',
  name: 'MyProfile',
  type: 'latest-release',
  created: DateTime.now().toIso8601String(),
  lastUsed: DateTime.now().toIso8601String(),
  lastVersionId: '1.21.3',
);

// Initialize launcher
final launcher = VanillaLauncher(
  gameDir: '/path/to/minecraft',
  javaDir: '/path/to/java',
  profiles: LauncherProfiles(
    profiles: {'my_profile': myProfile},
    settings: Settings(
      enableSnapshots: false,
      keepLauncherOpen: true,
      showGameLog: true,
    ),
    version: 3,
  ),
  activeProfile: myProfile,
  onOperationProgress: (operation, completed, total, percentage) {
    print('$operation: $percentage%');
  },
  launcherName: 'MyCustomLauncher',
  launcherVersion: '2.0.0',
);

// Launch the game
await launcher.launch(
  onStdout: (data) => print('Minecraft: $data'),
  onStderr: (data) => print('Error: $data'),
  onExit: (code) => print('Game exited with code: $code'),
);
```

### Using with Microsoft Authentication

```dart
import 'package:craft_launcher_core/vanilla_launcher.dart';
import 'package:craft_launcher_core/models/models.dart';
import 'package:mcid_connect/mcid_connect.dart';

// Authenticate with Microsoft (see mcid_connect package)
final authService = AuthService(
  clientId: 'your-azure-app-client-id',
  redirectUri: 'http://localhost:3000',
  scopes: ['XboxLive.signin', 'offline_access'],
  onGetDeviceCode: (deviceCodeResponse) {
    print('Please visit: ${deviceCodeResponse.verificationUri}');
    print('And enter this code: ${deviceCodeResponse.userCode}');
  },
);

await authService.startAuthenticationFlow();

// Initialize the launcher with auth
final launcher = VanillaLauncher(
  // Game directory settings
  gameDir: '/path/to/minecraft',
  javaDir: '/path/to/java',
  profiles: myProfiles,
  activeProfile: myProfile,
  
  // Authentication data from Microsoft login
  minecraftAuth: MinecraftAuth(
    clientId: 'your-azure-app-client-id',
    authXuid: authService.xstsUhs,
    userName: authService.minecraftProfile.name,
    uuid: authService.minecraftProfile.id,
    accessToken: authService.minecraftToken,
    userType: 'msa',
  ),
  
  launcherName: 'MyAuthenticatedLauncher',
  launcherVersion: '1.5.2',
);

// Launch with authentication
await launcher.launch();
```

### Creating a Custom Launcher Adapter

```dart
import 'package:craft_launcher_core/vanilla_launcher.dart';
import 'package:craft_launcher_core/launcher_adapter.dart';
import 'package:craft_launcher_core/models/models.dart';

class ModdedLauncherAdapter implements LauncherAdapter {
  final LauncherAdapter _vanillaAdapter;
  
  ModdedLauncherAdapter(this._vanillaAdapter);
  
  @override
  Future<void> afterBuildClasspath(
    VersionInfo versionInfo, 
    String versionId, 
    List<String> classpath,
  ) async {
    // Add mod loaders to classpath
    classpath.add('/path/to/forge.jar');
    
    // Continue with vanilla behavior
    await _vanillaAdapter.afterBuildClasspath(versionInfo, versionId, classpath);
  }
  
  // Implement other interface methods or delegate to vanilla adapter
  @override
  Future<void> beforeStartProcess(
    String javaExe,
    List<String> javaArgs,
    String workingDirectory,
    Map<String, String> environment,
    String versionId,
    MinecraftAuth? auth,
  ) async {
    // Add custom JVM arguments
    javaArgs.add('-Dfml.ignoreInvalidMinecraftCertificates=true');
    javaArgs.add('-Dfml.ignorePatchDiscrepancies=true');
    
    // Setup mod-specific environment variables
    environment['FORGE_LOGGING_MARKERS'] = 'SCAN,REGISTRIES,REGISTRYDUMP';
    
    // Continue with vanilla behavior
    await _vanillaAdapter.beforeStartProcess(
      javaExe, javaArgs, workingDirectory, environment, versionId, auth,
    );
  }
  
  @override
  Future<void> afterStartProcess(
    String versionId,
    MinecraftProcessInfo processInfo,
    MinecraftAuth? auth,
  ) async {
    // Do post-process operations like starting a mod server or logging
    print('Modded Minecraft started with PID: ${processInfo.pid}');
    
    // Continue with vanilla behavior if needed
    await _vanillaAdapter.afterStartProcess(versionId, processInfo, auth);
  }
  
  // Implement other hooks as needed to customize the launch process
  @override
  Future<void> beforeDownloadAssets(String versionId) async {
    print('Preparing to download assets for modded Minecraft $versionId');
    await _vanillaAdapter.beforeDownloadAssets(versionId);
  }
}

// Using the custom adapter with a vanilla launcher
final vanillaLauncher = VanillaLauncher(
  gameDir: '/path/to/minecraft',
  javaDir: '/path/to/java',
  profiles: myProfiles,
  activeProfile: myProfile,
  // Other configuration...
);

// Wrap the vanilla launcher with your custom adapter
final moddedAdapter = ModdedLauncherAdapter(vanillaLauncher);

// Launch using the modded adapter
// Note: you still use the vanilla launcher's launch method
// but the adapter hooks will be called during the process
await vanillaLauncher.launch();
```

## Additional information

### Requirements

- Dart SDK 3.7.2 or higher
- Java Runtime Environment (JRE) or Java Development Kit (JDK) for running Minecraft
- Internet connection for downloading game assets and libraries

### Customization Options

- **Launcher Branding**: Customize the launcher name and version that appears in Minecraft by setting the `launcherName` and `launcherVersion` parameters in the `VanillaLauncher` constructor. If not specified, the default values "CraftLauncher" and "1.0.0" will be used.

### Contributing

Contributions are welcome! Feel free to submit issues or pull requests on the GitHub repository.

### License

This package is available under the MIT License.
