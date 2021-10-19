import 'package:hive_flutter/adapters.dart';

part 'configuration_hive.g.dart';

@HiveType(typeId: 2)
class ConfigurationHive {
  @HiveField(0)
  String apiUrl;
  @HiveField(1)
  String deviceID;
  @HiveField(2)
  String key;

  ConfigurationHive({
    required this.apiUrl,
    required this.deviceID,
    required this.key,
  });
}
