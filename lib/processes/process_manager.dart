import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/interfaces/vanilla_launcher_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Contains information about a running Minecraft process.
class MinecraftProcessInfo {
  /// Process identifier.
  final int pid;

  /// Version of Minecraft being run.
  final String versionId;

  /// Authentication details for the player.
  final MinecraftAuth? auth;

  /// Reference to the actual process.
  final Process process;

  /// Creates a new MinecraftProcessInfo instance.
  ///
  /// [pid] - Process identifier
  /// [versionId] - Version of Minecraft
  /// [process] - Reference to the actual process
  /// [auth] - Optional authentication details
  MinecraftProcessInfo({
    required this.pid,
    required this.versionId,
    required this.process,
    this.auth,
  });
}

/// Manages Minecraft processes including starting, monitoring, and terminating them.
class ProcessManager {
  /// Singleton instance of the ProcessManager.
  static final ProcessManager _instance = ProcessManager._internal();

  /// Map of currently running processes, keyed by process ID.
  final Map<int, MinecraftProcessInfo> _runningProcesses = {};

  /// Factory constructor that returns the singleton instance.
  factory ProcessManager() {
    return _instance;
  }

  /// Private constructor for singleton pattern.
  ProcessManager._internal();

  /// Starts a new Minecraft process.
  ///
  /// [javaExe] - Path to the Java executable
  /// [javaArgs] - Arguments to pass to Java
  /// [workingDirectory] - Working directory for the process
  /// [environment] - Environment variables for the process
  /// [versionId] - Version of Minecraft to run
  /// [auth] - Optional authentication details
  /// [onStdout] - Optional callback for standard output
  /// [onStderr] - Optional callback for standard error
  /// [onExit] - Optional callback for when the process exits
  /// Returns information about the started process.
  Future<MinecraftProcessInfo> startProcess({
    required String javaExe,
    required List<String> javaArgs,
    required String workingDirectory,
    required Map<String, String> environment,
    required String versionId,
    MinecraftAuth? auth,
    JavaStdoutCallback? onStdout,
    JavaStderrCallback? onStderr,
    JavaExitCallback? onExit,
  }) async {
    // On Windows, use a batch file to avoid command line length limitations
    if (Platform.isWindows) {
      return startProcessWithBatchFile(
        javaExe: javaExe,
        javaArgs: javaArgs,
        workingDirectory: workingDirectory,
        environment: environment,
        versionId: versionId,
        auth: auth,
        onStdout: onStdout,
        onStderr: onStderr,
        onExit: onExit,
      );
    }

    final process = await Process.start(
      javaExe,
      javaArgs,
      workingDirectory: workingDirectory,
      environment: environment,
    );

    final processInfo = MinecraftProcessInfo(
      pid: process.pid,
      versionId: versionId,
      process: process,
      auth: auth,
    );

    _runningProcesses[process.pid] = processInfo;

    if (onStdout != null) {
      process.stdout.listen((data) {
        final output = utf8.decode(data, allowMalformed: true);
        debugPrint('Minecraft stdout [${process.pid}]: $output');
        onStdout(output);
      });
    } else {
      process.stdout.listen((data) {
        debugPrint(
          'Minecraft stdout [${process.pid}]: ${utf8.decode(data, allowMalformed: true)}',
        );
      });
    }

    if (onStderr != null) {
      process.stderr.listen((data) {
        final output = utf8.decode(data, allowMalformed: true);
        debugPrint('Minecraft stderr [${process.pid}]: $output');
        onStderr(output);
      });
    } else {
      process.stderr.listen((data) {
        debugPrint(
          'Minecraft stderr [${process.pid}]: ${utf8.decode(data, allowMalformed: true)}',
        );
      });
    }

    process.exitCode.then((exitCode) {
      debugPrint(
        'Minecraft process ${process.pid} exited with code: $exitCode',
      );
      _runningProcesses.remove(process.pid);

      if (onExit != null) {
        onExit(exitCode);
      }
    });

    debugPrint(
      'Minecraft process started: PID=${process.pid}, User=${auth?.userName ?? "anonymous"}, Version=$versionId',
    );
    return processInfo;
  }

  /// Starts a new Minecraft process using a temporary batch file on Windows.
  ///
  /// This method works around Windows path length limitations by creating a temporary
  /// batch file containing the Java command and its arguments. The batch file is then
  /// executed using Process.start.
  ///
  /// [javaExe] - Path to the Java executable
  /// [javaArgs] - Arguments to pass to Java
  /// [workingDirectory] - Working directory for the process
  /// [environment] - Environment variables for the process
  /// [versionId] - Version of Minecraft to run
  /// [auth] - Optional authentication details
  /// [onStdout] - Optional callback for standard output
  /// [onStderr] - Optional callback for standard error
  /// [onExit] - Optional callback for when the process exits
  /// Returns information about the started process.
  Future<MinecraftProcessInfo> startProcessWithBatchFile({
    required String javaExe,
    required List<String> javaArgs,
    required String workingDirectory,
    required Map<String, String> environment,
    required String versionId,
    MinecraftAuth? auth,
    JavaStdoutCallback? onStdout,
    JavaStderrCallback? onStderr,
    JavaExitCallback? onExit,
  }) async {
    // Create a temporary directory for batch file
    final tempDir = await Directory.systemTemp.createTemp(
      'minecraft_launcher_',
    );
    final batchFilePath = path.join(tempDir.path, 'run_minecraft.bat');

    // Escape javaExe path if it contains spaces
    final escapedJavaExe = javaExe.contains(' ') ? '"$javaExe"' : javaExe;

    // Build batch file content
    // @echo off disables command echoing
    // The exit /b %ERRORLEVEL% ensures the batch file returns the Java process exit code
    final batchContent =
        '@echo off\r\n'
        '$escapedJavaExe ${javaArgs.join(' ')}\r\n'
        'exit /b %ERRORLEVEL%';

    // Write batch file
    await File(batchFilePath).writeAsString(
      batchContent,
    ); // Start the process with hidden console window
    // Using normal mode instead of detached to ensure stdio is connected
    // while still hiding the console window in Windows
    final process = await Process.start(
      batchFilePath,
      [],
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: true,
    );

    final processInfo = MinecraftProcessInfo(
      pid: process.pid,
      versionId: versionId,
      process: process,
      auth: auth,
    );

    _runningProcesses[process.pid] = processInfo;

    // Handle stdout
    if (onStdout != null) {
      process.stdout.listen((data) {
        final output = utf8.decode(data, allowMalformed: true);
        debugPrint('Minecraft stdout [${process.pid}]: $output');
        onStdout(output);
      });
    } else {
      process.stdout.listen((data) {
        debugPrint(
          'Minecraft stdout [${process.pid}]: ${utf8.decode(data, allowMalformed: true)}',
        );
      });
    }

    // Handle stderr
    if (onStderr != null) {
      process.stderr.listen((data) {
        final output = utf8.decode(data, allowMalformed: true);
        debugPrint('Minecraft stderr [${process.pid}]: $output');
        onStderr(output);
      });
    } else {
      process.stderr.listen((data) {
        debugPrint(
          'Minecraft stderr [${process.pid}]: ${utf8.decode(data, allowMalformed: true)}',
        );
      });
    }

    // Handle process exit and cleanup
    process.exitCode.then((exitCode) {
      debugPrint(
        'Minecraft process ${process.pid} exited with code: $exitCode',
      );
      _runningProcesses.remove(process.pid);

      // Cleanup: Delete the temporary batch file and directory
      try {
        File(batchFilePath).deleteSync();
        tempDir.deleteSync(recursive: true);
      } catch (e) {
        debugPrint('Error cleaning up temporary files: $e');
      }

      if (onExit != null) {
        onExit(exitCode);
      }
    });

    debugPrint(
      'Minecraft process started with batch file: PID=${process.pid}, User=${auth?.userName ?? "anonymous"}, Version=$versionId',
    );
    return processInfo;
  }

  /// Terminates a running Minecraft process.
  ///
  /// [pid] - Process identifier to terminate
  /// Returns true if the process was successfully terminated, false otherwise.
  bool terminateProcess(int pid) {
    final processInfo = _runningProcesses[pid];
    if (processInfo != null) {
      try {
        processInfo.process.kill();
        return true;
      } catch (e) {
        debugPrint('Error terminating process $pid: $e');
        return false;
      }
    }
    return false;
  }

  /// Terminates all running Minecraft processes.
  void terminateAllProcesses() {
    for (final pid in _runningProcesses.keys.toList()) {
      terminateProcess(pid);
    }
  }

  /// Gets a list of processes for a specific user.
  ///
  /// [uuid] - UUID of the user
  /// Returns a list of process information for the specified user.
  List<MinecraftProcessInfo> getProcessesByUser(String uuid) {
    return _runningProcesses.values
        .where((process) => process.auth?.uuid == uuid)
        .toList();
  }

  /// Gets a list of all running Minecraft processes.
  ///
  /// Returns a list of all process information.
  List<MinecraftProcessInfo> getAllProcesses() {
    return _runningProcesses.values.toList();
  }

  /// Checks if a process with the specified ID is running.
  ///
  /// [pid] - Process identifier to check
  /// Returns true if the process is running, false otherwise.
  bool isProcessRunning(int pid) {
    return _runningProcesses.containsKey(pid);
  }
}
