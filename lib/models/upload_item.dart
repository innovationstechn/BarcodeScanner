import 'package:hive_flutter/adapters.dart';

part 'upload_item.g.dart';

@HiveType(typeId: 1)
class UploadItem {
  @HiveField(0)
  String data;
  @HiveField(1)
  String checksum;
  @HiveField(2)
  String id;
  @HiveField(3)
  String url;

  UploadItem(
      {required this.checksum,
      required this.data,
      required this.id,
      required this.url});

}
