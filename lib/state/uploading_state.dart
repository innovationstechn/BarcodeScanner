import 'package:flutter/foundation.dart';
import 'package:serial_number_barcode_scanner/api/data_uploader.dart';
import 'package:serial_number_barcode_scanner/models/configuration_hive.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';

// Exposes methods for uploading data, as well as for keeping track of
// the uploading process and to-be-uploaded items.
class UploadingState extends ChangeNotifier {
  late DataUploader _dataUploader;

  // Should upload process be started?
  bool get itemsNeedToBeUploaded =>
      !_dataUploader.isUploading && _dataUploader.itemsAreQueued;

  // Is data being uploaded?
  bool get isUploading => _dataUploader.isUploading;

  UploadingState() {
    // Utility class, provides updates to the UI when an upload event occurs.
    _dataUploader = DataUploader(
      uploadingDone: (String response) => notifyListeners(),
      uploadingFailed: () => notifyListeners(),
      startedUploading: () => notifyListeners(),
    );
  }

  // Save an item to the database for uploading later.
  Future<void> queue(DNN item) => _dataUploader.queueItem(item);

  // Start the uploading process with [configuration] parameters.
  //
  // The UI will be provided updates about this upload process.
  Future<String> upload(ConfigurationHive configuration) =>
      _dataUploader.upload(configuration);
}
