import 'dart:io';

import 'package:qrshare/QrcpConfig.dart';

class ConfigStorage {

  String getConfigFile() {
    final envVar = Platform.environment['XDG_CONFIG_HOME'];
    final homeVar = Platform.environment['HOME'];
    if (homeVar == null) {
      throw Exception("HOME is not defined");
    }
    final targetVar = envVar ?? homeVar;
    return '$targetVar/.config/qrcp/config.yml';
  }

  void writeConfig(QrcpConfig config) {
    var file = File(getConfigFile());
    file.writeAsStringSync(config.toYaml());
  }

  void writeFile(String content) {
    var file = File(getConfigFile());
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  String readConfigStr() {
    var file = File(getConfigFile());
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
    var file = File((getConfigFile()));
    return file.existsSync();
  }
}