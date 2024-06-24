// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:goodeeps2/controllers/base_controller.dart';
// import 'package:goodeeps2/routes.dart';
//
// enum VibrationType {
//   ,
//   vibrationControl,
//   userInfo,
//   deviceUpdate;
//
//   String get title {
//     switch (this) {
//       case SettingType.alignProcess:
//         return "Align Process";
//       case SettingType.vibrationControl:
//         return "진동자극 조절";
//       case SettingType.userInfo:
//         return "회원정보 수정";
//       case SettingType.deviceUpdate:
//         return "업데이트";
//     }
//   }
//
//   AssetImage get image {
//     switch (this) {
//       case SettingType.alignProcess:
//         return const AssetImage("assets/images/calicon.png");
//       case SettingType.vibrationControl:
//         return const AssetImage("assets/images/vibraicon.png");
//       case SettingType.userInfo:
//         return const AssetImage("assets/images/usericon.png");
//       case SettingType.deviceUpdate:
//         return const AssetImage("assets/images/usericon.png");
//     }
//   }
// }
//
// class VibrationController extends BaseController {
//   final settings = SettingType.values;
//   @override
//   void onInit() {
//     // TODO: implement onInit
//     super.onInit();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }
//
//   void pressedItem(SettingType setting) {
//     switch (setting) {
//       case SettingType.alignProcess:
//         Get.toNamed(PageRouter.alignProcess.rawValue);
//       case SettingType.vibrationControl:
//       // TODO: Handle this case.
//       case SettingType.userInfo:
//       // TODO: Handle this case.
//       case SettingType.deviceUpdate:
//       // TODO: Handle this case.
//     }
//   }
// }
