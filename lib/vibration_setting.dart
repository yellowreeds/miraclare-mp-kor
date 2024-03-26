import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:goodeeps2/vibration_pattern_screen.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class VibrationSetting extends StatefulWidget {
  final BluetoothDevice? connectedDevice;
  const VibrationSetting({super.key, required this.connectedDevice});

  @override
  State<VibrationSetting> createState() =>
      _VibrationSettingState(connectedDevice);
}

class _VibrationSettingState extends State<VibrationSetting> {
  BluetoothDevice? connectedDevice;
  _VibrationSettingState(this.connectedDevice);
  double screenHeight = 0;
  double screenWidth = 0;
  double vibIntensity = 0;
  int vibPattern = 0;
  bool autoVibrate = false;
  String selectedOption = "Night";
  bool isLoading = false;

  late SharedPreferences prefs;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      MediaQueryData mediaQueryData = MediaQuery.of(context);
      if (mediaQueryData.orientation == Orientation.portrait) {
        setState(() {
          screenHeight = mediaQueryData.size.height;
          screenWidth = mediaQueryData.size.height;
        });
      } else {
        setState(() {
          screenHeight = mediaQueryData.size.width;
          screenWidth = mediaQueryData.size.height;
        });
      }
      prefs = await SharedPreferences.getInstance();
      vibIntensity = await prefs.getDouble('vibrationIntensity') ?? 5;
      selectedOption = await prefs.getString('vibPatternName') ?? "Night";
      vibPattern = await prefs.getInt('vibrationPattern') ?? 0;
      autoVibrate = await prefs.getBool('autoVibrate') ?? false;
    });
  }

  @override
  void dispose() {
    isLoading = false;
    super.dispose();
  }

  void sendUARTCommand(String uartCommand) async {
    if (connectedDevice != null) {
      List<BluetoothService> services =
          await connectedDevice!.discoverServices();
      BluetoothCharacteristic? uartCharacteristic;
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write) {
            uartCharacteristic = characteristic;
            break;
          }
        }
      }
      String command = uartCommand;
      List<int> commandBytes = utf8.encode(command);
      await uartCharacteristic?.write(commandBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            textScaleFactor: 0.8,
            "진동자극 조절",
          ),
          backgroundColor: Color(0xFF0F0D2B),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            height: screenHeight,
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
                  height: screenHeight * 0.03,
                ),
                Text(
                  textScaleFactor: 0.8,
                  "진동세기 조절",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'Pretendart',
                      color: Colors.white,
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.bold),
                ),
                MediaQuery(
                  data: const MediaQueryData(textScaleFactor: 0.85),
                  child: SfSliderTheme(
                    data: SfSliderThemeData(
                      activeTrackHeight: 15,
                      inactiveTrackHeight: 15,
                      activeLabelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight * 0.018,
                      ),
                      inactiveLabelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight * 0.018,
                      ),
                    ),
                    child: SfSlider(
                      value: vibIntensity,
                      min: 1,
                      max: 10,
                      showLabels: true,
                      activeColor: Color(0xFFFFC71B),
                      interval: 1,
                      showDividers: true,
                      stepSize: 1.0,
                      dividerShape: _DividerShape(),
                      onChanged: (value) {
                        setState(() {
                          vibIntensity = value;
                        });
                      },
                      labelFormatterCallback:
                          (dynamic value, String formattedValue) {
                        // Customize the labels to show only 0, 5, and 10
                        if (value == 1 || value == 5 || value == 10) {
                          return value.toInt().toString();
                        }
                        return '';
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: autoVibrate,
                        checkColor: Colors.black,
                        activeColor: Colors.white,
                        onChanged: (value) {
                          setState(() {
                            autoVibrate = value!;
                            if (autoVibrate) {
                              prefs.setBool("autoVibrate", true);
                            } else {
                              prefs.setBool("autoVibrate", false);
                            }
                          });
                        },
                      ),
                      Text(
                        textScaleFactor: 0.8,
                        '자동 조절 옵션',
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.018,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Text(
                  textScaleFactor: 0.8,
                  "진동패턴",
                  style: TextStyle(
                      fontFamily: 'Pretendart',
                      color: Colors.white,
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  color: Colors.transparent,
                  child: TextButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VibrationPattern(
                              connectedDevice: connectedDevice,
                              vibPatternIndex: vibPattern),
                        ),
                      ).then((returnedData) {
                        if (returnedData != null) {
                          setState(() {
                            print('returnedData: $returnedData');
                            selectedOption =
                                returnedData.toString().split("-")[0];
                            vibPattern = int.parse(
                                returnedData.toString().split("-")[1]);
                          });
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            textScaleFactor: 0.8,
                            selectedOption,
                            style: TextStyle(
                                fontFamily: 'Pretendart',
                                color: Colors.white,
                                fontSize: screenHeight * 0.022),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1.0,
                  color: Color(0xFFFFFFFF),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Color(0xFF714AC6),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            prefs.setDouble('vibrationIntensity', vibIntensity);
                            prefs.setBool('autoVibrate', autoVibrate);
                            prefs.setInt('vibrationPattern', vibPattern);
                            prefs.setString('vibPatternName', selectedOption);

                            sendUARTCommand("SB+" +
                                "testPat=" +
                                vibPattern.toString() +
                                "," +
                                (vibIntensity.toInt()).toString() +
                                ",2,2" +
                                r"\" +
                                "n");
                            await Future.delayed(Duration(seconds: 2));
                            sendUARTCommand("SB+" + "testPat=-1" + r"\" + "n");
                            await Future.delayed(Duration(milliseconds: 500));
                            sendUARTCommand("SB+" +
                                "pat=" +
                                vibPattern.toString() +
                                "," +
                                (vibIntensity.toInt()).toString() +
                                ",2,2" +
                                r"\" +
                                "n");
                            await Future.delayed(Duration(seconds: 1));
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }

                            await scaffoldMessengerKey.currentState
                                ?.showSnackBar(
                              SnackBar(
                                content: Text(
                                  textScaleFactor: 0.8,
                                  '설정이 성공적으로 저장되었습니다!',
                                  style:
                                      TextStyle(fontSize: screenHeight * 0.02),
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: screenHeight * 0.02,
                            height: screenHeight * 0.02,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ) // Display loading indicator
                        : Text(
                            textScaleFactor: 0.8,
                            '저장',
                            style: TextStyle(
                              fontFamily: 'Pretendart',
                              fontSize: screenHeight * 0.02,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DividerShape extends SfDividerShape {
  @override
  void paint(PaintingContext context, Offset center, Offset? thumbCenter,
      Offset? startThumbCenter, Offset? endThumbCenter,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection}) {
    context.canvas.drawRect(
        Rect.fromCenter(center: center, width: 1, height: 15),
        Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.fill
          ..color = Colors.black);
  }
}
