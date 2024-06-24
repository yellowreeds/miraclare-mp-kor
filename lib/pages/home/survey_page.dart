import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/survey_controller.dart';
import 'package:goodeeps2/utils/color_style.dart';
import 'package:goodeeps2/utils/survey_type.dart';
import 'package:goodeeps2/widgets/backgrounds.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';
import 'package:goodeeps2/widgets/page_progress_widget.dart';
import 'package:goodeeps2/widgets/survey_grid_widget.dart';
import 'package:goodeeps2/widgets/survey_list_widget.dart';

class SurveyPage extends GetView<SurveyController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: "설문조사", showBackButton: false),
      body: GradientBackground(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Obx(
                  () => Container(
                    height: 10, // 원하는 높이 설정
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), // 둥근 모서리 설정
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      // 둥근 모서리 설정
                      child: LinearProgressIndicator(
                        value: controller.progressIndicatorValue,
                        backgroundColor: ColorStyle.C_89_93_104,
                        // 배경색 제거
                        color: ColorStyle.C_255_172_27, // 진행 색상 설정
                      ),
                    ),
                  ),
                )),
                SizedBox(width: 10),
                Obx(
                  () => Text(
                      "${controller.currentPageIndex.value + 1}/${controller.surveyTypes.length}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Pretendart",
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                )
              ],
            ),
            SizedBox(height: 40),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: NeverScrollableScrollPhysics(),
                children: controller.surveyTypes.map((surveyType) {
                  if (surveyType == SurveyType.painIntensity) {
                    return SurveyGridWidget(
                        surveyType: surveyType, controller: controller);
                  }
                  return SurveyListWidget(
                    surveyType: surveyType,
                    controller: controller,
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
