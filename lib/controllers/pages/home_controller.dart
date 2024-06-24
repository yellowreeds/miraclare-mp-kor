import 'dart:io';
import 'dart:ui';
import 'package:goodeeps2/utils/local_file_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/routes.dart';
import 'package:goodeeps2/services/sleep_analysis_service.dart';
import 'package:goodeeps2/services/user_service.dart';
import 'package:goodeeps2/utils/bluetooth_manager.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/widgets/battery_status_widget.dart';
import 'package:goodeeps2/widgets/alerts.dart';

import '../../models/user_model.dart';

enum OperationButtonState {
  disabled, // 비활성화 상태
  start, // 시작할 수 있는 상태
  stop; // 정지할 수 있는 상태

  String get title {
    switch (this) {
      case OperationButtonState.disabled:
        return "동작 시작";
      case OperationButtonState.start:
        return "동작 시작";
      case OperationButtonState.stop:
        return "동작 완료";
    }
  }

  String get description {
    switch (this) {
      case OperationButtonState.disabled:
        return "디바이스 상태를 확인해주세요.";
      case OperationButtonState.start:
        return "동작을 시작해주세요.";
      case OperationButtonState.stop:
        return "동작중 입니다.";
    }
  }

  Color get color {
    switch (this) {
      case OperationButtonState.disabled:
        return Color.fromRGBO(71, 60, 77, 1);
      case OperationButtonState.start:
        return Color.fromRGBO(128, 59, 160, 1);
      case OperationButtonState.stop:
        return Color.fromRGBO(128, 59, 160, 1);
    }
  }
}

class HomeController extends BaseController {
  final BluetoothManager bluetoothManager = BluetoothManager.instance;
  Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final userService = UserService();
  final sleepAnalysisService = SleepAnalysisService();

  var operationButtonState = OperationButtonState.disabled.obs;
  var isLeadOn = false.obs;
  var isOperating = false.obs;
  var isConnected = false.obs;
  var isLoading = false.obs;
  var battery = 0.obs;
  var isCharging = false.obs;

  var batteryLevel = BatteryLevel.disconnect.obs;

  @override
  void onInit() async {
    super.onInit();
    setupEver();
    userModel.value = await userService.getMe();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setupEver() {
    ever(isOperating, handleIsOperating);
    ever(operationButtonState, handleOperationButtonState);

    ever(bluetoothManager.leadStatus, handleIsLeadOn);
    ever(bluetoothManager.isConnected, handleIsConnected);
    ever(bluetoothManager.battery, handleBattery);
    ever(bluetoothManager.chargingStatus, handleIsCharging);

    ever(isLoading, handleIsLoading);
  }

  void handleOperationButtonState(OperationButtonState state) {
    switch (state) {
      case OperationButtonState.disabled:
        isOperating.value = false;
        break;
      case OperationButtonState.start:
        isOperating.value = false;
        break;
      case OperationButtonState.stop:
        isOperating.value = true;
        break;
    }
  }

  void handleIsConnected(bool isConnected) {
    this.isConnected.value = isConnected;
    if (!isConnected) {
      this.isLeadOn.value = false;
      this.isCharging.value = false;
      this.batteryLevel.value = BatteryLevel.disconnect;
      this.battery.value = 0;
    }
  }

  void handleIsOperating(bool isOperaing) {
    bluetoothManager.isOperating.value = isOperaing;
  }

  void handleIsLeadOn(bool isLeadOn) {
    this.isLeadOn.value = isLeadOn;
    if (this.isOperating.value) {
      operationButtonState.value = OperationButtonState.stop;
    } else {
      if (isLeadOn) {
        operationButtonState.value = OperationButtonState.start;
      } else {
        operationButtonState.value = OperationButtonState.disabled;
      }
    }
  }

  void handleIsLoading(bool isLoading) {
    if (isLoading) {
      GoodeepsDialog.showIndicator();
    } else {
      GoodeepsDialog.hideIndicator();
      // Get.back();
    }
  }

  void handleIsCharging(bool isCharging) {
    this.isCharging.value = isCharging;
  }

  void handleBattery(int battery) {
    if (this.isCharging.value) {
      this.batteryLevel.value = BatteryLevel.charging;
    } else {
      this.battery.value = battery;
      this.batteryLevel.value = BatteryLevel.getLevel(battery);
    }
  }

  bool canStart() {
    return (this.isLeadOn.value && this.isConnected.value);
  }

  void switchConnectionToggle(bool? value) async {
    if (value != null) {
      if (value) {
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
        if (BluetoothManager.instance.device != null) {
          await BluetoothManager.instance.disconnect();
        }
      }
    }
    // logger.i(value);
    // final deviceId =
    //     await SharedPreferencesHelper.fetchData(SharedPreferencesKey.deviceId);
    // if (deviceId == null) {
    //   goToBluetoothConnectionPage();
    // } else {
    //   this.isLoading.value = true;
    //   final device =
    //       BluetoothDevice(remoteId: DeviceIdentifier(deviceId.toString()));
    //   await BluetoothManager.instance.connect(device);
    //   this.isLoading.value = false;
    // }
    // final _isConnected = value ?? false;
    // isConnected.value = _isConnected;


  }

  void goToBluetoothConnectionPage() {
    Get.toNamed(PageRouter.bluetoothConnection.rawValue);
  }

  void pressedSettingButton() {
    Get.toNamed(PageRouter.setting.rawValue);
  }

  Future<void> pressdOperationButton() async {
    switch (this.operationButtonState.value) {
      case OperationButtonState.disabled:
        break;
      case OperationButtonState.start:
        this.operationButtonState.value = OperationButtonState.stop;
        break;
      case OperationButtonState.stop:
        if (this.isLeadOn.value) {
          this.operationButtonState.value = OperationButtonState.start;
        } else {
          this.operationButtonState.value = OperationButtonState.disabled;
        }

        await uploadSleepAnalysisFile();

        break;
    }
  }

  Future<void> pressedGuideButton() async {
    userModel.value = await userService.getMe();
  }

  Future<void> uploadSleepAnalysisFile() async {
    isLoading.value = true;
    final path = LocalFileManager.instance.sleepAnalysisFilePath;
    if (path != null) {
      final file = File(path);
      await sleepAnalysisService.uploadSleepAnalysis(file);
    }
    isLoading.value = false;
  }

  void requestUserInfo() {}
}
