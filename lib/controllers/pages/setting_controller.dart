import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/routes.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';

enum SettingType {
  alignProcess,
  // vibrationControl,
  userInfo,
  // deviceUpdate,
  logout;

  String get title {
    switch (this) {
      case SettingType.alignProcess:
        return "Align Process";
      // case SettingType.vibrationControl:
      //   return "진동자극 조절";
      case SettingType.userInfo:
        return "회원정보 수정";
      // case SettingType.deviceUpdate:
      //   return "업데이트";
      case SettingType.logout:
        return "로그아웃";
    }
  }

  Widget get leading {
    switch (this) {
      case SettingType.alignProcess:
        return Image.asset("assets/images/calicon.png", width: 28, height: 28);
      // case SettingType.vibrationControl:
        return Image.asset("assets/images/vibraicon.png", width: 28, height: 28);
      case SettingType.userInfo:
        return Image.asset("assets/images/usericon.png", width: 28, height: 28);
      // case SettingType.deviceUpdate:
        return Image.asset("assets/images/usericon.png", width: 28, height: 28);
      case SettingType.logout:
        return Icon(Icons.logout, size: 28, color: Colors.white); // 로그아웃 아이콘
      default:
        return Icon(Icons.help, size: 28, color: Colors.white); // 기본 아이콘 설정
    }
  }

  AssetImage get image {
    switch (this) {
      case SettingType.alignProcess:
        return const AssetImage("assets/images/calicon.png");
      // case SettingType.vibrationControl:
        return const AssetImage("assets/images/vibraicon.png");
      case SettingType.userInfo:
        return const AssetImage("assets/images/usericon.png");
      // case SettingType.deviceUpdate:
        return const AssetImage("assets/images/usericon.png");
      case SettingType.logout:
        return const AssetImage("assets/images/usericon.png");
    }
  }
}

class SettingController extends BaseController {
  final settings = SettingType.values;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> pressedItem(SettingType setting) async {
    switch (setting) {
      case SettingType.alignProcess:
        Get.toNamed(PageRouter.alignProcess.rawValue);
        break;
      // case SettingType.vibrationControl:

      case SettingType.userInfo:
        break;

      // case SettingType.deviceUpdate:

      case SettingType.logout:
        await SharedPreferencesHelper.clearAll();
        Get.offAllNamed(PageRouter.login.rawValue);
        break;
    }
  }
}
