import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/evaluation_controller.dart';
import 'package:goodeeps2/utils/color_style.dart';
import 'package:goodeeps2/widgets/gradient_slider_widget.dart';

class EvaluationPainIntensityWidget extends StatelessWidget {
  final EvaluationController controller;

  const EvaluationPainIntensityWidget({super.key, required this.controller});

  final space = 10.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("오늘 아침에 느끼는 치아, 턱관절\n통증의 정도가 어떻게 되십니까?",
            style: TextStyle(
                color: Colors.white,
                fontFamily: "Pretendart",
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Container(
          height: 80,
          child: GradientSliderWidget(controller:controller.gradientSliderController),
        ),
        SizedBox(height: space),
        Expanded(
            child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2,
          ),
          padding: EdgeInsets.zero,
          itemCount: controller.painIntensityLabels.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                onTap: () {
                  // controller.updatePainIntensityIndex(index);
                },
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: controller.painIntensitySelectedIndex == index
                          ? ColorStyle.C_113_74_198
                          : ColorStyle.C_64_58_87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        controller.painIntensityLabels[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ));
          },
        )),
        SizedBox(width: space),
        Row(
          children: [
            Expanded(
                child: Container(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.pressedNextButton,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ColorStyle.C_113_74_198,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // 원하는 radius로 설정
                  ),
                ),
                child: Text("다음",
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
