import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/evaluation_controller.dart';
import 'package:goodeeps2/widgets/backgrounds.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';
import 'package:goodeeps2/widgets/evaluation_pain_intensity_widget.dart';
import 'package:goodeeps2/widgets/evaluation_vibration_frequency_widget.dart';
import 'package:goodeeps2/widgets/evaluation_vibration_intensity_widget.dart';
import 'package:goodeeps2/widgets/page_progress_widget.dart';

class EvaluationPage extends GetView<EvaluationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: "평가", showBackButton: false),
      body: GradientBackground(
        child: Column(
          children: [
            PageProgressWidget(controller: controller),
            SizedBox(height: 40),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  EvaluationPainIntensityWidget(controller: controller),
                  EvaluationVibrationIntensityWidget(controller: controller),
                  EvaluationVibrationFrequencyWidget(controller: controller)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
