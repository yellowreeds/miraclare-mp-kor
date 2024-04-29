import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:goodeeps2/controllers/base_controller.dart';

class StateButtonController extends BaseController {
  var buttonColor = Colors.blue.obs; // 버튼 색상을 관찰 가능한 상태로 설정

  void toggleButtonColor() {
    // 버튼 색상을 토글하는 메소드
    buttonColor.value = buttonColor.value == Colors.blue ? Colors.red : Colors.blue;
  }
}
