import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serial_number_barcode_scanner/models/configuration_hive.dart';
import 'package:serial_number_barcode_scanner/state/configuration_state.dart';
import 'package:serial_number_barcode_scanner/widgets/simple_button.dart';

class Configuration extends StatefulWidget {
  const Configuration({Key? key}) : super(key: key);

  @override
  _ConfigurationState createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration>{
  final urlController = TextEditingController();
  final deviceIDController = TextEditingController();
  final keyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Consumer<ConfigurationState>(
              builder: (context, model, child) {
                String url = "",
                    id = "",
                    key = "";
                if (!model.isConfigurationNeeded) {
                  url = model.configuration!.apiUrl;
                  id = model.configuration!.deviceID;
                  key = model.configuration!.key;
                }

                urlController.text = url;
                deviceIDController.text = id;
                keyController.text = key;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 30),
                  child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("CONFIGURATION",
                          style: TextStyle(color: Colors.black, fontSize: 25),),
                        const SizedBox(height: 20),
                        customizeTextInput(
                            urlController, "URL", "Enter API-URL"),
                        customizeTextInput(deviceIDController, "DEVICE-ID",
                            "Enter the DEVICE-ID"),
                        customizeTextInput(
                            keyController, "KEY", "Enter the KEY"),
                        const SizedBox(height: 40,),
                        SimpleButton("SAVE", 70, () async {
                          ConfigurationHive configurationHive = ConfigurationHive(
                              apiUrl: urlController.text,
                              deviceID: deviceIDController.text,
                              key: keyController.text);
                          await model.setConfiguration(configurationHive).then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('CONFIGURATION SAVED')),
                            );
                            Navigator.pop(context);
                          });
                        }, color: Colors.red)
                      ]),
                );
              }
          )
      ),
    );
  }

  Widget customizeTextInput(
      TextEditingController controller, String title, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.redAccent, fontSize: 14),
        ),
        TextField(
          controller: controller,
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
      ],
    );
  }
}
