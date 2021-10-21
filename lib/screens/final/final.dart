import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serial_number_barcode_scanner/screens/ean/enn_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:serial_number_barcode_scanner/main.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';
import 'package:serial_number_barcode_scanner/models/upload_item.dart';
import 'package:serial_number_barcode_scanner/screens/dnn/dnn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/final/final_provider.dart';
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
  String dnn = "", ean = "";
  List<String> snnCodes = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _showMyDialog();
      },
      child: SafeArea(
        child: Scaffold(
          body:
          Consumer<FinalProvider>(builder: (context,model,child){
            return  Padding(
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
                        //Fetching Data
                        fetchAllScanData(true);
                        if (ean != "" && snnCodes.isNotEmpty) {
                          // Store DNN
                          model.addDNN(dnn, ean, snnCodes);
                          //Clear All Data
                          clearAllScanData();
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
                      customizeButton("NEXT EAN", 100, () async {
                        fetchAllScanData(true);
                        if (dnn != "") {
                          //Store ENN
                          model.addEAN(ean, snnCodes);
                          // Clear Previous Data in ENN AND SNN SCREENS
                          clearEANData();
                          // Here we have to REMOVE SCREEN UP TO ENN Screen
                          Navigator.pushNamed(context, 'ean',
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
                      fetchAllScanData(false);
                      if (ean != "") {
                        Navigator.pushNamed(context, 'snn',
                            arguments: [dnn, ean]);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('NO EAN EXISTS')),
                        );
                      }
                    }),
                  ),
                  customizeExpandableFittedBox(
                      context,
                      3,
                      customizeButton("FINISH/SEND", 150, () {
                        fetchAllScanData(true);
                        if (dnn != "") {
                          if (ean != "" && snnCodes.isNotEmpty) {
                            model.addDNN(dnn, ean, snnCodes);
                          }
                        }

                        if (model.dnnList.isNotEmpty) {
                          // Send the Data to server or DB
                          String id, key;
                          ConfigurationState configurationState =
                          Provider.of<ConfigurationState>(context,
                              listen: false);
                          id = configurationState.configuration!.deviceID;
                          key = configurationState.configuration!.key;

                          onFinishPressed(context, model.dnnList, key, id);
                          model.dnnList = [];
                          clearAllScanData();
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
            );
          })
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
  }

  clearAllScanData() {
    Provider.of<DNNProvider>(context, listen: false).dnnCode = "";
    clearEANData();
  }

  clearEANData() {
    Provider.of<EANProvider>(context, listen: false).eanCode = "";
    Provider.of<SNNProvider>(context, listen: false).snnCodes = [];
  }

  fetchAllScanData(bool doSNNScan) {
    // Last DNN Scan
    dnn = Provider.of<DNNProvider>(context, listen: false).dnnCode;
    // Last EAN Scan
    ean = Provider.of<EANProvider>(context, listen: false).eanCode;
    // Last scan SSN List
    if(doSNNScan) {
      snnCodes = Provider.of<SNNProvider>(context, listen: false).snnCodes;
    }
  }

  _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Final'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Do you want to discard scan list:'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('DISCARD'),
              onPressed: () {
                Navigator.pushAndRemoveUntil<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => const MyHome(),
                    ),
                    (route) =>
                        false); //if you want to disable back feature set to false
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
