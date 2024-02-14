import 'dart:io';

import 'package:path/path.dart';

class Env {

  static String getDownloadDir() {
    if (Platform.isWindows) {
      final prof = Platform.environment["USERPROFILE"];
      if (prof == null) {
        throw Exception("USERPROFILE not defined");
      }
      return join(prof, "Downloads");
    }

    final envVar = Platform.environment['XDG_DOWNLOAD_DIR'];
    final homeVar = Platform.environment['HOME'];
    if (homeVar == null) {
      throw Exception("HOME not defined");
    }
    final result = envVar ?? '$homeVar/Downloads';
    return result;
  }
}