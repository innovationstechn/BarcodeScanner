import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:serial_number_barcode_scanner/widgets/customize_widgets_mixin.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_mixin.dart';

import 'enn_provider.dart';

class EAN extends StatefulWidget {
  final String DNN;

  const EAN({required this.DNN});

  @override
  State<StatefulWidget> createState() => _EAN();
}

class _EAN extends State<EAN> with QRCode, CustomizeWidgets {
  Barcode? result;
  QRViewController? controller;
  bool scanningState = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
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
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customizeDisplayBarCode("DNN", widget.DNN),
                      Consumer<EANProvider>(builder: (context, model, child) {
                        return model.eanCode != "" && !scanningState
                            ? customizeButton("NEXT", 100, () async {
                                Navigator.pushNamed(context, 'snn',
                                    arguments: [widget.DNN, model.eanCode]);
                              })
                            : Container();
                      })
                    ],
                  ),
                )),
            Expanded(
                flex: 3,
                child: customizeQRView(
                    buildQrView(context, _onQRViewCreated, 300))),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                  child:
                      Consumer<EANProvider>(builder: (context, model, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!scanningState)
                          Text('Barcode Scanned: ${model.eanCode}'),
                        SizedBox(
                          child: customizeScanButton(
                            scanningState,
                            100,
                            35,
                            model.eanCode == "" ? "SCAN EAN" : "RESCAN EAN",
                            () {
                              if (!scanningState) {
                                controller!.resumeCamera();
                              } else {
                                controller!.pauseCamera();
                              }
                              scanningState = !scanningState;
                              model.setState();
                            },
                          ),
                        )
                      ],
                    );
                  }),
                )),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (scanningState) {
        result = scanData;
        scanningState = !scanningState;
        Provider.of<EANProvider>(context, listen: false).setEAN(scanData.code);
        controller.pauseCamera();
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
