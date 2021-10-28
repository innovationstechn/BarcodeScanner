import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serial_number_barcode_scanner/models/configuration_hive.dart';
import 'package:serial_number_barcode_scanner/models/dnn_model.dart';
import 'package:serial_number_barcode_scanner/screens/dnn/dnn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/ean/enn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/final/final_provider.dart';
import 'package:serial_number_barcode_scanner/screens/snn/snn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/starting/starting.dart';
import 'package:serial_number_barcode_scanner/state/configuration_state.dart';
import 'package:serial_number_barcode_scanner/state/uploading_state.dart';
import 'package:serial_number_barcode_scanner/widgets/display_barcode.dart';
import 'package:serial_number_barcode_scanner/widgets/expandable_fittedbox.dart';
import 'package:serial_number_barcode_scanner/widgets/simple_button.dart';

class Final extends StatefulWidget {
  const Final({Key? key}) : super(key: key);

  @override
  _FinalState createState() => _FinalState();
}

class _FinalState extends State<Final> {
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
            body: Consumer<FinalProvider>(builder: (context, model, child) {
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const ExpandableFittedBox(
                    1, Center(child: Text("BARCODE SCANNER"))),
                ExpandableFittedBox(
                    3,
                    SimpleButton("NEXT DNN", 150, () async {
                      //Fetching Data
                      fetchAllScanData(true);
                      // Checking whether user scan the ean and snn or not.
                      if (ean.isNotEmpty && snnCodes.isNotEmpty) {
                        // Store DNN
                        model.addDNN(dnn, ean, snnCodes);
                        //Clear All Data
                        clearAllScanData();
                      }
                      Navigator.pushNamed(context, 'dnn');
                    })),
                const SizedBox(height: 10),
                const ExpandableFittedBox(
                  1,
                  Text(
                    "THIS DELIVERY NOTE",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                ExpandableFittedBox(
                    1,
                    DisplayBarCode(
                        barcodeName: "",
                        barcode:
                            Provider.of<DNNProvider>(context, listen: false)
                                .dnnCode)),
                ExpandableFittedBox(
                    2,
                    SimpleButton("NEXT EAN", 100, () async {
                      fetchAllScanData(true);
                      if (dnn.isNotEmpty) {
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
                ExpandableFittedBox(
                  2,
                  SimpleButton("NEXT SNN", 100, () async {
                    fetchAllScanData(false);
                    if (ean.isNotEmpty) {
                      Navigator.pushNamed(context, 'snn',
                          arguments: [dnn, ean]);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('NO EAN EXISTS')),
                      );
                    }
                  }),
                ),
                ExpandableFittedBox(
                    3,
                    SimpleButton("FINISH/SEND", 150, () {
                      fetchAllScanData(true);
                      // Storing the last dnn scanned.
                      if (dnn.isNotEmpty) {
                        if (ean.isNotEmpty && snnCodes.isNotEmpty) {
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
                              builder: (BuildContext context) =>
                                  const StartingPage(),
                            ),
                            (route) =>
                                false); //if you want to disable back feature set to false
                      }
                    }))
              ],
            ),
          );
        })),
      ),
    );
  }

  Future<void> onFinishPressed(
      BuildContext context, List<DNN> scanned, String key, String id) async {
    ConfigurationHive configurationHive =
        Provider.of<ConfigurationState>(context, listen: false).configuration!;

    for (var element in scanned) {
      await Provider.of<UploadingState>(context, listen: false).queue(element);
    }
    String response = await Provider.of<UploadingState>(context, listen: false)
        .upload(configurationHive);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response),
      ),
    );
  }

  // Clearing all the DNN previous data stored in temporary storage(Providers) to enable next DNN Scan
  clearAllScanData() {
    Provider.of<DNNProvider>(context, listen: false).dnnCode = "";
    clearEANData();
  }

  // Clearing the EAN data stored in temporary storage(Providers) to enable next EAN scan.
  clearEANData() {
    Provider.of<EANProvider>(context, listen: false).eanCode = "";
    Provider.of<SNNProvider>(context, listen: false).snnCodes = [];
  }

  // Fetching the stored data
  fetchAllScanData(bool doSNNScan) {
    // fetch Last DNN Scan
    dnn = Provider.of<DNNProvider>(context, listen: false).dnnCode;
    // fetch Last EAN Scan
    ean = Provider.of<EANProvider>(context, listen: false).eanCode;
    // fetch Last scan SSN List
    if (doSNNScan) {
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
                      builder: (BuildContext context) => const StartingPage(),
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
