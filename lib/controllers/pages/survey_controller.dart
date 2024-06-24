import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/controllers/widgets/gradient_slider_controller.dart';
import 'package:goodeeps2/models/evaluation_request_model.dart';
import 'package:goodeeps2/services/evaluation_service.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/utils/survey_type.dart';

class SurveyController extends BaseController {
  final surveyTypes = SurveyType.values;
  final pageController = PageController();
  final gradientSliderController = GradientSliderController();

  // final EvaluationService evaluationService = EvaluationService();

  var currentPageIndex = 0.obs;
  late var selectedIndexes = <int>[].obs;

  late RxList<dynamic> selectionList = RxList<dynamic>();

  var sliderValue = 0.0.obs;

  // 계산 프로퍼티
  double get progressIndicatorValue {
    final totalPageCount = surveyTypes.length;
    if (totalPageCount == 0) {
      return 0;
    }
    return (currentPageIndex.value + 1) / totalPageCount;
  }

  late RxBool canNextPage = RxBool(false);

  int get painIntensityIndex {
    return surveyTypes.indexOf(SurveyType.painIntensity);
  }

  int indexOf(SurveyType type) {
    return surveyTypes.indexOf(type);
  }

  // SurveyType currentSurveyType(int index) {
  //   return surveyTypes
  //
  // }

  @override
  void onInit()  {
    super.onInit();
    pageController.addListener(() {
      currentPageIndex.value = pageController.page?.round() ?? 0;
    });
    initSelectionList();
    ever(gradientSliderController.sliderValue, (updatePainIntensityIndex));
    ever(selectionList, updateSelectionList);
    ever(currentPageIndex, updateCurrentPageIndex);
    ever(selectedIndexes, updateSelectedIndexes);
  }

  void updateSelectedIndexes(List<int> indexes) {
    canNextPage.value = indexes.isNotEmpty;
  }

  Future<void> initSelectionList() async {
    final _selectionList =
        await SharedPreferencesHelper.fetchData(SharedPreferencesKey.survey);

    if (_selectionList != null) {
      final list = _selectionList as List<dynamic>;
      logger.i(_selectionList);

      selectionList.value = list;
      selectedIndexes.value = [selectionList.first];
      canNextPage.value = selectionList.first != null;
      final double painIntensity = selectionList[indexOf(SurveyType.painIntensity)];
      gradientSliderController.sliderValue.value = painIntensity;
    } else {
      selectionList =
          List<dynamic>.filled(surveyTypes.length, null, growable: false).obs;
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    gradientSliderController.dispose();
    super.dispose();
  }


  void updatePainIntensityIndex(double value) {
    final index = value.toInt();
    selectionList[indexOf(SurveyType.painIntensity)] = index;
  }

  void updateCurrentPageIndex(int index) {

    final type = surveyTypes[index];
    selectedIndexes.clear();
    logger.i(type);
    final selection = selectionList[index];
    logger.i("index: ${index} :${selection} : ${selectionList}");
    if (selection != null) {
      switch (type) {
        case SurveyType.sleepSymptoms:
          final _selection = (selection as List<dynamic>).map((e) => e as int).toList();
          logger.i(_selection);
          selectedIndexes.value = _selection;
        default:
          selectedIndexes.value = [selection];
      }
    }
  }

  Future<void> updateSelectionList(List<dynamic> selectionList) async {
    await SharedPreferencesHelper.saveData(
        SharedPreferencesKey.survey, selectionList);
  }

  void updateSelection(int index, SurveyType type) {
    switch (type) {

      case SurveyType.sleepSymptoms:
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
        } else {
          if (index == 4) {
            selectedIndexes.clear();
            selectedIndexes.add(index);
          } else {
            if (selectedIndexes.length == 1 && selectedIndexes.contains(4)) {
              selectedIndexes.remove(4);
            }
            selectedIndexes.add(index);
          }
        }
        selectionList[currentPageIndex.value] = selectedIndexes;

      default:
        if (type == SurveyType.painIntensity) {
          gradientSliderController.sliderValue.value = index.toDouble();
        }
        if (selectedIndexes.length > 0) {
          selectedIndexes[0] = index; // 기존 요소를 업데이트
        } else {
          selectedIndexes.add(index); // 리스트에 요소를 추가
        }

        selectionList[currentPageIndex.value] = index;
    }
    canNextPage.value = selectedIndexes.isNotEmpty;
  }

  void pressedNextButton() {
    // pageController.animateToPage(2, duration: Duration(milliseconds: 200), curve:Curves.easeInOut);
    pageController.nextPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void pressedPreviousButton() {
    pageController.previousPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<void> pressedSubmitButton() async {
    try {
      // final requestModel = EvaluationRequestModel(
      //   user_id: "user_id", // 실제 사용자 ID를 설정하세요
      //   pain_intensity: painIntensitySelectedIndex.value,
      //   vibration_intensity: vibrationIntensitySelectedIndex.value,
      //   vibration_frequency: vibrationFrequencySelectedIndex.value,
      // );
      // final response = await evaluationService.saveEvaluation(requestModel);
      // 응답 처리: 성공 시 UI 업데이트 또는 알림
      // Get.snackbar('Success', 'Evaluation saved successfully');
    } catch (e) {
      // 에러 처리: 실패 시 UI 업데이트 또는 알림
      // Get.snackbar('Error', 'Failed to save evaluation ${e}');
    }
  }
}
