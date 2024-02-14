import 'dart:io';
import 'package:path/path.dart';
import 'package:qrshare/QrcpConfig.dart';
import 'package:qrshare/StringExtensions.dart';

class ConfigStorage {

  void ensureDirectory(String filePath) {
    final dirPath = Directory(filePath).parent.path;
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  String ensureConfigFile() {
    String locationBase;
    if (Platform.isWindows) {
      final envVar = Platform.environment["LOCALAPPDATA"];
      if (envVar == null) {
        throw Exception("LOCALAPPDATA is not defined");
      }
      locationBase = envVar;
    } else {
      final envVar = Platform.environment['XDG_CONFIG_HOME'];
      final homeVar = Platform.environment['HOME'];
      if (envVar == null && homeVar == null) {
        throw Exception("XDG_CONFIG_HOME and HOME is not defined");
      }
      if (envVar != null) {
        locationBase = envVar;
      } else {
        locationBase = join(homeVar!.withoutTrailingSlash(), ".config");
      }
    }
    final finalLocation = join(locationBase.withoutTrailingSlash(), "qrcp", "config.yml");
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
