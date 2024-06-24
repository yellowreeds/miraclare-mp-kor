import 'package:goodeeps2/utils/bluetooth_manager.dart';
import 'package:goodeeps2/utils/uart_command.dart';

class UartCommandHelper {
  static Future<void> command(UartCommand uartCommand) async {
    if (BluetoothManager.instance.characteristics.value.item2 != null) {
      await BluetoothManager.instance.characteristics.value.item2!
          .write(uartCommand.bytes);
    }
  }
}
