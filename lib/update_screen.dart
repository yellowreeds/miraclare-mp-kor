import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hex/hex.dart';

class UpdateScreen extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  const UpdateScreen({super.key, required this.connectedDevice});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState(connectedDevice);
}

class _UpdateScreenState extends State<UpdateScreen> {
  double screen = 0;
  BluetoothDevice? connectedDevice;
  _UpdateScreenState(this.connectedDevice);
  StreamSubscription<List<int>>? valueSubscription;
  BluetoothCharacteristic? readCharacteristic;
  BluetoothCharacteristic? uartCharacteristic;
  bool upgradeStart = false;
  late int? fileSize;
  int index = 0;
  String commandFromDevice = "";

  void sendUARTCommand(String uartCommand) async {
    if (valueSubscription != null) {
      valueSubscription!.cancel();
    }
    // Wakelock.enable();
    if (connectedDevice != null) {
      List<BluetoothService> services =
          await connectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write) {
            uartCharacteristic = characteristic;
            break;
          }
        }
      }
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify) {
            readCharacteristic = characteristic;
            break;
          }
        }
      }
      if (!upgradeStart) {
        List<int> commandBytes = utf8.encode(uartCommand);
        await uartCharacteristic?.write(commandBytes);
      }
      if (upgradeStart) {
        Uint8List? commandBytes;
        List<int> hexBytes = [];
        for (int i = 0; i < uartCommand.length; i += 2) {
          hexBytes.add(int.parse(uartCommand.substring(i, i + 2), radix: 16));
          commandBytes = Uint8List.fromList(hexBytes);
        }
        await uartCharacteristic?.write(commandBytes!);
      }
      if (readCharacteristic != null) {
        await readCharacteristic!.setNotifyValue(true);
        valueSubscription = readCharacteristic!.value.listen(
          (value) async {
            if (!mounted) {
              return;
            }
            if (HEX.encode(value).isNotEmpty) {
              print('index: $index');
              List<int> bytes = HEX.decode(HEX.encode(value));
              try {
                String decodedString = utf8.decode(bytes);
                if (decodedString.contains("SA+upgSize")) {
                  fileSize = await getFileSize();
                  sendUARTCommand(
                      "SB+" + "upgSize=" + "$fileSize" + r"\" + "n");
                }
                String text = 'SA+upgBin=${fileSize! - 128},128';
                String hexString = text.codeUnits.map((unit) {
                  return unit.toRadixString(16).padLeft(2, '0');
                }).join('');
                if (HEX.encode(value).contains(hexString) && index == 0) {
                  upgradeStart = true;
                  String lastBytes =
                      await readBinaryFileInChunks(fileSize! - 128, 128);
                  sendUARTCommand(lastBytes);
                }
                if (index <= (fileSize! - 128)) {
                  if (decodedString.contains("SA+upgBin=$index,128") &&
                      commandFromDevice != decodedString) {
                    commandFromDevice = decodedString;
                    String bytesChunk =
                        await readBinaryFileInChunks(index, 128);
                    sendUARTCommand(bytesChunk);
                    index = index + 128;
                  }
                  if (decodedString.contains("SA+upgEnd")) {
                    Navigator.of(context).pop();
                    showSuccessDialog(
                        context, "업데이트가 완료되었습니다! 장치를 켜고 다시 연결하여 사용하세요.");
                  }

                  if (index >= (fileSize! - 128)) {
                    index = 0;
                  }
                }
              } catch (e) {
                print("Error: $e");
              }
            }
          },
        );
      }
    }
  }

  Future<int?> getFileSize() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/GooDeeps_20231227_V2.10.7.bin';
      final file = File(filePath);

      if (await file.exists()) {
        fileSize = await file.length();
        return fileSize;
      } else {
        print('File does not exist.');
      }
    } catch (e) {
      print('Error getting file size: $e');
    }
    return null;
  }

  Future<String> readBinaryFileInChunks(int start, int length) async {
    final int chunkSize = 128;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/GooDeeps_20231227_V2.10.7.bin';
    final file = File(filePath);

    if (await file.exists()) {
      final raf = await file.open();
      final buffer = List<int>.generate(chunkSize, (index) => 0);

      final endPosition = start + length;

      await raf.setPosition(start);

      while (await raf.position() < endPosition) {
        final bytesRead = await raf.readInto(buffer);
        if (bytesRead > 0) {
          int decimalNumber = start;
          String hexadecimalStringHeader =
              decimalNumber.toRadixString(16).padLeft(8, '0');
          int endNumber = 4294967295;
          String endNumberString = endNumber.toRadixString(16);
          String hexadecimalString = buffer
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join('');
          return "${hexadecimalStringHeader}$hexadecimalString${endNumberString}";
        }
      }
      await raf.close();
    } else {
      return 'File does not exist.';
    }
    return "Error";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MediaQueryData mediaQueryData = MediaQuery.of(context);
      if (mediaQueryData.orientation == Orientation.portrait) {
        setState(() {
          screen = mediaQueryData.size.height;
        });
      } else {
        setState(() {
          screen = mediaQueryData.size.width;
        });
      }
    });
  }

  Future<void> showSuccessDialog(BuildContext context, String status) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: screen,
            padding: EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 5),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    textScaleFactor: 0.8,
                    status,
                    style: TextStyle(
                      fontFamily: 'Pretendart',
                      color: Colors.white,
                      fontSize: screen * 0.02,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: screen * 0.05,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    textScaleFactor: 0.8,
                    '확인',
                    style: TextStyle(
                        fontFamily: 'Pretendart', fontSize: screen * 0.02),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          textScaleFactor: 0.8,
          "업데이트",
        ),
        backgroundColor: Color(0xFF0F0D2B),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg2.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: screen * 0.02,
            ),
            Text(
              textScaleFactor: 0.8,
              "모바일 App",
              style: TextStyle(
                  fontFamily: 'Pretendart',
                  fontSize: screen * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(
              height: screen * 0.02,
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF464060),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        textScaleFactor: 0.8,
                        "App 정보",
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screen * 0.02,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        textScaleFactor: 0.8,
                        "1.0/1.0",
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screen * 0.02,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screen * 0.02,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF170839),
                      minimumSize: Size(screen, screen * 0.055),
                    ),
                    child: Text(
                      textScaleFactor: 0.8,
                      '업데이트',
                      style: TextStyle(
                        fontFamily: 'Pretendart',
                        fontSize: screen * 0.02,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screen * 0.02,
            ),
            Text(
              textScaleFactor: 0.8,
              "디바이스 펌웨어",
              style: TextStyle(
                  fontFamily: 'Pretendart',
                  fontSize: screen * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(
              height: screen * 0.02,
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF464060),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        textScaleFactor: 0.8,
                        "디바이스 펌웨어",
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screen * 0.02,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        textScaleFactor: 0.8,
                        "2.10.7/2.10.7",
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screen * 0.02,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screen * 0.02,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      sendUARTCommand("SB+" + "upgStart" + r"\" + "n");
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return WillPopScope(
                            onWillPop: () async {
                              return false;
                            },
                            child: AlertDialog(
                              contentPadding: EdgeInsets.zero,
                              content: Container(
                                width: screen,
                                padding: EdgeInsets.only(
                                    top: 30, left: 30, right: 30, bottom: 30),
                                color: Colors.black,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(
                                      textScaleFactor: 0.8,
                                      '업데이트 중...\n애플리케이션을 종료하지 말고 화면을 끄지 마세요.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Pretendart',
                                          fontSize: screen * 0.019,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF170839),
                      minimumSize: Size(screen, screen * 0.055),
                    ),
                    child: Text(
                      textScaleFactor: 0.8,
                      '업데이트',
                      style: TextStyle(
                        fontFamily: 'Pretendart',
                        fontSize: screen * 0.02,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
