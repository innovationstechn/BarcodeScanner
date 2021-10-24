import 'package:hive/hive.dart';

part 'sn.g.dart';

@HiveType(typeId: 5)
class SN {
  @HiveField(0)
  final String sn;

  SN({required this.sn});

  String toJson() => sn;

  @override
  String toString() => sn;
}
