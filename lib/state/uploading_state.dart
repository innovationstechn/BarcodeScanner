import 'package:flutter/foundation.dart';
import 'package:serial_number_barcode_scanner/api/data_uploader.dart';
import 'package:serial_number_barcode_scanner/models/upload_item.dart';

class UploadingState extends ChangeNotifier {
  late DataUploader _dataUploader;

  bool get itemsNeedToBeUploaded =>
      !_dataUploader.isUploading && _dataUploader.itemsAreQueued;

  bool get isUploading => _dataUploader.isUploading;

  UploadingState() {
    _dataUploader = DataUploader(
      uploadingDone: () => notifyListeners(),
      uploadingFailed: () => notifyListeners(),
      startedUploading: () => notifyListeners(),
    );
  }
  // check Wait

  Future<void> queue(UploadItem item) => _dataUploader.queueItem(item);

  Future<void> upload() => _dataUploader.upload();
}
