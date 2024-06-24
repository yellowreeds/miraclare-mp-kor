import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/home_controller.dart';

class OperationStatusWidget extends StatelessWidget {
  final HomeController controller;

  const OperationStatusWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(64, 55, 84, 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      height: 96,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 32,
                height: 32,
                child: Obx(
                      () => Image(
                      image: AssetImage(controller.isOperating.value
                          ? "assets/images/icon3v3.png"
                          : "assets/images/icon3v3off.png")),
                )),
            const SizedBox(height: 8),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "디바이스 작동",
                  style: TextStyle(
                      color: controller.isOperating.value
                          ? Colors.white
                          : const Color.fromRGBO(164, 164, 188, 1),
                      fontFamily: "Pretendart",
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  controller.isOperating.value ? "ON" : "OFF",
                  style: TextStyle(
                      color: controller.isOperating.value
                          ? Colors.white
                          : const Color.fromRGBO(164, 164, 188, 1),
                      fontFamily: "Pretendart",
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
