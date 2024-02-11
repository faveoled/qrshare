import 'package:qrshare/ConfigStorage.dart';
import 'package:qrshare/QrcpConfig.dart';

class CachingConfigStorage extends ConfigStorage {

  // Private constructor
  CachingConfigStorage._private();

  static final CachingConfigStorage instance = CachingConfigStorage._private();

  static const readCfgKey = "CONFIG_FILE";

  final Map<String, QrcpConfig> _cache = {};

  @override
  QrcpConfig readConfig() {
    final found = _cache[readCfgKey];
    if (found != null) {
      return _cache[readCfgKey]!;
    }
    final config = super.readConfig();
    _cache[readCfgKey] = config;
    return config;
  }

  @override
  void writeConfig(QrcpConfig config) {
    super.writeConfig(config);
    _cache[readCfgKey] = config;
  }

  @override
  void writeFile(String content) {
    super.writeFile(content);
    _cache.clear();
  }
}
