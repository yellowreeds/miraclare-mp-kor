import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/utils/bluetooth_manager.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/widgets/battery_status_widget.dart';
import 'package:goodeeps2/widgets/goodeeps_alert.dart';

class HomeController extends BaseController {
  var isConnected = false.obs;
  var isLoading = false.obs;
  var isLeadOn = false.obs;
  var isWorking = false.obs;
  var batteryStatus = BatteryStatus.disconnect;

  @override
  void onInit() {
    super.onInit();
    setupEver();
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

  void switchConnectionToggle(bool? value) async {
    final _isConnected = value ?? false;
    isConnected.value = _isConnected;

    if (_isConnected) {
      final deviceId = await SharedPreferencesHelper.fetchData(
          SharedPreferencesKey.deviceId);
      if (deviceId == null) {
        goToBluetoothConnectionPage();
      } else {
        this.isLoading.value = true;
        final device =
            BluetoothDevice(remoteId: DeviceIdentifier(deviceId.toString()));
        await BluetoothManager.instance.connect(device);
        this.isLoading.value = false;
      }
    } else {
      BluetoothManager.instance.disconnect();
    }
  }

  void goToBluetoothConnectionPage() {
    Get.toNamed("/bluetooth-connection");
  }
}
