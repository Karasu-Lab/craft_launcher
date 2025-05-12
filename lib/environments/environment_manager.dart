import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// 環境変数を管理するためのクラス。
/// MinecraftのJavaランチャー実行時の環境変数を設定します。
class EnvironmentManager {
  /// ネイティブライブラリのパスを環境変数に追加します。
  /// 
  /// [nativesPath]: ネイティブライブラリの場所
  /// [environment]: 既存の環境変数（デフォルトはPlatform.environment）
  /// 
  /// プラットフォームに応じて適切な環境変数を設定します:
  /// - Windows: PATH
  /// - Linux: LD_LIBRARY_PATH
  /// - macOS: LD_LIBRARY_PATH および DYLD_LIBRARY_PATH
  static Map<String, String> configureEnvironment({
    required String nativesPath,
    Map<String, String>? environment,
  }) {
    final envVars = Map<String, String>.from(environment ?? Platform.environment);
    
    if (Platform.isWindows) {
      final String currentPath = envVars['PATH'] ?? '';
      envVars['PATH'] = '$nativesPath;$currentPath';
      
      debugPrint('Added natives directory to PATH: $nativesPath');
      debugPrint('Java library path: -Djava.library.path=$nativesPath');
    } else {
      final String currentLdLibraryPath = envVars['LD_LIBRARY_PATH'] ?? '';
      envVars['LD_LIBRARY_PATH'] = '$nativesPath:$currentLdLibraryPath';

      if (Platform.isMacOS) {
        final String currentDyldLibraryPath = envVars['DYLD_LIBRARY_PATH'] ?? '';
        envVars['DYLD_LIBRARY_PATH'] = '$nativesPath:$currentDyldLibraryPath';
      }
      
      debugPrint('Added natives directory to LD_LIBRARY_PATH: $nativesPath');
    }
    
    return envVars;
  }
  
  /// Java実行ファイルのパスを正規化して返します。
  /// 
  /// [javaDir]: Javaのインストールディレクトリ
  static String getJavaExecutablePath(String javaDir) {
    return p.normalize(
      p.join(javaDir, 'bin', Platform.isWindows ? 'javaw.exe' : 'java'),
    );
  }
  
  /// パスを正規化します
  static String normalizePath(String path) {
    return p.normalize(path);
  }
}
