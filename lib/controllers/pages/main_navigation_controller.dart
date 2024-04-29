import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/pages/evaluation/evaluation_page.dart';
import 'package:goodeeps2/pages/home/home_page.dart';
import 'package:goodeeps2/pages/info/info_page.dart';
import 'package:goodeeps2/pages/setting/setting_page.dart';

enum MainNavigationItem {
  evaluation,
  setting,
  home,
  info,
  logout;

  Widget? get widget {
    switch (this) {
      case MainNavigationItem.evaluation:
        return EvaluationPage();
      case MainNavigationItem.setting:
        return SettingPage();
      case MainNavigationItem.home:
        return HomePage();
      case MainNavigationItem.info:
        return InfoPage();
      case MainNavigationItem.logout:
        return null;
    }
  }

  String get routeName {
    switch (this) {
      case MainNavigationItem.evaluation:
        return '/evaluation';
      case MainNavigationItem.setting:
        return '/setting';
      case MainNavigationItem.home:
        return '/home';
      case MainNavigationItem.info:
        return '/info';
      case MainNavigationItem.logout:
        return '/logout';  // 라우트를 구현해야 합니다.
      default:
        return '/';
    }
  }
}

class MainNavigationController extends BaseController {
  final currentIndex = 2.obs;

  final items = MainNavigationItem.values;

  final List<Widget?> pages =
      MainNavigationItem.values.map((e) => e.widget).toList();

  void changeTabIndex(int index) {
    if (index == 4) {
      // 4번 인덱스 (logout)를 클릭했을 때
      logout();
    } else {
      currentIndex.value = index; // 다른 탭을 클릭했을 때는 인덱스 변경
    }
  }

  // void changeTabIndex(int index) {
  //   String routeName = MainNavigationItem.values[index].routeName;
  //   logger.i(routeName);
  //   if (routeName == '/logout') {
  //     logout();
  //   } else {
  //     Get.toNamed(routeName);
  //   }
  // }

  void logout() {
    logger.i("로그아웃");
  }
}
