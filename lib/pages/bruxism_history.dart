import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:goodeeps2/utils/chart_data.dart';
import 'package:goodeeps2/services/bruxism.dart';

class BruxismHistory extends StatefulWidget {
  const BruxismHistory({super.key});

  @override
  State<BruxismHistory> createState() => _BruxismHistoryState();
}

class _BruxismHistoryState extends State<BruxismHistory> {
  double screenHeight = 0;
  double screenWidth = 0;
  String latestBrEpisode = "";
  String highestBrMax = "";
  String latestData = "";
  String weeklyBrAverage = "";
  String sleepStart = "1970-12-13T18:26:38.000Z";
  String sleepStop = "1970-12-13T18:26:38.000Z";
  String sleepDuration = "60";
  bool isLoading = false;
  late SharedPreferences prefs;
  late String? custUsername;
  Map<String, int> brData = {};
  final TextEditingController dateController = TextEditingController();

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
          screenWidth = mediaQueryData.size.height;
        });
      }
      prefs = await SharedPreferences.getInstance();
      custUsername = await prefs.getString('custUsername');
      await loadSleepData(custUsername!);
    });
  }

  Future<void> loadSleepData(
    String custUsername, {
    String? fromDate,
    String? toDate,
  }) async {
    String toDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final jsonResponse = await Bruxism().getSleepDataResult(
        context, custUsername,
        fromDate: fromDate, toDate: toDate);

    if (jsonResponse != null) {
      setState(() {
        latestBrEpisode = jsonResponse['latest_br_episode'].toString();
        highestBrMax = jsonResponse['highest_br_max'].toString();
        latestData = jsonResponse['latest_data'].toString();
        weeklyBrAverage = jsonResponse['average_br_episode'].toString();
        sleepStart = jsonResponse['sleep_start'] == null
            ? "1970-12-13T18:26:38.000Z"
            : jsonResponse['sleep_start'].toString();
        sleepStop = jsonResponse['sleep_stop'] == null
            ? "1970-12-13T18:26:38.000Z"
            : jsonResponse['sleep_stop'].toString();
        sleepDuration = jsonResponse['sleep_duration'] == null
            ? "-99"
            : jsonResponse['sleep_duration']
                .toString(); // -99 means no sleep duration
        final brDataMap = Map<String, int>.from(jsonResponse['br_data']);

        final toDateDateTime = DateFormat('yyyy-MM-dd').parse(toDate);

        for (int i = 0; i < 7; i++) {
          final formattedDate = DateFormat('yy.MM.dd')
              .format(toDateDateTime.subtract(Duration(days: i)));
          if (!brDataMap.containsKey(formattedDate)) {
            brDataMap[formattedDate] = -99; // -99 means no sleep bruxism
          }
        }

        brData = brDataMap;
        List<MapEntry<String, int>> brDataList = brData.entries.toList();
        brDataList.sort((a, b) => a.key.compareTo(b.key));
        brData = Map.fromEntries(brDataList);

        if (brData.length > 7) {
          List<String> keysToRemove =
              brData.keys.take(brData.length - 7).toList();
          keysToRemove.forEach((key) {
            brData.remove(key);
          });
        }

        brData.forEach((date, brEpisode) {
          print('Date: $date, Br Episode: $brEpisode');
        });
      });
    } else {
      print('Failed to load user data');
    }
  }

  DateTime? parseDate(String text) {
    // The text is in the "YYYY.MM.DD" format
    final dateParts = text.split('.'); // Split the text into parts
    if (dateParts.length != 3) {
      return null;
    }
    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);

    if (year != null && month != null && day != null) {
      return DateTime(year, month, day);
    } else {
      return null;
    }
  }

  // automatically format the date to YYYY.MM.DD
  void _formatDate() {
    final text = dateController.text;
    final formattedDate = _formatDateString(text);
    if (formattedDate != text) {
      dateController.value = dateController.value.copyWith(
        text: formattedDate,
        selection: TextSelection.collapsed(offset: formattedDate.length),
      );
    }
  }

  String _formatDateString(String input) {
    final sanitizedString =
        input.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    final length = sanitizedString.length;

    if (length <= 4) {
      return sanitizedString;
    } else if (length <= 6) {
      return '${sanitizedString.substring(0, 4)}.${sanitizedString.substring(4)}';
    } else {
      return '${sanitizedString.substring(0, 4)}.${sanitizedString.substring(4, 6)}.${sanitizedString.substring(6)}';
    }
  }

  SfCartesianChart _buildBarChart(Map<String, dynamic> brData) {
    List<ChartData> chartData = [];

    brData.forEach((date, brEpisode) {
      if (brEpisode == -99) {
        final formattedDate = DateFormat('yy.MM.dd').parse(date);
        final dayNameInKorean = DateFormat.EEEE('ko_KR')
            .format(formattedDate); // Format day name in Korean
        final dateWithoutYear = DateFormat('MM.dd')
            .format(formattedDate); // Format date without year
        final dayNameWithoutYoil =
            dayNameInKorean.replaceFirst('요일', ''); // Remove "요일"

        chartData.add(ChartData('$dateWithoutYear\n$dayNameWithoutYoil\n',
            null)); // Combine date and day name
      } else {
        final formattedDate = DateFormat('yy.MM.dd').parse(date);
        final dayNameInKorean = DateFormat.EEEE('ko_KR')
            .format(formattedDate); // Format day name in Korean
        final dateWithoutYear = DateFormat('MM.dd')
            .format(formattedDate); // Format date without year
        final dayNameWithoutYoil =
            dayNameInKorean.replaceFirst('요일', ''); // Remove "요일"

        chartData.add(ChartData('$dateWithoutYear\n$dayNameWithoutYoil\n',
            brEpisode)); // Combine date and day name
      }
    });

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        // majorGridLines: MinorGridLines(width: 0),
        labelStyle:
            TextStyle(fontSize: screenHeight * 0.015, color: Colors.white),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(width: 0),
        minorGridLines: MinorGridLines(width: 0),
        interval: 1,
        labelStyle:
            TextStyle(fontSize: screenHeight * 0.015, color: Colors.white),
      ),
      plotAreaBorderColor: Colors.transparent,
      series: <ColumnSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: chartData,
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: (Radius.circular(15)), topRight: (Radius.circular(15))),
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.brEpisode,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.auto,
            labelPosition: ChartDataLabelPosition.outside,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          textScaleFactor: 0.8,
          "히스토리",
        ),
        backgroundColor: Color(0xFF0F0D2B),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF110925), Color(0xFF2A0C54)],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: screenHeight * 0.4,
                    child: _buildBarChart(brData),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      textScaleFactor: 0.8,
                      "이갈이 정보",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: screenWidth * 0.9,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: (screenWidth * 0.9) / 1.3,
                              child: Text(
                                textScaleFactor: 0.8,
                                "해당일 이갈이 횟수",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.02,
                                    color: Color(0xFFB6B7BA)),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                textScaleFactor: 0.8,
                                "$latestBrEpisode",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.02,
                                    color: Color(0xFFB6B7BA)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: (screenWidth * 0.9) / 1.3,
                              child: Text(
                                textScaleFactor: 0.8,
                                "해당주간 최대 횟수",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.02,
                                    color: Color(0xFFB6B7BA)),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                textScaleFactor: 0.8,
                                "$highestBrMax",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.02,
                                    color: Color(0xFFB6B7BA)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: (screenWidth * 0.9) / 1.3,
                              child: Text(
                                textScaleFactor: 0.8,
                                "해당주간 평균 횟수",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.02,
                                    color: Color(0xFFB6B7BA)),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                textScaleFactor: 0.8,
                                weeklyBrAverage.contains('.')
                                    ? (weeklyBrAverage.split('.')[1].length < 2
                                        ? weeklyBrAverage
                                        : "${weeklyBrAverage.substring(0, weeklyBrAverage.indexOf('.') + 3)}")
                                    : weeklyBrAverage,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Pretendart',
                                  fontSize: screenHeight * 0.02,
                                  color: Color(0xFFB6B7BA),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: screenWidth,
                      child: Text(
                        textScaleFactor: 0.8,
                        "수면 패턴",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'Pretendart',
                            fontSize: screenHeight * 0.025,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: screenWidth * 0.9,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: screenWidth / 2.8,
                              child: Text(
                                textScaleFactor: 0.8,
                                "취침 시각",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.02,
                                    color: Color(0xFFB6B7BA)),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.05,
                            ),
                            Expanded(
                              child: Container(
                                child: sleepStart == "1970-12-13T18:26:38.000Z"
                                    ? Text(
                                        textScaleFactor: 0.8,
                                        "선택일 기록 없음",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.02,
                                            color: Color(0xFFB6B7BA)),
                                      )
                                    : Text(
                                        textScaleFactor: 0.8,
                                        "${DateFormat('yyyy.MM.dd HH:mm:ss').format(DateTime.parse(sleepStart))}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.02,
                                            color: Color(0xFFB6B7BA)),
                                      ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: screenWidth / 2.8,
                              child: Text(
                                textScaleFactor: 0.8,
                                "기상 시각",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.02,
                                    color: Color(0xFFB6B7BA)),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.05,
                            ),
                            Expanded(
                              child: Container(
                                child: sleepStop == "1970-12-13T18:26:38.000Z"
                                    ? Text(
                                        textScaleFactor: 0.8,
                                        "선택일 기록 없음",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.02,
                                            color: Color(0xFFB6B7BA)),
                                      )
                                    : Text(
                                        textScaleFactor: 0.8,
                                        "${DateFormat('yyyy.MM.dd HH:mm:ss').format(DateTime.parse(sleepStop))}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.02,
                                            color: Color(0xFFB6B7BA)),
                                      ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: screenWidth / 2.8,
                              child: Text(
                                textScaleFactor: 0.8,
                                "수면 시간",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.02,
                                    color: Color(0xFFB6B7BA)),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.05,
                            ),
                            Expanded(
                              child: Container(
                                child: sleepDuration == "-99"
                                    ? Text(
                                        textScaleFactor: 0.8,
                                        '선택일 기록 없음',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.02,
                                            color: Color(0xFFB6B7BA)),
                                      )
                                    : Text(
                                        textScaleFactor: 0.8,
                                        '${(int.parse(sleepDuration) ~/ 3600).toString().padLeft(2, '0')}:' +
                                            '${((int.parse(sleepDuration) % 3600) ~/ 60).toString().padLeft(2, '0')}:' +
                                            '${(int.parse(sleepDuration) % 60).toString().padLeft(2, '0')}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.02,
                                            color: Color(0xFFB6B7BA)),
                                      ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.05,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: screenWidth,
                            child: Text(
                              textScaleFactor: 0.8,
                              "정보 조회",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontFamily: 'Pretendart',
                                  fontSize: screenHeight * 0.025,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        MediaQuery(
                          data: const MediaQueryData(textScaleFactor: 0.85),
                          child: TextField(
                            controller: dateController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (newValue) {
                              if (newValue.length > 8) {
                                // If the input exceeds 8 characters, truncate it
                                dateController.text = newValue.substring(0, 8);
                                dateController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(offset: 8),
                                );
                              }
                              _formatDate();
                            },
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  fontFamily: 'Pretendart',
                                  color: Color.fromRGBO(133, 135, 140, 1),
                                  fontSize: screenHeight * 0.02),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              labelText: '날짜 입력 (yyyy.mm.dd)',
                            ),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * 0.025),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            textScaleFactor: 0.8,
                            "* 선택일로부터 1주일간 데이터만 조회합니다.",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Pretendart',
                              fontSize: screenHeight * 0.02,
                              color: Color(0xFFB6B7BA),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.025,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: ElevatedButton(
                            onPressed: () async {
                              DateTime? parsedDate =
                                  parseDate(dateController.text);
                              final currentDate = DateTime.now();

                              if (parsedDate!.isAfter(currentDate)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      textScaleFactor: 0.8,
                                      '선택한 날짜는 미래일 수 없습니다.',
                                      style: TextStyle(
                                          fontSize: screenHeight * 0.02),
                                    ),
                                  ),
                                );
                              } else {
                                DateTime? parsedDate =
                                    parseDate(dateController.text);
                                await loadSleepData(custUsername!,
                                    toDate: DateFormat('yyyy-MM-dd')
                                        .format(parsedDate!),
                                    fromDate: DateFormat('yyyy-MM-dd').format(
                                        parsedDate
                                            .subtract(Duration(days: 6))));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 144, 122, 197),
                              minimumSize: Size(
                                  screenWidth * 0.35, screenHeight * 0.055),
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
                                    '선택',
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.025,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.025,
                        ),
                      ],
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
