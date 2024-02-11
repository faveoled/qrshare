import 'package:qrshare/Env.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

class QrcpConfig {
  String? interface;
  String? bind;
  int? port;
  String? path;
  String? output;
  String? fqdn;
  bool? keepAlive;
  bool? secure;
  String? tlsCert;
  String? tlsKey;

  QrcpConfig(this.interface,
      this.bind,
      this.port,
      this.path,
      this.output,
      this.fqdn,
      this.keepAlive,
      this.secure,
      this.tlsCert,
      this.tlsKey);

  factory QrcpConfig.getDefaults() {
    return QrcpConfig(
        'any',
        '0.0.0.0', null, null, Env.getDownloadDir(), null, false, false, null, null
    );
  }

  factory QrcpConfig.fromYaml(String yamlString) {
    final yamlMap = loadYaml(yamlString);

    return QrcpConfig(
      yamlMap['interface'] as String?,
      yamlMap['bind'] as String?,
      yamlMap['port'] as int?,
      yamlMap['path'] as String?,
      yamlMap['output'] as String?,
      yamlMap['fqdn'] as String?,
      yamlMap['keepAlive'] as bool?,
      yamlMap['secure'] as bool?,
      yamlMap['tlsCert'] as String?,
      yamlMap['tlsKey'] as String?
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'interface': interface,
      'bind': bind,
      'port': port,
      'path': path,
      'output': output,
      'fqdn': fqdn,
      'keepAlive': keepAlive,
      'secure': secure,
      'tlsCert': tlsCert,
      'tlsKey': tlsKey,
    }..removeWhere((key, value) => value == null);
  }

  final yamlWriter = YamlWriter();

  String toYaml() {
    return yamlWriter.write(toMap());
  }


  QrcpConfig copy() {
    return QrcpConfig(
      interface,
      bind,
      port,
      path,
      output,
      fqdn,
      keepAlive,
      secure,
      tlsCert,
      tlsKey,
    );
  }
}
