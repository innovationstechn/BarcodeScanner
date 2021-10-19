import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:serial_number_barcode_scanner/main.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';
import 'package:serial_number_barcode_scanner/models/upload_item.dart';
import 'package:serial_number_barcode_scanner/screens/dnn/dnn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/enn/enn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/final/final_cache.dart';
import 'package:serial_number_barcode_scanner/screens/snn/snn_provider.dart';
import 'package:serial_number_barcode_scanner/state/configuration_state.dart';
import 'package:serial_number_barcode_scanner/state/uploading_state.dart';
import 'package:serial_number_barcode_scanner/utils/encoding_utils.dart';
import 'package:serial_number_barcode_scanner/widgets/customize_widgets_mixin.dart';

class Final extends StatefulWidget {
  const Final({Key? key}) : super(key: key);

  @override
  _FinalState createState() => _FinalState();
}

class _FinalState extends State<Final> with CustomizeWidgets {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              customizeExpandableFittedBox(
                  context, 1, const Center(child: Text("BARCODE SCANNER"))),
              customizeExpandableFittedBox(
                  context,
                  3,
                  customizeButton("NEXT DNN", 150, () async {
                    // Last DNN Scan
                    String dnn =
                        Provider.of<DNNProvider>(context, listen: false)
                            .dnnCode;
                    // Last ENN Scan
                    String enn =
                        Provider.of<ENNProvider>(context, listen: false)
                            .ennCode;
                    // Last scan SSN List
                    List<String> ssnCodes =
                        Provider.of<SSNProvider>(context, listen: false)
                            .ssnCodes;
                    if (enn != "" && ssnCodes.isNotEmpty) {
                      // Store DNN
                      FinalCache.addDNN(dnn, enn, ssnCodes);
                      Provider.of<DNNProvider>(context, listen: false).dnnCode =
                          "";
                      clearENNData();
                    }
                    Navigator.pushNamed(context, 'dnn');
                  })),
              const SizedBox(height: 10),
              customizeExpandableFittedBox(
                context,
                1,
                const Text(
                  "THIS DELIVERY NOTE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              customizeExpandableFittedBox(
                context,
                1,
                customizeDisplayBarCode("",
                    Provider.of<DNNProvider>(context, listen: false).dnnCode),
              ),
              customizeExpandableFittedBox(
                  context,
                  2,
                  customizeButton("NEXT ENN", 100, () async {
                    String dnn =
                        Provider.of<DNNProvider>(context, listen: false)
                            .dnnCode;
                    if (dnn != "") {
                      // Last ENN Scan
                      String enn =
                          Provider.of<ENNProvider>(context, listen: false)
                              .ennCode;
                      // Last SSN Scan List
                      List<String> ssnCodes =
                          Provider.of<SSNProvider>(context, listen: false)
                              .ssnCodes;
                      //Store ENN
                      FinalCache.addENN(enn, ssnCodes);
                      // Clear Previous Data in ENN AND SSN SCREENS
                      clearENNData();
                      // Here we have to REMOVE SCREEN UP TO ENN Screen
                      Navigator.pushNamed(context, 'enn',
                          arguments:
                              Provider.of<DNNProvider>(context, listen: false)
                                  .dnnCode);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('NO DNN EXISTS')),
                      );
                    }
                  })),
              customizeExpandableFittedBox(
                context,
                2,
                customizeButton("NEXT SNN", 100, () async {
                  // Here we have to remove screen up to SNN

                  String dnn =
                      Provider.of<DNNProvider>(context, listen: false).dnnCode;
                  // Last ENN Scan
                  String enn =
                      Provider.of<ENNProvider>(context, listen: false).ennCode;

                  if (enn != "") {
                    Navigator.pushNamed(context, 'snn', arguments: [dnn,enn]);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('NO ENN EXISTS')),
                    );
                  }
                }),
              ),
              customizeExpandableFittedBox(
                  context,
                  3,
                  customizeButton("FINISH/SEND", 150, () {
                    String dnn =
                        Provider.of<DNNProvider>(context, listen: false)
                            .dnnCode;

                    if (dnn != "") {
                      // Last ENN Scan
                      String enn =
                          Provider.of<ENNProvider>(context, listen: false)
                              .ennCode;
                      // Last scan SSN List
                      List<String> ssnCodes =
                          Provider.of<SSNProvider>(context, listen: false)
                              .ssnCodes;
                      if (enn != "" && ssnCodes.isNotEmpty) {
                        FinalCache.addDNN(dnn, enn, ssnCodes);
                      }
                    }

                    if (FinalCache.dnnList.isNotEmpty) {
                      // Send the Data to server or DB
                      String id,key;
                      ConfigurationState configurationState = Provider.of<ConfigurationState>(context, listen: false);
                      id = configurationState.configuration!.deviceID;
                      key = configurationState.configuration!.key;

                      onFinishPressed(context, FinalCache.dnnList,
                          key,id);
                      FinalCache.dnnList=[];
                      Provider.of<DNNProvider>(context, listen: false).dnnCode =
                          "";
                      clearENNData();
                      // Navigate to main page
                      Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => const MyHome(),
                          ),
                          (route) =>
                              false); //if you want to disable back feature set to false
                    }
                  }))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onFinishPressed(
      BuildContext context, List<DNN> scanned, String key, String id) async {
    final data = Map<String, Map<String, List<String>>>();

    scanned.forEach((element) {
      data[element.dnn] = element.toJson();
    });

    Tuple2<String, String> processed = scannedToEncodings(data, key);

    print('Data: ${processed.item1}');
    print('Checksum: ${processed.item2}');

    // Dio dio = Dio();
    // APIClient client = APIClient(dio);

    UploadItem item = UploadItem(
        url: 'https://serial.aitigo.de',
        data: processed.item1,
        checksum: processed.item2,
        id: id);

    await Provider.of<UploadingState>(context, listen: false).queue(item);
    await Provider.of<UploadingState>(context, listen: false).upload();

    // final result = response.body;
    //
    // if (result == "OK")
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Successfully uploaded to the server.'),
    //     ),
    //   );
    // else
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Error while uploading to the server. $result'),
    //     ),
    //   );

    // context.read(ScannedBarcodes.state).clearAll();
    //
    // String result =
    //     await client.sendDNNs(processed.item1, processed.item2, id, 0);

    // print(result);
  }

  clearENNData() {
    Provider.of<ENNProvider>(context, listen: false).ennCode = "";
    Provider.of<SSNProvider>(context, listen: false).ssnCodes = [];
  }
}
