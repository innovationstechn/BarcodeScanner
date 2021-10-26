import 'package:hive/hive.dart';
import 'package:serial_number_barcode_scanner/models/sn.dart';

part 'ean_model.g.dart';

// Represents a scanned European Article Number.
// Annotated with Hive as this item is saved in the database (within DNNs).
@HiveType(typeId: 4)
class EANModel {
  // The scanned EAN.
  @HiveField(0)
  String eanCode;
  // SN barcodes associated with this EAN.
  @HiveField(1)
  List<SN> snnCodes = [];

  EANModel({required this.eanCode, required this.snnCodes});

  // For converting this EAN to the specified JSON format provided
  // in the documentation.
  List<String> toJson() {
    return snnCodes.map((e) => e.toJson()).toList();
  }
}
