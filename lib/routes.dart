import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:serial_number_barcode_scanner/screens/configuration_screen.dart';
import 'package:serial_number_barcode_scanner/screens/dnn/dnn.dart';
import 'package:serial_number_barcode_scanner/screens/enn/enn.dart';
import 'package:serial_number_barcode_scanner/screens/final/final.dart';
import 'package:serial_number_barcode_scanner/screens/snn/snn.dart';

import 'main.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => const MyHome());
      case 'dnn':
        return MaterialPageRoute(
            builder: (_) => DNNScreen());
      case 'enn':
        String arg = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => ENN(DNN: arg));
      case 'snn':
        List<dynamic> args = settings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              SNN(DNN: args[0], ENN: args[1]),
        );
      case 'final':
        return MaterialPageRoute(
          builder: (_) =>
              const Final(),
        );
      case 'configuration':
        return MaterialPageRoute(
          builder: (_) =>
              const Configuration(),
        );
      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}