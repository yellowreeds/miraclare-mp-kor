import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/widgets/state_button_controller.dart';

class StateButton extends StatelessWidget {
  final StateButtonController controller =
      Get.put(StateButtonController()); // 컨트롤러 인스턴스화


  // StateButton({Key? key, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          child: ElevatedButton(
            onPressed: controller.toggleButtonColor, // 버튼 클릭 시 색상 토글
            style: ElevatedButton.styleFrom(
              foregroundColor: controller.buttonColor.value,
              backgroundColor: controller.buttonColor.value,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), //
                // 테두리 둥근 모서리 설정
              ), // 버튼의 배경 색상 바인딩
            ),
            child: Text(
              'Toggle Color',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
