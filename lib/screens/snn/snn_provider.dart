import 'package:flutter/cupertino.dart';
import 'package:serial_number_barcode_scanner/models/ean_model.dart';

class SNNProvider extends ChangeNotifier{

  List<EANModel> eanList=[];
  List<String> snnCodes = [];

  void add(var scanData){
    if (!snnCodes.contains(scanData.code.toString())) {
      snnCodes.add(scanData.code.toString());
    }
    setState();
  }

  void remove(int index){
    snnCodes.removeAt(
        snnCodes.length - index - 1);
    setState();
  }

  String getQRCode(int index){
    return snnCodes.elementAt(
        snnCodes.length - 1 - index);
  }

  void setState(){
    notifyListeners();
  }
}