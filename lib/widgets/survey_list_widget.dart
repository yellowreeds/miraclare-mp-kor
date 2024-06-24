import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/survey_controller.dart';
import 'package:goodeeps2/utils/color_style.dart';
import 'package:goodeeps2/utils/survey_type.dart';

class SurveyListWidget extends StatelessWidget {
  final SurveyType surveyType;
  final SurveyController controller;

  const SurveyListWidget(
      {super.key, required this.surveyType, required this.controller});

  final space = 10.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(surveyType.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontFamily: "Pretendart",
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: surveyType.options.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      controller.updateSelection(index, surveyType);
                    },
                    child: Obx(
                      () => Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: controller.selectedIndexes.contains(index)
                              ? ColorStyle.C_113_74_198
                              : ColorStyle.C_64_58_87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          surveyType.options[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ));
              }),
        ),
        SizedBox(width: space),
        Row(
          children: [
            Expanded(
                child: Container(
              height: 54,
              child: ElevatedButton(
                onPressed: controller.pressedPreviousButton,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ColorStyle.C_129_124_153,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // 원하는 radius로 설정
                  ),
                ),
                child: Text("이전",
                    style: TextStyle(
                        fontFamily: "Pretendart",
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            )),
            SizedBox(width: 10),
            Expanded(
                child: Container(
                    height: 54,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: () =>  controller.canNextPage.value
                            ? controller.pressedNextButton()
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: controller.canNextPage.value
                              ? ColorStyle.C_113_74_198
                              : ColorStyle.C_129_124_153,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(4), // 원하는 radius로 설정
                          ),
                        ),
                        child: Text("다음",
                            style: TextStyle(
                                fontFamily: "Pretendart",
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    )))
          ],
        ),
        SizedBox(height: space * 2),
      ],
    );
  }
}
