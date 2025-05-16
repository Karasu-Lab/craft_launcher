import 'package:flutter_test/flutter_test.dart';
import 'package:craft_launcher_core/models/versions/version_manifest_v2.dart';
import 'package:craft_launcher_core/models/news.dart';
import 'package:craft_launcher_core/models/alert_messaging.dart';
import 'package:craft_launcher_core/models/versions/version_info.dart';
import 'package:craft_launcher_core/models/versions/jre_manifest.dart';

void main() {
  group('VersionManifestV2 model parsing tests', () {
    test('Can correctly parse VersionManifestV2 from valid JSON', () {
      final Map<String, dynamic> mockJson = {
        'latest': {'release': '1.20.2', 'snapshot': '23w40a'},
        'versions': [
          {'id': '1', 'type': 'release', 'url': 'https://example.com/1'},
          {'id': '2', 'type': 'snapshot', 'url': 'https://example.com/2'},
          {'id': '3', 'type': 'beta', 'url': 'https://example.com/3'},
        ],
      };

      final VersionManifestV2 result = VersionManifestV2.fromJson(mockJson);

      expect(result, isA<VersionManifestV2>());
      expect(result.latest.release, equals('1.20.2'));
      expect(result.latest.snapshot, equals('23w40a'));
      expect(result.versions.length, equals(3));
      expect(result.versions[0].id, equals('1'));
      expect(result.versions[1].type, equals('snapshot'));
      expect(result.versions[2].url, equals('https://example.com/3'));
    });

    test('Can correctly parse even with an empty version list', () {
      final Map<String, dynamic> mockJson = {
        'latest': {'release': '1.20.2', 'snapshot': '23w40a'},
        'versions': [],
      };

      final VersionManifestV2 result = VersionManifestV2.fromJson(mockJson);

      expect(result, isA<VersionManifestV2>());
      expect(result.latest.release, equals('1.20.2'));
      expect(result.latest.snapshot, equals('23w40a'));
      expect(result.versions.length, equals(0));
    });

    test('toJson method correctly converts to JSON', () {
      final Latest latest = Latest(release: '1.20.2', snapshot: '23w40a');
      final List<Version> versions = [
        Version(id: '1', type: 'release', url: 'https://example.com/1'),
        Version(id: '2', type: 'snapshot', url: 'https://example.com/2'),
        Version(id: '3', type: 'beta', url: 'https://example.com/3'),
      ];
      final VersionManifestV2 versionManifest = VersionManifestV2(
        latest: latest,
        versions: versions,
      );

      final Map<String, dynamic> result = versionManifest.toJson();

      expect(result, isA<Map<String, dynamic>>());

      expect(result['latest'], isNotNull);
      final latest1 = result['latest'] as dynamic;
      expect(latest1.release, equals('1.20.2'));
      expect(latest1.snapshot, equals('23w40a'));

      expect(result['versions'], isNotNull);
      expect(result['versions'].length, equals(2));
      final version0 = result['versions'][0] as dynamic;
      final version1 = result['versions'][1] as dynamic;
      expect(version0.id, equals('1'));
      expect(version1.id, equals('2'));
    });
  });

  group('News model parsing tests', () {
    test('Can correctly parse News from valid JSON', () {
      final Map<String, dynamic> mockJson = {
        'version': 1,
        'entries': [
          {
            'title': 'Latest Minecraft News',
            'tag': 'Update',
            'category': 'game',
            'date': '2025-05-11',
            'text': 'New features have been added',
            'id': '1',
          },
          {
            'title': 'Minecraft Dungeons',
            'tag': 'DLC',
            'category': 'dungeons',
            'date': '2025-05-10',
            'text': 'New DLC released',
            'id': '2',
          },
        ],
      };

      final News result = News.fromJson(mockJson);
      expect(result, isA<News>());
      expect(result.version, equals(1));
      expect(result.entries.length, equals(2));
      expect(result.entries[0].title, equals('Latest Minecraft News'));
      expect(result.entries[0].tag, equals('Update'));
      expect(result.entries[1].title, equals('Minecraft Dungeons'));
      expect(result.entries[1].date, equals('2025-05-10'));
    });

    test('Can parse correctly with empty entries', () {
      final Map<String, dynamic> mockJson = {'version': 1, 'entries': []};

      final News result = News.fromJson(mockJson);

      expect(result, isA<News>());
      expect(result.version, equals(1));
      expect(result.entries.length, equals(0));
    });

    test('toJson method correctly converts to JSON', () {
      final List<LauncherNews> entries = [
        LauncherNews(
          title: 'Latest Minecraft News',
          tag: 'Update',
          category: 'game',
          date: '2025-05-11',
          text: 'New features have been added',
          id: '1',
        ),
      ];
      final News news = News(version: 1, entries: entries);

      final Map<String, dynamic> result = news.toJson();

      expect(result, isA<Map<String, dynamic>>());
      expect(result['version'], equals(1));
      expect(result['entries'].length, equals(1));
      expect(result['entries'][0]['title'], equals('Latest Minecraft News'));
      expect(result['entries'][0]['tag'], equals('Update'));
    });
  });

  group('AlertMessaging model parsing tests', () {
    test('Can correctly parse AlertMessaging from valid JSON', () {
      final Map<String, dynamic> mockJson = {
        'version': 1,
        'entries': [
          {
            'message': 'Server maintenance in progress',
            'severity': 'high',
            'timestamp': '2025-05-11T12:00:00Z',
          },
          {
            'message': 'New version has been released',
            'severity': 'low',
            'timestamp': '2025-05-10T10:00:00Z',
          },
        ],
      };

      final AlertMessaging result = AlertMessaging.fromJson(mockJson);

      expect(result, isA<AlertMessaging>());
      expect(result.version, equals(1));
      expect(result.entries.length, equals(2));
      expect(
        result.entries[0]['message'],
        equals('Server maintenance in progress'),
      );
      expect(result.entries[0]['severity'], equals('high'));
      expect(
        result.entries[1]['message'],
        equals('New version has been released'),
      );
    });

    test('Can parse correctly with empty entries', () {
      final Map<String, dynamic> mockJson = {'version': 1, 'entries': []};

      final AlertMessaging result = AlertMessaging.fromJson(mockJson);

      expect(result, isA<AlertMessaging>());
      expect(result.version, equals(1));
      expect(result.entries.length, equals(0));
    });

    test('toJson method correctly converts to JSON', () {
      final List<dynamic> entries = [
        {
          'message': 'Server maintenance in progress',
          'severity': 'high',
          'timestamp': '2025-05-11T12:00:00Z',
        },
      ];
      final AlertMessaging alertMessaging = AlertMessaging(
        version: 1,
        entries: entries,
      );

      final Map<String, dynamic> result = alertMessaging.toJson();

      expect(result, isA<Map<String, dynamic>>());
      expect(result['version'], equals(1));
      expect(result['entries'].length, equals(1));
      expect(
        result['entries'][0]['message'],
        equals('Server maintenance in progress'),
      );
      expect(result['entries'][0]['severity'], equals('high'));
    });
  });

  group('JRE Manifest model parsing tests', () {
    test('Can correctly parse JRE Manifest from valid JSON', () {
      final Map<String, dynamic> mockJson = {
        'manifest': {
          'gamecore': {
            'java-runtime-alpha': [
              {
                'availability': {'group': 1, 'progress': 100},
                'manifest': {
                  'sha1': 'abcdef1234567890',
                  'size': 12345678,
                  'url': 'https://example.com/jdk-17.0.1-gamecore.zip',
                },
                'version': {'name': '17.0.1', 'released': '2023-01-01'},
              },
            ],
            'java-runtime-beta': [],
            'java-runtime-delta': [],
            'java-runtime-gamma': [],
            'java-runtime-gamma-snapshot': [],
            'jre-legacy': [],
            'minecraft-java-exe': [],
          },
          'linux': {
            'java-runtime-alpha': [
              {
                'availability': {'group': 1, 'progress': 100},
                'manifest': {
                  'sha1': 'abcdef1234567890',
                  'size': 12345678,
                  'url': 'https://example.com/jdk-17.0.1-linux.tar.gz',
                },
                'version': {'name': '17.0.1', 'released': '2023-01-01'},
              },
            ],
            'java-runtime-beta': [],
            'java-runtime-delta': [],
            'java-runtime-gamma': [],
            'java-runtime-gamma-snapshot': [],
            'jre-legacy': [],
            'minecraft-java-exe': [],
          },
          'linux-i386': {
            'java-runtime-alpha': [],
            'java-runtime-beta': [],
            'java-runtime-delta': [],
            'java-runtime-gamma': [],
            'java-runtime-gamma-snapshot': [],
            'jre-legacy': [],
            'minecraft-java-exe': [],
          },
          'mac-os': {
            'java-runtime-alpha': [],
            'java-runtime-beta': [],
            'java-runtime-delta': [],
            'java-runtime-gamma': [],
            'java-runtime-gamma-snapshot': [],
            'jre-legacy': [],
            'minecraft-java-exe': [],
          },
          'mac-os-arm64': {
            'java-runtime-alpha': [],
            'java-runtime-beta': [],
            'java-runtime-delta': [],
            'java-runtime-gamma': [],
            'java-runtime-gamma-snapshot': [],
            'jre-legacy': [],
            'minecraft-java-exe': [],
          },
          'windows-arm64': {
            'java-runtime-alpha': [],
            'java-runtime-beta': [],
            'java-runtime-delta': [],
            'java-runtime-gamma': [],
            'java-runtime-gamma-snapshot': [],
            'jre-legacy': [],
            'minecraft-java-exe': [],
          },
          'windows-x64': {
            'java-runtime-alpha': [
              {
                'availability': {'group': 1, 'progress': 100},
                'manifest': {
                  'sha1': 'abcdef1234567890',
                  'size': 12345678,
                  'url': 'https://example.com/jdk-17.0.1-windows-x64.zip',
                },
                'version': {'name': '17.0.1', 'released': '2023-01-01'},
              },
            ],
            'java-runtime-beta': [],
            'java-runtime-delta': [],
            'java-runtime-gamma': [],
            'java-runtime-gamma-snapshot': [],
            'jre-legacy': [],
            'minecraft-java-exe': [],
          },
          'windows-x86': {
            'java-runtime-alpha': [],
            'java-runtime-beta': [],
            'java-runtime-delta': [],
            'java-runtime-gamma': [],
            'java-runtime-gamma-snapshot': [],
            'jre-legacy': [],
            'minecraft-java-exe': [],
          },
        },
      };

      final JreManifest result = JreManifest.fromJson(mockJson);

      expect(result, isA<JreManifest>());
      expect(result.manifest, isNotNull);
      expect(result.manifest.windowsX64.javaRuntimeAlpha, isNotEmpty);
      expect(
        result.manifest.windowsX64.javaRuntimeAlpha[0].version!.name,
        equals('17.0.1'),
      );
      expect(
        result.manifest.linux.javaRuntimeAlpha[0].manifest!.url,
        contains('linux.tar.gz'),
      );
      expect(
        result.manifest.gamecore.javaRuntimeAlpha[0].availability!.progress,
        equals(100),
      );
    });

    test('toJson method correctly converts to JSON', () {
      final JavaRuntime javaRuntime = JavaRuntime(
        availability: Availability(group: 1, progress: 100),
        manifest: ManifestFileInfo(
          sha1: 'abcdef1234567890',
          size: 12345678,
          url: 'https://example.com/jdk-17.0.1-windows-x64.zip',
        ),
        version: JavaRuntimeVersionInfo(name: '17.0.1', released: '2023-01-01'),
      );

      final PlatformJavaRuntimes platformJavaRuntimes = PlatformJavaRuntimes(
        javaRuntimeAlpha: [javaRuntime],
        javaRuntimeBeta: [],
        javaRuntimeDelta: [],
        javaRuntimeGamma: [],
        javaRuntimeGammaSnapshot: [],
        jreLegacy: [],
        minecraftJavaExe: [],
      );

      final ManifestData manifestData = ManifestData(
        gamecore: platformJavaRuntimes,
        linux: platformJavaRuntimes,
        linuxI386: platformJavaRuntimes,
        macOs: platformJavaRuntimes,
        macOsArm64: platformJavaRuntimes,
        windowsArm64: platformJavaRuntimes,
        windowsX64: platformJavaRuntimes,
        windowsX86: platformJavaRuntimes,
      );

      final JreManifest jreManifest = JreManifest(manifest: manifestData);

      final Map<String, dynamic> result = jreManifest.toJson();

      expect(result, isA<Map<String, dynamic>>());
      expect(result['manifest'], isNotNull);
      expect(result['manifest']['windows-x64'], isNotNull);
      expect(
        result['manifest']['windows-x64']['java-runtime-alpha'],
        isNotEmpty,
      );
      expect(
        result['manifest']['windows-x64']['java-runtime-alpha'][0]['version']['name'],
        equals('17.0.1'),
      );
    });
  });

  group('Version Info model parsing tests', () {
    test('Can correctly parse VersionInfo from valid JSON', () {
      final Map<String, dynamic> mockJson = {
        'id': '1.20.2',
        'type': 'release',
        'mainClass': 'net.minecraft.client.main.Main',
        'minecraftArguments':
            '--username \${auth_player_name} --version \${version_name}',
        'arguments': {
          'game': [
            '--username',
            '\${auth_player_name}',
            '--version',
            '\${version_name}',
          ],
          'jvm': ['-Xmx2G', '-XX:+UnlockExperimentalVMOptions'],
        },
        'assetIndex': {
          'id': '1.20',
          'sha1': 'abcdef1234567890',
          'size': 12345,
          'totalSize': 67890,
          'url': 'https://example.com/assets/1.20/index.json',
        },
        'assets': '1.20',
        'complianceLevel': 1,
        'downloads': {
          'client': {
            'sha1': 'abcdef1234567890',
            'size': 12345678,
            'url': 'https://example.com/client-1.20.2.jar',
          },
          'server': {
            'sha1': '0987654321fedcba',
            'size': 87654321,
            'url': 'https://example.com/server-1.20.2.jar',
          },
        },
        'javaVersion': {'component': 'java-runtime-gamma', 'majorVersion': 17},
        'libraries': [
          {
            'name': 'com.mojang:minecraft:1.20.2',
            'downloads': {
              'artifact': {
                'path': 'com/mojang/minecraft/1.20.2/minecraft-1.20.2.jar',
                'sha1': 'abcdef1234567890',
                'size': 12345678,
                'url': 'https://example.com/minecraft-1.20.2.jar',
              },
            },
          },
        ],
        'logging': {
          'client': {
            'argument': '-Dlog4j.configurationFile=\${path}',
            'file': {
              'id': 'client-1.20.2-log4j2.xml',
              'sha1': 'abcdef1234567890',
              'size': 1234,
              'url': 'https://example.com/client-1.20.2-log4j2.xml',
            },
            'type': 'log4j2-xml',
          },
        },
        'minimumLauncherVersion': 21,
        'releaseTime': '2025-05-10T10:00:00Z',
        'time': '2025-05-11T12:00:00Z',
      };

      final VersionInfo result = VersionInfo.fromJson(mockJson);

      expect(result, isA<VersionInfo>());
      expect(result.id, equals('1.20.2'));
      expect(result.type, equals('release'));
      expect(result.mainClass, equals('net.minecraft.client.main.Main'));
      expect(result.assets, equals('1.20'));
      expect(result.complianceLevel, equals(1));
      expect(result.javaVersion!.component, equals('java-runtime-gamma'));
      expect(result.javaVersion!.majorVersion, equals(17));
      expect(result.assetIndex!.id, equals('1.20'));
      expect(result.arguments!.game!.length, equals(4));
      expect(result.arguments!.jvm!.length, equals(2));
      expect(result.downloads!.client!.url, contains('client-1.20.2.jar'));
      expect(result.libraries!.length, equals(1));
    });

    test('Can correctly parse with inheritsFrom in JSON', () {
      final Map<String, dynamic> mockJson = {
        'id': 'forge-1.20.2',
        'inheritsFrom': '1.20.2',
        'type': 'modified',
        'mainClass': 'net.minecraftforge.client.main.Main',
        'arguments': {
          'game': ['--fml.forgeVersion', '47.1.0', '--fml.mcVersion', '1.20.2'],
        },
        'libraries': [
          {
            'name': 'net.minecraftforge:forge:1.20.2-47.1.0',
            'downloads': {
              'artifact': {
                'path':
                    'net/minecraftforge/forge/1.20.2-47.1.0/forge-1.20.2-47.1.0.jar',
                'sha1': 'abcdef1234567890',
                'size': 12345678,
                'url': 'https://example.com/forge-1.20.2-47.1.0.jar',
              },
            },
          },
        ],
        'releaseTime': '2025-05-10T10:00:00Z',
        'time': '2025-05-11T12:00:00Z',
      };

      final VersionInfo result = VersionInfo.fromJson(mockJson);

      expect(result, isA<VersionInfo>());
      expect(result.id, equals('forge-1.20.2'));
      expect(result.inheritsFrom, equals('1.20.2'));
      expect(result.type, equals('modified'));
      expect(result.mainClass, equals('net.minecraftforge.client.main.Main'));
      expect(result.arguments!.game!.length, equals(4));
      expect(result.libraries!.length, equals(1));
    });

    test('toJson method correctly converts to JSON', () {
      final VersionInfo versionInfo = VersionInfo(
        id: '1.20.2',
        type: 'release',
        mainClass: 'net.minecraft.client.main.Main',
        assets: '1.20',
        complianceLevel: 1,
        javaVersion: JavaVersion(
          component: 'java-runtime-gamma',
          majorVersion: 17,
        ),
        assetIndex: AssetIndex(
          id: '1.20',
          url: 'https://example.com/assets/1.20/index.json',
        ),
        time: '2025-05-11T12:00:00Z',
        releaseTime: '2025-05-10T10:00:00Z',
      );

      final Map<String, dynamic> result = versionInfo.toJson();

      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], equals('1.20.2'));
      expect(result['type'], equals('release'));
      expect(result['mainClass'], equals('net.minecraft.client.main.Main'));
      expect(result['assets'], equals('1.20'));
      expect(result['complianceLevel'], equals(1));
      expect(result['javaVersion']['component'], equals('java-runtime-gamma'));
      expect(result['javaVersion']['majorVersion'], equals(17));
      expect(result['assetIndex']['id'], equals('1.20'));
    });
  });
}
