import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:serial_number_barcode_scanner/widgets/customize_widgets_mixin.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_mixin.dart';
import 'enn_provider.dart';

class ENN extends StatefulWidget {
  final String DNN;

  ENN({required this.DNN});

  @override
  State<StatefulWidget> createState() => _ENN();
}

class _ENN extends State<ENN> with QRCode, CustomizeWidgets {
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
                      customizeButton("FINISH", 100,() async {
                        if (result != null) {
                          Navigator.pushNamed(context, 'snn',arguments: [widget.DNN,result!.code]);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please scan ENN before proceed')));
                        }
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
                      Consumer<ENNProvider>(builder: (context, model, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (result != null)
                          Text('Barcode Scanned: ${result!.code}'),
                        SizedBox(
                          child: customizeScanButton(
                            scanningState,
                            100,
                            35,
                            "SCAN ENN",
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
        Provider.of<ENNProvider>(context, listen: false).setENN(scanData.code);
        controller.pauseCamera();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
