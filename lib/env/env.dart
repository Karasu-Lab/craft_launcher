import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'AZURE_APP_CLIENT_ID')
  static final String azureAppClientId = _Env.azureAppClientId;
}
