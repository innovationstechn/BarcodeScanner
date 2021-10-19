import 'package:serial_number_barcode_scanner/models/sn.dart';

class ENNModel {
  String ennCode;
  List<SN> ssnCodes = [];

  ENNModel({required this.ennCode, required this.ssnCodes});

  List<String> toJson() {
    return ssnCodes.map((e) => e.toJson()).toList();
  }
}
