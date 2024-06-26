import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';
import '../../controllers/pages/bluetooth_connection_controller.dart';
import '../../widgets/backgrounds.dart';

class BluetoothConnectionPage extends GetView<BluetoothConnectionController> {
  const BluetoothConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const CustomAppBar(title: "블루투스 연결"),
        body: ImageBackground(
          child: Obx(
                () => ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: controller.scannedDevices.length,
              itemBuilder: (BuildContext context, int index) {
                BluetoothDevice device = controller.scannedDevices[index];
                return Column(children: [
                  ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      title: Text(
                        device.platformName,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      subtitle: Text(
                        device.remoteId.toString(),
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      onTap: () =>
                          controller.pressedItem(device)),
                  const Divider(
                    color: Colors.white24,
                    thickness: 0.4,
                  )
                ]);
              },
            ),
          ),
        ));
  }
}
