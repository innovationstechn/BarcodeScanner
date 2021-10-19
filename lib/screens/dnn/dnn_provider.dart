import 'package:flutter/cupertino.dart';

class DNNProvider extends ChangeNotifier{

  String dnnCode="";

  setBarCode(String barcode){
    dnnCode = barcode;
    setState();
  }

  setState(){
    notifyListeners();
  }
}