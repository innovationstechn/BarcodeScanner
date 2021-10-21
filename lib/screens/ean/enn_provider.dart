import 'package:flutter/cupertino.dart';

class EANProvider extends ChangeNotifier{

  String eanCode="";

  setEAN(String barcode){
    eanCode = barcode;
    setState();
  }

  setState(){
    notifyListeners();
  }
}