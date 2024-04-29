import 'dart:async';
import 'dart:collection';
import 'dart:ffi';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/utils/uart_command.dart';
import 'package:hex/hex.dart';
import 'package:tuple/tuple.dart';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();

  BluetoothManager._internal();

  late bool isUpgradeMode = false;

  static BluetoothManager get instance => _instance;
  Queue<String> dataBuffer = Queue<String>();

  final Guid serviceUUId = Guid("fff0");
  late var devices = <BluetoothDevice>[].obs;
  late var isConnected = false.obs;
  late Worker characteristicsWorker;
  late BluetoothDevice? device;

  // 0 : notify 1: write
  late Rx<Tuple2<BluetoothCharacteristic?, BluetoothCharacteristic?>>
      characteristics =
      Rx<Tuple2<BluetoothCharacteristic?, BluetoothCharacteristic?>>(
          Tuple2(null, null));

  late StreamSubscription<BluetoothAdapterState>? bluetoothStateSubscription =
      null;
  late StreamSubscription<BluetoothConnectionState>?
      connectionStateSubscription = null;
  late StreamSubscription<List<ScanResult>>? scanSubscription = null;
  late StreamSubscription<List<int>>? characteristicSubscription = null;

  void setupEver() {
    characteristicsWorker = ever(characteristics, updatedCharacteristics);
  }

  void updatedCharacteristics(
      Tuple2<BluetoothCharacteristic?, BluetoothCharacteristic?>
          characteristics) {
    logger.i(characteristics);
    final notifyCharacteristic = characteristics.item1;
    final writeCharacteristic = characteristics.item2;

    if ((notifyCharacteristic != null) && (writeCharacteristic != null)) {
      subscribeToNotifyCharacteristic(notifyCharacteristic);
      UartCommandHelper.command(UartCommand.start);
    }
  }

  void subscribeToBluetoothState() {
    bluetoothStateSubscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      logger.i(state);
      if (state == BluetoothAdapterState.on) {
        startScan(withServices: [serviceUUId]);
      } else {
        // show an error to the user, etc
        logger.e(state);
      }
    });
  }

  void subscribeToScanResults() {
    scanSubscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        devices.value = results.map((result) => result.device).toList();
      },
      onError: (e) => logger.e(e.toString()),
    );
    FlutterBluePlus.cancelWhenScanComplete(scanSubscription!);
  }

  void subscribeToConnectionState(BluetoothDevice device) {
    connectionStateSubscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      logger.i(state);
      switch (state) {
        case BluetoothConnectionState.disconnected:
          isConnected.value = false;
          break;
        case BluetoothConnectionState.connected:
          isConnected.value = true;
          await SharedPreferencesHelper.saveData(
              SharedPreferencesKey.deviceId, device.remoteId.str);
          logger.i(device);
          this.device = device;
          devices.clear();
          await cancelScanSubscription();
          await discoverServices(device);
          break;
        default:
          isConnected.value = false;
          break;
      }
    });
  }

  void subscribeToNotifyCharacteristic(BluetoothCharacteristic characteristic) {
    characteristicSubscription = characteristic.onValueReceived.listen((value) {
      RegExp pattern = RegExp(r'(a5.{32}5a)');
      final hex = HEX.encode(value);
      logger.i(hex);
      final extractedData =
          pattern.allMatches(hex).map((match) => match.group(0)).toList();
      // loggerNoStack.i(hex);
      dataBuffer.addAll(extractedData.whereType<String>());

      loggerNoStack.i(extractedData.length);
    });
    this.device!.cancelWhenDisconnected(characteristicSubscription!,
        delayed: true, next: true);
  }

  Future<void> cancelBluetoothStateSubscription() async {
    if (bluetoothStateSubscription != null) {
      await bluetoothStateSubscription?.cancel();
      bluetoothStateSubscription = null;
    }
  }

  Future<void> cancelScanSubscription() async {
    if (scanSubscription != null) {
      await scanSubscription?.cancel();
      scanSubscription = null;
    }
  }

  Future<void> cancelConnectionStateSubscription() async {
    if (connectionStateSubscription != null) {
      await connectionStateSubscription?.cancel();
      connectionStateSubscription = null;
    }
  }

  Future<void> cancelNotifyCharacteristicSubscription() async {
    if (connectionStateSubscription != null) {
      await connectionStateSubscription?.cancel();
      connectionStateSubscription = null;
    }
  }

  void startScan(
      {List<Guid> withServices = const [],
      List<String> withRemoteIds = const []}) async {
    if (!FlutterBluePlus.isScanningNow) {
      subscribeToScanResults();
      await FlutterBluePlus.startScan(
          withServices: withServices, withRemoteIds: withRemoteIds);
    } else {
      logger.e("already Scanning");
    }
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    logger.i("services count : ${services.length}");
    setupEver();
    services.forEach((service) {
      discoverCharacteristics(service);
    });
  }

  void discoverCharacteristics(BluetoothService service) {
    List<BluetoothCharacteristic> characteristics = service.characteristics;
    characteristics.forEach((characteristic) {
      logger.i(characteristic.uuid);

      switch (characteristic.uuid.str) {
        // notify
        case "fff1":
          characteristic.setNotifyValue(true);
          this.characteristics.value =
              this.characteristics.value.withItem1(characteristic);
          break;

        // write
        case "fff2":
          this.characteristics.value =
              this.characteristics.value.withItem2(characteristic);
          break;

        default:
          break;
      }
    });
  }

  Future<void> connect(BluetoothDevice device) async {
    subscribeToConnectionState(device);
    await device
        .connect(autoConnect: false, timeout: const Duration(seconds: 10))
        .catchError((error) {
      logger.e(error);
      cancelConnectionStateSubscription();
    });
  }

  Future<void> disconnect() async {
    FlutterBluePlus.connectedDevices.forEach((element) {
      logger.i(
          "connected devices : ${element.platformName} ${element.remoteId.str})");
    });
    await device?.disconnect().then((_) async {
      logger
          .i("disconnected : ${device?.platformName} ${device?.remoteId.str})");
      this.device = null;
    }).catchError((error) {
      logger.e("Error : $error");
    });
  }

  Future<void> cancelSubscriptions(BluetoothDevice device) async {}
}
