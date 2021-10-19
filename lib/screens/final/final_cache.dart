import 'package:serial_number_barcode_scanner/models/dnn_model.dart';
import 'package:serial_number_barcode_scanner/models/enn_model.dart';
import 'package:serial_number_barcode_scanner/models/sn.dart';
import 'package:serial_number_barcode_scanner/screens/enn/enn.dart';

class FinalCache {
  static List<DNN> dnnList = [];
  static List<ENNModel> ennOfLastDNNScanned = [];

  static addDNN(String dnn, String enn, List<String> ssnCodes) {
    //Store enn scan at last.
    ennOfLastDNNScanned.add(ENNModel(
        ennCode: enn, ssnCodes: ssnCodes.map((e) => SN(sn: e)).toList()));
    // Store DNN
    dnnList.add(DNN(dnn: dnn, ennList: ennOfLastDNNScanned));

    ennOfLastDNNScanned = [];
  }

  static addENN(String enn, List<String> ssnCodes) {
    ennOfLastDNNScanned.add(ENNModel(
        ennCode: enn, ssnCodes: ssnCodes.map((e) => SN(sn: e)).toList()));
  }
}
