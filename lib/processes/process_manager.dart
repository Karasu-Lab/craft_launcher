import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/interfaces/vanilla_launcher_interface.dart';
import 'package:flutter/foundation.dart';

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
