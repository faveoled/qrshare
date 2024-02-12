import 'dart:io';

import 'package:qrshare/QrcpConfig.dart';

extension StringExtensions on String {
  String removeTrailingSlash() {
    if (endsWith('/')) {
      return substring(0, length - 1);
    } else {
      return this;
    }
  }
}

class ConfigStorage {

  void ensureDirectory(String filePath) {
    final dirPath = Directory(filePath).parent.path;
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  String ensureConfigFile() {
    final envVar = Platform.environment['XDG_CONFIG_HOME'];
    final homeVar = Platform.environment['HOME'];
    if (homeVar == null) {
      throw Exception("HOME is not defined");
    }
    final targetVar = envVar ?? homeVar;
    var finalLocation = '${targetVar.removeTrailingSlash()}/.config/qrcp/config.yml';
    ensureDirectory(finalLocation);
    return finalLocation;
  }

  void writeConfig(QrcpConfig config) {
    var file = File(ensureConfigFile());
    file.writeAsStringSync(config.toYaml());
  }

  void writeFile(String content) {
    var file = File(ensureConfigFile());
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  String readConfigStr() {
    var file = File(ensureConfigFile());
    return file.readAsStringSync();
  }

  QrcpConfig readConfig() {
    if (!isConfigPresent()) {
      return QrcpConfig.getDefaults();
    }
    final configYaml = readConfigStr();
    return QrcpConfig.fromYaml(configYaml);
  }

  bool isConfigPresent() {
    var file = File((ensureConfigFile()));
    return file.existsSync();
  }
}
