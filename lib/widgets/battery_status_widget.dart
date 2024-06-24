import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:goodeeps2/controllers/pages/home_controller.dart';

enum BatteryLevel {
  full, // 86% ~ 100%
  high, // 51% ~ 85%
  medium, // 20% ~ 50%
  low, // 20% 미만
  charging, // 충전중
  disconnect; // 연결되지 않았을 경우

  AssetImage get image {
    switch (this) {
      case BatteryLevel.full:
        return AssetImage("assets/images/btr10086.png");
      case BatteryLevel.high:
        return AssetImage("assets/images/btr8551.png");
      case BatteryLevel.medium:
        return AssetImage("assets/images/btr5020.png");
      case BatteryLevel.low:
        return AssetImage("assets/images/btr190.png");
      case BatteryLevel.charging:
        return AssetImage("assets/images/battery.gif");
      case BatteryLevel.disconnect:
        return AssetImage("assets/images/btr190.png");
    }
  }

  Color get color {
    switch (this) {
      case BatteryLevel.full:
        return Color.fromRGBO(6, 239, 127, 1);
        break;
      case BatteryLevel.high:
        return Color.fromRGBO(255, 199, 0, 1);
        break;
      case BatteryLevel.medium:
        return Color.fromRGBO(255, 131, 41, 1);
        break;
      case BatteryLevel.low:
        return Color.fromRGBO(237, 70, 69, 1);
        break;
      case BatteryLevel.charging:
        return Color.fromRGBO(6, 239, 127, 1);
        break;
      case BatteryLevel.disconnect:
        return Color.fromRGBO(237, 70, 69, 1);
        break;
    }
  }

  static BatteryLevel getLevel(int battery) {
    if (battery >= 86) {
      return BatteryLevel.full;
    } else if (battery >= 51) {
      return BatteryLevel.high;
    } else if (battery >= 20) {
      return BatteryLevel.medium;
    } else if (battery > 0) {
      return BatteryLevel.low;
    } else {
      return BatteryLevel.disconnect; // 배터리가 0%인 경우도 disconnect로 간주
    }
  }
}

class BatteryStatusWidget extends StatelessWidget {
  final HomeController controller;

  BatteryStatusWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(64, 55, 84, 1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 120,
                    height: 120,
                    child: Image(image: controller.batteryLevel.value.image)),
                SizedBox(height: 20),
                Text(
                  controller.isCharging.value
                      ? "배터리 충전중"
                      : "배터리 ${controller.battery}%",
                  style: TextStyle(
                      color: controller.batteryLevel.value.color,
                      fontFamily: "Pretendart",
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ));
  }
}
