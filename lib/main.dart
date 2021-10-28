import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';
import 'package:serial_number_barcode_scanner/models/ean_model.dart';
import 'package:serial_number_barcode_scanner/models/sn.dart';
import 'package:serial_number_barcode_scanner/routes.dart';
import 'package:serial_number_barcode_scanner/screens/dnn/dnn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/ean/enn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/final/final_provider.dart';
import 'package:serial_number_barcode_scanner/screens/snn/snn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/starting/starting.dart';
import 'package:serial_number_barcode_scanner/state/configuration_state.dart';
import 'package:serial_number_barcode_scanner/state/uploading_state.dart';
import 'api/data_uploader.dart';
import 'models/configuration_hive.dart';

void main() async {
  await _initHive();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DNNProvider>(create: (_) => DNNProvider()),
      ChangeNotifierProvider<EANProvider>(create: (_) => EANProvider()),
      ChangeNotifierProvider<SNNProvider>(create: (_) => SNNProvider()),
      ChangeNotifierProvider<ConfigurationState>(
          create: (_) => ConfigurationState()),
      ChangeNotifierProvider<UploadingState>(
          create: (context) => UploadingState()),
      ChangeNotifierProvider<FinalProvider>(create: (_) => FinalProvider()),
    ],
    child: const MaterialApp(
      home: StartingPage(),
      onGenerateRoute: Routes.generateRoute,
    ),
  ));
}

Future<void> _initHive() async {
  Hive.registerAdapter(DNNAdapter());
  Hive.registerAdapter(EANModelAdapter());
  Hive.registerAdapter(SNAdapter());
  Hive.registerAdapter(ConfigurationHiveAdapter());

  await Hive.initFlutter();
  await DataUploader.initialize();
  await ConfigurationState.initialize();
}

