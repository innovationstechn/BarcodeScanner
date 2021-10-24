import 'package:flutter/foundation.dart';
import 'package:serial_number_barcode_scanner/api/data_uploader.dart';
import 'package:serial_number_barcode_scanner/models/configuration_hive.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';

class UploadingState extends ChangeNotifier {
  late DataUploader _dataUploader;

  bool get itemsNeedToBeUploaded =>
      !_dataUploader.isUploading && _dataUploader.itemsAreQueued;

  bool get isUploading => _dataUploader.isUploading;

  UploadingState() {
    _dataUploader = DataUploader(
      uploadingDone: (String response) => notifyListeners(),
      uploadingFailed: () => notifyListeners(),
      startedUploading: () => notifyListeners(),
    );
  }
  // check Wait

  Future<void> queue(DNN item) => _dataUploader.queueItem(item);

  Future<String> upload(ConfigurationHive configuration) =>
      _dataUploader.upload(configuration);
}
