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
  craft_launcher_core: ^0.0.1
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
  // カスタムランチャー名とバージョンを設定（任意）
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
  
  // カスタムランチャーブランディング設定（任意）
  launcherName: 'MyAuthenticatedLauncher',
  launcherVersion: '1.5.2',
);

// Launch with authentication
await launcher.launch();
```

### Creating a Custom Launcher Adapter

```dart
import 'package:craft_launcher_core/launcher_adapter.dart';

class ModdedLauncherAdapter implements LauncherAdapter {
  final LauncherAdapter _vanillaAdapter;
  
  ModdedLauncherAdapter(this._vanillaAdapter);
  
  @override
  Future<void> afterBuildClasspath(
    VersionInfo versionInfo, 
    String versionId, 
    List<String> classpath
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
    
    await _vanillaAdapter.beforeStartProcess(
      javaExe, javaArgs, workingDirectory, environment, versionId, auth
    );
  }
}
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
