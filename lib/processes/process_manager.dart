import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:craft_launcher_core/craft_launcher_core.dart';
import 'package:craft_launcher_core/interfaces/vanilla_launcher_interface.dart';
import 'package:flutter/foundation.dart';

class MinecraftProcessInfo {
  final int pid;

  final String versionId;

  final MinecraftAuth? auth;

  final Process process;

  MinecraftProcessInfo({
    required this.pid,
    required this.versionId,
    required this.process,
    this.auth,
  });
}

class ProcessManager {
  static final ProcessManager _instance = ProcessManager._internal();

  final Map<int, MinecraftProcessInfo> _runningProcesses = {};

  factory ProcessManager() {
    return _instance;
  }

  ProcessManager._internal();

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
        final output = utf8.decode(data);
        debugPrint('Minecraft stdout [${process.pid}]: $output');
        onStdout(output);
      });
    } else {
      process.stdout.listen((data) {
        debugPrint('Minecraft stdout [${process.pid}]: ${utf8.decode(data)}');
      });
    }

    if (onStderr != null) {
      process.stderr.listen((data) {
        final output = utf8.decode(data);
        debugPrint('Minecraft stderr [${process.pid}]: $output');
        onStderr(output);
      });
    } else {
      process.stderr.listen((data) {
        debugPrint('Minecraft stderr [${process.pid}]: ${utf8.decode(data)}');
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

  void terminateAllProcesses() {
    for (final pid in _runningProcesses.keys.toList()) {
      terminateProcess(pid);
    }
  }

  List<MinecraftProcessInfo> getProcessesByUser(String uuid) {
    return _runningProcesses.values
        .where((process) => process.auth?.uuid == uuid)
        .toList();
  }

  List<MinecraftProcessInfo> getAllProcesses() {
    return _runningProcesses.values.toList();
  }

  bool isProcessRunning(int pid) {
    return _runningProcesses.containsKey(pid);
  }
}
