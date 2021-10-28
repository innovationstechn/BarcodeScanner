import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:serial_number_barcode_scanner/widgets/display_barcode.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_mixin.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_view_style.dart';
import 'package:serial_number_barcode_scanner/widgets/scan_button.dart';
import 'package:serial_number_barcode_scanner/widgets/simple_button.dart';

import 'enn_provider.dart';

class EAN extends StatefulWidget {
  final String dnn;

  const EAN({required this.dnn});

  @override
  State<StatefulWidget> createState() => _EAN();
}

class _EAN extends State<EAN> with QRCode {
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
                      DisplayBarCode(barcodeName: "DNN", barcode: widget.dnn),
                      Consumer<EANProvider>(builder: (context, model, child) {
                        return model.eanCode.isNotEmpty && !scanningState
                            ? SimpleButton("NEXT", 100, () async {
                                Navigator.pushNamed(context, 'snn',
                                    arguments: [widget.dnn, model.eanCode]);
                              })
                            : Container();
                      })
                    ],
                  ),
                )),
            Expanded(
                flex: 3,
                child:
                    QRViewStyle(buildQrView(context, _onQRViewCreated, 300))),
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
                          child: ScanButton(
                            scanningState: scanningState,
                            height: 100,
                            fontSize: 35,
                            name: model.eanCode.isEmpty
                                ? "SCAN EAN"
                                : "RESCAN EAN",
                            btnClick: () {
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

    // Controller is listening to the stream of scan codes.
    controller.scannedDataStream.listen((scanData) {
      if (scanningState) {
        // Disabling the scan
        scanningState = !scanningState;
        // EAN Provider is saving the scan bar code for temporary storage also notifying listener.
        Provider.of<EANProvider>(context, listen: false).setEAN(scanData.code);
        controller.pauseCamera();
        // Producing Vibrations
        Vibrate.vibrate();
      }
    });
  }

  // Disposing the controller
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
