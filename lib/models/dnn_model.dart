import 'package:serial_number_barcode_scanner/models/ean_model.dart';

class DNN{
  String dnn;
  List<EANModel> eanList=[];

  DNN({required this.dnn,required this.eanList});

  Map<String, List<String>> toJson() {
    Map<String, List<String>> json = Map();

    eanList.forEach((element) {
      print("EANList:"+element.toString());
      json[element.eanCode] = element.toJson();
    });

    return json;
  }

}