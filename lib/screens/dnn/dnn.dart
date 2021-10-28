import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_mixin.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_view_style.dart';
import 'package:serial_number_barcode_scanner/widgets/scan_button.dart';
import 'package:serial_number_barcode_scanner/widgets/simple_button.dart';
import 'dnn_provider.dart';

class DNNScreen extends StatefulWidget {
  const DNNScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DNNScreen();
}

class _DNNScreen extends State<DNNScreen> with QRCode{
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
                  return model.dnnCode.isEmpty || scanningState
                      ? Container()
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: SimpleButton("NEXT", 80, () async {
                            controller!.pauseCamera();
                            Navigator.pushNamed(context, 'ean',
                                    arguments: model.dnnCode)
                                .then((value) => controller!.resumeCamera());
                          }),
                        );
                })),
            Expanded(
                flex: 4,
                child:
                    QRViewStyle(buildQrView(context, _onQRViewCreated, 250))),
            Expanded(
                flex: 3,
                child: Consumer<DNNProvider>(builder: (context, model, child) {
                  return Column(
                    children: [
                      if (model.dnnCode.isNotEmpty && !scanningState)
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
                        child: ScanButton(
                            scanningState: scanningState,
                            height: 100,
                            fontSize: 20,
                            name: model.dnnCode.isEmpty
                                ? "SCAN DNN"
                                : "RESCAN DNN",
                            btnClick: () {
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

  // This method will be called when QRScanner view is created.
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    // Controller is listening to the stream of scan codes.
    controller.scannedDataStream.listen((scanData) async {
      if (scanningState) {
        // Disabling the scan
        scanningState = !scanningState;
        // DNN Provider is saving the scan bar code for temporary storage also notifying listener.
        Provider.of<DNNProvider>(context, listen: false)
            .setBarCode(scanData.code);
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
