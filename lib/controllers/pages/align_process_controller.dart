import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/models/align_process_model.dart';
import 'package:goodeeps2/services/align_process_service.dart';
import 'package:goodeeps2/utils/align_process_state.dart';
import 'package:goodeeps2/utils/bluetooth_manager.dart';
import 'package:goodeeps2/utils/local_file_manager.dart';
import 'package:goodeeps2/utils/process_helper.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/utils/uart_command.dart';
import 'package:goodeeps2/utils/uart_command_helper.dart';
import 'package:goodeeps2/widgets/alerts.dart';
import 'package:goodeeps2/widgets/backgrounds.dart';

class AlignProcessController extends BaseController {
  final manager = BluetoothManager.instance;
  final alignProcessService = AlignProcessService();
  var counter = 3.obs;
  var progress = 0.0.obs;
  var currentProcessState = AlignProcessState.ready().obs;
  var processResult = Rxn<AlignProcessResult>(null);
  var defaultVTH = "2000";

  // A5-5A = 250개 기준으로 validate 실행 (250*4 = 1000개 데이터)
  // A5-5A 안에 총 4개의 서로다른 EMG data 가 들어있음
  final targetLength = 250;

  // 2,4,8
  final fraction = 2;

  late var processHexDataList = <String>[].obs;
  late var clenchHexDataList = <String>[].obs;
  late var relexHexDataList = <String>[].obs;

  late var processRawDataList = <int>[].obs;

  var mean_raw = 0.0;
  var std_raw = 0.0;

  var processStates = [
    AlignProcessState.measuring(MeasurementType.clench),
    AlignProcessState.measuring(MeasurementType.relax),
    AlignProcessState.measuring(MeasurementType.clench),
    AlignProcessState.measuring(MeasurementType.relax),
    AlignProcessState.measuring(MeasurementType.clench),
    AlignProcessState.measuring(MeasurementType.relax),
  ].obs;

  @override
  void onInit() async {
    super.onInit();
    setupEver();
    defaultVTH =
        await SharedPreferencesHelper.fetchData(SharedPreferencesKey.vth) ??
            320;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setupEver() {
    ever<AlignProcessState>(currentProcessState, updateProcessState);
    ever<AlignProcessResult?>(processResult, (result) async {
      await updateProcessResult(result);
    });
    ever<String>(manager.hexData, setHexData);
  }

  void setHexData(String hexData) {
    // final emgData = ProcessHelper.extractRawEMGDataList(hexData);
    currentProcessState.value.when(
      measuring: (detail) {
        switch (detail) {
          case MeasurementType.clench:
            // clenchRawEMGData.addAll(emgData);
            clenchHexDataList.add(hexData);
            break;
          case MeasurementType.relax:
            // relexRawEMGData.addAll(emgData);
            relexHexDataList.add(hexData);
            break;
        }
      },
      ready: () {},
      finish: () {},
    );
  }

  void updateProcessState(AlignProcessState state) {
    state.when(
      ready: () {
        progress.value = 0.0;
        processStates.value = [
          AlignProcessState.measuring(MeasurementType.clench),
          AlignProcessState.measuring(MeasurementType.relax),
          AlignProcessState.measuring(MeasurementType.clench),
          AlignProcessState.measuring(MeasurementType.relax),
          AlignProcessState.measuring(MeasurementType.clench),
          AlignProcessState.measuring(MeasurementType.relax),
        ];
        processResult.value = null;
      },
      measuring: (detail) {
        switch (detail) {
          case MeasurementType.clench:
            if (relexHexDataList.isNotEmpty) {
              final middleHexDataList = getMiddleData(relexHexDataList);
              processHexDataList.addAll(middleHexDataList);
              // processRawData.addAll(middleData);
              relexHexDataList.clear();
            }
            break;

          case MeasurementType.relax:
            if (clenchHexDataList.isNotEmpty) {
              final middleHexDataList = getMiddleData(clenchHexDataList);
              processHexDataList.addAll(middleHexDataList);
              // processRawData.addAll(middleData);
              clenchHexDataList.clear();
            }
            break;
        }
        logger.i(detail);
      },
      finish: () {
        if (relexHexDataList.isNotEmpty) {
          final middleHexDataList = getMiddleData(relexHexDataList);
          processHexDataList.addAll(middleHexDataList);
          // processRawData.addAll(middleData);
          relexHexDataList.clear();
          validateAlignProcessResult();
        }
      },
    );
  }

  Future<void> updateProcessResult(AlignProcessResult? result) async {
    if (result != null) {
      showAlignProcessResultDialog(result);
      switch (result) {
        case AlignProcessResult.success:
          final cleansedProcessData = cleanseProcessData(processRawDataList);
          logger.i(cleansedProcessData);
          final calculatedProcessData =
              calculateProcessData(cleansedProcessData);
          logger.i(calculatedProcessData);

          if (calculatedProcessData != null) {
            await alignProcessService.saveAlignProcess(calculatedProcessData);
            await SharedPreferencesHelper.saveData(
                SharedPreferencesKey.vth, calculatedProcessData.maa.toInt());
          }
          logger.i(calculatedProcessData);
          break;
        case AlignProcessResult.fail:
          clearAll();
          break;
      }
    }
  }

  void clearAll() {
    processHexDataList.clear();
    clenchHexDataList.clear();
    relexHexDataList.clear();
    processRawDataList.clear();
    mean_raw = 0.0;
    std_raw = 0.0;
  }

  List<String> getMiddleData(List<String> hexDataList) {
    int startIndex = (hexDataList.length - targetLength) ~/ fraction;
    int endIndex = startIndex + targetLength;
    // 데이터 길이를 초과하지 않도록 조정
    if (endIndex > hexDataList.length) {
      endIndex = hexDataList.length;
    }

    List<String> middleData = hexDataList.sublist(startIndex, endIndex);
    return middleData;
  }

  // List<int> getMiddleData(List<int> data) {
  //   // int halfLength = data.length ~/ 2;
  //   // int startIndexForRawData = (data.length - halfLength) ~/ 2;
  //   // int endIndexForRawData = startIndexForRawData + halfLength;
  //   int startIndexForRawData = (data.length - 1000) ~/ 2;
  //   int endIndexForRawData = startIndexForRawData + 1000;
  //
  //   // int startIndexForHexData = ()
  //   // int endindexForHexData = ()
  //
  //   List<int> middleData =
  //       data.sublist(startIndexForRawData, endIndexForRawData);
  //   return middleData;
  // }

  void pressedStartProcessButton() {
    if (manager.isConnected.value && manager.leadStatus.value) {
      showProgressCounter();
    } else {
      GoodeepsDialog.showError("디바이스를 연결하고 부착한뒤 시작해주세요.");
    }
  }

  // void clearAll() {
  //   processRawData.clear();
  //   clenchRawEMGData.clear();
  //   relexRawEMGData.clear();
  //
  //   processHexData.clear();
  //   clenchRawEMGData.clear();
  //   relexHexData.clear();
  // }

  void validateAlignProcessResult() {
    // 250 = A5-5A 개수
    // 250 + 250 + 250 + 250 + 250 + 250 = 1500
    if (processHexDataList.length != 1500) {
      processResult.value = AlignProcessResult.fail;
      return;
    }

    // Hex to Dec
    List<int> flattenedEMGDataList = processHexDataList
        .map((hexData) => ProcessHelper.extractRawEMGDataList(hexData))
        .expand((emgDataList) => emgDataList)
        .toList();

    logger.i(processHexDataList.length);
    logger.i(flattenedEMGDataList.length);

    List<double> sigDouble =
        flattenedEMGDataList.map((value) => value.toDouble()).toList();
    double mean = sigDouble.reduce((a, b) => a + b) / sigDouble.length;
    sigDouble = sigDouble.map((value) => value - mean).toList();
    // previous dB
    // double snrThreshold = 10;

    // dummy dB
    // double snrThreshold = 5;

    // modified dB
    double snrThreshold = 13;

    bool sigAvailable = true;

    for (int phase = 0; phase < 3; phase++) {
      // 3 phases
      double snrSig = 0;
      double snrNoise = 0;

      // First 1000 samples for signal (clenching)
      for (int i = 0; i < 1000; i++) {
        snrSig += pow(sigDouble[i + 2000 * phase], 2);
      }

      // Next 1000 samples for noise (relaxing)
      for (int i = 1000; i < 2000; i++) {
        snrNoise += pow(sigDouble[i + 2000 * phase], 2);
      }

      double snr = 10 * (log(snrSig / (snrNoise * 2)) / log(10));
      if (snr < snrThreshold) {
        sigAvailable = false;
        break;
      }
    }

    logger.i(sigAvailable);

    if (sigAvailable) {
      processRawDataList.value = flattenedEMGDataList;
      processResult.value = AlignProcessResult.success;
    } else {
      processResult.value = AlignProcessResult.fail;
    }
  }

  void startProcess() {
    UartCommandHelper.command(UartCommand.vth(defaultVTH));
    fillProgress(processStates[0]);
  }

  void fillProgress(AlignProcessState state) {
    progress.value = 0.0;
    currentProcessState.value = state;
    final duration = Duration(seconds: state.duration); // 전체 진행 시간
    const tick = Duration(milliseconds: 10); // 업데이트 간격
    Timer.periodic(tick, (timer) {
      if (progress.value >= 1.0) {
        timer.cancel();
        processStates.removeAt(0);
        if (processStates.isNotEmpty) {
          fillProgress(processStates.first);
        } else {
          currentProcessState.value = AlignProcessState.finish();
          // validateAlignProcessResult();
        }
      } else {
        progress.value += tick.inMilliseconds / duration.inMilliseconds;
      }
    });
  }

  void showProgressCounter() {
    counter.value = 3;
    Get.dialog(
      barrierDismissible: false,
      Dialog.fullscreen(
        backgroundColor: Colors.black26,
        child: Center(
          child: Obx(() {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(100), // 반경 설정
              ),
              child: Center(
                child: Text(
                  '${counter.value}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
    startCountdown();
  }

  void showAlignProcessResultDialog(AlignProcessResult result) {
    Get.dialog(
      barrierDismissible: false,
      Dialog.fullscreen(
        backgroundColor: Colors.black26,
        child: GradientBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                result.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pretendart',
                ),
              ),
              SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                      child: InnerShadow(
                    shadows: [
                      Shadow(
                          color: Colors.white.withOpacity(0.25),
                          blurRadius: 8,
                          offset: Offset(0, 4))
                    ],
                    child: Container(
                      height: 72,
                      child: ElevatedButton(
                        child: Text(
                          result.buttonTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pretendart',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: result.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), //
                          ),
                        ),
                        onPressed: () async {
                          await pressedRetryProcessButton(result);
                        },
                      ),
                    ),
                  ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pressedRetryProcessButton(AlignProcessResult result) async {
    switch (result) {
      case AlignProcessResult.success:
        currentProcessState.value = AlignProcessState.ready();
        final bytes = ProcessHelper.toBytes(processHexDataList);
        await LocalFileManager.instance.writeFile(bytes, FileType.alignProcess);
        break;
      case AlignProcessResult.fail:
        currentProcessState.value = AlignProcessState.ready();
        break;
    }
    Get.back();
  }

  void startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (counter.value > 1) {
        counter.value--;
        startCountdown();
      } else {
        Get.back();
        Future.delayed(Duration(milliseconds: 500), () {
          startProcess();
        });
      }
    });
  }

  List<int> cleanseProcessData(List<int> processData) {
    // 1. Calculate the initial mean, variance, and standard deviation of processData
    final double mean = processData.isNotEmpty
        ? processData.reduce((a, b) => a + b) / processData.length
        : 0.0; // 평균
    final double variance = processData.isNotEmpty
        ? processData.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
            processData.length
        : 0.0; // 분산
    final double standardDeviation = sqrt(variance); // 표준 편차

    // 2. Define the lower and upper bounds using mean ± 2 * standard deviation
    final double lowerBound = mean - 2 * standardDeviation;
    final double upperBound = mean + 2 * standardDeviation;

    // 3. Replace outliers in processData with the mean value
    final List<int> processedData = processData.map((value) {
      if (value < lowerBound || value > upperBound) {
        return mean.toInt();
      } else {
        return value;
      }
    }).toList();

    mean_raw = mean;
    std_raw = standardDeviation;
    return processedData;
  }

  AlignProcessModel? calculateProcessData(List<int> processData) {
    try {
      // 1. Calculate the initial mean, variance, and standard deviation of processData
      final double mean = processData.isNotEmpty
          ? processData.reduce((a, b) => a + b) / processData.length
          : 0.0; // 평균
      final double variance = processData.isNotEmpty
          ? processData.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
              processData.length
          : 0.0; // 분산
      final double standardDeviation = sqrt(variance); // 표준 편차

      final int max = processData.isNotEmpty
          ? processData.reduce((a, b) => a > b ? a : b)
          : 0;
      final int min = processData.isNotEmpty
          ? processData.reduce((a, b) => a < b ? a : b)
          : 0;

      // 5. Calculate MAA (Maximum Absolute Amplitude)
      //    Subtract mean from each value, take absolute value
      final List<double> absoluteDeviations =
          processData.map((value) => (value - mean).abs()).toList();
      final double maxAbsoluteDeviation = absoluteDeviations.isNotEmpty
          ? absoluteDeviations.reduce((a, b) => a > b ? a : b)
          : 0;
      final double maa = maxAbsoluteDeviation * 0.80;

      // List<double> subtractedData =
      //     processData.map((value) => (value - mean).abs()).toList();
      // double maxDataAfterRemovingOffset = subtractedData.isNotEmpty
      //     ? subtractedData.reduce((a, b) => a > b ? a : b)
      //     : 0;
      // double MAA = maxDataAfterRemovingOffset * 0.80;

      // 6. Store final results with two decimal precision
      logger.i(mean);
      logger.i(standardDeviation);
      logger.i(max);
      logger.i(min);
      logger.i(maa);
      final mean_emg = double.parse(mean.toStringAsFixed(2));
      final std_emg = double.parse(standardDeviation.toStringAsFixed(2));
      final max_emg = double.parse(max.toDouble().toStringAsFixed(2));
      final min_emg = double.parse(min.toDouble().toStringAsFixed(2));
      final maa_emg = double.parse(maa.toStringAsFixed(2));

      final alignProcessModel = AlignProcessModel(
          meanRaw: mean_raw,
          stdRaw: std_raw,
          meanEmg: mean_emg,
          max: max_emg,
          min: min_emg,
          stdEmg: std_emg,
          maa: maa_emg);

      logger.i(alignProcessModel);

      return alignProcessModel;
    } catch (error) {
      logger.e(error);
      return null;
    }
  }
}
