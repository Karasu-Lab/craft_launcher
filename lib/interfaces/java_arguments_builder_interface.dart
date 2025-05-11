import 'package:craft_launcher_core/models/versions/version_info.dart';

abstract interface class JavaArgumentsBuilderInterface {
  JavaArgumentsBuilderInterface setGameDir(String gameDir);
  JavaArgumentsBuilderInterface setVersion(String version);
  JavaArgumentsBuilderInterface addClassPaths(List<String> classPaths);
  JavaArgumentsBuilderInterface setNativesDir(String nativesDir);
  JavaArgumentsBuilderInterface setClientJar(String clientJarPath);
  JavaArgumentsBuilderInterface setMainClass(String mainClass);
  JavaArgumentsBuilderInterface addAdditionalArguments(String? additionalArgs);
  JavaArgumentsBuilderInterface addGameArguments(Arguments? arguments);
  String build();
}
