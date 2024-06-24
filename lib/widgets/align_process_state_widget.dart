import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:goodeeps2/controllers/pages/align_process_controller.dart';
import 'package:goodeeps2/utils/align_process_state.dart';
import 'package:goodeeps2/utils/color_style.dart';
import 'package:goodeeps2/widgets/custom_linear_progress_indicator.dart';

class AlignProcessStateWidget extends StatelessWidget {
  final AlignProcessController controller;

  AlignProcessStateWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(
        child: Obx(() {
          return _buildContent(controller.currentProcessState.value);
        }),
      ),
      SizedBox(height: 20),
      Obx(() => CustomLinearProgressIndicator(
        progress: controller.progress,
        // Example progress value
        backgroundColor: ColorStyle.C_81_72_95,
        fillColor: controller.currentProcessState.value.progressColor,
        height: 24,
        borderRadius: BorderRadius.circular(4),
      )),
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
              child: Obx(() => ElevatedButton(
                    child: Text(
                      controller.currentProcessState.value.buttonTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pretendart',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          controller.currentProcessState.value.buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), //
                      ),
                    ),
                    onPressed: controller.pressedStartProcessButton,
                  )),
            ),
          ))
        ],
      ),
    ]);
  }

  Widget _buildContent(AlignProcessState state) {
    return state.when(
      ready: () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon(Icons.circle,
          //     color: detail == MeasurementDetail.clench
          //         ? ColorStyle.C_93_217_34
          //         : ColorStyle.C_210_18_30,
          //     size: 20),
          // SizedBox(width: 8),
          Center(
            child: Text(
              state.description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pretendart',
              ),
            ),
          ),
        ],
      ),
      measuring: (detail) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.circle,
              color: detail == MeasurementType.clench
                  ? ColorStyle.C_93_217_34
                  : ColorStyle.C_210_18_30,
              size: 20),
          SizedBox(width: 8),
          Center(
            child: Text(
              state.description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pretendart',
              ),
            ),
          ),
        ],
      ), finish: () => Container(),
    );
  }
}
