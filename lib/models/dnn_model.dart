import 'package:hive/hive.dart';
import 'package:serial_number_barcode_scanner/models/ean_model.dart';

part 'dnn_model.g.dart';

@HiveType(typeId: 3)
class DNN {
  @HiveField(0)
  String dnn;
  @HiveField(1)
  List<EANModel> eanList = [];

  DNN({required this.dnn, required this.eanList});

  Map<String, List<String>> toJson() {
    Map<String, List<String>> json = {};

    for (var element in eanList) {
      json[element.eanCode] = element.toJson();
    }

    return json;
  }
}
