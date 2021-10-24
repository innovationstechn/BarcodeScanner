import 'package:hive/hive.dart';
import 'package:serial_number_barcode_scanner/models/sn.dart';

part 'ean_model.g.dart';

@HiveType(typeId: 4)
class EANModel {
  @HiveField(0)
  String eanCode;
  @HiveField(1)
  List<SN> snnCodes = [];

  EANModel({required this.eanCode, required this.snnCodes});

  List<String> toJson() {
    return snnCodes.map((e) => e.toJson()).toList();
  }
}
