import 'package:hive_flutter/adapters.dart';

part 'configuration_hive.g.dart';

// Contains data associated with the configuration input by the user.
@HiveType(typeId: 2)
class ConfigurationHive {
  // The URL to which data will be uploaded.
  @HiveField(0)
  String apiUrl;
  // The id assigned to the device which is uploading the data.
  @HiveField(1)
  String deviceID;
  // Key for salting the checksum.
  @HiveField(2)
  String key;

  ConfigurationHive({
    required this.apiUrl,
    required this.deviceID,
    required this.key,
  });
}
