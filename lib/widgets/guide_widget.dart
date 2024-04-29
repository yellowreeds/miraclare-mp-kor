import 'package:flutter/material.dart';
import 'package:goodeeps2/controllers/pages/home_controller.dart';

class GuideWidget extends StatelessWidget {
  final HomeController controller;

  GuideWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "이재진님 반갑습니다",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Pretendart",
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            Container(
              child: ElevatedButton(
                  onPressed: () => {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(64, 55, 84, 1)),
                  child: Text(
                    "도움말",
                    style: TextStyle(color: Colors.white),
                  )),
            )
          ],
        ),
        Text(
          "오늘의 평가는 잊지 않으셨나요 ?",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Pretendart",
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
