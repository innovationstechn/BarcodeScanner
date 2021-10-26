import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:serial_number_barcode_scanner/models/configuration_hive.dart';

// Exposes methods for saving and reading Configurations from the database.
// Also provides updates to the UI when Configurations are saved
// in the database.
class ConfigurationState extends ChangeNotifier {
  // Is Hive ready for interacting with the database?
  static bool _initialized = false;
  // For interacting with the stored data.
  static Box<ConfigurationHive>? _box;

  // Ready Hive for reading data from the database.
  static Future<void> initialize() async {
    _box = await Hive.openBox("configuration");
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  // A configuration is 'set' as long as it has been stored once.
  bool get isConfigurationNeeded => _box!.get('configuration') == null;

  // Retrieve Configuration from the database.
  ConfigurationHive? get configuration => _box!.get('configuration');

  // Save configuration in the database.
  Future<void> setConfiguration(ConfigurationHive configuration) async {
    await _box!.put('configuration', configuration);
    notifyListeners();
  }
}
