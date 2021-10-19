import 'package:flutter/cupertino.dart';

class ENNProvider extends ChangeNotifier{

  String ennCode="";

  setENN(String barcode){
    ennCode = barcode;
    setState();
  }

  setState(){
    notifyListeners();
  }
}