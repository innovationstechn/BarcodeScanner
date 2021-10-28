import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleButton extends StatelessWidget {
  final String name;
  final double height;
  final Function? btnClick;
  final Color color;

  const SimpleButton(this.name, this.height, this.btnClick,
      {this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(height),
              shadowColor: color == Colors.blue
                  ? Colors.lightBlueAccent
                  : Colors.redAccent,
              primary: color == Colors.blue ? Colors.blue : Colors.red),
          onPressed: btnClick == null ? null : () => btnClick!(),
          child: Text(
            name,
            style: const TextStyle(fontSize: 35),
          )),
    );
  }
}
