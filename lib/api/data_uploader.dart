import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:serial_number_barcode_scanner/models/configuration_hive.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';
import 'package:serial_number_barcode_scanner/utils/encoding_utils.dart';
import 'package:tuple/tuple.dart';

// Stores items in the database for uploading later.
// Uploads data to the server and provides updates about the upload process.
class DataUploader {
  static Box<DNN>? _box;
  static bool _initialized = false;

  // Is set to true whenever this widget is uploading.
  bool isUploading = false;

  // These 3 function are called when uploading is finished, failed or started
  // respectively. Useful for updating the UI.
  final void Function(String) uploadingDone;
  final void Function() uploadingFailed;
  final void Function() startedUploading;

  // Get Hive ready to interact with stored data.
  static Future<void> initialize() async {
    _box = await Hive.openBox("queued");
    _initialized = true;
  }

  DataUploader(
      {required this.uploadingDone,
      required this.uploadingFailed,
      required this.startedUploading});

  // Is Hive ready to interact with the database?
  bool get isInitialized => _initialized;

  // Are there any items stored for uploading?
  bool get itemsAreQueued => _box!.isNotEmpty;

  // Store an [item] for uploading later.
  Future _queueItem(DNN item) => _box!.add(item);
  // Delete an item which was added for uploading at [index] position.
  Future _dequeueItem(int index) => _box!.deleteAt(index);
  // Read a DNN at position [index]
  DNN? _readItem(int index) => _box!.getAt(index);
  // Read all items in box and return them as a List (not an iterator).
  List<DNN>? _readAllItems() => _box!.values.toList();
  // Remove all all items from the current box.
  Future<void> _dropAllItems() => _box!.clear();
  // Store an [item] for uploading later.
  Future<void> queueItem(DNN item) => _queueItem(item);

  // Upload all stored items in the box with the [configuration]
  // provided by user.
  // Either returns 'Uploading...' if upload process is already started
  // or returns the result of upload process.
  // Also calls uploadingDone, uploadingFailed or uploadingDone based on the
  // result of upload process.
  Future<String> upload(ConfigurationHive configuration) async {
    if (isUploading) return "Uploading...";

    String response = "?";

    isUploading = true;
    startedUploading();

    try {
      if (itemsAreQueued) {
        // Get all the elements that need to be uploaded.
        List<DNN>? items = _readAllItems();

        final data = <String, Map<String, List<String>>>{};

        // Add all of the items in the map for converting
        // them into the specified JSON.
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

        // Items are only cleared from the database if the server responds
        // with OK.
        if (serverResponse.body == 'OK') {
          await _dropAllItems();
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
