import 'dart:io';

import 'package:craft_launcher_core/interfaces/java_arguments_builder_interface.dart';
import 'package:craft_launcher_core/models/jvm_rule.dart';
import 'package:craft_launcher_core/models/versions/version_info.dart';

enum ArgumentType { jvm, game }

class JavaArgumentsBuilder implements JavaArgumentsBuilderInterface {
  String? _gameDir;
  String? _version;
  final List<String> _classPaths = [];
  String? _nativesDir;
  String? _clientJar;
  String? _mainClass;
  String? _additionalArgs;
  Arguments? _arguments;
  String? _minecraftArguments;

  String? _assetsIndexName;
  String? _authPlayerName;
  String? _authUuid;
  String? _authAccessToken;
  String? _clientId;
  String? _authXuid;
  String? _userType;
  String _launcherName = 'CraftLauncher';
  String _launcherVersion = '1.0.0';

  final Map<String, bool> _featureFlags = {
    'is_demo_user': false,
    'has_custom_resolution': false,
    'has_quick_plays_support': false,
    'is_quick_play_singleplayer': false,
    'is_quick_play_multiplayer': false,
    'is_quick_play_realms': false,
  };

  int _width = 854;
  int _height = 480;

  String? _quickPlayPath;
  String? _quickPlaySingleplayer;
  String? _quickPlayMultiplayer;
  String? _quickPlayRealms;

  JavaArgumentsBuilder({String? launcherName, String? launcherVersion}) {
    _launcherName = launcherName ?? 'CraftLauncher';
    _launcherVersion = launcherVersion ?? '1.0.0';
  }

  @override
  JavaArgumentsBuilder setGameDir(String gameDir) {
    _gameDir = gameDir;
    return this;
  }

  @override
  JavaArgumentsBuilder setVersion(String version) {
    _version = version;
    return this;
  }

  @override
  JavaArgumentsBuilder addClassPaths(List<String> classPaths) {
    _classPaths.addAll(classPaths);
    return this;
  }

  @override
  JavaArgumentsBuilder setNativesDir(String nativesDir) {
    _nativesDir = nativesDir;
    return this;
  }

  @override
  JavaArgumentsBuilder setClientJar(String clientJarPath) {
    _clientJar = clientJarPath;
    if (!_classPaths.contains(clientJarPath)) {
      _classPaths.add(clientJarPath);
    }
    return this;
  }

  @override
  JavaArgumentsBuilder setMainClass(String mainClass) {
    _mainClass = mainClass;
    return this;
  }

  @override
  JavaArgumentsBuilder addAdditionalArguments(String? additionalArgs) {
    _additionalArgs = additionalArgs;
    return this;
  }

  @override
  JavaArgumentsBuilder addGameArguments(Arguments? arguments) {
    _arguments = arguments;
    return this;
  }

  JavaArgumentsBuilder setAssetsIndexName(String assetsIndexName) {
    _assetsIndexName = assetsIndexName;
    return this;
  }

  JavaArgumentsBuilder setAuthPlayerName(String authPlayerName) {
    _authPlayerName = authPlayerName;
    return this;
  }

  JavaArgumentsBuilder setAuthUuid(String authUuid) {
    _authUuid = authUuid;
    return this;
  }

  JavaArgumentsBuilder setAuthAccessToken(String? authAccessToken) {
    _authAccessToken = authAccessToken;
    return this;
  }

  JavaArgumentsBuilder setClientId(String clientId) {
    _clientId = clientId;
    return this;
  }

  JavaArgumentsBuilder setAuthXuid(String authXuid) {
    _authXuid = authXuid;
    return this;
  }

  JavaArgumentsBuilder setUserType(String userType) {
    _userType = userType;
    return this;
  }

  JavaArgumentsBuilder setLauncherName(String launcherName) {
    _launcherName = launcherName;
    return this;
  }

  JavaArgumentsBuilder setLauncherVersion(String launcherVersion) {
    _launcherVersion = launcherVersion;
    return this;
  }

  JavaArgumentsBuilder setMinecraftArguments(String minecraftArguments) {
    _minecraftArguments = minecraftArguments;
    return this;
  }

  String? getMinecraftArguments() => _minecraftArguments;

  // フラグ設定メソッド
  JavaArgumentsBuilder setDemoUser(bool isDemo) {
    _featureFlags['is_demo_user'] = isDemo;
    return this;
  }

  JavaArgumentsBuilder setCustomResolution(int width, int height) {
    _featureFlags['has_custom_resolution'] = true;
    _width = width;
    _height = height;
    return this;
  }

  JavaArgumentsBuilder setQuickPlaySupport(String path) {
    _featureFlags['has_quick_plays_support'] = true;
    _quickPlayPath = path;
    return this;
  }

  JavaArgumentsBuilder setQuickPlaySingleplayer(String levelName) {
    _featureFlags['is_quick_play_singleplayer'] = true;
    _quickPlaySingleplayer = levelName;
    return this;
  }

  JavaArgumentsBuilder setQuickPlayMultiplayer(String serverAddress) {
    _featureFlags['is_quick_play_multiplayer'] = true;
    _quickPlayMultiplayer = serverAddress;
    return this;
  }

  JavaArgumentsBuilder setQuickPlayRealms(String realmId) {
    _featureFlags['is_quick_play_realms'] = true;
    _quickPlayRealms = realmId;
    return this;
  }

  // ゲッター
  String? getGameDir() => _gameDir;
  String? getVersion() => _version;
  List<String> getClassPaths() => List.unmodifiable(_classPaths);
  String? getNativesDir() => _nativesDir;
  String? getClientJar() => _clientJar;
  String? getMainClass() => _mainClass;
  String? getAdditionalArgs() => _additionalArgs;
  Arguments? getArguments() => _arguments;
  String? getAssetsIndexName() => _assetsIndexName;
  String? getAuthPlayerName() => _authPlayerName;
  String? getAuthUuid() => _authUuid;
  String? getAuthAccessToken() => _authAccessToken;
  String? getClientId() => _clientId;
  String? getAuthXuid() => _authXuid;
  String? getUserType() => _userType;
  String getLauncherName() => _launcherName;
  String getLauncherVersion() => _launcherVersion;

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

  bool _is32BitArchitecture() {
    if (Platform.isWindows) {
      return Platform.environment['PROCESSOR_ARCHITECTURE']?.toLowerCase() ==
          'x86';
    } else {
      return false;
    }
  }

  String _replaceWithRegex(String a, String b, [String? c]) {
    if (c != null) {
      final RegExp placeholderPattern = RegExp(RegExp.escape(b));
      return a.replaceAll(placeholderPattern, c);
    } else {
      return a;
    }
  }
}
