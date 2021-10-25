import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';
import 'package:serial_number_barcode_scanner/models/sn.dart';
import 'package:serial_number_barcode_scanner/routes.dart';
import 'package:serial_number_barcode_scanner/screens/dnn/dnn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/ean/enn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/final/final_provider.dart';
import 'package:serial_number_barcode_scanner/screens/snn/snn_provider.dart';
import 'package:serial_number_barcode_scanner/state/configuration_state.dart';
import 'package:serial_number_barcode_scanner/state/uploading_state.dart';
import 'package:serial_number_barcode_scanner/widgets/customize_widgets_mixin.dart';

import 'api/data_uploader.dart';
import 'models/configuration_hive.dart';
import 'models/ean_model.dart';
import 'models/upload_item.dart';

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
      home: MyHome(),
      onGenerateRoute: Routes.generateRoute,
    ),
  ));
}

Future<void> _initHive() async {
  Hive.registerAdapter(UploadItemAdapter());
  Hive.registerAdapter(DNNAdapter());
  Hive.registerAdapter(EANModelAdapter());
  Hive.registerAdapter(SNAdapter());
  Hive.registerAdapter(ConfigurationHiveAdapter());

  await Hive.initFlutter();
  await DataUploader.initialize();
  await ConfigurationState.initialize();
}

class MyHome extends StatelessWidget with CustomizeWidgets {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: Consumer<ConfigurationState>(
        builder: (context, configModel, child) {
          return Consumer<UploadingState>(builder: (context, model, child) {
            return Padding(
                padding: const EdgeInsets.all(30),
                child: Column(children: [
                  customizeExpandableFittedBox(
                      context,
                      2,
                      const Center(
                          child: Text(
                        "Barcode Scanner",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
                  customizeExpandableFittedBox(
                      context,
                      3,
                      Column(
                        children: [
                          if (model.isUploading)
                            const Center(
                              child: SizedBox(
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ),
                            )
                          else if (model.itemsNeedToBeUploaded)
                            const Center(
                                child: Text(
                              "UNSENT SERIALS",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            )),
                          if (model.itemsNeedToBeUploaded)
                            customizeButton(
                              "SEND MANUALLY",
                              150,
                              () async {
                                String response = await model
                                    .upload(configModel.configuration!);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response),
                                  ),
                                );
                              },
                            ),
                        ],
                      )),
                  customizeExpandableFittedBox(
                      context,
                      2,
                      customizeButton(
                          "NEW SCAN",
                          150,
                          configModel.isConfigurationNeeded
                              ? null
                              : () async {
                                  Navigator.pushNamed(context, 'dnn')
                                      .then((value) => {
                                            Provider.of<DNNProvider>(context,
                                                    listen: false)
                                                .dnnCode = "",
                                            Provider.of<EANProvider>(context,
                                                    listen: false)
                                                .eanCode = "",
                                            Provider.of<SNNProvider>(context,
                                                    listen: false)
                                                .snnCodes = []
                                          });
                                })),
                  customizeExpandableFittedBox(
                      context,
                      2,
                      customizeButton("CONFIGURATION", 80, () async {
                        Navigator.pushNamed(context, 'configuration');
                      }, color: Colors.red))
                ]));
          });
        },
      )),
    );
  }
}
