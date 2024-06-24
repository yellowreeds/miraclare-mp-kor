import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/controllers/widgets/gradient_slider_controller.dart';
import 'package:goodeeps2/models/evaluation_request_model.dart';
import 'package:goodeeps2/services/evaluation_service.dart';

class EvaluationController extends BaseController {
  final pageController = PageController();
  final gradientSliderController = GradientSliderController();
  final EvaluationService evaluationService = EvaluationService();

  var currentPageIndex = 0.obs;

  var painIntensitySelectedIndex = (0).obs;
  var vibrationIntensitySelectedIndex = (0).obs;
  var vibrationFrequencySelectedIndex = (0).obs;
  var sliderValue = 0.0.obs;

  final List<String> painIntensityLabels = [
    "통증 없음",
    "조금 불편함",
    "불편함",
    "조금 아픔",
    "아픔",
    "많이 아픔",
    "매우 아픔",
    "극심함",
    "매우 극심함",
    "참기 힘듬",
    "매우 참기 힘듬"
  ];

  final List<String> vibrationIntensityLabels = [
    "매우 약했다",
    "약했다",
    "보통이다",
    "강했다",
    "매우 강했다",
  ];

  final List<String> vibrationFrequencyLabels = [
    "매우 적었다",
    "적었다",
    "보통이다",
    "많았다",
    "매우 많았다"
  ];

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      currentPageIndex.value = pageController.page?.round() ?? 0;
    });

    ever(gradientSliderController.sliderValue, (updatePainIntensityIndex));
  }

  @override
  void dispose() {
    pageController.dispose();
    gradientSliderController.dispose();
    super.dispose();
  }

  void updatePageIndex(int index) {}

  void updatePainIntensityIndex(double value) {
    final index = value.toInt();
    painIntensitySelectedIndex.value = index;
    sliderValue.value = index.toDouble();
  }

  void updateVibrationIntensityIndex(int index) {
    vibrationIntensitySelectedIndex.value = index;
  }

  void updateFrequencyIntensityIndex(int index) {
    vibrationFrequencySelectedIndex.value = index;
  }

  void pressedNextButton() {
    pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void pressedPreviousButton() {
    pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> pressedSubmitButton() async {
    try {
      final requestModel = EvaluationRequestModel(
        userId: "user_id", // 실제 사용자 ID를 설정하세요
        painIntensity: painIntensitySelectedIndex.value,
        vibrationIntensity: vibrationIntensitySelectedIndex.value,
        vibrationFrequency: vibrationFrequencySelectedIndex.value,
      );
      final response = await evaluationService.saveEvaluation(requestModel);
      // 응답 처리: 성공 시 UI 업데이트 또는 알림
      Get.snackbar('Success', 'Evaluation saved successfully');
    } catch (e) {
      // 에러 처리: 실패 시 UI 업데이트 또는 알림
      Get.snackbar('Error', 'Failed to save evaluation ${e}');
    }
  }
}
