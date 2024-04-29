import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/utils/bluetooth_manager.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';
import '../../controllers/pages/ble_connection_controller.dart';
import '../../widgets/gradient_background.dart';

class BluetoothConnectionPage extends GetView<BluetoothConnectionController> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(title: "블루투스 연결"),
        body: ImageBackground(
          child: Obx(
            () => Container(
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: controller.scannedDevices.length,
                itemBuilder: (BuildContext context, int index) {
                  BluetoothDevice device = controller.scannedDevices[index];
                  return Column(children: [
                    Container(
                      child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          title: Text(
                            device.platformName,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          subtitle: Text(
                            device.remoteId.toString(),
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          onTap: () =>
                              controller.pressedItem(device)),
                      // onTap: () => controller.connect(device)),
                    ),
                    Divider(
                      color: Colors.white24,
                      thickness: 0.4,
                    )
                  ]);
                },
              ),
            ),
          ),
        ));
  }
}
