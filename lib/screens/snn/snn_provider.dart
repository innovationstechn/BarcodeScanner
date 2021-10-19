import 'package:flutter/cupertino.dart';
import 'package:serial_number_barcode_scanner/models/enn_model.dart';

class SSNProvider extends ChangeNotifier{

  List<ENNModel> ennList=[];
  List<String> ssnCodes = [];

  void add(var scanData){
    if (!ssnCodes.contains(scanData.code.toString())) {
      ssnCodes.add(scanData.code.toString());
      notifyListeners();
    }
  }

  void remove(int index){
    ssnCodes.removeAt(
        ssnCodes.length - index - 1);
    notifyListeners();
  }

  String getQRCode(int index){
    return ssnCodes.elementAt(
        ssnCodes.length - 1 - index);
  }

}