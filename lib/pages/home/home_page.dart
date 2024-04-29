import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/widgets/battery_status_widget.dart';
import 'package:goodeeps2/widgets/bluetooth_connection_status_widget.dart';
import 'package:goodeeps2/widgets/gradient_background.dart';
import 'package:goodeeps2/widgets/guide_widget.dart';
import 'package:goodeeps2/widgets/lead_on_status_widget.dart';
import 'package:goodeeps2/widgets/operation_status_widget.dart';
import '../../controllers/pages/home_controller.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Stack(children: [
      GradientBackground(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          GuideWidget(controller: controller),
          SizedBox(height: 40),
          BluetoothConnectionStatusWidget(
            controller: controller,
          ),
          SizedBox(height: 8),
          Container(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      children: [
                        LeadOnStatusWidget(controller: controller),
                        SizedBox(height: 8),
                        OperationStatusWidget(controller: controller)
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                    child: BatteryStatusWidget(
                  controller: controller,
                ))
              ],
            ),
          ),
          SizedBox(height: 56),
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
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => null,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromRGBO(71, 60, 77, 1),
                        // backgroundColor: Color.fromRGBO(128, 59, 160, 1),
                        disabledBackgroundColor: Color.fromRGBO(71, 60, 77, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), //
                          // 테두리 둥근 모서리 설정
                        ),
                      ),
                      child: Text(
                        '동작 시작',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pretendart',
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ]),
      ),
      // Obx(() {
      //   if (controller.isLoading.value) {
      //     // isLoading이 true일 때 로딩 인디케이터를 표시합니다.
      //     return Center(child:GoodeepsDialog.showIndicator());
      //   } else {
      //     return SizedBox.shrink(); // 아무것도 표시하지 않습니다.
      //   }
      // }),
    ]));
  }
}
