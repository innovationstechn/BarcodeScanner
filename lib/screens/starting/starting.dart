import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serial_number_barcode_scanner/screens/dnn/dnn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/ean/enn_provider.dart';
import 'package:serial_number_barcode_scanner/screens/snn/snn_provider.dart';
import 'package:serial_number_barcode_scanner/state/configuration_state.dart';
import 'package:serial_number_barcode_scanner/state/uploading_state.dart';
import 'package:serial_number_barcode_scanner/widgets/expandable_fittedbox.dart';
import 'package:serial_number_barcode_scanner/widgets/simple_button.dart';

class StartingPage extends StatelessWidget{
  const StartingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: Consumer<ConfigurationState>(
        builder: (context, configModel, child) {
          return Consumer<UploadingState>(builder: (context, model, child) {
            return Padding(
                padding: const EdgeInsets.all(30),
                child: Column(children: [
                  const ExpandableFittedBox(
                      2,
                      Center(
                          child: Text(
                            "Barcode Scanner",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ))),
                  ExpandableFittedBox(
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
                            SimpleButton(
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
                  ExpandableFittedBox(
                      2,
                      SimpleButton(
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
                  ExpandableFittedBox(
                      2,
                      SimpleButton("CONFIGURATION", 80, () async {
                        Navigator.pushNamed(context, 'configuration');
                      }, color: Colors.red))
                ]));
          });
        },
      )),
    );
  }
}
