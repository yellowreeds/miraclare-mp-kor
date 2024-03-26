import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';

class CalibrationSetting extends StatefulWidget {
  final BluetoothDevice? connectedDevice;
  const CalibrationSetting({super.key, required this.connectedDevice});

  @override
  State<CalibrationSetting> createState() =>
      _CalibrationSettingState(connectedDevice);
}

class _CalibrationSettingState extends State<CalibrationSetting>
    with TickerProviderStateMixin {
  BluetoothDevice? connectedDevice;
  _CalibrationSettingState(this.connectedDevice);
  double screenHeight = 0;
  double screenWidth = 0;
  String result = "";
  double meanFinal = 0;
  double maaFinal = 0;
  double maxFinal = 0;
  double minFinal = 0;
  double stdFinal = 0;
  int offsetValue = 0;
  int timeFrame = 250;
  late SharedPreferences prefs;
  bool goodMeasurementResult = false;

  bool isMeasuring = false;
  bool finishedMeasuring = false;

  bool clenching = false;
  bool resting = false;

  List<int> restingData = [];
  List<int> clenchData = [];
  List<int> totalData = [];
  List<String> rawDataClench = [];
  List<String> rawDataRest = [];
  List<String> totalDataRaw = [];

  List<double> calibrationResult = [];
  String timerClench = "2";
  String timerRest = "3";
  bool showCountdownOverlay = false;
  int countdown = 3;
  late int? savedMAAValue;
  ChartSeriesController? chartSeriesController;
  StreamSubscription<List<int>>? _subscription;
  List<String?> extractedData = [];
  RegExp pattern = RegExp(r'(a5.{32}5a)');
  Queue<String> dataBuffer = Queue<String>();
  late Timer? timer = null;

  late AnimationController timerClenchController;
  late Animation<double> timerClenchAnimation;

  late AnimationController timerRestController;
  late Animation<double> timerRestAnimation;

  double vibIntensity = 0;
  int vibPattern = 0;
  String custUsername = "";

  @override
  void initState() {
    super.initState();
    // initialize timerClenchController and animation
    timerClenchController = AnimationController(
      vsync: this,
      duration: Duration(
          seconds: int.parse(timerClench)), // Use your timer value here
    );
    timerClenchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(timerClenchController);

    // initialize timerRestController and animation
    timerRestController = AnimationController(
      vsync: this,
      duration:
          Duration(seconds: int.parse(timerRest)), // Use your timer value here
    );
    timerRestAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(timerRestController);
    // initiate screen height and width
    // initiate shared preferences
    // assign vibration intensity
    // assign vibration pattern
    // assign saved MAA value
    // assign user's username
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prefs = await SharedPreferences.getInstance();
      MediaQueryData mediaQueryData = MediaQuery.of(context);
      if (mediaQueryData.orientation == Orientation.portrait) {
        setState(() {
          screenHeight = mediaQueryData.size.height;
          screenWidth = mediaQueryData.size.width;
        });
      } else {
        setState(() {
          screenWidth = mediaQueryData.size.height;
          screenHeight = mediaQueryData.size.width;
        });
      }
      prefs = await SharedPreferences.getInstance();
      vibIntensity = await prefs.getDouble('vibrationIntensity') ?? 5;
      vibPattern = await prefs.getInt('vibrationPattern') ?? 0;
      savedMAAValue = await prefs.getInt('vthValue') ?? 320;
      custUsername = await prefs.getString('custUsername') ?? "";
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
    }
    _subscription?.cancel();
    timerClenchController.dispose();
    timerRestController.dispose();
    super.dispose();
  }

  // upload calibration data if succeeded
  Future<void> uploadCalibration(
      BuildContext context,
      double cal_mean_raw,
      double cal_std_raw,
      double cal_mean_emg,
      double cal_max_emg,
      double cal_min_emg,
      double cal_std_emg,
      double cal_maa) async {
    try {
      final String apiUrl =
          'http://3.21.156.190:3000/api/customers/calibration';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': await prefs.getString('custUsername'),
          'cal_mean_raw': cal_mean_raw.toString(),
          'cal_std_raw': cal_std_raw.toString(),
          'cal_mean_emg': cal_mean_emg.toString(),
          'cal_max_emg': cal_max_emg.toString(),
          'cal_min_emg': cal_min_emg.toString(),
          'cal_std_emg': cal_std_emg.toString(),
          'cal_maa': cal_maa.toString(),
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            textScaleFactor: 0.8,
            '측정 완료',
            style: TextStyle(
                fontFamily: 'Pretendart', fontSize: screenHeight * 0.02),
          ),
        ));
        Navigator.of(context).pop();
      } else {
        print("failed: ${response.body}");
      }
    } catch (error) {
      showSuccessDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
    }
  }

  // send UART command to device to get EMG data
  void sendUARTCommand(String uartCommand) async {
    if (_subscription != null) {
      _subscription!.cancel();
    }
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
      BluetoothCharacteristic? readCharacteristic;
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify) {
            readCharacteristic = characteristic;
            break;
          }
        }
      }
      String command = uartCommand;
      List<int> commandBytes = utf8.encode(command);
      await uartCharacteristic?.write(commandBytes);
      if (readCharacteristic != null && !finishedMeasuring) {
        await readCharacteristic.setNotifyValue(true);
        _subscription = readCharacteristic.value.listen(
          (value) async {
            if (!mounted) {
              return;
            }
            // a5 00 38 0b d9 0b e2 0b 98 0a d7 08 00 3f 14 83 3b 5a
            if (result != "") {
              if (result.endsWith("5a") &&
                  result.substring(result.length - 36, result.length - 34) ==
                      "a5") {
                result = "";
              } else {
                result = result.substring(result.length - 36);
              }
            }
            result = result + HEX.encode(value);
            extractedData = pattern
                .allMatches(result)
                .map((match) => match.group(0))
                .toList();
            dataBuffer.addAll(extractedData.whereType<String>());
            processDataFromBuffer();
          },
        );
      }
    }
  }

  void processDataFromBuffer() {
    const int batchSize = 15;

    for (int i = 0; i < batchSize; i++) {
      if (dataBuffer.isNotEmpty) {
        String dataPoint = dataBuffer.removeFirst();
        processSingleDataPoint(dataPoint);
      }
    }

    if (dataBuffer.isNotEmpty) {
      const Duration delay = Duration(milliseconds: 500);
      Future.delayed(delay, processDataFromBuffer);
    }
  }

  void processSingleDataPoint(String dataPoint) async {
    // a5 00 38 0b d9 0b e2 0b 98 0a d7 08 00 3f 14 83 3b 5a
    int start = 6;
    int end = 10;
    int mask = 0xFFFF;
    int hexToInt(String hex) => int.parse(hex, radix: 16);
    int offsetHex = hexToInt(dataPoint.substring(22, 26));
    offsetValue = offsetHex;

    // only get 9 seconds worth of data
    if (totalData.length < 9000) {
      // start to get clench data for 2 seconds
      if (clenching) {
        rawDataClench.add(dataPoint);
      }
      if (rawDataClench.length > 250) {
        timerClench = "1";
      }
      if (rawDataClench.length < 1) {
        timerClench = "2";
      }

      // starts to get rest data for 3 seconds
      if (resting) {
        rawDataRest.add(dataPoint);
      }

      if (rawDataRest.length > 250 && rawDataClench.length < 500) {
        timerRest = "2";
      }
      if (rawDataRest.length > 500 && rawDataClench.length < 750) {
        timerRest = "1";
      }
      if (rawDataRest.length < 1) {
        timerRest = "3";
      }

      // parse the clench and rest data
      for (int j = 0; j < 4; j++) {
        int emgDataParsed =
            int.parse(dataPoint.substring(start, end), radix: 16) & mask;

        if (clenching) {
          clenchData.add(emgDataParsed);
        }
        if (resting) {
          restingData.add(emgDataParsed);
        }
        chartSeriesController?.updateDataSource();
        setState(() {});
        start = start + 4;
        end = end + 4;
      }
      // only save the 2 seconds worth of data
      if (clenching && clenchData.length > 2000) {
        // for raw data
        if (rawDataClench.length > 500) {
          rawDataClench = rawDataClench.sublist(0, 500);
          totalDataRaw.addAll(rawDataClench);
          rawDataClench.clear();
        }
        // for calibration process
        clenchData = clenchData.sublist(0, 2000);
        totalData.addAll(clenchData);
        clenchData.clear();
        clenching = false;
        resting = true;
      }
      // only save 1 second data in the middle
      // remove the first 1 second data
      // remove the last 1 second data
      if (resting && restingData.length > 3000) {
        if (rawDataRest.length > 750) {
          int startIndexRaw = (rawDataRest.length - 250) ~/ 2;
          rawDataRest = rawDataRest.sublist(startIndexRaw, startIndexRaw + 250);
          totalDataRaw.addAll(rawDataRest);
          rawDataRest.clear();
        }
        int startIndex = (restingData.length - 1000) ~/ 2;
        restingData = restingData.sublist(startIndex, startIndex + 1000);
        totalData.addAll(restingData);
        restingData.clear();
        clenching = true;
        resting = false;
      }
    } else {
      if (mounted) {
        validateCalibrationResult();
        _subscription?.cancel();
        isMeasuring = false;
        clenching = false;
        resting = false;
        finishedMeasuring = true;
      }
    }
  }

  // validate the calibration data
  void validateCalibrationResult() {
    List<double> sigDouble =
        totalData.map((value) => value.toDouble()).toList();
    double mean = sigDouble.reduce((a, b) => a + b) / sigDouble.length;
    sigDouble = sigDouble.map((value) => value - mean).toList();
    double snrThreshold = 10;

    bool sigAvailable = true;

    for (int phase = 0; phase < 3; phase++) {
      double snrSig = 0;
      double snrNoise = 0;

      for (int i = 0; i < 2000; i++) {
        snrSig += pow(sigDouble[i + 3000 * phase], 2);
      }

      for (int i = 2000; i < 3000; i++) {
        snrNoise += pow(sigDouble[i + 3000 * phase], 2);
      }
      double snr = 10 * (log(snrSig / (snrNoise * 2)) / log(10));
      if (snr < snrThreshold) {
        sigAvailable = false;
        break;
      }
    }
    // if the data is above threshold = good measurement
    if (sigAvailable) {
      goodMeasurementResult = true;
    } else {
      goodMeasurementResult = false;
    }
  }

  // start the countdown timer
  // set the vth to maximum to turn off vibration
  void startCountdown() {
    sendUARTCommand("SB+" + "vth=2000" + r"\" + "n");
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          showCountdownOverlay = false;
        });
        countdown = 3;
        isMeasuring = !isMeasuring;
        clenching = true;
        finishedMeasuring = false;
        sendUARTCommand("SB+" + "start" + r"\" + "n");
        meanFinal = 0;
        stdFinal = 0;
        maxFinal = 0;
        minFinal = 0;
        maaFinal = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (clenching) {
      timerRestController.reset();
      timerClenchController.forward();
    } else if (resting) {
      timerClenchController.reset();
      timerRestController.forward();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          textScaleFactor: 0.8,
          "Align Process",
        ),
        backgroundColor: Color(0xFF0F0D2B),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02, vertical: screenHeight * 0.01),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg2.png'),
                fit: BoxFit.fill,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                finishedMeasuring
                    ? goodMeasurementResult
                        ? Column(
                            children: [
                              Container(
                                width: screenWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: screenHeight * 0.045,
                                      color: Color(0xFF16BF82),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.01,
                                    ),
                                    Container(
                                      width: screenWidth * 0.4444,
                                      height: screenHeight * 0.045,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          textScaleFactor: 0.8,
                                          "측정이 완료되었습니다.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.045,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.visible,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.054,
                              ),
                              Container(
                                width: screenWidth,
                                height: screenHeight * 0.1,
                                decoration: BoxDecoration(
                                  color: Color(0xFF16BF82),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ElevatedButton(
                                  // if measurement is good, save calibration result to server and raw emg data locally (for admin account)
                                  onPressed: () async {
                                    double meanBefore = totalData.isNotEmpty
                                        ? totalData.reduce((a, b) => a + b) /
                                            totalData.length
                                        : 0.0;
                                    double varianceBefore = totalData.isNotEmpty
                                        ? totalData
                                                .map((x) =>
                                                    pow(x - meanBefore, 2))
                                                .reduce((a, b) => a + b) /
                                            totalData.length
                                        : 0.0;
                                    double stdDeviationBefore =
                                        sqrt(varianceBefore);
                                    double lowerBound =
                                        meanBefore - 2 * stdDeviationBefore;
                                    double upperBound =
                                        meanBefore + 2 * stdDeviationBefore;
                                    totalData.forEach((value) {
                                      if (value < lowerBound ||
                                          value > upperBound) {
                                        totalData[totalData.indexOf(value)] =
                                            meanBefore.toInt();
                                      }
                                    });
                                    // 2. calculate mean, STD, max, min
                                    // mean
                                    double meanAfter = totalData.isNotEmpty
                                        ? totalData.reduce((a, b) => a + b) /
                                            totalData.length
                                        : 0.0;
                                    // std
                                    double varianceAfter = totalData.isNotEmpty
                                        ? totalData
                                                .map((x) =>
                                                    pow(x - meanAfter, 2))
                                                .reduce((a, b) => a + b) /
                                            totalData.length
                                        : 0.0;
                                    double stdDeviationAfter =
                                        sqrt(varianceAfter);
                                    // max
                                    int max = totalData.isNotEmpty
                                        ? totalData
                                            .reduce((a, b) => a > b ? a : b)
                                        : 0;
                                    // min
                                    int min = totalData.isNotEmpty
                                        ? totalData
                                            .reduce((a, b) => a < b ? a : b)
                                        : 0;

                                    // 3. calculate MAA
                                    // remove offset & make the number absolute
                                    List<double> subtractedData = totalData
                                        .map((value) =>
                                            (value - meanAfter).abs())
                                        .toList();

                                    double maxDataAfterRemovingOffset =
                                        subtractedData.isNotEmpty
                                            // get max data from the absolute
                                            ? subtractedData
                                                .reduce((a, b) => a > b ? a : b)
                                            : 0;
                                    // calculate VTH - MAA * 20%
                                    double MAA =
                                        maxDataAfterRemovingOffset * (80 / 100);
                                    meanFinal = double.parse(
                                        meanAfter.toStringAsFixed(2));
                                    stdFinal = double.parse(
                                        stdDeviationAfter.toStringAsFixed(2));
                                    maxFinal = double.parse(
                                        max.toDouble().toStringAsFixed(2));
                                    minFinal = double.parse(
                                        min.toDouble().toStringAsFixed(2));
                                    maaFinal =
                                        double.parse(MAA.toStringAsFixed(2));

                                    calibrationResult.add(double.parse(
                                        meanFinal.toStringAsFixed(2)));
                                    calibrationResult.add(double.parse(
                                        stdDeviationAfter.toStringAsFixed(2)));
                                    calibrationResult.add(double.parse(
                                        maxFinal.toStringAsFixed(2)));
                                    calibrationResult.add(double.parse(
                                        minFinal.toStringAsFixed(2)));
                                    calibrationResult.add(double.parse(
                                        maaFinal.toStringAsFixed(2)));
                                    if (custUsername == "abismaw" ||
                                        custUsername == "dhkim" ||
                                        custUsername == "jsseo" ||
                                        custUsername == "jhkim" ||
                                        custUsername == "jhbyun" ||
                                        custUsername == "gmstest") {
                                      Uint8List bytes =
                                          Uint8List.fromList(calibrationResult
                                              .map((doubleValue) {
                                                return Float64List.fromList(
                                                        [doubleValue])
                                                    .buffer
                                                    .asUint8List();
                                              })
                                              .expand((byteList) => byteList)
                                              .toList());
                                      final Directory? directoryCalRes =
                                          Directory(
                                              "storage/emulated/0/Download");
                                      final File fileCalRes = File(
                                          '${directoryCalRes!.path}/clrs${DateTime.now().millisecondsSinceEpoch}.bin');
                                      await fileCalRes.writeAsBytes(bytes,
                                          mode: FileMode.append);
                                      List<int> bytesRaw = [];
                                      for (String data in totalDataRaw) {
                                        List<int> hexBytes = [];
                                        for (int i = 0;
                                            i < data.length;
                                            i += 2) {
                                          String hexByte =
                                              data.substring(i, i + 2);
                                          hexBytes.add(
                                              int.parse(hexByte, radix: 16));
                                        }
                                        bytesRaw.addAll(hexBytes);
                                      }
                                      totalDataRaw.clear();
                                      final Directory? directoryRaw = Directory(
                                          "storage/emulated/0/Download");
                                      final File fileRaw = File(
                                          '${directoryRaw!.path}/clrw${DateTime.now().millisecondsSinceEpoch}.bin');
                                      await fileRaw.writeAsBytes(bytesRaw,
                                          mode: FileMode.append);
                                    }
                                    setState(() {
                                      clenchData.clear();
                                      restingData.clear();
                                      rawDataClench.clear();
                                      rawDataRest.clear();
                                      totalData.clear();
                                      calibrationResult.clear();
                                    });
                                    // set the vth according to the MAA value
                                    sendUARTCommand("SB+" +
                                        "vth=${MAA.toInt()}" +
                                        r"\" +
                                        "n");
                                    finishedMeasuring = false;
                                    prefs.setBool('calibrationDone', true);
                                    prefs.setInt('vthValue', MAA.toInt());
                                    uploadCalibration(
                                        context,
                                        double.parse(
                                            meanBefore.toStringAsFixed(2)),
                                        double.parse(
                                            varianceBefore.toStringAsFixed(2)),
                                        double.parse(
                                            meanFinal.toStringAsFixed(2)),
                                        double.parse(
                                            maxFinal.toStringAsFixed(2)),
                                        double.parse(
                                            minFinal.toStringAsFixed(2)),
                                        double.parse(
                                            stdFinal.toStringAsFixed(2)),
                                        double.parse(
                                            maaFinal.toStringAsFixed(2)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    textScaleFactor: 0.8,
                                    '저장',
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.03,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : Column(
                            // if the measurement is bad
                            children: [
                              Container(
                                width: screenWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error,
                                      size: screenHeight * 0.045,
                                      color: Color(0xFFED4645),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.0267,
                                    ),
                                    Container(
                                      width: screenWidth * 0.4444,
                                      height: screenHeight * 0.045,
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          textScaleFactor: 0.8,
                                          "다시 측정해주세요.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.035,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.visible,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.054,
                              ),
                              Container(
                                width: screenWidth,
                                height: screenHeight * 0.1,
                                decoration: BoxDecoration(
                                  color: Color(0xFFED4645),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      clenchData.clear();
                                      restingData.clear();
                                      rawDataClench.clear();
                                      rawDataRest.clear();
                                      totalData.clear();
                                      totalDataRaw.clear();
                                      calibrationResult.clear();
                                      _subscription?.cancel();
                                      isMeasuring = false;
                                      clenching = false;
                                      resting = false;
                                      finishedMeasuring = false;
                                      // return the last saved vth value
                                      sendUARTCommand("SB+" +
                                          "vth=${savedMAAValue}" +
                                          r"\" +
                                          "n");
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    textScaleFactor: 0.8,
                                    '측정실패',
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.03,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                    : !isMeasuring
                        ? Container(
                            width: screenWidth * 0.48,
                            height: screenHeight * 0.03,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                textScaleFactor: 0.85,
                                "측정을 시작해주세요.",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                    overflow: TextOverflow.visible,
                                    fontFamily: 'Pretendart',
                                    fontSize: screenWidth * 0.07,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                        : Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: clenching
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: screenWidth * 0.0567,
                                              height: screenHeight * 0.0567,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF4EBF18),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth * 0.0222,
                                            ),
                                            Container(
                                              width: screenWidth * 0.5778,
                                              height: screenHeight * 0.03,
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  textScaleFactor: 0.85,
                                                  "${timerClench}초간 이를 악물어주세요.",
                                                  overflow:
                                                      TextOverflow.visible,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontFamily: 'Pretendart',
                                                    fontSize: screenWidth * 0.5,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : resting
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.0567,
                                                  height: screenHeight * 0.0567,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFD2121E),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.0222,
                                                ),
                                                Container(
                                                  width: screenWidth * 0.4067,
                                                  height: screenHeight * 0.03,
                                                  child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Text(
                                                      textScaleFactor: 0.85,
                                                      "${timerRest}초간 쉬어주세요.",
                                                      overflow:
                                                          TextOverflow.visible,
                                                      maxLines: 2,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Pretendart',
                                                        fontSize:
                                                            screenHeight * 0.03,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.025,
                                ),
                                Container(
                                  width: screenWidth * 0.9222,
                                  height: screenHeight * 0.03,
                                  child: AnimatedBuilder(
                                    animation: clenching
                                        ? timerClenchAnimation
                                        : timerRestAnimation,
                                    builder: (context, child) {
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: LinearProgressIndicator(
                                          value: clenching
                                              ? timerClenchAnimation.value
                                              : timerRestAnimation.value,
                                          minHeight: 24,
                                          backgroundColor: Colors.grey,
                                          valueColor: clenching
                                              ? AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF5DD922))
                                              : AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFD2121E)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                SizedBox(
                  height: screenHeight * 0.06,
                ),
                !finishedMeasuring
                    ? Container(
                        width: screenWidth * 0.923,
                        height: screenHeight * 0.093,
                        decoration: !isMeasuring
                            ? BoxDecoration(
                                color: Color(0xFF803BA0),
                                borderRadius: BorderRadius.circular(10.0),
                              )
                            : BoxDecoration(
                                color: Color(0xFFFA9702),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                        child: ElevatedButton(
                            onPressed: () {
                              if (!isMeasuring) {
                                setState(() {
                                  showCountdownOverlay = true;
                                  clenchData.clear();
                                  restingData.clear();
                                  rawDataClench.clear();
                                  rawDataRest.clear();
                                  totalData.clear();
                                  calibrationResult.clear();
                                  totalDataRaw.clear();
                                });
                                startCountdown();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 40,
                            ),
                            child: Container(
                              width: screenWidth * 0.223,
                              height: screenHeight * 0.03,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 0.85,
                                  !isMeasuring ? '측정 시작' : '측정중',
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.028,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      )
                    : Text(textScaleFactor: 0.8, ""),
                SizedBox(
                  height: screenHeight * 0.122,
                ),
                !finishedMeasuring
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: screenWidth * 0.089,
                          height: screenHeight * 0.03,
                          child: Text(
                            textScaleFactor: 1,
                            "TIP",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.02,
                              fontFamily: 'Pretendart',
                            ),
                          ),
                        ),
                      )
                    : Text(textScaleFactor: 0.8, ""),
                !finishedMeasuring
                    ? Container(
                        width: screenWidth * 0.9222,
                        height: screenHeight * 0.265,
                        decoration: BoxDecoration(
                          color: Color(0xFFFCE8DB),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.053,
                              horizontal: screenWidth * 0.1377),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: screenHeight * 0.034,
                                    height: screenHeight * 0.034,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF4EBF18),
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.0222,
                                  ),
                                  Container(
                                    width: screenWidth * 0.5333,
                                    height: screenHeight * 0.058,
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        textScaleFactor: 0.85,
                                        '초록색 신호가 나타나면 2초간\n이를 꽉 물어주세요.',
                                        textAlign: TextAlign.left,
                                        maxLines: 2,
                                        style: TextStyle(
                                            overflow: TextOverflow.visible,
                                            fontFamily: 'Pretendart',
                                            fontSize: screenWidth * 0.07,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: screenHeight * 0.042,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: screenHeight * 0.034,
                                    height: screenHeight * 0.034,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFD2121E),
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.0222,
                                  ),
                                  Container(
                                    width: screenWidth * 0.5333,
                                    height: screenHeight * 0.058,
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        textScaleFactor: 0.85,
                                        '빨간색 신호가 나타나면 3초간\n쉬어주세요.',
                                        textAlign: TextAlign.left,
                                        maxLines: 2,
                                        style: TextStyle(
                                            overflow: TextOverflow.visible,
                                            fontFamily: 'Pretendart',
                                            fontSize: screenWidth * 0.07,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(textScaleFactor: 0.8, ""),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
              ],
            ),
          ),
          if (showCountdownOverlay)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(seconds: 1),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          textScaleFactor: 0.8,
                          countdown.toString(),
                          style: TextStyle(
                            fontSize: 150.0,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // show success dialog
  Future<void> showSuccessDialog(BuildContext context, String status) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
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
                    status,
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
                    Navigator.of(context).pop();
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
        );
      },
    );
  }
}
