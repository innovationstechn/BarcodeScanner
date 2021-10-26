import 'package:hive/hive.dart';
import 'package:serial_number_barcode_scanner/models/ean_model.dart';

part 'dnn_model.g.dart';

// Represents a scanned Delivery Note Number.
// Annotated with Hive as this item is saved in the database.
@HiveType(typeId: 3)
class DNN {
  // The scanned dnn.
  @HiveField(0)
  String dnn;
  // EAN barcodes associated with this DNN.
  @HiveField(1)
  List<EANModel> eanList = [];

  DNN({required this.dnn, required this.eanList});

  // For converting this DNN to the specified JSON format provided
  // in the documentation.
  Map<String, List<String>> toJson() {
    Map<String, List<String>> json = {};

    for (var element in eanList) {
      json[element.eanCode] = element.toJson();
    }

    return json;
  }
}
