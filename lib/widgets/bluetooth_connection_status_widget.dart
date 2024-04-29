import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/home_controller.dart';

class BluetoothConnectionStatusWidget extends StatelessWidget {
  final HomeController controller;

  BluetoothConnectionStatusWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Color.fromRGBO(74, 74, 92, 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(255, 255, 255, 1).withOpacity(0.2),
              // 흰색에 전체 투명도 20% 적용
              Color.fromRGBO(0, 0, 0, 0).withOpacity(0.2),
              // 검정색(기본적으로 투명)에 전체 투명도 20% 적용
            ],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image(
                        image: AssetImage(controller.isConnected.value
                            ? "assets/images/icon1v3.png"
                            : "assets/images/icon1v3off.png")),
                    SizedBox(width: 16),
                    Text(
                      "디바이스 통신",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Pretendart",
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      controller.isConnected.value ? "ON" : "OFF",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Pretendart",
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 8),
                    CupertinoSwitch(
                      value: controller.isConnected.value,
                      activeColor: Color.fromRGBO(19, 211, 40, 1),
                      trackColor: Color.fromRGBO(175, 177, 183, 1),
                      onChanged: controller.switchConnectionToggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
