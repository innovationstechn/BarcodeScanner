import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:serial_number_barcode_scanner/widgets/customize_widgets_mixin.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_mixin.dart';
import 'dnn_provider.dart';

class DNNScreen extends StatefulWidget {
  const DNNScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DNNScreen();
}

class _DNNScreen extends State<DNNScreen> with QRCode, CustomizeWidgets {
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
            const Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "DELIVERY NOTE NUMBER",
                    style: TextStyle(fontSize: 15),
                  ),
                )),
            Expanded(
                flex: 2,
                child: Consumer<DNNProvider>(builder: (context, model, child) {
                  return model.dnnCode == "" || scanningState
                      ? Container()
                      : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: customizeButton("NEXT", 80, () async {
                            controller!.pauseCamera();
                            Navigator.pushNamed(context, 'ean',
                                    arguments: model.dnnCode)
                                .then((value) => controller!.resumeCamera());
                          }),
                      );
                })),
            Expanded(
                flex: 4,
                child: customizeQRView(
                    buildQrView(context, _onQRViewCreated, 250))),
            Expanded(
                flex: 3,
                child: Consumer<DNNProvider>(builder: (context, model, child) {
                  return Column(
                    children: [
                      if (model.dnnCode != "" && !scanningState)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            'Barcode scan: ${model.dnnCode}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15),
                          ),
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: customizeScanButton(scanningState, 100, 20,
                            model.dnnCode == "" ? "SCAN DNN" : "RESCAN DNN",
                            () {
                          scanningState = !scanningState;
                          model.setState();
                        }),
                      )
                    ],
                  );
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
        Provider.of<DNNProvider>(context, listen: false)
            .setBarCode(scanData.code);
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
