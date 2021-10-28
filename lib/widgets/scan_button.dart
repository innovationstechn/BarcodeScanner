import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  final bool scanningState;
  final double height, fontSize;
  final String name;
  final Function() btnClick;

  const ScanButton(
      {required this.scanningState,
      required this.height,
      required this.fontSize,
      required this.name,
      required this.btnClick});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: scanningState
            ? ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(height),
            shadowColor: Colors.deepOrangeAccent,
            primary: Colors.red)
            : ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(height),
            shadowColor: Colors.greenAccent,
            primary: Colors.lightGreen),
        onPressed: () => btnClick(),
        child: scanningState
            ? Text(
          "PAUSE",
          style: TextStyle(fontSize: fontSize),
        )
            : Text(
          name,
          style: TextStyle(fontSize: fontSize),
        ));

  }
}
