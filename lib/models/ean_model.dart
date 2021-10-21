import 'package:serial_number_barcode_scanner/models/sn.dart';

class EANModel {
  String eanCode;
  List<SN> snnCodes = [];

  EANModel({required this.eanCode, required this.snnCodes});

  List<String> toJson() {
    return snnCodes.map((e) => e.toJson()).toList();
  }
}
