import 'package:flutter/cupertino.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';
import 'package:serial_number_barcode_scanner/models/ean_model.dart';
import 'package:serial_number_barcode_scanner/models/sn.dart';


class FinalProvider extends ChangeNotifier{
  List<DNN> dnnList = [];
  List<EANModel> eanOfLastDNNScanned = [];

  void addDNN(String dnn, String ean, List<String> snnCodes) {
    //Store enn scan at last.
    eanOfLastDNNScanned.add(EANModel(
        eanCode: ean, snnCodes: snnCodes.map((e) => SN(sn: e)).toList()));
    // Store DNN
    dnnList.add(DNN(dnn: dnn, eanList: eanOfLastDNNScanned));

    eanOfLastDNNScanned = [];
  }

  void addEAN(String ean, List<String> snnCodes) {
    eanOfLastDNNScanned.add(EANModel(
        eanCode: ean, snnCodes: snnCodes.map((e) => SN(sn: e)).toList()));
  }
}
