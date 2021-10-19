// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigurationHiveAdapter extends TypeAdapter<ConfigurationHive> {
  @override
  final int typeId = 2;

  @override
  ConfigurationHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigurationHive(
      apiUrl: fields[0] as String,
      deviceID: fields[1] as String,
      key: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConfigurationHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.apiUrl)
      ..writeByte(1)
      ..write(obj.deviceID)
      ..writeByte(2)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
