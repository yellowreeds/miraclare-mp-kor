import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/evaluation_controller.dart';
import 'package:goodeeps2/utils/color_style.dart';
import 'package:goodeeps2/widgets/gradient_slider_widget.dart';

class EvaluationVibrationFrequencyWidget extends StatelessWidget {
  final EvaluationController controller;

  const EvaluationVibrationFrequencyWidget(
      {super.key, required this.controller});

  final space = 10.0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("자는 동안 진동이 얼만큼 울렸나요?\n그로 인해 불편함이 없었습니까?",
            style: TextStyle(
                color: Colors.white,
                fontFamily: "Pretendart",
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        SizedBox(height: space),
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: controller.vibrationFrequencyLabels.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      controller.updateFrequencyIntensityIndex(index);
                    },
                    child: Obx(
                      () => Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: controller.vibrationFrequencySelectedIndex ==
                                  index
                              ? ColorStyle.C_113_74_198
                              : ColorStyle.C_64_58_87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          controller.vibrationFrequencyLabels[index],
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
              height: 48,
              child: ElevatedButton(
                onPressed: controller.pressedPreviousButton,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ColorStyle.C_113_74_198,
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
              height: 48,
              child: ElevatedButton(
                onPressed: controller.pressedSubmitButton,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ColorStyle.C_113_74_198,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // 원하는 radius로 설정
                  ),
                ),
                child: Text("제출하기",
                    style: TextStyle(
                        fontFamily: "Pretendart",
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ))
          ],
        ),
        SizedBox(height: space * 2),
      ],
    );
  }
}
