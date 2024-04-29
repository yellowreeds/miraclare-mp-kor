import 'dart:convert';

import 'package:goodeeps2/utils/bluetooth_manager.dart';

enum UartCommand {
  start("SB+" + "start" + r"\" + "n"),
  stop("SB+" + "stop" + r"\" + "n");

  List<int> bytes() {
    return utf8.encode(this.rawValue);
  }
  final String rawValue;

  const UartCommand(this.rawValue);
}

class UartCommandHelper {

  static Future<void> command(UartCommand uartCommand) async {
    if (BluetoothManager.instance.characteristics.value.item2 != null) {
      await BluetoothManager.instance.characteristics.value.item2!.write
        (uartCommand.bytes());
    }
  }
}