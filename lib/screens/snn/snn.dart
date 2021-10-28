import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:serial_number_barcode_scanner/screens/final/final.dart';
import 'package:serial_number_barcode_scanner/screens/snn/snn_provider.dart';
import 'package:serial_number_barcode_scanner/widgets/display_barcode.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_mixin.dart';
import 'package:serial_number_barcode_scanner/widgets/qr_view_style.dart';
import 'package:serial_number_barcode_scanner/widgets/scan_button.dart';
import 'package:serial_number_barcode_scanner/widgets/simple_button.dart';

class SNN extends StatefulWidget {
  final String dnn, ean;

  const SNN({required this.dnn, required this.ean});

  @override
  State<StatefulWidget> createState() => _SNN();
}

class _SNN extends State<SNN> with QRCode{
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
                            child: DisplayBarCode(
                                barcodeName: "DNN", barcode: widget.dnn)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: SimpleButton("FINISH", 80, () async {
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
                child:
                    QRViewStyle(buildQrView(context, _onQRViewCreated, 250))),
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
                            child: DisplayBarCode(
                                barcodeName: "Current EAN",
                                barcode: widget.ean)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Consumer<SNNProvider>(
                            builder: (context, model, child) {
                              return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ScanButton(
                                    scanningState: scanningState,
                                    height: 70,
                                    fontSize: 35,
                                    name: "SCAN SNN",
                                    btnClick: () {
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

  // This method will be called when QRScanner view is created.
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    // Controller is listening to the stream of scan codes.
    controller.scannedDataStream.listen((scanData) async {
      if (scanningState) {
        // Disabling the scan
        scanningState = !scanningState;
        // SNN Provider is saving the scan bar code for temporary storage also notifying listener.
        Provider.of<SNNProvider>(context, listen: false).add(scanData);
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
