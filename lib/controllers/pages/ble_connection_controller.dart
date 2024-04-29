import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/utils/bluetooth_manager.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/widgets/goodeeps_alert.dart';
import 'package:permission_handler/permission_handler.dart';

/*
  순서
  권한체크 -> subscribeToBluetoothState ->


 */
class BluetoothConnectionController extends BaseController {
  late var isLoading = false.obs;
  var scannedDevices = BluetoothManager.instance.devices;

  @override
  void onInit() async {
    super.onInit();
    setupEver();
    await requestPermissions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setupEver() {
    ever(isLoading, (bool isLoading) {
      if (isLoading) {
        GoodeepsDialog.showIndicator();
      } else {
        GoodeepsDialog.hideIndicator();
        // Get.back();
      }
    });
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    bool isLocationGranted = statuses[Permission.location]?.isGranted ?? false;
    bool isBluetoothScanGranted =
        statuses[Permission.bluetoothScan]?.isGranted ?? false;
    bool isBluetoothConnectGranted =
        statuses[Permission.bluetoothConnect]?.isGranted ?? false;

    if (isLocationGranted &&
        isBluetoothScanGranted &&
        isBluetoothConnectGranted) {
      BluetoothManager.instance.subscribeToBluetoothState();
    } else {
      GoodeepsDialog.showError("Not all permissions granted");
      logger.e("Not all permissions granted");
      // 하나라도 권한이 거부된 경우 실행할 코드
    }
  }

  Future<void> pressedItem(BluetoothDevice device) async {
    isLoading.value = true;
    await BluetoothManager.instance.connect(device);
    isLoading.value = false;
    Get.back();
  }
}
