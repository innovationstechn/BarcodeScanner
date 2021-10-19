
import 'package:serial_number_barcode_scanner/models/enn_model.dart';

class DNN{
  String dnn;
  List<ENNModel> ennList=[];

  DNN({required this.dnn,required this.ennList});

  Map<String, List<String>> toJson() {
    Map<String, List<String>> json = Map();


    ennList.forEach((element) {
      print("ENNList:"+element.toString());
      json[element.ennCode] = element.toJson();
    });
// send it. Code ko seedha baad ma karay gay.
    return json;
  }

}