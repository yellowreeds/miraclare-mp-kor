import 'dart:async';
import 'dart:collection';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/utils/local_file_manager.dart';
import 'package:goodeeps2/utils/observable_queue.dart';
import 'package:goodeeps2/utils/process_helper.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/utils/uart_command.dart';
import 'package:goodeeps2/utils/uart_command_helper.dart';
import 'package:hex/hex.dart';
import 'package:tuple/tuple.dart';

/*["a5", "07", "bd", "08", "8a", "09", "29", "09", "14", "09", "78", "08", "00", "32", "14", "04", "5e", "5a"];
  index
  0  ===================Sync0===================
  1  =
  2  =
  3  =
  4  =
  5  =
  6  =
  7  =
  8  =
  9  =
  10 =
  11 =
  12 =
  13 =
  14 =
  15 =
  16 ==================bettery==================
  17 ===================Sync1===================

*/

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();

  BluetoothManager._internal();

  late bool isUpgradeMode = false;
  late bool shouldSave = false;

  static BluetoothManager get instance => _instance;
  final int batchSize = 4;

  // late Queue<String> buffer = Queue<String>();
  final buffer = ObservableQueue<String>();
  final Guid serviceUUId = Guid("fff0");
  late var devices = <BluetoothDevice>[].obs;
  late var isConnected = false.obs;
  late Worker characteristicsWorker;
  late Worker bufferWorker;
  late BluetoothDevice? device;

  late var hexData = "".obs;

  late var isOperating = false.obs;
  late var offset = 0.obs;
  late var amplitude = 0.obs;
  late var vth = 0.obs;
  late var vibration = 0.obs;
  late var windowSize = 0.obs;
  late var leadStatus = false.obs;
  late var bruxismStatus = false.obs;
  late var battery = 0.obs;
  late var chargingStatus = false.obs;

  late var vibIntensity = 0.obs;

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

  void updateCharacteristics(
      Tuple2<BluetoothCharacteristic?, BluetoothCharacteristic?>
          characteristics) {
    logger.i(characteristics);
    final notifyCharacteristic = characteristics.item1;
    final writeCharacteristic = characteristics.item2;

    if ((notifyCharacteristic != null) && (writeCharacteristic != null)) {
      subscribeToNotifyCharacteristic(notifyCharacteristic);
      bufferWorker = ever(buffer.rxQueue, processQueue);
      UartCommandHelper.command(UartCommand.start());
      // 2초 대기 후 실행
      // Future.delayed(Duration(seconds: 2), () {
      //   UartCommandHelper.command(UartCommand.stop());
      // });
    }
  }

  void startOperating() {
    UartCommandHelper.command(UartCommand.start());
  }

  void processQueue(Queue<String> queue) {
    // logger.i(queue);
    while (queue.length >= batchSize) {
      List<String> batch = queue.toList().sublist(0, batchSize);
      processBatch(batch);
    }
  }

  void processBatch(List<String> batch) {
    for (String chunk in batch) {
      processBuffer(chunk);
      buffer.remove(chunk);
    }
  }

  void processBuffer(String chunk) {
    final data = splitStringIntoParts(chunk);
    // final counter = int.parse(data[2], radix: 16);

    final offset = int.parse(data[11] + data[12], radix: 16);
    final amplitude = int.parse(data[13], radix: 16);
    final vth = int.parse(data[14], radix: 16);

    final etcRaw = int.parse(data[15], radix: 16);
    final bool bruxismStatus = (etcRaw & 0x01) != 0;
    final bool leadStatus = (etcRaw & 0x02) != 0;
    final int windowSize = (etcRaw & 0x06) >> 2;
    final int vibration = (etcRaw & 0xF0) >> 4;

    final betteryRaw = int.parse(data[16], radix: 16);
    final battery = betteryRaw & 0x7F;
    final isCharging = (betteryRaw >> 7) & 1 == 1;

    this.offset.value = offset;
    this.amplitude.value = amplitude * 16;
    this.vth.value = vth * 16;
    this.vibration.value = vibration;
    this.windowSize.value = windowSize;
    this.leadStatus.value = leadStatus;
    this.bruxismStatus.value = bruxismStatus;
    this.battery.value = battery;
    this.chargingStatus.value = isCharging;

    hexData.value = chunk;

    // 로깅 맵 생성
    // final Map<String, dynamic> logging = {
    //   'Counter': counter,
    //   'Amplitude Raw': amplitude,
    //   'VTH Raw': vth,
    //   'ETC Raw': etcRaw,
    //   'Bruxism Status': bruxismStatus,
    //   'Lead Status': leadStatus,
    //   'Window Size': windowSize,
    //   'Vibrator': vibration,
    //   'Battery Raw': betteryRaw,
    //   'Battery Level': battery,
    //   'Is Charging': isCharging
    // };
    // loggerNoStack.t(logging);
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
        logger.i(results);
        devices.value = results.map((result) => result.device).toList();
      },
      onError: (e) => logger.e(e.toString()),
    );
    FlutterBluePlus.cancelWhenScanComplete(scanSubscription!);
  }

  void subscribeToConnectionState(BluetoothDevice device) {
    connectionStateSubscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      // logger.i(state);
      switch (state) {
        case BluetoothConnectionState.disconnected:
          isConnected.value = false;
          break;
        case BluetoothConnectionState.connected:
          isConnected.value = true;
          await SharedPreferencesHelper.saveData(
              SharedPreferencesKey.deviceId, device.remoteId.str);
          // logger.i(device);
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

  List<String> splitStringIntoParts(String str) {
    List<String> chunks = [];
    for (int i = 0; i < str.length; i += 2) {
      chunks.add(str.substring(i, i + 2));
    }
    return chunks;
  }

  // List<int> toRawData(String chunk) {
  //   List<int> filteredRawData = [];
  //   for (int i = 0; i < chunk.length; i += 2) {
  //     String part = chunk.substring(i, i + 2);
  //     filteredRawData.add(int.parse(part, radix: 16));
  //   }
  //   return filteredRawData;
  // }

  void subscribeToNotifyCharacteristic(BluetoothCharacteristic characteristic) {
    characteristicSubscription =
        characteristic.onValueReceived.listen((rawData) async {
      final hex = HEX.encode(rawData);
      // logger.i(hex);
      final List<String> chunks = RegExp(r'(a5.{32}5a)')
          .allMatches(hex)
          .map((match) => match.group(0))
          .whereType<String>() // null 값을 제거하고 String 타입만 남김
          .toList();
      // logger.i(chunks.length);

      if (chunks.isNotEmpty) {
        buffer.addAll(chunks.whereType<String>());
        if (isOperating.value) {
          final filteredRawData = ProcessHelper.toBytes(chunks);
          // final List<int> filteredRawData =
          //     chunks.map((chunk) => toRawData(chunk)).expand((x) => x).toList();
          await LocalFileManager.instance
              .writeFile(filteredRawData, FileType.sleepAnalysis);
        }
      }
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
      characteristicSubscription = null;
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
    // logger.i("services count : ${services.length}");
    characteristicsWorker = ever(characteristics, updateCharacteristics);
    services.forEach((service) {
      discoverCharacteristics(service);
    });
  }

  void discoverCharacteristics(BluetoothService service) {
    List<BluetoothCharacteristic> characteristics = service.characteristics;
    characteristics.forEach((characteristic) {
      // logger.i(characteristic.uuid);

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
