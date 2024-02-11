import 'package:test/test.dart';
import 'package:qrshare/QrcpConfig.dart';

void main() {
  test('QrcpConfig constructor sets correct values', () {
    final config = QrcpConfig(
      'interface',
      'bind',
      8080,
      'path',
      'output',
      'fqdn',
      true,
      true,
      'tlsCert',
      'tlsKey',
    );

    expect(config.interface, 'interface');
    expect(config.bind, 'bind');
    expect(config.port, 8080);
    expect(config.path, 'path');
    expect(config.output, 'output');
    expect(config.fqdn, 'fqdn');
    expect(config.keepAlive, true);
    expect(config.secure, true);
    expect(config.tlsCert, 'tlsCert');
    expect(config.tlsKey, 'tlsKey');
  });

  test('QrcpConfig.fromYaml parses YAML string correctly', () {
    final yamlString = '''
interface: interface
bind: bind
port: 8080
path: path
output: output
fqdn: fqdn
keepAlive: true
secure: true
tlsCert: tlsCert
tlsKey: tlsKey
''';

    final config = QrcpConfig.fromYaml(yamlString);

    expect(config.interface, 'interface');
    expect(config.bind, 'bind');
    expect(config.port, 8080);
    expect(config.path, 'path');
    expect(config.output, 'output');
    expect(config.fqdn, 'fqdn');
    expect(config.keepAlive, true);
    expect(config.secure, true);
    expect(config.tlsCert, 'tlsCert');
    expect(config.tlsKey, 'tlsKey');
  });



  test('QrcpConfig.fromYaml reads partial yaml', () {
    final yamlString = '''
interface: 'interface'
port: 1234
''';

    final config = QrcpConfig.fromYaml(yamlString);

    expect(config.interface, 'interface');
    expect(config.bind, null);
    expect(config.port, 1234);
    expect(config.path, null);
    expect(config.output, null);
    expect(config.fqdn, null);
    expect(config.keepAlive, null);
    expect(config.secure, null);
    expect(config.tlsCert, null);
    expect(config.tlsKey, null);
  });

  test('QrcpConfig.toYaml converts to YAML string correctly', () {
    final config = QrcpConfig(
      'interface',
      'bind',
      8080,
      'path',
      'output',
      'fqdn',
      true,
      true,
      'tlsCert',
      'tlsKey',
    );

    final yamlString = config.toYaml();

    expect(yamlString, '''
interface: 'interface'
bind: 'bind'
port: 8080
path: 'path'
output: 'output'
fqdn: 'fqdn'
keepAlive: true
secure: true
tlsCert: 'tlsCert'
tlsKey: 'tlsKey'
''');
  });


  test('QrcpConfig.toYaml writes partial object', () {
    final config = QrcpConfig(
      'interface',
      'bind',
      8080,
      'path',
      null,
      null,
      null,
      null,
      null,
      null,
    );

    final yamlString = config.toYaml();

    expect(yamlString, '''
interface: 'interface'
bind: 'bind'
port: 8080
path: 'path'
''');
  });
}
