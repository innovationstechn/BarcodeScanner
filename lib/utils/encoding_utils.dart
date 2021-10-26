import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:tuple/tuple.dart';

// Takes a Map [scanned] which mirrors the format specified in the documentation
// and produces base64 encoded data along with a checksum of base64 encoded data
// (salted with [key]) as specified in the documentation.
Tuple2<String, String> scannedToEncodings(Map scanned, String key) {
  final jsonEncoded = jsonEncode(scanned);
  final base64 = const Base64Encoder().convert(jsonEncoded.codeUnits);
  final htmlEncoded = Uri.encodeQueryComponent(base64);
  final checksum = sha256.convert(htmlEncoded.codeUnits).toString();
  final checksum2 =
      sha256.convert([...checksum.codeUnits, ...key.codeUnits]).toString();

  return Tuple2(htmlEncoded, checksum2);
}
