import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/home_controller.dart';

class LeadOnStatusWidget extends StatelessWidget {
  final HomeController controller;

  LeadOnStatusWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(64, 55, 84, 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      height: 96,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Image(
                  image: AssetImage(controller.isConnected.value
                      ? "assets/images/icon2v3.png"
                      : "assets/images/icon2v3off.png")),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "디바이스 부착",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Pretendart",
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "OFF",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Pretendart",
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
