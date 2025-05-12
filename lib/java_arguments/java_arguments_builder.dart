import 'dart:io';

import 'package:craft_launcher_core/interfaces/java_arguments_builder_interface.dart';
import 'package:craft_launcher_core/models/jvm_rule.dart';
import 'package:craft_launcher_core/models/versions/version_info.dart';

/// Enum defining the types of arguments that can be processed.
enum ArgumentType { jvm, game }

/// Builder class for constructing Java arguments used to launch Minecraft.
/// This class handles the complex task of assembling all necessary JVM and game arguments,
/// including variable substitution and platform-specific formatting.
class JavaArgumentsBuilder implements JavaArgumentsBuilderInterface {
  /// Game directory path.
  String? _gameDir;

  /// Minecraft version.
  String? _version;

  /// List of classpath entries.
  final List<String> _classPaths = [];

  /// Directory containing native libraries.
  String? _nativesDir;

  /// Path to the Minecraft client JAR.
  String? _clientJar;

  /// Main class to execute.
  String? _mainClass;

  /// Additional JVM arguments.
  String? _additionalArgs;

  /// Arguments object from version manifest.
  Arguments? _arguments;

  /// Legacy Minecraft arguments string.
  String? _minecraftArguments;

  /// Asset index name.
  String? _assetsIndexName;

  /// Player username.
  String? _authPlayerName;

  /// Player UUID.
  String? _authUuid;

  /// Authentication access token.
  String? _authAccessToken;

  /// Client ID.
  String? _clientId;

  /// Authentication XUID.
  String? _authXuid;

  /// User authentication type.
  String? _userType;

  ///  Launcher name.
  String _launcherName = 'CraftLauncher';

  /// Launcher version.
  String _launcherVersion = '1.0.0';

  /// Feature flags that control argument inclusion.
  final Map<String, bool> _featureFlags = {
    'is_demo_user': false,
    'has_custom_resolution': false,
    'has_quick_plays_support': false,
    'is_quick_play_singleplayer': false,
    'is_quick_play_multiplayer': false,
    'is_quick_play_realms': false,
  };

  /// Game window width.
  int _width = 854;

  /// Game window height.
  int _height = 480;

  /// Path for quick play.
  String? _quickPlayPath;

  /// Singleplayer world name for quick play.
  String? _quickPlaySingleplayer;

  /// Multiplayer server address for quick play.
  String? _quickPlayMultiplayer;

  /// Realms ID for quick play.
  String? _quickPlayRealms;

  /// Creates a new JavaArgumentsBuilder instance.
  ///
  /// [launcherName] - Optional name of the launcher
  /// [launcherVersion] - Optional version of the launcher
  JavaArgumentsBuilder({String? launcherName, String? launcherVersion}) {
    _launcherName = launcherName ?? 'CraftLauncher';
    _launcherVersion = launcherVersion ?? '1.0.0';
  }

  /// Sets the game directory.
  ///
  /// [gameDir] - Path to the game directory
  /// Returns this builder for method chaining.
  @override
  JavaArgumentsBuilder setGameDir(String gameDir) {
    _gameDir = gameDir;
    return this;
  }

  /// Sets the Minecraft version.
  ///
  /// [version] - Minecraft version string
  /// Returns this builder for method chaining.
  @override
  JavaArgumentsBuilder setVersion(String version) {
    _version = version;
    return this;
  }

  /// Adds classpath entries.
  ///
  /// [classPaths] - List of paths to add to the classpath
  /// Returns this builder for method chaining.
  @override
  JavaArgumentsBuilder addClassPaths(List<String> classPaths) {
    _classPaths.addAll(classPaths);
    return this;
  }

  /// Sets the directory containing native libraries.
  ///
  /// [nativesDir] - Path to the natives directory
  /// Returns this builder for method chaining.
  @override
  JavaArgumentsBuilder setNativesDir(String nativesDir) {
    _nativesDir = nativesDir;
    return this;
  }

  /// Sets the path to the client JAR file and adds it to the classpath.
  ///
  /// [clientJarPath] - Path to the client JAR file
  /// Returns this builder for method chaining.
  @override
  JavaArgumentsBuilder setClientJar(String clientJarPath) {
    _clientJar = clientJarPath;
    if (!_classPaths.contains(clientJarPath)) {
      _classPaths.add(clientJarPath);
    }
    return this;
  }

  /// Sets the main class to execute.
  ///
  /// [mainClass] - Fully qualified name of the main class
  /// Returns this builder for method chaining.
  @override
  JavaArgumentsBuilder setMainClass(String mainClass) {
    _mainClass = mainClass;
    return this;
  }

  /// Adds additional JVM arguments.
  ///
  /// [additionalArgs] - Space-separated additional arguments
  /// Returns this builder for method chaining.
  @override
  JavaArgumentsBuilder addAdditionalArguments(String? additionalArgs) {
    _additionalArgs = additionalArgs;
    return this;
  }

  /// Adds game arguments from the version manifest.
  ///
  /// [arguments] - Arguments object from the version manifest
  /// Returns this builder for method chaining.
  @override
  JavaArgumentsBuilder addGameArguments(Arguments? arguments) {
    _arguments = arguments;
    return this;
  }

  /// Sets the asset index name.
  ///
  /// [assetsIndexName] - Name of the assets index
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setAssetsIndexName(String assetsIndexName) {
    _assetsIndexName = assetsIndexName;
    return this;
  }

  /// Sets the player username.
  ///
  /// [authPlayerName] - Player username
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setAuthPlayerName(String authPlayerName) {
    _authPlayerName = authPlayerName;
    return this;
  }

  /// Sets the player UUID.
  ///
  /// [authUuid] - Player UUID
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setAuthUuid(String authUuid) {
    _authUuid = authUuid;
    return this;
  }

  /// Sets the authentication access token.
  ///
  /// [authAccessToken] - Authentication access token
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setAuthAccessToken(String? authAccessToken) {
    _authAccessToken = authAccessToken;
    return this;
  }

  /// Sets the client ID.
  ///
  /// [clientId] - Client ID
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setClientId(String clientId) {
    _clientId = clientId;
    return this;
  }

  /// Sets the authentication XUID.
  ///
  /// [authXuid] - Authentication XUID
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setAuthXuid(String authXuid) {
    _authXuid = authXuid;
    return this;
  }

  /// Sets the user authentication type.
  ///
  /// [userType] - User authentication type (e.g., 'msa', 'mojang', 'legacy')
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setUserType(String userType) {
    _userType = userType;
    return this;
  }

  /// Sets the launcher name.
  ///
  /// [launcherName] - Name of the launcher
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setLauncherName(String launcherName) {
    _launcherName = launcherName;
    return this;
  }

  /// Sets the launcher version.
  ///
  /// [launcherVersion] - Version of the launcher
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setLauncherVersion(String launcherVersion) {
    _launcherVersion = launcherVersion;
    return this;
  }

  /// Sets the legacy Minecraft arguments string.
  ///
  /// [minecraftArguments] - Legacy arguments string from the version manifest
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setMinecraftArguments(String minecraftArguments) {
    _minecraftArguments = minecraftArguments;
    return this;
  }

  /// Gets the legacy Minecraft arguments string.
  ///
  /// Returns the legacy Minecraft arguments string if set, otherwise null.
  String? getMinecraftArguments() => _minecraftArguments;

  /// Sets the demo user flag.
  ///
  /// [isDemo] - Whether the user is in demo mode
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setDemoUser(bool isDemo) {
    _featureFlags['is_demo_user'] = isDemo;
    return this;
  }

  /// Sets a custom resolution for the game window.
  ///
  /// [width] - Window width in pixels
  /// [height] - Window height in pixels
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setCustomResolution(int width, int height) {
    _featureFlags['has_custom_resolution'] = true;
    _width = width;
    _height = height;
    return this;
  }

  /// Enables quick play support.
  ///
  /// [path] - Quick play path
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setQuickPlaySupport(String path) {
    _featureFlags['has_quick_plays_support'] = true;
    _quickPlayPath = path;
    return this;
  }

  /// Sets up quick play for singleplayer.
  ///
  /// [levelName] - Name of the singleplayer world
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setQuickPlaySingleplayer(String levelName) {
    _featureFlags['is_quick_play_singleplayer'] = true;
    _quickPlaySingleplayer = levelName;
    return this;
  }

  /// Sets up quick play for multiplayer.
  ///
  /// [serverAddress] - Address of the multiplayer server
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setQuickPlayMultiplayer(String serverAddress) {
    _featureFlags['is_quick_play_multiplayer'] = true;
    _quickPlayMultiplayer = serverAddress;
    return this;
  }

  /// Sets up quick play for Realms.
  ///
  /// [realmId] - ID of the Realm
  /// Returns this builder for method chaining.
  JavaArgumentsBuilder setQuickPlayRealms(String realmId) {
    _featureFlags['is_quick_play_realms'] = true;
    _quickPlayRealms = realmId;
    return this;
  }

  /// Gets the game directory.
  ///
  /// Returns the game directory path if set, otherwise null.
  String? getGameDir() => _gameDir;

  /// Gets the Minecraft version.
  ///
  /// Returns the version string if set, otherwise null.
  String? getVersion() => _version;

  /// Gets the classpath entries.
  ///
  /// Returns an unmodifiable list of classpath entries.
  List<String> getClassPaths() => List.unmodifiable(_classPaths);

  /// Gets the natives directory.
  ///
  /// Returns the natives directory path if set, otherwise null.
  String? getNativesDir() => _nativesDir;

  /// Gets the client JAR path.
  ///
  /// Returns the client JAR path if set, otherwise null.
  String? getClientJar() => _clientJar;

  /// Gets the main class.
  ///
  /// Returns the main class name if set, otherwise null.
  String? getMainClass() => _mainClass;

  /// Gets the additional arguments.
  ///
  /// Returns the additional arguments string if set, otherwise null.
  String? getAdditionalArgs() => _additionalArgs;

  /// Gets the arguments object.
  ///
  /// Returns the arguments object if set, otherwise null.
  Arguments? getArguments() => _arguments;

  /// Gets the assets index name.
  ///
  /// Returns the assets index name if set, otherwise null.
  String? getAssetsIndexName() => _assetsIndexName;

  /// Gets the player username.
  ///
  /// Returns the player username if set, otherwise null.
  String? getAuthPlayerName() => _authPlayerName;

  /// Gets the player UUID.
  ///
  /// Returns the player UUID if set, otherwise null.
  String? getAuthUuid() => _authUuid;

  /// Gets the authentication access token.
  ///
  /// Returns the authentication access token if set, otherwise null.
  String? getAuthAccessToken() => _authAccessToken;

  /// Gets the client ID.
  ///
  /// Returns the client ID if set, otherwise null.
  String? getClientId() => _clientId;

  /// Gets the authentication XUID.
  ///
  /// Returns the authentication XUID if set, otherwise null.
  String? getAuthXuid() => _authXuid;

  /// Gets the user authentication type.
  ///
  /// Returns the user authentication type if set, otherwise null.
  String? getUserType() => _userType;

  /// Gets the launcher name.
  ///
  /// Returns the launcher name.
  String getLauncherName() => _launcherName;

  /// Gets the launcher version.
  ///
  /// Returns the launcher version.
  String getLauncherVersion() => _launcherVersion;

  /// Builds the complete Java arguments string.
  ///
  /// Returns a space-separated string of all Java arguments.
  /// Throws an exception if the main class is not set.
  @override
  String build() {
    if (_mainClass == null) {
      throw Exception('Main class must be set');
    }

    final List<String> args = [];

    if (_classPaths.isNotEmpty) {
      args.add('-cp');
      args.add(_classPaths.join(Platform.isWindows ? ';' : ':'));
    }

    args.add(_mainClass!);

    if (_additionalArgs != null && _additionalArgs!.isNotEmpty) {
      args.addAll(_additionalArgs!.split(' '));
    }

    args.add('-Dorg.lwjgl.util.DebugLoader=true');

    if (_nativesDir != null) {
      args.add('-Djava.library.path=$_nativesDir');
    }

    if (_minecraftArguments != null) {
      args.addAll(_processLegacyArguments(_minecraftArguments!));
    } else {
      if (_arguments?.jvm != null) {
        args.addAll(_processArguments(_arguments!.jvm!, ArgumentType.jvm));
      }

      if (_arguments?.game != null) {
        args.addAll(_processArguments(_arguments!.game!, ArgumentType.game));
      }
    }

    return args.join(' ');
  }

  /// Processes argument lists from the version manifest.
  ///
  /// [args] - List of arguments to process
  /// [type] - Type of arguments (JVM or game)
  /// Returns a list of processed arguments with variables substituted.
  List<String> _processArguments(List<dynamic> args, ArgumentType type) {
    final List<String> processedArgs = [];

    final Map<String, String?> variableMap = {
      'version_name': _version,
      'game_directory': _gameDir,
      'assets_root': _gameDir != null ? '$_gameDir/assets' : null,
      'assets_index_name': _assetsIndexName,
      'auth_player_name': _authPlayerName,
      'user_type': _userType,
      'natives_directory': _nativesDir,
      'launcher_name': _launcherName,
      'launcher_version': _launcherVersion,
      'classpath': _classPaths.join(Platform.isWindows ? ';' : ':'),
      'resolution_width': _width.toString(),
      'resolution_height': _height.toString(),
    };

    if (_clientId != null) {
      variableMap.addAll({'clientid': _clientId});
    }

    if (_authUuid != null) {
      variableMap.addAll({'auth_uuid': _authUuid});
    }

    if (_authXuid != null) {
      variableMap.addAll({'auth_xuid': _authXuid});
    }

    if (_authAccessToken != null) {
      variableMap.addAll({'auth_access_token': _authAccessToken});
    }

    if (_quickPlayPath != null) {
      variableMap.addAll({'quickPlayPath': _quickPlayPath});
    }

    if (_quickPlaySingleplayer != null) {
      variableMap.addAll({'quickPlaySingleplayer': _quickPlaySingleplayer});
    }

    if (_quickPlayMultiplayer != null) {
      variableMap.addAll({'quickPlayMultiplayer': _quickPlayMultiplayer});
    }

    if (_quickPlayRealms != null) {
      variableMap.addAll({'quickPlayRealms': _quickPlayRealms});
    }

    final List<String> optionPrefixes = ['--', '-', '-D'];

    bool classPathAdded = false;

    if (type == ArgumentType.jvm) {
      if (_classPaths.isNotEmpty && !classPathAdded) {
        processedArgs.add('-cp');
        processedArgs.add(_classPaths.join(Platform.isWindows ? ';' : ':'));
        classPathAdded = true;
      }
    }

    for (int i = 0; i < args.length; i++) {
      var arg = args[i];

      if (arg is String && (arg == '-cp' || arg == '-classpath')) {
        if (classPathAdded) {
          i++;
          continue;
        } else {
          classPathAdded = true;
        }
      }

      if (arg is String) {
        String processedArg = arg;

        variableMap.forEach((key, value) {
          if (value != null) {
            processedArg = _replaceWithRegex(processedArg, '\${$key}', value);
          }
        });

        if (i > 0 &&
            processedArg.startsWith('\${') &&
            processedArg.endsWith('}')) {
          final previousArg =
              processedArgs.isNotEmpty ? processedArgs.last : null;

          bool isPreviousOption = false;
          for (final prefix in optionPrefixes) {
            if (previousArg != null && previousArg.startsWith(prefix)) {
              isPreviousOption = true;
              break;
            }
          }

          if (isPreviousOption) {
            final varName = processedArg.substring(2, processedArg.length - 1);
            final value = variableMap[varName];

            if (value == null) {
              processedArgs.removeLast();
            } else {
              processedArgs.add(value);
            }
          } else {
            if (!processedArg.startsWith('\${') ||
                !processedArg.endsWith('}')) {
              processedArgs.add(processedArg);
            }
          }
        } else {
          if (processedArg.startsWith('-D')) {
            if (!processedArg.contains('\${')) {
              processedArgs.add(processedArg);
            }
          } else {
            processedArgs.add(processedArg);
          }
        }
        continue;
      }

      if (arg is Map<String, dynamic>) {
        var jvmRule = JvmRule.fromJson(arg);
        bool shouldApply = _evaluateRules(jvmRule.rules);

        if (shouldApply) {
          bool featuresMatch = _evaluateFeatures(jvmRule.rules);
          if (!featuresMatch) continue;

          if (jvmRule.value is String) {
            String value = jvmRule.value as String;

            variableMap.forEach((key, varValue) {
              if (varValue != null) {
                value = _replaceWithRegex(value, '\${$key}', varValue);
              }
            });

            if (!value.contains('\${')) {
              processedArgs.add(value);
            }
          } else if (jvmRule.values != null) {
            List<String> valueList = jvmRule.values!;

            for (int j = 0; j < valueList.length; j++) {
              String value = valueList[j];

              variableMap.forEach((key, varValue) {
                if (varValue != null) {
                  value = _replaceWithRegex(value, '\${$key}', varValue);
                }
              });

              if (j > 0 && value.startsWith('\${') && value.endsWith('}')) {
                final previousValue =
                    processedArgs.isNotEmpty ? processedArgs.last : null;

                bool isPreviousOption = false;
                for (final prefix in optionPrefixes) {
                  if (previousValue != null &&
                      previousValue.startsWith(prefix)) {
                    isPreviousOption = true;
                    break;
                  }
                }

                if (isPreviousOption) {
                  final varName = value.substring(2, value.length - 1);
                  final resolvedValue = variableMap[varName];

                  if (resolvedValue == null) {
                    processedArgs.removeLast();
                  } else {
                    processedArgs.add(resolvedValue);
                  }
                } else {
                  if (!value.contains('\${')) {
                    processedArgs.add(value);
                  }
                }
              } else {
                if (!value.contains('\${')) {
                  processedArgs.add(value);
                }
              }
            }
          }
        }
      }
    }

    return processedArgs;
  }

  /// Processes legacy Minecraft arguments string.
  ///
  /// [arguments] - Legacy arguments string to process
  /// Returns a list of processed arguments with variables substituted.
  List<String> _processLegacyArguments(String arguments) {
    final List<String> processedArgs = [];
    final List<String> argParts = arguments.split(' ');

    final Map<String, String?> variableMap = {
      'version_name': _version,
      'version_type': 'release',
      'game_directory': _gameDir,
      'assets_root': _gameDir != null ? '$_gameDir/assets' : null,
      'assets_index_name': _assetsIndexName,
      'auth_player_name': _authPlayerName,
      'auth_uuid': _authUuid,
      'auth_access_token': _authAccessToken,
      'user_type': _userType ?? 'legacy',
      'resolution_width': _width.toString(),
      'resolution_height': _height.toString(),
    };

    for (int i = 0; i < argParts.length; i++) {
      var arg = argParts[i];

      if (arg.startsWith('--') && i + 1 < argParts.length) {
        String nextArg = argParts[i + 1];

        if (nextArg.startsWith('\${') && nextArg.endsWith('}')) {
          final varName = nextArg.substring(2, nextArg.length - 1);
          final value = variableMap[varName];

          if (value != null) {
            processedArgs.add(arg);
            processedArgs.add(value);
          }
          i++;
        } else {
          processedArgs.add(arg);
          if (i + 1 < argParts.length && !argParts[i + 1].startsWith('--')) {
            processedArgs.add(argParts[i + 1]);
            i++;
          }
        }
      } else {
        String processedArg = arg;

        variableMap.forEach((key, value) {
          if (value != null) {
            processedArg = _replaceWithRegex(processedArg, '\${$key}', value);
          }
        });

        if (!processedArg.contains('\${')) {
          processedArgs.add(processedArg);
        }
      }
    }

    processedArgs.addAll(['--width', _width.toString()]);
    processedArgs.addAll(['--height', _height.toString()]);

    if (_minecraftArguments != null) {
      if (_minecraftArguments!.contains('--userProperties')) {
        processedArgs.addAll(['--userProperties', '{}']);
      }
    }

    return processedArgs;
  }

  /// Evaluates JVM rules to determine if arguments should be included.
  ///
  /// [rules] - List of JVM rule conditions to evaluate
  /// Returns true if the arguments should be included, false otherwise.
  bool _evaluateRules(List<JvmRuleCondition> rules) {
    if (rules.isEmpty) {
      return true;
    }

    bool shouldApply = false;

    for (final rule in rules) {
      final action = rule.action;
      final os = rule.os;
      bool matches = true;

      if (os != null) {
        final osName = os.name;
        if (osName != null) {
          if (osName == 'windows' && !Platform.isWindows) {
            matches = false;
          } else if (osName == 'osx' && !Platform.isMacOS) {
            matches = false;
          } else if (osName == 'linux' && !Platform.isLinux) {
            matches = false;
          }
        }

        final arch = os.arch;
        if (arch != null && matches) {
          if (arch == 'x86' && !_is32BitArchitecture()) {
            matches = false;
          }
        }
      }

      if (matches) {
        shouldApply = action == 'allow';
      }
    }

    return shouldApply;
  }

  /// Evaluates feature flags in JVM rules.
  ///
  /// [rules] - List of JVM rule conditions to evaluate
  /// Returns true if all feature requirements are met, false otherwise.
  bool _evaluateFeatures(List<JvmRuleCondition> rules) {
    if (rules.isEmpty) {
      return true;
    }

    for (final rule in rules) {
      if (rule.features != null) {
        for (final feature in rule.features!.entries) {
          final key = feature.key;
          final expectedValue = feature.value;

          if (_featureFlags.containsKey(key)) {
            final actualValue = _featureFlags[key];
            if (expectedValue != actualValue) {
              return false;
            }
          } else {
            if (expectedValue == true) {
              return false;
            }
          }
        }
      }
    }

    return true;
  }

  /// Determines if the current architecture is 32-bit.
  ///
  /// Returns true if the architecture is 32-bit, false otherwise.
  bool _is32BitArchitecture() {
    if (Platform.isWindows) {
      return Platform.environment['PROCESSOR_ARCHITECTURE']?.toLowerCase() ==
          'x86';
    } else {
      return false;
    }
  }

  /// Replaces placeholders in a string with their values.
  ///
  /// [a] - String containing placeholders
  /// [b] - Placeholder pattern
  /// [c] - Optional replacement value
  /// Returns the string with placeholders replaced.
  String _replaceWithRegex(String a, String b, [String? c]) {
    if (c != null) {
      final RegExp placeholderPattern = RegExp(RegExp.escape(b));
      return a.replaceAll(placeholderPattern, c);
    } else {
      return a;
    }
  }
}
