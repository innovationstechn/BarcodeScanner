import 'package:flutter/cupertino.dart';

class ExpandableFittedBox extends StatelessWidget {
  final int flex;
  final Widget widget;

  const ExpandableFittedBox(this.flex, this.widget);

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: widget);
  }
}
