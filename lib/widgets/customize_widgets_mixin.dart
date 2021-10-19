import 'package:flutter/material.dart';

mixin CustomizeWidgets {
  Widget customizeScanButton(bool scanningState, double height, double fontSize,
      String name, Function() btnClick) {
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

  Widget customizeButton(String name, double height,Function? btnClick, {Color color=Colors.blue}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(height),
              shadowColor: color==Colors.blue?Colors.lightBlueAccent:Colors.redAccent,
              primary: color==Colors.blue?Colors.blue:Colors.red),
          onPressed: btnClick == null? null : () => btnClick(),
          child: Text(
            name,
            style: const TextStyle(fontSize: 35),
          )),
    );
  }

  Widget customizeDisplayBarCode(
      String barcodeName, String barcode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (barcodeName!="")
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
                child: barcode != null ? Text(barcode) : const Text(""))),
      ],
    );
  }

  Widget customizeQRView(Widget buildQrView) {
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

  Widget customizeExpandableFittedBox(BuildContext context,int flex,Widget widget){
   return Expanded(
        flex: flex,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: widget),
        ));
  }

  Widget customizeTextInput(TextEditingController controller,String title,String hint){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
        title,
        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
      ),
      TextField(
        controller:controller,
        decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          hintText: hint,
          // hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      const SizedBox(
        height: 10,
      )
    ],);
  }
}
