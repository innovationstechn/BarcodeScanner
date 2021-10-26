import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:serial_number_barcode_scanner/screens/final/final.dart';
import 'package:serial_number_barcode_scanner/screens/snn/snn_provider.dart';
import 'package:serial_number_barcode_scanner/widgets/customize_widgets_mixin.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_mixin.dart';

class SNN extends StatefulWidget {
  final String DNN, EAN;

  const SNN({required this.DNN, required this.EAN});

  @override
  State<StatefulWidget> createState() => _SNN();
}

class _SNN extends State<SNN> with QRCode, CustomizeWidgets {
  Barcode? result;
  QRViewController? controller;
  bool scanningState = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: customizeDisplayBarCode("DNN", widget.DNN)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: customizeButton("FINISH", 80, () async {
                            int scanItem =
                                Provider.of<SNNProvider>(context, listen: false)
                                    .snnCodes
                                    .length;
                            if (scanItem > 0) {
                              controller!.pauseCamera();
                              Navigator.pushAndRemoveUntil<dynamic>(
                                context,
                                MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) =>
                                      const Final(),
                                ),
                                (route) =>
                                    false, //if you want to disable back feature set to false
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please scan at least one item')));
                            }
                          }),
                        )
                      ],
                    ),
                  ),
                )),
            Expanded(
                flex: 5,
                child: customizeQRView(
                    buildQrView(context, _onQRViewCreated, 250))),
            Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: customizeDisplayBarCode(
                                "Current EAN", widget.EAN)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Consumer<SNNProvider>(
                            builder: (context, model, child) {
                              return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: customizeScanButton(
                                    scanningState,
                                    70,
                                    35,
                                    "SCAN SNN",
                                    () {
                                      scanningState = !scanningState;
                                      model.setState();
                                    },
                                  ));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            Expanded(
                flex: 3,
                child: Consumer<SNNProvider>(builder: (context, model, child) {
                  return ListView.builder(
                      itemCount: model.snnCodes.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            leading: Text(
                                '# ${(model.snnCodes.length - index).toString()}'),
                            trailing: GestureDetector(
                              child: const Icon(
                                Icons.delete,
                                size: 40,
                              ),
                              onTap: () {
                                model.remove(index);
                              },
                            ),
                            title: Text(model.getQRCode(index)));
                      });
                }))
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanningState) {
        scanningState = !scanningState;
        Provider.of<SNNProvider>(context, listen: false).add(scanData);
        Vibrate.vibrate();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
