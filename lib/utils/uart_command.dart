import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'uart_command.freezed.dart'; // ensure this is correctly named

@freezed
class UartCommand with _$UartCommand {
  const factory UartCommand.start() = Start;

  const factory UartCommand.stop() = Stop;

  const factory UartCommand.vth(String vth) = Vth;

  const UartCommand._();

  String get command {
    return when(
      start: () => "SB+start\\n",
      stop: () => "SB+stop\\n",
      vth: (vth) => "SB+vth=$vth\\n",
    );
  }

  List<int> get bytes => utf8.encode(command);
}
