import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QRViewStyle extends StatelessWidget {
  final Widget buildQrView;

  const QRViewStyle(this.buildQrView);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black12, width: 2.0, style: BorderStyle.solid),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: buildQrView));
  }
}
