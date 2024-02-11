import 'package:test/test.dart';
import 'package:qrshare/ConfigStorage.dart';
import 'dart:io';

void main() {
  test('Write file', () {
    var fileWriter = ConfigStorage();
    fileWriter.writeFile('Test content');

    var file = File('${Platform.environment['XDG_CONFIG_HOME']}/.config/qrcp/config.yml');
    expect(file.existsSync(), isTrue);
    expect(file.readAsStringSync(), 'Test content');
  });

  test('isConfigPresent', () {
    var file = File('${Platform.environment['XDG_CONFIG_HOME']}/.config/qrcp/config.yml');
    if (file.existsSync()) {
      file.deleteSync();
    }
    var config = ConfigStorage();
    expect(config.isConfigPresent(), isFalse);
    config.writeFile('test content');
    expect(config.isConfigPresent(), isTrue);
  });
}
