import 'dart:io';

class Env {

  static String getDownloadDir() {
    final envVar = Platform.environment['XDG_DOWNLOAD_DIR'];
    final homeVar = Platform.environment['HOME'];
    if (homeVar == null) {
      throw Exception("HOME not defined");
    }
    final result = envVar ?? '$homeVar/Downloads';
    return result;
  }
}