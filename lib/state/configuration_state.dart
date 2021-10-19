import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:serial_number_barcode_scanner/models/configuration_hive.dart';


class ConfigurationState extends ChangeNotifier {
  static bool _initialized = false;
  static Box<ConfigurationHive>? _box;

  static Future<void> initialize() async {
    _box = await Hive.openBox("configuration");
    _initialized = true;
  }

  bool get isInitialized => _initialized;
  bool get isConfigurationNeeded => _box!.get('configuration') == null;

  ConfigurationHive? get configuration => _box!.get('configuration');
  Future<void> setConfiguration(ConfigurationHive configuration) async {
    await _box!.put('configuration', configuration);
    notifyListeners();
  }
}
