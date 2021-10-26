import 'package:hive/hive.dart';

part 'sn.g.dart';

// Represents a scanned Serial Number.
// Annotated with Hive as this item is saved in the database (within EANs).
@HiveType(typeId: 5)
class SN {
  // The scanned sn.
  @HiveField(0)
  final String sn;

  SN({required this.sn});

  // For converting this SN to the specified JSON format provided
  // in the documentation.
  String toJson() => sn;

  @override
  String toString() => sn;
}
