import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VibrationPattern extends StatefulWidget {
  final BluetoothDevice? connectedDevice;
  final int? vibPatternIndex;
  const VibrationPattern(
      {super.key,
      required this.connectedDevice,
      required this.vibPatternIndex});

  @override
  State<VibrationPattern> createState() =>
      _VibrationPatternState(connectedDevice, vibPatternIndex);
}

class _VibrationPatternState extends State<VibrationPattern> {
  BluetoothDevice? connectedDevice;
  int? vibPatternIndex;
  _VibrationPatternState(this.connectedDevice, this.vibPatternIndex);
  double screen = 0;
  late SharedPreferences prefs;
  int selectedValue = -1;
  List<String> vibPatternOptions = ['Night', 'Star', 'Moon', 'Dream', 'Random'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
      prefs = await SharedPreferences.getInstance();
      selectedValue = vibPatternIndex!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          textScaleFactor: 0.8,
          "진동패턴 선택",
        ),
        backgroundColor: Color(0xFF0F0D2B),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: screen,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg2.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedValue = index;
                      Navigator.pop(
                        context,
                        "${vibPatternOptions[selectedValue]}-${selectedValue}",
                      );
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          textScaleFactor: 0.8,
                          '${vibPatternOptions[index]}',
                          style: TextStyle(
                            fontFamily: 'Pretendart',
                            color: Colors.white,
                            fontSize: screen * 0.02,
                          ),
                        ),
                        Theme(
                          data: ThemeData(unselectedWidgetColor: Colors.grey),
                          child: Radio(
                            value: index,
                            groupValue: selectedValue,
                            activeColor: Colors.white,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value!;
                                Navigator.pop(
                                  context,
                                  "${vibPatternOptions[selectedValue]}-${selectedValue}",
                                );
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1.5,
                  color: Color(0xFF4A4A5C),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
