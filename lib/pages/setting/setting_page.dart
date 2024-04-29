import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/setting_controller.dart';

class SettingPage extends StatelessWidget {
  final SettingController controller = Get.find<SettingController>();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Text("SETTING"),
      ),
    );
  }
}
