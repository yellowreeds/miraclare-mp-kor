import 'package:flutter/material.dart';
import 'package:goodeeps2/controllers/pages/home_controller.dart';

enum BatteryStatus {
  full, // 86% ~ 100%
  high, // 51% ~ 85%
  medium, // 20% ~ 50%
  low, // 20% 미만
  charging, // 충전중
  disconnect; // 연결되지 않았을 경우

  AssetImage get image {
    switch (this) {
      case BatteryStatus.full:
        return AssetImage("assets/images/btr10086.png");
      case BatteryStatus.high:
        return AssetImage("assets/images/btr8551.png");
      case BatteryStatus.medium:
        return AssetImage("assets/images/btr5020.png");
      case BatteryStatus.low:
        return AssetImage("assets/images/btr190.png");
      case BatteryStatus.charging:
        return AssetImage("assets/images/battery.gif");
      case BatteryStatus.disconnect:
        return AssetImage("assets/images/btr190.png");
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 120,
                height: 120,
                child: Image(image: controller.batteryStatus.image)),
            SizedBox(height: 20),
            Text(
              "배터리 92%",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Pretendart",
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
