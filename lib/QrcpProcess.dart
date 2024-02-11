import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qrshare/Env.dart';
import 'package:qrshare/ErrorsModel.dart';

class QrcpProcess {

  Future<(Future<String>, Process)> runSend(BuildContext context, String? interface, List<String> fileNames) async {
    return runProcess(context, 'qrcp', [ '-i', interface ?? 'any' ] + fileNames);
  }

  Future<(Future<String>, Process)> runReceive(BuildContext context, String? interface) async {
    return runProcess(context, 'qrcp', [ '-i', interface ?? 'any', 'receive']);
  }

  Future<(Future<String>, Process)> runProcess(BuildContext context, String cmd, List<String> arguments) async {
    print("Running cmd: $cmd: args: $arguments");
    Process process = await Process.start(cmd, arguments, workingDirectory: Env.getDownloadDir());

    final outBuff = StringBuffer();

    Completer<String> completer = Completer();

    process.stdout.transform(utf8.decoder).listen((data) {
      print('qrcp: $data');
      if (!completer.isCompleted) {
        outBuff.write(data);
        for (var line in LineSplitter.split(outBuff.toString())) {
          if (line.startsWith("http")) {
            completer.complete(line);
            break;
          }
        }
      }
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      final errorsModel = context.read<ErrorsModel>();
      errorsModel.write("qrcp err: $data");
    });
    return (completer.future, process);
  }
}