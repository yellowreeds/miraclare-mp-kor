import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/widgets/battery_status_widget.dart';
import 'package:goodeeps2/widgets/bluetooth_connection_status_widget.dart';
import 'package:goodeeps2/widgets/backgrounds.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';
import 'package:goodeeps2/widgets/guide_widget.dart';
import 'package:goodeeps2/widgets/lead_on_status_widget.dart';
import 'package:goodeeps2/widgets/operation_status_widget.dart';
import '../../controllers/pages/home_controller.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          // 투명 배경 지정
          elevation: 0, // 그림자 제거
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings_outlined),
              iconSize: 32.0,
              onPressed:controller.pressedSettingButton,
            ),
          ],
        ),
        body: Stack(children: [
          GradientBackground(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(height: 16),
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
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.pressdOperationButton,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: controller
                                      .operationButtonState.value.color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), //
                                    // 테두리 둥근 모서리 설정
                                  ),
                                ),
                                child: Text(
                                  controller.operationButtonState.value.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Pretendart',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ))
                      ],
                    ),
                    SizedBox(height: 20),
                    Obx(() => Text(
                          controller.operationButtonState.value.description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pretendart',
                          ),
                        ))
                  ]),
            ]),
          ),
        ]));
  }
}
