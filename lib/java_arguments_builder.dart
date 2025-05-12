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

  // 追加のフィールド
  String? _assetsIndexName;
  String? _authPlayerName;
  String? _authUuid;
  String? _authAccessToken;
  String? _clientId;
  String? _authXuid;
  String? _userType;
  String _launcherName = 'CraftLauncher';
  String _launcherVersion = '1.0.0';

  // 機能フラグ
  final Map<String, bool> _featureFlags = {
    'is_demo_user': false,
    'has_custom_resolution': false,
    'has_quick_plays_support': false,
    'is_quick_play_singleplayer': false,
    'is_quick_play_multiplayer': false,
    'is_quick_play_realms': false,
  };

  // 解像度
  int _width = 854; // デフォルト解像度を設定
  int _height = 480; // デフォルト解像度を設定

  // クイックプレイパス
  String? _quickPlayPath;
  String? _quickPlaySingleplayer;
  String? _quickPlayMultiplayer;
  String? _quickPlayRealms;

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

    // Javaコマンドの正しい順序: クラスパス、JVMオプション、メインクラス、アプリケーション引数
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

    // 変数名と対応する値のマッピング - すべてのフィールドを使用
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

    // オプション引数の先頭パターンリスト
    final List<String> optionPrefixes = ['--', '-', '-D'];

    // クラスパスが追加済みかどうかを追跡
    bool classPathAdded = false;

    // JavaVMの引数とMinecraftの起動引数を明確に分離
    if (type == ArgumentType.jvm) {
      // クラスパスを最初に追加（重複を避けるため）
      if (_classPaths.isNotEmpty && !classPathAdded) {
        processedArgs.add('-cp');
        processedArgs.add(_classPaths.join(Platform.isWindows ? ';' : ':'));
        classPathAdded = true;
      }
    }

    for (int i = 0; i < args.length; i++) {
      var arg = args[i];

      // クラスパスの重複を避ける
      if (arg is String && (arg == '-cp' || arg == '-classpath')) {
        if (classPathAdded) {
          // クラスパスがすでに追加されている場合は、この引数とその値をスキップ
          i++; // 次の引数（クラスパスの値）もスキップ
          continue;
        } else {
          classPathAdded = true;
        }
      }

      // 文字列引数の処理
      if (arg is String) {
        String processedArg = arg;

        // すべての変数置換を適用
        variableMap.forEach((key, value) {
          if (value != null) {
            processedArg = _replaceWithRegex(processedArg, '\${$key}', value);
          }
        });

        // インデックスが1以上で、前の引数とペアになっている場合の処理
        if (i > 0 &&
            processedArg.startsWith('\${') &&
            processedArg.endsWith('}')) {
          final previousArg =
              processedArgs.isNotEmpty ? processedArgs.last : null;

          // 前の引数がオプション引数かチェック
          bool isPreviousOption = false;
          for (final prefix in optionPrefixes) {
            if (previousArg != null && previousArg.startsWith(prefix)) {
              isPreviousOption = true;
              break;
            }
          }

          if (isPreviousOption) {
            // 変数名を取得 (${variable_name}から変数名部分を抽出)
            final varName = processedArg.substring(2, processedArg.length - 1);
            final value = variableMap[varName];

            // 値がnullの場合は前の引数も削除
            if (value == null) {
              processedArgs.removeLast(); // 前のオプション引数を削除
            } else {
              // 値がある場合は追加
              processedArgs.add(value);
            }
          } else {
            // 前の引数がオプション引数でない場合は通常通り追加
            if (!processedArg.startsWith('\${') ||
                !processedArg.endsWith('}')) {
              // 変数が置換されていれば追加
              processedArgs.add(processedArg);
            }
          }
        } else {
          // -Dで始まる引数は特別な処理（変数置換後に追加）
          if (processedArg.startsWith('-D')) {
            // -D引数内の変数が置換されたかチェック
            if (!processedArg.contains('\${')) {
              processedArgs.add(processedArg);
            }
          } else {
            // 通常の引数はそのまま追加
            processedArgs.add(processedArg);
          }
        }
        continue;
      }

      // Map型の引数(JvmRule)の処理
      if (arg is Map<String, dynamic>) {
        var jvmRule = JvmRule.fromJson(arg);
        bool shouldApply = _evaluateRules(jvmRule.rules);

        if (shouldApply) {
          // 特徴フラグに基づく評価を追加
          bool featuresMatch = _evaluateFeatures(jvmRule.rules);
          if (!featuresMatch) continue;

          if (jvmRule.value is String) {
            String value = jvmRule.value as String;

            // すべての変数置換を適用
            variableMap.forEach((key, varValue) {
              if (varValue != null) {
                value = _replaceWithRegex(value, '\${$key}', varValue);
              }
            });

            // 変数が正常に置換された場合のみ追加
            if (!value.contains('\${')) {
              processedArgs.add(value);
            }
          } else if (jvmRule.values != null) {
            List<String> valueList = jvmRule.values!;

            for (int j = 0; j < valueList.length; j++) {
              String value = valueList[j];

              // すべての変数置換を適用
              variableMap.forEach((key, varValue) {
                if (varValue != null) {
                  value = _replaceWithRegex(value, '\${$key}', varValue);
                }
              });

              // ペア引数の処理（リスト内でも同様に処理）
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
                  // 変数が置換された場合のみ追加
                  if (!value.contains('\${')) {
                    processedArgs.add(value);
                  }
                }
              } else {
                // 変数が置換された場合のみ追加
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

    // 変数名と対応する値のマッピング - 旧形式のMinecraft引数用
    final Map<String, String?> variableMap = {
      'version_name': _version,
      'version_type': 'release', // デフォルト値
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

    // オプション引数の先頭パターンリスト
    final List<String> optionPrefixes = ['--', '-', '-D'];

    for (int i = 0; i < argParts.length; i++) {
      var arg = argParts[i];
      
      // 引数の処理
      if (arg.startsWith('--') && i + 1 < argParts.length) {
        String nextArg = argParts[i + 1];
        
        // 次の引数が変数プレースホルダーの場合
        if (nextArg.startsWith('\${') && nextArg.endsWith('}')) {
          // 変数名を抽出
          final varName = nextArg.substring(2, nextArg.length - 1);
          final value = variableMap[varName];
          
          // 値が存在する場合のみ引数を追加
          if (value != null) {
            processedArgs.add(arg);
            processedArgs.add(value);
          }
          // 次の引数は既に処理したのでスキップ
          i++;
        } else {
          // 通常の引数の場合はそのまま追加
          processedArgs.add(arg);
          // 次の引数がオプションでなければ値として追加
          if (i + 1 < argParts.length && !argParts[i + 1].startsWith('--')) {
            processedArgs.add(argParts[i + 1]);
            i++;
          }
        }
      } else {
        // オプション以外の引数はそのまま追加
        String processedArg = arg;
        
        // 変数置換を適用
        variableMap.forEach((key, value) {
          if (value != null) {
            processedArg = _replaceWithRegex(processedArg, '\${$key}', value);
          }
        });
        
        // 変数が置換された場合のみ追加
        if (!processedArg.contains('\${')) {
          processedArgs.add(processedArg);
        }
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

  // 特徴フラグの評価用の新しい関数
  bool _evaluateFeatures(List<JvmRuleCondition> rules) {
    if (rules.isEmpty) {
      return true;
    }

    for (final rule in rules) {
      if (rule.features != null) {
        // featuresが存在する場合、それらが設定されているかチェック
        for (final feature in rule.features!.entries) {
          final key = feature.key;
          final expectedValue = feature.value;

          // _featureFlagsにあるフラグと比較
          if (_featureFlags.containsKey(key)) {
            final actualValue = _featureFlags[key];
            // 期待される値と実際の値が一致しない場合はfalseを返す
            if (expectedValue != actualValue) {
              return false;
            }
          } else {
            // フラグが設定されていない場合、期待値がtrueならfalseを返す
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
    // プラットフォームに応じて32ビットかどうかを判定
    if (Platform.isWindows) {
      return Platform.environment['PROCESSOR_ARCHITECTURE']?.toLowerCase() ==
          'x86';
    } else {
      // Linuxとmacでは通常64ビットですが、必要に応じて判定ロジックを追加
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
