import 'package:flutter/material.dart';
import 'package:goodeeps2/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';

class PersonalInformation extends StatefulWidget {
  final String custID;
  const PersonalInformation({super.key, required this.custID});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState(custID);
}

class _PersonalInformationState extends State<PersonalInformation> {
  String custID;
  _PersonalInformationState(this.custID);
  double screenHeight = 0;
  double screenWidth = 0;
  bool isDontKnowSelected = false;
  late SharedPreferences prefs;

  List<int> questionsAnswer = List<int>.filled(19, 0);

  double fillValue = 0.053;
  int qCounter = 1;
  int counter = 0;
  double _value = 0;
  DateTime now = DateTime.now();
  List<int> selectedButtonIndices = [];

  int selectedButtonIndex = -1;
  String custUsername = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      MediaQueryData mediaQueryData = MediaQuery.of(context);
      if (mediaQueryData.orientation == Orientation.portrait) {
        setState(() {
          screenHeight = mediaQueryData.size.height;
          screenWidth = mediaQueryData.size.width;
        });
      } else {
        setState(() {
          screenHeight = mediaQueryData.size.width;
          screenWidth = mediaQueryData.size.width;
        });
      }
      prefs = await SharedPreferences.getInstance();
      custUsername = await prefs.getString('custUsername') ?? "";
    });
  }

  void selectButton(int index) {
    setState(() {
      if (qCounter == 5) {
        if (selectedButtonIndices.contains(index)) {
          selectedButtonIndices.remove(index);
        } else {
          selectedButtonIndices.add(index);
        }
        if (selectedButtonIndices.contains(4)) {
          selectedButtonIndices.clear();
          selectedButtonIndices.add(4);
        }
      } else {
        selectedButtonIndex = index;
      }
    });
  }

  String _twoDigitFormat(int number) {
    return number.toString().padLeft(2, '0');
  }

  Future<void> surveySubmit(BuildContext context) async {
    try {
      final String apiUrl = 'http://3.21.156.190:3000/api/customers/survey';

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'sur_height': questionsAnswer[0].toString(),
          'sur_weight': questionsAnswer[1].toString(),
          'sur_split_ext': questionsAnswer[2].toString(),
          'sur_botox_trt': questionsAnswer[3].toString(),
          'sur_sleep_disd': selectedButtonIndices.toString(),
          'sur_dur_brx': questionsAnswer[5].toString(),
          'sur_pain_area': questionsAnswer[6].toString(),
          'sur_sick_tzone': questionsAnswer[7].toString(),
          'sur_pain_lvl': questionsAnswer[8].toString(),
          'sur_apr_obs': questionsAnswer[9].toString(),
          'sur_jaw_jmg': questionsAnswer[10].toString(),
          'sur_fc_asmy': questionsAnswer[11].toString(),
          'sur_headache': questionsAnswer[12].toString(),
          'sur_chr_ftg': questionsAnswer[13].toString(),
          'sur_pain_ttgm': questionsAnswer[14].toString(),
          'sur_tth_hysn': questionsAnswer[15].toString(),
          'sur_strs_lvl': questionsAnswer[16].toString(),
          'sur_smkg': questionsAnswer[17].toString(),
          'sur_drnk': questionsAnswer[18].toString(),
          'sur_ent_date':
              '${now.year}-${_twoDigitFormat(now.month)}-${_twoDigitFormat(now.day)}',
          'cust_id': custID
        },
      );

      if (response.statusCode == 201) {
        print("Success");
        showSuccessDialog(context, '완료 되었습니다.');
      } else {
        print("Error: ${response.body}");
      }
    } catch (error) {
      showSuccessDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
    }
  }

  final List<String> questionList = [
    '당신의 키는 몇 cm 입니까?',
    '당신의 몸무게는 몇 kg 입니까?',
    '당신은 이갈이 완화를 위해\n 스플린트(Splint)를 사용해본\n 경험이 있습니까?',
    '당신은 이갈이 완화를 위해\n보톡스 치료를 하신 경험이 있습니까?',
    '수면에 관하여 어떤 증상이 있습니까?',
    '관련 증상을 앓은지 얼마나 되셨습니까?',
    '턱이나 치아의 통증이 있다면\n어느 쪽이 아픕니까?',
    '턱이나 치아의 통증이 있다면\n언제 불편하십니까?',
    '턱이나 치아의 통증이 있다면\n어느 정도 아픕니까? ',
    '기상 후 입이 잘 벌어지십니까?',
    '기상 후 입을 벌릴 때 자주 턱이 걸립니까?',
    '평소에 입을 벌릴 때 틀어지십니까?',
    '기상 후 두통이 있습니까?',
    '기상 후 피로감을 느낍니까?',
    '기상 후 치아 혹은 잇몸 통증을 느낍니까?',
    '기상 후 이 시림 증상을 느낍니까?',
    '당신이 느끼는 스트레스는\n어느 정도 입니까?',
    '당신은 흡연을 하고 있습니까?',
    '당신은 음주를 하고 있습니까?',
  ];

  List<List<String>> choices = [
    [
      '150cm 미만',
      '150cm 이상 ~ 160cm 미만',
      '160cm 이상 ~ 170cm 미만',
      '170cm 이상 ~ 180cm 미만',
      '180cm 이상'
    ],
    [
      '50kg 미만',
      '50kg 이상 ~ 60kg 미만',
      '60kg 이상 ~ 70kg 미만',
      '70kg 이상 ~ 80kg 미만',
      '80kg 이상'
    ],
    [
      '있다',
      '없다',
    ],
    [
      '있다',
      '없다',
    ],
    ['이갈기', '이악물기', '코골이', '불면증', '잘 모르겠다'],
    ['1개월 미만', '1개월 이상 ~ 3개월 미만', '3개월 이상 ~ 6개월 미만', '6개월 이상 ~ 1년 미만', '1년 이상'],
    ['왼쪽', '오른쪽', '양쪽', '잘 모르겠다'],
    ['기상 후', '일과중', '밤', '수시로', '잘 모르겠다'],
    [
      '통증 없음',
      '조금\n불편함',
      '불편함',
      '조금 아픔',
      '아픔',
      '많이 아픔',
      '매우 아픔',
      '극심함',
      '매우\n극심함',
      '참기 힘듦',
      '매우\n참기힘듦',
    ],
    ['매우 그렇지 않다', '그렇지 않다', '보통이다', '그렇다', '매우 그렇다'],
    ['매우 그렇지 않다', '그렇지 않다', '보통이다', '그렇다', '매우 그렇다'],
    ['매우 그렇지 않다', '그렇지 않다', '보통이다', '그렇다', '매우 그렇다'],
    ['전혀 없다', '드물다', '보통이다', '종종 있다', '빈번하다'],
    ['전혀 없다', '드물다', '보통이다', '종종 있다', '빈번하다'],
    ['전혀 없다', '드물다', '보통이다', '종종 있다', '빈번하다'],
    ['전혀 없다', '드물다', '보통이다', '종종 있다', '빈번하다'],
    ['매우 낮다', '낮다', '보통이다', '높다', '매우 높다'],
    [
      '비흡연',
      '흡연 (주 1갑 미만)',
      '흡연 (주 2갑 이상)',
      '금연',
    ],
    [
      '비음주',
      '음주 (주 1~2회 미만)',
      '음주 (주 3회 이상)',
      '금주',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF110925), Color(0xFF2A0C54)],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.08,
                ),
                Center(
                  child: Container(
                    width: screenWidth * 0.5,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      textScaleFactor: 0.8,
                      "설문조사",
                      style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: screenHeight * 0.015,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: LinearProgressIndicator(
                            value: fillValue,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFC71B),
                            ),
                            backgroundColor: Color.fromRGBO(89, 93, 104, 1),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      textScaleFactor: 0.8,
                      qCounter < 10 ? "0${qCounter}/19" : "${qCounter}/19",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.018),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                Center(
                  child: Container(
                    width: screenWidth,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      textScaleFactor: 0.8,
                      "${questionList[counter]}",
                      style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontFamily: 'Pretendart',
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                qCounter == 9
                    ? SizedBox(
                        height: screenHeight * 0.03,
                      )
                    : SizedBox(
                        height: screenHeight * 0.01,
                      ),
                qCounter == 9
                    ? Column(
                        children: [
                          Container(
                            height: screenHeight * 0.015,
                            padding: EdgeInsets.only(top: screenHeight * 0.007),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(111, 218, 49, 1),
                                  Color.fromRGBO(225, 223, 53, 1),
                                  Color.fromRGBO(254, 189, 68, 1),
                                  Color.fromRGBO(253, 123, 87, 1),
                                  Color.fromRGBO(254, 63, 43, 1),
                                  Color.fromRGBO(255, 6, 4, 1),
                                ],
                                stops: [
                                  0.0,
                                  0.2,
                                  0.4,
                                  0.6,
                                  0.8,
                                  1.0,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: MediaQuery(
                              data: const MediaQueryData(textScaleFactor: 0.85),
                              child: SfSliderTheme(
                                data: SfSliderThemeData(
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
                                  min: 0.0,
                                  max: 10.0,
                                  value: _value,
                                  interval: 1,
                                  stepSize: 1.0,
                                  labelFormatterCallback: (dynamic actualValue,
                                      String formattedText) {
                                    return actualValue % 2 == 0
                                        ? actualValue.toInt().toString()
                                        : '';
                                  },
                                  inactiveColor: Colors.transparent,
                                  activeColor: Colors.transparent,
                                  showDividers: true,
                                  dividerShape: _DividerShape(),
                                  thumbShape: _SfThumbShape(),
                                  showLabels: true,
                                  onChanged: (dynamic value) {
                                    setState(() {
                                      _value = value;
                                      selectedButtonIndex = _value.toInt();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                        ],
                      )
                    : Text(textScaleFactor: 0.8, ""),
                qCounter == 9
                    ? SizedBox(
                        height: screenHeight * 0.03,
                      )
                    : SizedBox(
                        height: screenHeight * 0.00,
                      ),
                qCounter != 9
                    ? Column(
                        children: [
                          for (int i = 0; i < choices[counter].length; i++)
                            Column(
                              children: [
                                buildButton(i, '${choices[counter][i]}',
                                    Color.fromRGBO(64, 58, 88, 1)),
                                SizedBox(
                                  height: screenHeight * 0.012,
                                ),
                              ],
                            ),
                        ],
                      )
                    : Container(
                        width: screenWidth,
                        child: Column(
                          children: List.generate(
                            (choices[counter].length / 3).ceil(),
                            (rowIndex) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      3,
                                      (colIndex) {
                                        final index = rowIndex * 3 + colIndex;
                                        if (index < choices[counter].length) {
                                          return SizedBox(
                                            width: (screenWidth -
                                                    (screenWidth * 0.2 * 2)) *
                                                0.5,
                                            child: buildButton(
                                              index,
                                              '${choices[counter][index]}',
                                              Color.fromRGBO(64, 58, 88, 1),
                                            ),
                                          );
                                        } else {
                                          return SizedBox(
                                            width: (screenWidth -
                                                    (screenWidth * 0.2 * 2)) *
                                                0.5,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                Container(
                  width: screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: (screenWidth / 2) -
                            (screenWidth * 0.02 * 2) -
                            (screenWidth * 0.03),
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (counter > 0) {
                                questionsAnswer[counter] = selectedButtonIndex;
                                counter -= 1;
                                if (fillValue > 0.053) {
                                  setState(() {
                                    if (selectedButtonIndices.contains(4) &&
                                        qCounter == 7) {
                                      qCounter -= 2;
                                      counter -= 1;
                                      fillValue -= 0.106;
                                    } else {
                                      qCounter -= 1;
                                      fillValue -= 0.053;
                                    }
                                    selectedButtonIndex = -1;
                                  });
                                }
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF817C99),
                          ),
                          child: Text(
                            textScaleFactor: 0.8,
                            '이전',
                            style: TextStyle(
                                fontSize: screenHeight * 0.02,
                                fontFamily: 'Pretendart',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.03,
                      ),
                      SizedBox(
                        width: (screenWidth / 2) -
                            (screenWidth * 0.02 * 2) -
                            (screenWidth * 0.03),
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (counter < 18) {
                                if ((qCounter != 5 &&
                                        selectedButtonIndex != -1 ||
                                    (qCounter == 5 &&
                                        selectedButtonIndices.isNotEmpty))) {
                                  questionsAnswer[counter] =
                                      selectedButtonIndex;
                                  counter += 1;
                                  if (fillValue < 1.0) {
                                    setState(
                                      () {
                                        if (selectedButtonIndices.contains(4) &&
                                            (qCounter == 5)) {
                                          qCounter += 2;
                                          counter += 1;
                                          fillValue += 0.106;
                                        } else {
                                          qCounter += 1;
                                          fillValue += 0.053;
                                        }
                                        selectedButtonIndex = -1;
                                      },
                                    );
                                  }
                                }
                              } else {
                                if (selectedButtonIndex != -1) {
                                  questionsAnswer[counter] =
                                      selectedButtonIndex;
                                  if (custUsername == "abismaw" ||
                                      custUsername == "dhkim" ||
                                      custUsername == "jsseo" ||
                                      custUsername == "jhkim" ||
                                      custUsername == "jhbyun" ||
                                      custUsername == "gmstest") {
                                    Uint8List bytes =
                                        Uint8List.fromList(questionsAnswer);
                                    final Directory? directoryRaw = Directory(
                                        "storage/emulated/0/Download");
                                    final File fileRaw = File(
                                        '${directoryRaw!.path}/prsq${DateTime.now().millisecondsSinceEpoch}.bin');
                                    fileRaw.writeAsBytes(bytes,
                                        mode: FileMode.append);
                                  }
                                  surveySubmit(context);
                                }
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF714AC6),
                          ),
                          child: Text(
                            textScaleFactor: 0.8,
                            '다음',
                            style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(int index, String label, Color color) {
    bool isSelected = selectedButtonIndices.contains(index);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: screenHeight * 0.08,
      ),
      child: IntrinsicHeight(
          child: Container(
        width: screenWidth,
        child: ElevatedButton(
          onPressed: isDontKnowSelected && (index != 4) && (qCounter == 5)
              ? null
              : () {
                  selectButton(index);
                  setState(() {
                    if (qCounter == 9) {
                      _value = index.toDouble();
                    }
                    if (qCounter == 5 && index == 4) {
                      isDontKnowSelected = !isDontKnowSelected;
                    }
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: qCounter == 5
                ? isSelected
                    ? Color(0xFF714AC6)
                    : color
                : selectedButtonIndex == index
                    ? Color(0xFF714AC6)
                    : color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Container(
            width: screenWidth,
            padding: EdgeInsets.only(left: 2),
            child: Align(
              alignment:
                  qCounter == 9 ? Alignment.center : Alignment.centerLeft,
              child: Text(
                textScaleFactor: 0.8,
                "$label",
                textAlign: qCounter == 9 ? TextAlign.center : TextAlign.left,
                style: qCounter == 9
                    ? TextStyle(
                        color: Colors.white, fontSize: screenHeight * 0.0195)
                    : TextStyle(
                        color: Colors.white, fontSize: screenHeight * 0.022),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Future<void> showSuccessDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent dialog from being dismissed
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: screenWidth,
              padding: EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 5),
              color: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      textScaleFactor: 0.8,
                      message,
                      style: TextStyle(
                        fontFamily: 'Pretendart',
                        color: Colors.white,
                        fontSize: screenHeight * 0.02,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      prefs.setBool('calibrationDone', false);
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      textScaleFactor: 0.8,
                      '확인',
                      style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.02),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SfThumbShape extends SfThumbShape {
  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required SfThumb? thumb}) {
    final Path path = Path();

    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx + 10, center.dy - 15);
    path.lineTo(center.dx - 10, center.dy - 15);
    path.close();
    context.canvas.drawPath(path, Paint()..color = Color(0xFFFFC71B));
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
        Rect.fromCenter(center: center, width: 2, height: 15),
        Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.fill
          ..color = Colors.black);
  }
}
