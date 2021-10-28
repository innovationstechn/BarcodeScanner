import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DisplayBarCode extends StatelessWidget {
  final String barcodeName, barcode;

  const DisplayBarCode({required this.barcodeName, required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (barcodeName.isNotEmpty)
          Text(
            barcodeName,
            style: const TextStyle(color: Colors.black, fontSize: 15),
          ),
        Container(
            height: 50,
            decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Center(
                child: barcode.isNotEmpty ? Text(barcode) : const Text(""))),
      ],
    );
  }
}
