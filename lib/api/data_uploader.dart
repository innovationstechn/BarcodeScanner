import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:serial_number_barcode_scanner/models/configuration_hive.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';
import 'package:serial_number_barcode_scanner/utils/encoding_utils.dart';
import 'package:tuple/tuple.dart';

class DataUploader {
  static Box<DNN>? _box;
  static bool _initialized = false;
  bool isUploading = false;
  final void Function(String) uploadingDone;
  final void Function() uploadingFailed;
  final void Function() startedUploading;

  static Future<void> initialize() async {
    _box = await Hive.openBox("queued");
    _initialized = true;
  }

  DataUploader(
      {required this.uploadingDone,
      required this.uploadingFailed,
      required this.startedUploading});

  bool get isInitialized => _initialized;

  bool get itemsAreQueued => _box!.isNotEmpty;

  Future _queueItem(DNN item) => _box!.add(item);

  Future _dequeueItem(int index) => _box!.deleteAt(index);

  DNN? _readItem(int index) => _box!.getAt(index);
  List<DNN>? _readAllItems() => _box!.values.toList();

  Future<void> _dropAllItems() => _box!.clear();

  Future<void> queueItem(DNN item) => _queueItem(item);

  Future<String> upload(ConfigurationHive configuration) async {
    if (isUploading) return "Uploading...";

    String response = "?";

    isUploading = true;
    startedUploading();

    try {
      if (itemsAreQueued) {
        List<DNN>? items = _readAllItems();

        final data = <String, Map<String, List<String>>>{};

        for (var element in items!) {
          data[element.dnn] = element.toJson();
        }

        Tuple2<String, String> processed =
            scannedToEncodings(data, configuration.key);

        log('Data: ${processed.item1}');
        log('Checksum: ${processed.item2}');

        final serverResponse = await http.get(
          Uri.parse(
            '${configuration.apiUrl}/?data=${processed.item1}&checksum=${processed.item2}&id=${configuration.deviceID}&debug=0',
          ),
        );

        response = serverResponse.body;
        response = "Server Response:  $response";

        log(response);

        if (serverResponse.body == 'OK') {
          await _box!.clear();
          log("Cleared all items from the queue!");
        }
      }

      uploadingDone(response);
    } catch (e) {
      response = "Could not send data to server.";
      isUploading = false;
      uploadingFailed();
    } finally {
      isUploading = false;
    }

    return response;
  }
}
