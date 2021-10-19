import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:serial_number_barcode_scanner/models/upload_item.dart';

class DataUploader {
  static Box<UploadItem>? _box;
  static bool _initialized = false;
  bool isUploading = false;
  final void Function() uploadingDone;
  final void Function() uploadingFailed;
  final void Function() startedUploading;

  static Future<void> initialize() async {
    _box = await Hive.openBox("queued");
    _initialized = true;
  }

  DataUploader({required this.uploadingDone, required this.uploadingFailed, required this.startedUploading});

  bool get isInitialized => _initialized;

  bool get itemsAreQueued => _box!.isNotEmpty;

  Future _queueItem(UploadItem item) => _box!.add(item);

  Future _dequeueItem(int index) => _box!.deleteAt(index);

  UploadItem? _readItem(int index) => _box!.getAt(index);

  Future<void> queueItem(UploadItem item) => _queueItem(item);

  Future<void> upload() async {
    if (isUploading) return;

    isUploading = true;
    startedUploading();

    try {
      while (itemsAreQueued) {
        UploadItem item = _readItem(0)!;

        final response = await http.get(Uri.parse(
            '${item.url}/?data=${item.data}&checksum=${item.checksum}&id=${item.id}&debug=1'));

        // print("Item number  ${response.body}");
        await _dequeueItem(0);
      }

      uploadingDone();
    } catch (e) {
      isUploading = false;
      uploadingFailed();
    } finally {
      isUploading = false;
    }
  }
}
