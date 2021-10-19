import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:serial_number_barcode_scanner/routes.dart';
import 'package:serial_number_barcode_scanner/screens/dnn/dnn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/enn/enn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/snn/snn_provider.dart';
import 'package:serial_number_barcode_scanner/state/configuration_state.dart';
import 'package:serial_number_barcode_scanner/state/uploading_state.dart';
import 'package:serial_number_barcode_scanner/widgets/customize_widgets_mixin.dart';

import 'api/data_uploader.dart';
import 'models/configuration_hive.dart';
import 'models/upload_item.dart';

void main() async {
  await _initHive();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DNNProvider>(create: (_) => DNNProvider()),
      ChangeNotifierProvider<ENNProvider>(create: (_) => ENNProvider()),
      ChangeNotifierProvider<SSNProvider>(create: (_) => SSNProvider()),
      ChangeNotifierProvider<ConfigurationState>(
          create: (_) => ConfigurationState()),
      ChangeNotifierProvider<UploadingState>(create: (_) => UploadingState()),
    ],
    child: const MaterialApp(
      home: MyHome(),
      onGenerateRoute: Routes.generateRoute,
    ),
  ));
}

Future<void> _initHive() async {
  Hive.registerAdapter(UploadItemAdapter());
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
                          customizeButton(
                              "SEND MANUALLY",
                              150,
                              configModel.isConfigurationNeeded
                                  ? null
                                  : () async {
                                      model.upload();
                                    }),
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
                                            Provider.of<ENNProvider>(context,
                                                    listen: false)
                                                .ennCode = "",
                                            Provider.of<SSNProvider>(context,
                                                    listen: false)
                                                .ssnCodes = []
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
